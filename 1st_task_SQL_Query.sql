SELECT * FROM Employee;
SELECT * FROM Attribute;
SELECT * FROM EmployeeAttribute;

-- Start a transaction to ensure that all changes are executed as a single unit.
BEGIN TRANSACTION;

-- Declare variables to hold the unique identifier of an employee and the attribute.
DECLARE @EmpID UNIQUEIDENTIFIER;
DECLARE @AttrID UNIQUEIDENTIFIER;

-- 
DECLARE emp_cursor CURSOR FOR 
    SELECT EMP_ID FROM Employee;

-- Opening the cursor and  beginning fetching  records.
OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @EmpID;

-- Starting the process for each employee individually.
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Checking if the Attribute ''Weight' already exists for the employee we look for.
    IF EXISTS (
        SELECT 1-- This use checks if at least one record matches the condition.
        FROM EmployeeAttribute ea
        JOIN Attribute a ON ea.EMPATTR_AttributeID = a.ATTR_ID
        WHERE ea.EMPATTR_EmployeeID = @EmpID AND a.ATTR_Name = 'Weight'
    )
    BEGIN
        -- If the value is''Weight''in the Attribute ,then we update  its value to 'Thin'.
        UPDATE a
        SET a.ATTR_Value = 'Thin'
        FROM Attribute a
        JOIN EmployeeAttribute ea ON a.ATTR_ID = ea.EMPATTR_AttributeID
        WHERE ea.EMPATTR_EmployeeID = @EmpID AND a.ATTR_Name = 'Weight';
        PRINT 'Ενημερώθηκε το Weight για τον εργαζόμενο ' + CAST(@EmpID AS NVARCHAR(50));
    END
    ELSE
    BEGIN
        -- Checking if the  Attribute does not exist, create a new one with value 'Thin'.
        SET @AttrID = NEWID();  --Here we make a generated unique ID for the new attribute.

		 -- Here we  Link the new created Attribute to the Employee (Attribute - Employee) connection.
        INSERT INTO Attribute (ATTR_ID, ATTR_Name, ATTR_Value)
        VALUES (@AttrID, 'Weight', 'Thin');
        INSERT INTO EmployeeAttribute (EMPATTR_EmployeeID, EMPATTR_AttributeID)
        VALUES (@EmpID, @AttrID);
        PRINT 'Inserted new Weight attribute with value Thin for employee  ' + CAST(@EmpID AS NVARCHAR(50));
    END

    -- Fetching  the next Employee record.
    FETCH NEXT FROM emp_cursor INTO @EmpID;
END

	-- Close the cursor 

CLOSE emp_cursor;
DEALLOCATE emp_cursor;

-- Closinh the transaction
COMMIT TRANSACTION;



--We used here a  cursor because its allows us to go through each employee one by one and check if they
--already have the "Weight" attribute. So it is by a lot easier to decide whether to update or insert the
--attribute for each employee.In this case,
--using a cursor gives us better control over each step of the process. It also helps us make sure that all
--changes happen safely inside a transaction!!
--
--
