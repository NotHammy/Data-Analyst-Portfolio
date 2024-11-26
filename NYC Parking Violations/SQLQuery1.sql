/*******************************************************************************************************
* Author: Hamza Jalal                                                                                  *
* Date: Nov 2024                                                                                       *
* Description: This SQL script analyses the NYC Parking Violations dataset, which records violations   *
*              issued from July 1, 2021, to June 30, 2022. The script focuses on identifying trends    *
*              and patterns in parking violations across different times, locations, and other         *
*              dimensions provided in the dataset. It aims to extract actionable insights that could   *
*              inform urban planning and traffic enforcement strategies.							   *
*																									   *
* Purpose: To leverage the Parking Violations data to enhance understanding of parking behaviour in    *
*          NYC, facilitate urban planning, improve traffic management, and optimise law enforcement    *
*          resource allocation. This analysis also supports policy-making by providing empirical       *
*          evidence on the effectiveness of current parking regulations and identifying areas where    *
*          improvements are needed.                                                                    *
*******************************************************************************************************/


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


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


SELECT TOP 100 * FROM nyc;


------------------------------------------------------------------------ Exploratory Data Analysis -----------------------------------------------------------------------------------------------------------------------------|



-- Which parking violation was most commonly committed by vehicles in NYC that were registered in various states?
-- Include percentage distribution of violations.
WITH TotalViolations AS (
    SELECT SUM(COUNT(*)) OVER () AS TotalCount
    FROM nyc
),
StateViolations AS (
    SELECT Registration_State AS State, COUNT(*) AS Count
    FROM nyc
    GROUP BY Registration_State
),
RankedViolations AS (
    SELECT State, Count, ROUND((CAST(Count AS FLOAT) / TotalCount) * 100, 2) AS Percentage, ROW_NUMBER() OVER (PARTITION BY State ORDER BY Count DESC) AS Rank
    FROM StateViolations, TotalViolations
)
SELECT TOP 30 State, Count, Percentage
FROM RankedViolations
WHERE State <> 'NY'  -- Excluding New York from the final results
ORDER BY Percentage DESC;



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- Total number of violations committed in NYC in the current Fiscal Year
SELECT COUNT(DISTINCT Summons_Number) AS Total_Violations
FROM nyc; 



-- Most Commonly Committed Parking Violations and their distributions
SELECT TOP 10 Violation, Count, ROUND((CAST(Count AS FLOAT) / TotalViolations) * 100, 2) AS Percentage
FROM (
	SELECT Violation_Description AS Violation, COUNT(Violation_Description) AS Count
    FROM nyc
    GROUP BY Violation_Description
) AS Violations
CROSS JOIN (
	SELECT COUNT(Violation_Description) AS TotalViolations
    FROM nyc
) AS Total
ORDER BY Count DESC; 


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|



-- How do parking violations vary across days of the week?
-- Assign day name to date

-- Select the day of the week and count violations
SELECT 
    -- Translate numeric day of the week to its name
    CASE
        WHEN DATEPART(WEEKDAY, Issue_Date) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 7 THEN 'Saturday'
    END AS issue_weekday,
    COUNT(Summons_Number) AS Violation_Count  -- Count of violations per weekday
FROM 
    nyc
GROUP BY 
    -- Group results by the weekday name for aggregation
    CASE
        WHEN DATEPART(WEEKDAY, Issue_Date) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, Issue_Date) = 7 THEN 'Saturday'
    END
ORDER BY 
    Violation_Count DESC -- Sort results by count of violations



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
