-- To deytero task thelei na prosthesw to Height = Short
-- ston Greg kai ton Oleg poy einai Supervisors 


-- Declare variables for the "Height" attribute
DECLARE @HeightAttrID UNIQUEIDENTIFIER;  -- stores the id of the "Height" attribute
DECLARE @ShortValue NVARCHAR(50) = 'Short';  -- the value we need to assign into later

-- Checking here if the "Height" attribute with the value "Short" already exists
SELECT @HeightAttrID = ATTR_ID 
FROM Attribute 
WHERE ATTR_Name = 'Height' AND ATTR_Value = @ShortValue;

-- If the attribute does not exist then we create it
IF @HeightAttrID IS NULL
BEGIN
    SET @HeightAttrID = NEWID(); -- Generate a unique ID
    INSERT INTO Attribute (ATTR_ID, ATTR_Name, ATTR_Value)
    VALUES (@HeightAttrID, 'Height', @ShortValue);
END

BEGIN TRANSACTION;

-- Update supervisors who already have a "Height" attribute to 'Short'
UPDATE EmployeeAttribute
SET EMPATTR_AttributeID = @HeightAttrID
WHERE EMPATTR_EmployeeID IN (
    -- Selecting all supervisors (employees who are referenced as a supervisor by others)
    SELECT DISTINCT EMP_Supervisor FROM Employee WHERE EMP_Supervisor IS NOT NULL
)
AND EMPATTR_AttributeID IN (
    -- Only update existing 'Height' attributes
    SELECT ATTR_ID FROM Attribute WHERE ATTR_Name = 'Height'
);

-- Insert "Height = Short" attribute for supervisors who do NOT already have a Height attribute
INSERT INTO EmployeeAttribute (EMPATTR_EmployeeID, EMPATTR_AttributeID)
SELECT DISTINCT e.EMP_ID, @HeightAttrID
FROM Employee e
WHERE e.EMP_ID IN (SELECT EMP_Supervisor FROM Employee WHERE EMP_Supervisor IS NOT NULL)  -- Ensure they are supervisors
AND NOT EXISTS (
    -- Exclude supervisors who already have any 'Height' attribute
    SELECT 1 FROM EmployeeAttribute ea
    JOIN Attribute a ON ea.EMPATTR_AttributeID = a.ATTR_ID
    WHERE ea.EMPATTR_EmployeeID = e.EMP_ID
    AND a.ATTR_Name = 'Height'
);

COMMIT TRANSACTION;

PRINT 'THE supervisors were updated with the new value: Height -> Short.';




--We used this approach to ensure that all supervisors (employees who manage at least one other
--employee) have the "Height" attribute with the value "Short". First, we check if the attribute already
--exists, and if not, we then create it. Then, we update the Supervisors who already have a ''Height'' attribute by
--assigning them the correct value. After that, we inserting the attribute into  those who dont have it. 
--
--
