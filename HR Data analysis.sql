CREATE DATABASE HR;

USE HR;

SELECT *
FROM [HR Data];


SELECT termdate
from [HR Data]
order by termdate desc;

update [HR Data]
set termdate = format(convert (datetime, left(termdate,19),120),'yyyy-mm-dd')

alter table [HR Data]
Add new_termdate Date;

--copy convert time value from termdate to new_termdate

update [HR Data]
set new_termdate = Case
when termdate is not null and  ISDATE(termdate) = 1 then CAST (termdate AS DATETIME) else null end;
    
	-- create new column "age" 

	alter table [HR Data]
	add age nvarchar(50);

	-- populate new column with age

	update [HR Data]
	set age = DATEDIFF(year, birthdate, getdate());

	select age
	from [HR Data]

	-- min and max ages

SELECT 
 MIN(age) AS min_age, 
 MAX(AGE) AS max_age
FROM [HR Data]

-- QUESTIONS TO ANSWER FROM THE DATA

-- 1) What's the age distribution in the company?

SELECT 
 MIN(age) AS Youngest, 
 MAX(age) AS Oldest
FROM [HR Data];

-- Age group distribution

select age_group,
count(*) as count
from 
(Select 
Case
when age <= 22 and age <= 30 then '22 to 30'
when age <= 31 and age <= 40 then '31 to 40'
when age <= 41 and age <= 50 then '41 to 50'
else '50+'
end as age_group
from [HR Data]
where new_termdate is null
) AS subquery
group by age_group
order by age_group;

--Age Group by Gender

select age_group,
gender,
count(*) as count
from 
(Select 
Case
when age <= 22 and age <= 30 then '22 to 30'
when age <= 31 and age <= 40 then '31 to 40'
when age <= 41 and age <= 50 then '41 to 50'
else '50+'
end as age_group,
gender
from [HR Data]
where new_termdate is null
) AS subquery
group by age_group, gender
order by age_group, gender;

-- 2) What's the gender breakdown in the company?

SELECT
 gender,
 COUNT(gender) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;

-- 3) How does gender vary across departments and job titles?

SELECT department, gender, count(*) as count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- job titles 

SELECT department, jobtitle, gender, 
count(gender) as count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;

-- race distribution in the company 

select 
race, 
count(*) as count
from [HR Data]
where new_termdate is null
group by race 
order by count desc;

-- average lenght of employement in the company 

select 
Avg(datediff(year, hire_date, new_termdate)) as Tenure 
from [HR Data]
where new_termdate is not null and new_termdate <= Getdate();

-- which dpt has the highest turnover rate?
-- get total count
---get terminated count 
---terminated count/total count 

SELECT
 department,
 total_count,
 terminated_count,
 round(CAST(terminated_count AS FLOAT)/total_count, 2)*100 AS turnover_rate
FROM 
   (SELECT
   department,
   count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM [HR Data]
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;

--- What is the tenure distribution for each department? 

select 
department,
Avg(datediff(year, hire_date, new_termdate)) as Tenure 
from [HR Data]
where new_termdate is not null and new_termdate <= Getdate()
group by department
order by tenure desc;

-- how many employes works remotely for each department? 

Select 
location, 
count (*) as count
from [HR Data]
where new_termdate is null
group by location;

--what's the distribution of employees across diff states? 

select 
location_state,
count (*) as count
from [HR Data]
where new_termdate is null
group by location_state
order by count Desc;

--- how are job titles distributed within the company? 

select 
jobtitle,
count (*) as count 
from [HR Data]
where new_termdate is null
group by jobtitle
order by count desc;

--- how are employee hire count varied over time?
-- cal hires
--calculate terminations
--(hires-terminations)/hires percent hire change

SELECT
hire_yr,
hires,
terminations,
hires - terminations AS net_change,
(round(cast(hires - terminations as float)/hires, 2))*100 AS percent_hire_change
FROM  
  (SELECT
  YEAR(hire_date) AS hire_yr,
  count(*) as hires,
  SUM(CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) terminations
  FROM [HR Data]
  GROUP BY year(hire_date)
  ) AS subquery
ORDER BY percent_hire_change ASC;