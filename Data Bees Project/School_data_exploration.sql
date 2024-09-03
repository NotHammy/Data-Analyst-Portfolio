-- Considering Data from 2020 onwards
-- Crimson Global Academy only offers schooling for children aged 8-18

-- Percentage change of enrollments in schools each year
-- (listed by year)
;with EnrolmentData as (
	select Calendar_Year,School_Name, sum(Total_Enrolments) as Total_Enrolments
	from school
	where Calendar_Year >= '2020' 
	and Total_Enrolments is not null		-- Exclude schools with no enrollment data
	group by Calendar_Year, School_name
)
select Calendar_Year, School_Name, Total_Enrolments,
    lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year) as Previous_Year_Enrolments,
    round(cast((Total_Enrolments - lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year)) * 100.0 as float) / cast(lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year) as float), 2) as Percentage_Change
from EnrolmentData
order by School_Name, Calendar_Year;


|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- Average Percentage change of enrollments in a school from 2020-present
-- (listed by school)
-- Gather Enrolment history for each school
;with EnrolmentData as (
	select Calendar_Year, School_Name, sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Total_Enrolments is not null		-- Exclude schools with no enrollment data
	group by Calendar_Year, School_name
), 
-- Percentage change of enrollments in schools over Calendar_Year
PercentageChangeData as (
	select Calendar_Year, School_Name, Total_Enrolments,
	lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year) as Previous_Year_Enrolments,
	round(cast((Total_Enrolments - lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year)) * 100.0 as float) / cast(lag(Total_Enrolments) over (partition by School_Name order by Calendar_Year) as float), 2) as Percentage_Change
	from EnrolmentData
)
select school_name, cast(avg(Percentage_Change) as decimal(10, 2)) as Avg_Percentage_Change
from PercentageChangeData
group by School_name
order by Avg_Percentage_Change desc;


|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- Percentage change in enrollment by suburb
;with EnrolmentData as (
	select Calendar_Year, Suburb, sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	group by Calendar_Year, Suburb
), 
-- Percentage change of enrollments in suburbs over Calendar_Year
PercentageChangeData as (
	select Calendar_Year, Suburb, Total_Enrolments,
	lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as Previous_Year_Enrolments,
	round(cast((Total_Enrolments - lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year)) * 100.0 as float) / cast(lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as float), 2) as Percentage_Change
	from EnrolmentData
)
select Suburb, cast(avg(Percentage_Change) as decimal(10, 2)) as Avg_Percentage_Change
from PercentageChangeData
group by Suburb
order by Avg_Percentage_Change desc;


|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

-- This query proves that there is no data for Dayton Primary and Emmaus Catholic since they are new schools
-- For this reason the growth factor is exponentially high for the suburb Dayton and so it must be excluded from the 
-- result set
select Calendar_Year, Suburb, School_Name, ICSEA, ICSEA_Percentile, Total_Enrolments 
from School 
where Suburb = 'Dayton'
and Calendar_Year >= '2020'
order by Calendar_Year, Total_Enrolments


|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- Suburbs with the highest average percentage change with their avg ICSEA percentiles
;with EnrolmentData as (
	select Calendar_Year, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020'  
	and Suburb <> 'Dayton'					-- Exclude 'Dayton' due to it being an outlier
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	group by Calendar_Year, Suburb
), 
-- Percentage change of enrollments in suburbs over Calendar_Year
PercentageChangeData as (
	select Calendar_Year, Suburb, Total_Enrolments, avg_ICSEA_percentile,
	lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as Previous_Year_Enrolments,
	round(cast((Total_Enrolments - lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year)) * 100.0 as float) / cast(lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as float), 2) as Percentage_Change
	from EnrolmentData
)
select Suburb, cast(avg(Percentage_Change) as decimal(10, 2)) as Avg_Percentage_Change, avg(avg_ICSEA_percentile) as avg_ICSEA_percentile
from PercentageChangeData
where avg_ICSEA_percentile is not null
group by Suburb
order by Avg_Percentage_Change desc, avg_ICSEA_percentile desc;



|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- avg growth factor of a suburb based on their avg ICSEA percentile
-- This data can answer the hypothesis that high ICSEA percentile suburbs tend to have a lower change in enrollment numbers.
-- Group suburbs based on their ICSEA percentile.
;with EnrolmentData as (
	select Calendar_Year, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020'  
	and Suburb <> 'Dayton'					-- Exclude 'Dayton' due to it being an outlier
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	group by Calendar_Year, Suburb
), 
-- Percentage change of enrollments in suburbs over Calendar_Year
PercentageChangeData as (
	select Calendar_Year, Suburb, Total_Enrolments, avg_ICSEA_percentile,
	lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as Previous_Year_Enrolments,
	round(cast((Total_Enrolments - lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year)) * 100.0 as float) / cast(lag(Total_Enrolments) over (partition by Suburb order by Calendar_Year) as float), 2) as Percentage_Change
	from EnrolmentData
)
select cast(avg(Percentage_Change) as decimal(10, 2)) as Avg_Percentage_Change, avg(avg_ICSEA_percentile) as avg_ICSEA_percentile
from PercentageChangeData
where avg_ICSEA_percentile is not null
group by avg_ICSEA_percentile
order by  avg_ICSEA_percentile desc;



|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- List of all schools sorted by ICSEA
select Calendar_Year,School_Name, ICSEA, ICSEA_Percentile, Geolocation, School_Sector, School_Type,Top_SEA_Quarter
from School
where Calendar_Year >= '2020' 
order by ICSEA desc


-- Special Needs Schools sorted by ICSEA
select Calendar_Year,School_Name, ICSEA, ICSEA_Percentile, Geolocation, School_Sector, School_Type, Year_Range
from School
where Calendar_Year >= '2020' 
and School_Type = 'Special'
order by ICSEA desc


|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- find the richest schools with the most academically ambitious students, most athletes, and most travelling students. 
-- Top sea quarter % represents the number of students at school which are from the highest socio-educational advantage.
-- So schools with higher Top sea Quarter % will tend to have more students in the top 25% of Australia in terms of social educational advantage.
-- Advertising to schools with higher Top_Sea_Quarter % value will yield a greater result when advertising.
select school_name, Suburb, Top_SEA_Quarter 
from School
where Top_SEA_Quarter is not null
order by Top_SEA_Quarter desc


select Calendar_Year, Suburb, school_name, sum(Total_Enrolments) as Total_Enrolments
from School
where Calendar_Year >= '2020' 
and Total_Enrolments is not null		-- Exclude schools with no enrollment data
group by Calendar_Year, Suburb, school_name


