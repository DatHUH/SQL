
-- creating table for checkins
--create table checkins (
--	userid int not null,
--	Timestamp bigint not null,
--	loc_name varchar(50),
--	loc_id varchar(50),
--	loc_ctry varchar(50),
--	loc_city varchar(50),
--	loc_postal varchar(50),
--	rating int)

-- inserting values for checkins table
--insert into checkins
--values 
--(1, 20141028150345, 'In-n-Out', 123123123, 'US', 'Mountain View', '94043', 5),
--(1, 20141028181010, 'Starbucks', 234234234, 'US', 'San Francisco', '94213', null),
--(2, 20150801085657, '24th St Bart', 345345345, 'US', 'San Francisco', '94110', 2),
--(3, 20150000000001, 'Musee dOrsay' , 456456456, 'FR', 'Paris', '75007', 4),
--(3, 20150000000002, 'YVR', 567567567, 'CA', 'Vancouver', 'V7B 0A4', null),
--(3, 20150000000003, 'Starbucks', 234234234, 'US', 'San Francisco', '94213', 1)

-- creating table for cities
--create table cities (
--	city1 nvarchar(50),
--	city2 nvarchar(50),
--	distance int)

-- inserting values for cities table
--insert into cities
--values
--('A', 'B', 30),
--('A', 'B', 32),
--('B', 'A', 29),
--('A', 'C', 40),
--('C', 'A', 41)

-- creating table for customers
--create table customers (
--	customer_id int not null,
--	timestamps bigint,
--	revenue float)

-- inserting values into customers table
--insert into customers
--values
--(1, 20201212104510, 104.15),
--(2, 20191130121520, 92.12),
--(2, 20210228080030, 43.92),
--(3, 20200709041540, 543.26),
--(3, 20210115233050, 143.66),
--(3, 20190614194505, 15.01)

-- inserting testing values into customers table
--insert into customers
--values
--(4, 20201212104510, 14.15)

-- creating table for renters and videos
--create table renters (
--	userid int not null,
--	first_name varchar(50),
--	last_name varchar(50),
--	dob date)

--create table videos (
--	userid int not null,
--	videoid varchar(50) not null,
--	title varchar(50),
--	director varchar(50))

-- inserting values into renters and videos tables
--insert into renters
--values
--(1, 'Alex',  'Smith', '1990-05-01'),
--(2, 'Jane', 'Doe', '1995-01-30'),
--(3, 'John', 'Johnson', '2000-09-15')

--insert into videos
--values
--(1, 'A', 'Jurassic Park', 'Steven Spielsberg'),
--(2, 'B', 'Star Wars', 'George Lucas'),
--(3, 'C', 'Lord of the Rings', 'Peter Jackson')

-- inserting testing values in videos
insert into videos
values
(1, 'D', 'Jurassic Park 2', 'Steven Spielsberg'),
(1, 'E', 'Jurassic Park 3', 'Steven Spielsberg')

-- CHECKINS TABLE BEGINS HERE
-- View all data from checkins
select *
from checkins

-- Grab the number of unique users from all of time.

select count(distinct userid) as uniqueusers
from checkins

-- Grab the most recent location name for each user.

SELECT t.userid, t.loc_name, t.Timestamp
FROM checkins as t
INNER JOIN (
	SELECT userid, max(Timestamp) as LatestDate
	FROM checkins
	GROUP BY userid)
as tm on t.userid = tm.userid and t.Timestamp = tm.LatestDate


-- Grab the top 5 countries with the highest % of their check ins being at Starbucks.

select top 5 loc_ctry, cast((count(case when loc_name = 'Starbucks' then 1 end)) as float) / count(*) as starbucksRatio
from checkins
group by loc_ctry
order by starbucksRatio desc

-- The app allows users to enter/update their rating of a location anytime they check in. A location’s overall rating should reflect the average of the most recent user ratings 
-- (if a user’s most recent check-in didn’t include a rating, we would use the most recent rating the provided). Grab the average star rating for each location.

SELECT
     t.loc_id,
     t.loc_name,
     AVG(rating) as avgRating
FROM (
    SELECT
        loc_id,
        loc_name,
        CAST(rating as DECIMAL(12,2)) rating,
        CASE WHEN rating IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY loc_id,userid ORDER BY t1.Timestamp DESC) END as rn
    FROM
        checkins as t1
) as t
WHERE rn=1
GROUP BY
     t.loc_id,
     t.loc_name


-- CITIES TABLE BEGINS HERE
-- Grab the max, min, and average distances of every city pair from cities table (no duplicated city pair, in any direction).

select (case when city1 < city2 then city1 else city2 end) city1, (case when city1 < city2 then city2 else city1 end) city2, min(distance) as minDistance, max(distance) as maxDistance, avg(distance) as avgDistance
from cities
group by (case when city1 < city2 then city1 else city2 end), (case when city1 < city2 then city2 else city1 end)


-- Grab the single city pair with the largest discrepancy between their highest and lowest reported distances.

select top 1 (case when city1 < city2 then city1 else city2 end) city1, (case when city1 < city2 then city2 else city1 end) city2, (max(distance) - min(distance)) as largestDiscrepancy
from cities
group by (case when city1 < city2 then city1 else city2 end), (case when city1 < city2 then city2 else city1 end)
order by largestDiscrepancy desc



-- Grab the city most frequented by the road trippers.

select top 1 (case when city1 < city2 then city1 else city2 end) city1, 
			(case when city1 < city2 then city2 else city1 end) city2, 
			count(*) as Frequency
from cities
group by (case when city1 < city2 then city1 else city2 end), (case when city1 < city2 then city2 else city1 end)
order by Frequency desc


-- CUSTOMER TABLES BEGINS HERE
select *
from customers
-- Grab the top 10 customers by total spend.

select top 10 customer_id, sum(revenue) as total
from customers
group by customer_id
order by total desc


-- Grab the top 1% of customers by spend.

select top 1 percent customer_id, sum(revenue) as total
from customers
group by customer_id
order by total desc


-- Grab the single month from all of time with the most number of users making purchases.
select* from customers

select top 1 substring(cast(timestamps as varchar(50)), 5,2) as months, count(substring(cast(timestamps as varchar(50)), 5,2)) as counts
from customers
group by timestamps
order by counts desc


-- Grab the average time between the most recent two transactions for all customers in this table.

select avg(timestamps) as avgtime
from customers
where timestamps in (
select top 2 timestamps 
from customers
order by timestamps desc)




-- RENTERS AND VIDEOS BEGIN HERE

-- Grab all the information about users with the first name "Alex" or the last name "Doe."

select *
from renters as r
inner join videos as v on r.userid = v.userid
where first_name = 'Alex' or last_name = 'Doe'

-- For each user_id, grab the total number of videos that they rented.

select r.userid, count(*) as videosRented
from renters as r
inner join videos as v on r.userid = v.userid
group by  r.userid

-- Grab the number of videos rented by users with the first name "Alex," even if they rented 0 videos.


select r.first_name, count(*) as videosRented
from renters as r
inner join videos as v on r.userid = v.userid
group by r.userid, r.first_name
having r.first_name = 'Alex'