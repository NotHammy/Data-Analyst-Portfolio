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
select top 10 school_name, cast(avg(Percentage_Change) as decimal(10, 2)) as Avg_Percentage_Change
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
order by Avg_Percentage_Change desc



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


-- Rural and regional suburbs with the highest ICSEA scores and the most enrolment numbers 
-- Group based of a weighted average score to get most ideal rural suburbs to advertise to
-- This weighted average score is based on avg(ICSEA_Percentile) and avg(total_enrolments) of a suburb

-- ICSEA Percentile and total enrolments per suburb since 2020
;with EnrolmentData as (
	select Calendar_Year, Suburb, ICSEA_Percentile,  sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Geolocation in ('Outer Regional', 'Remote', 'Very Remote')
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	and Total_Enrolments > 100
	group by Calendar_Year, Suburb, ICSEA_Percentile
),
-- Normalise the data
NormalisedData as (
	select Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments,
		max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
		min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
		max(avg(Total_Enrolments)) over () as max_total_enrolments,
		min(avg(Total_Enrolments)) over () as min_total_enrolments
	from EnrolmentData
	group by Suburb
)
-- list of suburbs based on weighted score
-- NOTE: See formula in Methodology section in Report
select top 10 Suburb, avg_ICSEA_percentile, avg_total_enrolments, 
	  round(
        (
            (
                (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float))*0.67
            ) + 
            (
                (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                (cast(max_total_enrolments as float) - cast(min_total_enrolments as float))*0.33
            )
        ),
        3
    ) as weighted_score
from NormalisedData
order by weighted_score desc;



|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|




-- Above we found the best rural and regional suburbs for advertisement.
-- Query below finds the best rural and regional schools instead.


;with EnrolmentData as (
	select Calendar_Year, Suburb, School_Name, ICSEA_Percentile,  sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Geolocation in ('Outer Regional', 'Remote', 'Very Remote')
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	group by Calendar_Year, School_Name, Suburb,  ICSEA_Percentile
),
-- Normalise the data
NormalisedData as (
	select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments,
		max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
		min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
		max(avg(Total_Enrolments)) over () as max_total_enrolments,
		min(avg(Total_Enrolments)) over () as min_total_enrolments
	from EnrolmentData
	group by School_Name, Suburb
)
select top 10 School_Name, Suburb, avg_ICSEA_percentile, avg_total_enrolments, 
	  round(
        (
            (
                (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float))*0.67
            ) + 
            (
                (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                (cast(max_total_enrolments as float) - cast(min_total_enrolments as float))*0.33
            )
        ),
        3
    ) as weighted_score
from NormalisedData
order by weighted_score desc;





|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|




-- Special needs schools with high ICSEA percentiles and high enrollment counts

;with EnrolmentData as (
	select Calendar_Year, Suburb, School_Name, ICSEA_Percentile,  sum(Total_Enrolments) as Total_Enrolments, School_Type
	from School
	where Calendar_Year >= '2020' 
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	and School_Type = 'Special'
	group by Calendar_Year, School_Name, Suburb,  ICSEA_Percentile, School_Type
),
-- Normalise the data
NormalisedData as (
	select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments, School_Type,
		max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
		min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
		max(avg(Total_Enrolments)) over () as max_total_enrolments,
		min(avg(Total_Enrolments)) over () as min_total_enrolments
	from EnrolmentData
	group by School_Name, Suburb, School_Type
)
select School_Name, Suburb, School_Type, avg_ICSEA_percentile, avg_total_enrolments, 
	  round(
        (
            (
                (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float))*0.67
            ) + 
            (
                (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                (cast(max_total_enrolments as float) - cast(min_total_enrolments as float))*0.33
            )
        ),
        3
    ) as weighted_score
from NormalisedData
order by weighted_score desc;



|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|



-- Gather location data for all schools that we have recommended. 
-- Add Location data into current database as a seperate table. This table includes the 
-- longitude and latitude of all schools and suburbs. 
-- Join schools table on locations table




-- Top choices for Rural Suburbs with their latlongs

;with EnrolmentData as (
	select Calendar_Year, Suburb, ICSEA_Percentile,  sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Geolocation in ('Outer Regional', 'Remote', 'Very Remote')
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	and Total_Enrolments > 100
	group by Calendar_Year, Suburb, ICSEA_Percentile
),
-- Normalise the data
NormalisedData as (
	select Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments,
		max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
		min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
		max(avg(Total_Enrolments)) over () as max_total_enrolments,
		min(avg(Total_Enrolments)) over () as min_total_enrolments
	from EnrolmentData
	group by Suburb
),
-- list of suburbs based on weighted score
-- NOTE: See formula in Methodology section in Report
TopChoices as (
	select Suburb, avg_ICSEA_percentile, avg_total_enrolments, 
		  round(
			(
				(
					(cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
					(cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float))*0.67
				) + 
				(
					(cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
					(cast(max_total_enrolments as float) - cast(min_total_enrolments as float))*0.33
				)
			),
			3
		) as weighted_score
	from NormalisedData
)
select top 10 s.Suburb, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score, max(l.latitude) as lat, max(l.longitude) as long
from TopChoices s
Join Locations l on s.Suburb = l.Suburb
group by s.Suburb, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score
order by s.weighted_score desc;







-- Top choices for special needs schools with their latlong values

;with EnrolmentData as (
    select Calendar_Year, Suburb, School_Name, ICSEA_Percentile, sum(Total_Enrolments) as Total_Enrolments, School_Type
    from School
    where Calendar_Year >= '2020' 
    and Total_Enrolments is not null        -- Exclude suburbs with no enrollment data
    and School_Type = 'Special'
    group by Calendar_Year, School_Name, Suburb, ICSEA_Percentile, School_Type
),
-- Normalise the data
NormalisedData as (
    select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments, School_Type,
        max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
        min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
        max(avg(Total_Enrolments)) over () as max_total_enrolments,
        min(avg(Total_Enrolments)) over () as min_total_enrolments
    from EnrolmentData
    group by School_Name, Suburb, School_Type
), 
TopChoices as (
    select School_Name, Suburb, School_Type, avg_ICSEA_percentile, avg_total_enrolments,
          round(
            (
                (
                    (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                    (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) * 0.67
                ) + 
                (
                    (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                    (cast(max_total_enrolments as float) - cast(min_total_enrolments as float)) * 0.33
                )
            ),
            3
        ) as weighted_score
    from NormalisedData
)
select s.School_Name, s.Suburb, s.School_Type, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score, l.latitude as lat, l.longitude as long
from TopChoices s
Join Locations l on s.School_Name = l.School_Name
order by s.weighted_score desc;




-- Top Choices for Rural Schools with their LatLongs

;with EnrolmentData as (
	select Calendar_Year, Suburb, School_Name, ICSEA_Percentile,  sum(Total_Enrolments) as Total_Enrolments
	from School
	where Calendar_Year >= '2020' 
	and Geolocation in ('Outer Regional', 'Remote', 'Very Remote')
	and Total_Enrolments is not null		-- Exclude suburbs with no enrollment data
	group by Calendar_Year, School_Name, Suburb,  ICSEA_Percentile
),
-- Normalise the data
NormalisedData as (
	select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments,
		max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
		min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
		max(avg(Total_Enrolments)) over () as max_total_enrolments,
		min(avg(Total_Enrolments)) over () as min_total_enrolments
	from EnrolmentData
	group by School_Name, Suburb
),
TopChoices as (
	select top 10 School_Name, Suburb, avg_ICSEA_percentile, avg_total_enrolments, 
		  round(
			(
				(
					(cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
					(cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float))*0.67
				) + 
				(
					(cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
					(cast(max_total_enrolments as float) - cast(min_total_enrolments as float))*0.33
				)
			),
			3
		) as weighted_score
	from NormalisedData
	order by weighted_score desc
)
select s.School_Name, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score, l.latitude as lat, l.longitude as long
from TopChoices s
Join Locations l on s.School_Name = l.School_Name
order by s.weighted_score desc;



--|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|


-- Combined data from last 2 data sets to show overall ranking for schools based on weighted score. 

;with EnrolmentDataSpecial as (
    select Calendar_Year, Suburb, School_Name, ICSEA_Percentile, sum(Total_Enrolments) as Total_Enrolments, School_Type
    from School
    where Calendar_Year >= '2020' 
    and Total_Enrolments is not null
    and School_Type = 'Special'
    group by Calendar_Year, School_Name, Suburb, ICSEA_Percentile, School_Type
),
NormalisedDataSpecial as (
    select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments, School_Type,
        max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
        min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
        max(avg(Total_Enrolments)) over () as max_total_enrolments,
        min(avg(Total_Enrolments)) over () as min_total_enrolments
    from EnrolmentDataSpecial
    group by School_Name, Suburb, School_Type
),
TopChoicesSpecial as (
    select School_Name, Suburb, School_Type, avg_ICSEA_percentile, avg_total_enrolments,
          round(
            (
                (
                    (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                    (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) * 0.67
                ) + 
                (
                    (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                    (cast(max_total_enrolments as float) - cast(min_total_enrolments as float)) * 0.33
                )
            ),
            3
        ) as weighted_score
    from NormalisedDataSpecial
),
EnrolmentDataRural as (
    select Calendar_Year, Suburb, School_Name, ICSEA_Percentile, sum(Total_Enrolments) as Total_Enrolments
    from School
    where Calendar_Year >= '2020' 
    and Geolocation in ('Outer Regional', 'Remote', 'Very Remote')
    and Total_Enrolments is not null
    group by Calendar_Year, School_Name, Suburb, ICSEA_Percentile
),
NormalisedDataRural as (
    select School_Name, Suburb, avg(ICSEA_Percentile) as avg_ICSEA_percentile, avg(Total_Enrolments) as avg_total_enrolments,
        max(avg(ICSEA_Percentile)) over () as max_ICSEA_percentile,
        min(avg(ICSEA_Percentile)) over () as min_ICSEA_percentile,
        max(avg(Total_Enrolments)) over () as max_total_enrolments,
        min(avg(Total_Enrolments)) over () as min_total_enrolments
    from EnrolmentDataRural
    group by School_Name, Suburb
),
TopChoicesRural as (
    select School_Name, Suburb, 'Rural' as School_Type, avg_ICSEA_percentile, avg_total_enrolments,
          round(
            (
                (
                    (cast(avg_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) / 
                    (cast(max_ICSEA_percentile as float) - cast(min_ICSEA_percentile as float)) * 0.67
                ) + 
                (
                    (cast(avg_total_enrolments as float) - cast(min_total_enrolments as float)) / 
                    (cast(max_total_enrolments as float) - cast(min_total_enrolments as float)) * 0.33
                )
            ),
            3
        ) as weighted_score
    from NormalisedDataRural
),
CombinedResults as (
    select * from TopChoicesSpecial
    union all
    select * from TopChoicesRural
)
select s.School_Name, s.Suburb, s.School_Type, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score, l.latitude as lat, l.longitude as long
from CombinedResults s
join Locations l on s.School_Name = l.School_Name
group by s.School_Name, s.Suburb, s.School_Type, s.avg_ICSEA_percentile, s.avg_total_enrolments, s.weighted_score, l.latitude, l.longitude
order by s.weighted_score desc;
 


