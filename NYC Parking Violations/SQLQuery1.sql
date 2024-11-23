USE [Parking Violations];

-- Create a new table to store combined data
CREATE TABLE dbo.nyc (
    Registration_State NVARCHAR(10),
    Violation_Description NVARCHAR(MAX),
    Vehicle_Body_Type NVARCHAR(50),
    Issue_Date DATE,
    Summons_Number BIGINT,
    Plate_Type NVARCHAR(10),
    Vehicle_Body_Type2 NVARCHAR(50),
    Vehicle_Make NVARCHAR(50),
    Vehicle_Color NVARCHAR(50),
    Street_Code1 INT,
    Vehicle_Year INT
);

-- Populate the unified table
DECLARE @i INT = 1;
DECLARE @sql NVARCHAR(MAX);

WHILE @i <= 14  -- Adjust based on number of data tables (data files)
BEGIN
    SET @sql = 'INSERT INTO dbo.nyc (Registration_State, Violation_Description, Vehicle_Body_Type, Issue_Date, Summons_Number, Plate_Type, Vehicle_Body_Type2, Vehicle_Make, Vehicle_Color, Street_Code1, Vehicle_Year)
                SELECT Registration_State, Violation_Description, Vehicle_Body_Type, Issue_Date, Summons_Number, Plate_Type, Vehicle_Body_Type2, Vehicle_Make, Vehicle_Color, Street_Code1, Vehicle_Year
                FROM dbo.nyc_parking_violations_2022_part' + CAST(@i AS VARCHAR(2)) + ';';

    EXEC sp_executesql @sql;
    SET @i = @i + 1;
END;


SELECT TOP 100 * FROM nyc;



-- Exploratory Data Analysis

-- Which parking violation was most commonly committed by vehicles in NYC that were registered in various states?
WITH RankedViolations AS (
    SELECT Registration_State AS State, Violation_Description AS Violation, COUNT(Violation_Description) AS Count, ROW_NUMBER() OVER (PARTITION BY Registration_State ORDER BY COUNT(Violation_Description) DESC) AS Rank
    FROM nyc 
    GROUP BY Registration_State, Violation_Description
)
SELECT State, Violation, Count
FROM RankedViolations
WHERE Rank = 1
ORDER BY COUNT DESC;


-- testing if changed made on mssms sync with github