use laptop;

-- CREATING COPY OF LAPTOP 
CREATE TABLE laptop_copy LIKE laptop;
insert into laptop_copy
select * from laptop;

-- CHECKING SIZE OF DATA
SELECT 
    data_length / 1024
FROM
    information_schema.Tables
WHERE
    table_schema = 'laptop'
        AND table_name = 'laptops';

select * from laptops;

-- CHECKING THAT rows wiall all null values--  
    *
FROM
    laptop
WHERE
    company IS NULL AND Typename IS NULL
        AND inches IS NULL
        AND screenresolution IS NULL
        AND Cpu IS NULL
        AND ram IS NULL
        AND gpu IS NULL
        AND opsys IS NULL
        AND weight IS NULL
        AND price IS NULL;
    
select count(*) from laptop;     

select * from laptop;

-- change the datatype of inches column to decimal
alter table laptop
modify column inches decimal(10, 1);

-- Removing varchar and change value to integer of ram column for futher analysis
UPDATE laptop 
SET 
    Ram = REPLACE(Ram, 'GB', '');

alter table laptop
modify column Ram integer;

-- Removing varchar form weight  column for futher analysis
UPDATE laptop 
SET 
    weight = REPLACE(weight, 'kg', '');

SELECT DISTINCT
    (Weight)
FROM
    laptop
ORDER BY weight ASC;

UPDATE laptop 
SET 
    weight = REPLACE(weight, '', '');

-- updating price column
UPDATE laptop 
SET 
    price = ROUND(price);

alter table laptop
modify column price integer;

-- grouping same opsys brand 
select distinct(OpSys) from laptop;
-- macOS  -- Mac OS X
-- No OS
-- Windows 10  -- Windows 7  -- Windows 10 S
-- Chrome OS -- Android
-- Linux

select opsys,
case
	when opsys like '%mac%' then 'macos'
	when opsys like '%window%' then 'window'
    when opsys like '%No%' then 'N/A'
    when opsys like '%Linux%' then 'linux'
    else 'other'
    end as OSbrand
from laptop;


update laptop
set opsys = case
	when opsys like '%mac%' then 'macos'
	when opsys like '%window%' then 'window'
    when opsys like '%No%' then 'N/A'
    when opsys like '%Linux%' then 'linux'
    else 'other' end;
    
select * from laptop;

-- creating new column and diffentiatiate gpu column in other column 
alter table laptop
add column  gpu_brand varchar(255) after Gpu,
add column gpu_name varchar(255) after gpu_brand;

SELECT 
    SUBSTRING_INDEX(Gpu, ' ', 1)
FROM
    laptop;

UPDATE laptop 
SET 
    gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);

SELECT 
    REPLACE(gpu, gpu_brand, '')
FROM
    laptop;

UPDATE laptop 
SET 
    gpu_name = REPLACE(gpu, gpu_brand, '');

alter table laptop
drop column Gpu;

-- creating cpu_brand, cpu_name and cpu_speed column from cpu column;
alter table laptop
add column cpu_brand varchar(255) after cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed decimal(10, 1) after cpu_name;

SELECT 
    *
FROM
    laptop;


SELECT 
    SUBSTRING_INDEX(cpu, ' ', 1)
FROM
    laptop;
UPDATE laptop 
SET 
    cpu_brand = SUBSTRING_INDEX(cpu, ' ', 1);

SELECT 
    REPLACE(SUBSTRING_INDEX(Cpu, ' ', - 1),
        'GHz',
        '')
FROM
    laptop;

UPDATE laptop 
SET 
    cpu_speed = REPLACE(SUBSTRING_INDEX(Cpu, ' ', - 1),
        'GHz',
        '');


SELECT DISTINCT
    (cpu_brand)
FROM
    laptop;


SELECT 
    REPLACE(SUBSTRING_INDEX(Cpu, ' ', 3),
        cpu_brand,
        '')
FROM
    laptop;
UPDATE laptop 
SET 
    cpu_name = REPLACE(SUBSTRING_INDEX(Cpu, ' ', 3),
        cpu_brand,
        '');
-- drop previous cpu column
alter table laptop
drop column Cpu;

-- adding resolution_width and resolution_height column to get ppi later;
SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', - 1),
            'x',
            - 1)
FROM
    laptop;

alter table laptop
add column resolution_width integer after ScreenResolution,
add column resolution_height integer after resolution_width;

SELECT 
    *
FROM
    laptop;

UPDATE laptop 
SET 
    resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', - 1),
            'x',
            - 1),
    resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', - 1),
            'x',
            1);

-- adding touchscreen column as some laptops have support touchscreen
alter table laptop
add column touchscreen integer after resolution_height;

SELECT 
    screenresolution LIKE '%touchscreen%'
FROM
    laptop;

UPDATE laptop 
SET 
    touchscreen = screenresolution LIKE '%touch%';

alter table laptop
drop column ScreenResolution;

-- analysing cpu column
SELECT DISTINCT
    cpu_name
FROM
    laptop;

SELECT DISTINCT
    memory
FROM
    laptop;
    
-- adding memory_type, primary_storage, secondary_storage colum 
alter table laptop
add column memory_type varchar(255) after memory,
add column primary_storage integer after memory_type,
add column secondary_storage integer after primary_storage
;

select * from laptop;

SELECT 
    memory,
    CASE
        WHEN
            memory LIKE '%SSD%'
                AND memory LIKE '%HDD%'
        THEN
            'Hybrid'
        WHEN memory LIKE '%SSD%' THEN 'SSD'
        WHEN memory LIKE '%HDD%' THEN 'HDD'
        WHEN memory LIKE '%Flash Storage%' THEN 'FlashStorage'
        WHEN
            memory LIKE '%Flash Storage%'
                AND memory LIKE '%HDD%'
        THEN
            'FlashStorage'
        WHEN memory LIKE '%Hybrid%' THEN 'Hybrid'
    END AS type
FROM
    laptop;

UPDATE laptop 
SET 
    memory_type = CASE
        WHEN
            memory LIKE '%SSD%'
                AND memory LIKE '%HDD%'
        THEN
            'Hybrid'
        WHEN memory LIKE '%SSD%' THEN 'SSD'
        WHEN memory LIKE '%HDD%' THEN 'HDD'
        WHEN memory LIKE '%Flash Storage%' THEN 'FlashStorage'
        WHEN
            memory LIKE '%Flash Storage%'
                AND memory LIKE '%HDD%'
        THEN
            'FlashStorage'
        WHEN memory LIKE '%Hybrid%' THEN 'Hybrid'
    END;


select * from laptop;


-- seperating and updating values having 2 storage on '+'
SELECT 
    memory,
    REGEXP_SUBSTR(SUBSTRING_INDEX(memory, '+', 1),
            '[0-9]+'),
    CASE
        WHEN
            memory LIKE '%+%'
        THEN
            REGEXP_SUBSTR(SUBSTRING_INDEX(memory, '+', - 1),
                    '[0-9]+')
        ELSE 0
    END AS type
FROM
    laptop;

UPDATE laptop 
SET 
    primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(memory, '+', 1),
            '[0-9]+'),
    secondary_storage = CASE
        WHEN
            memory LIKE '%+%'
        THEN
            REGEXP_SUBSTR(SUBSTRING_INDEX(memory, '+', - 1),
                    '[0-9]+')
        ELSE 0
    END;

-- changing storage value in ''GB''
SELECT DISTINCT
    primary_storage
FROM
    laptop;

SELECT 
    primary_storage,
    CASE
        WHEN primary_storage <= 2 THEN primary_storage * 1024
        ELSE primary_storage
    END
FROM
    laptop;

SELECT 
    secondary_storage,
    CASE
        WHEN secondary_storage <= 2 THEN secondary_storage * 1024
        ELSE secondary_storage
    END
FROM
    laptop;

UPDATE laptop 
SET 
    primary_storage = CASE
        WHEN primary_storage <= 2 THEN primary_storage * 1024
        ELSE primary_storage
    END,
    secondary_storage = CASE
        WHEN secondary_storage <= 2 THEN secondary_storage * 1024
        ELSE secondary_storage
    END;

SELECT 
    *
FROM
    laptop;

alter table laptop
drop column Memory;

-- *********************************************************EDA*************************************************************EDA********************************************--  

-- HEAD 
SELECT 
    *
FROM
    laptops
ORDER BY `index`
LIMIT 5;

--  TAIL 
SELECT 
    *
FROM
    laptops
ORDER BY `index` DESC
LIMIT 5;

 -- SAMPLE 
SELECT 
    *
FROM
    laptops
ORDER BY RAND()
LIMIT 5;

-- missing value 
SELECT 
    COUNT(price)
FROM
    laptop
WHERE
    price IS NULL;

-- PLot histrogram

SELECT 
    t.buckets, REPEAT('*', COUNT(*) / 5) AS 'count'
FROM
    (SELECT 
        CASE
                WHEN price BETWEEN 0 AND 25000 THEN '0-25k'
                WHEN price BETWEEN 25001 AND 50000 THEN '25k-50k'
                WHEN price BETWEEN 50001 AND 100000 THEN '50k-100k'
                WHEN price BETWEEN 100001 AND 150000 THEN '100k-150k'
                ELSE '>150k'
            END AS 'buckets'
    FROM
        laptops) t
GROUP BY t.buckets;

-- counting laptop of each company
SELECT 
    Company, COUNT(company)
FROM
    laptops
GROUP BY company;

-- checking companies with total tocuhscreen laptop ever made 
SELECT 
    company,
    SUM(CASE
        WHEN Touchscreen = 1 THEN 1
        ELSE 0
    END) AS 'touchscreen_yes',
    SUM(CASE
        WHEN Touchscreen = 0 THEN 1
        ELSE 0
    END) AS 'touchscreen_no'
FROM
    laptop
GROUP BY company;

-- checing cpu_brand wise laptop of ech company
SELECT DISTINCT
    cpu_brand
FROM
    laptop;
SELECT 
    company,
    SUM(CASE
        WHEN cpu_brand = 'Intel' THEN 1
        ELSE 0
    END) AS 'intel',
    SUM(CASE
        WHEN cpu_brand = 'AMD' THEN 1
        ELSE 0
    END) AS 'AMD',
    SUM(CASE
        WHEN cpu_brand = 'Samsung' THEN 1
        ELSE 0
    END) AS 'samsung'
FROM
    laptop
GROUP BY company;

-- Categorical Numerical Bivariate analysis
SELECT 
    Company, MIN(price), MAX(price), AVG(price), STD(price)
FROM
    laptops
GROUP BY Company;

-- Dealing with missing values
SELECT 
    *
FROM
    laptops
WHERE
    price IS NULL;
-- no null values in any column

-- replacing weight column '' value with mean of weight value 
SELECT 
    weight
FROM
    laptops
WHERE
    weight = '';
 
SELECT 
    AVG(weight)
FROM
    laptops;
  
UPDATE laptop 
SET 
    weight = REPLACE(weight, '', 2.0);

-- Feature Engineering *************************************************************************************************************************
-- adding new column for ppi 
ALTER TABLE laptops 
ADD COLUMN ppi INTEGER;

UPDATE laptops 
SET 
    ppi = ROUND(SQRT(resolution_width * resolution_width + resolution_height * resolution_height) / Inches);

SELECT 
    *
FROM
    laptops
ORDER BY ppi DESC;

-- adding screen_size column and diving on basis of screen
ALTER TABLE laptops 
ADD COLUMN screen_size VARCHAR(255) AFTER Inches;


UPDATE laptops
SET screen_size = CASE 
	WHEN Inches < 14.0 THEN 'small'
    WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
	ELSE 'large'
END;

SELECT screen_size,AVG(price) FROM laptops
GROUP BY screen_size;


-- analysing gpu_brand column
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptops














