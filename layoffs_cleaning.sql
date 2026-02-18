SELECT * 
FROM layoffs;

-- Remove Duplicates
-- Standardize the Data
-- Null Values or Blank Values
-- Remove Columns not needed


-- Step one create a copy of raw data
Create Table layoffs_staging
like layoffs_staging;

SELECT * 
FROM layoffs_staging;
  
Insert layoffs_staging
select * 
From layoffs;

-- Removing Duplicates 
SELECT *,
Row_number() over(
partition by company,industry,total_laid_off,percentage_laid_off, `date`  ) as row_num
FROM layoffs_staging;

-- The code below view duplicates from the criteria above NB we do cte so we could apply the WHERE function
with duplicate_cte as
(
SELECT *,
Row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off, `date`, stage ,country, funds_raised_millions  ) as row_num
FROM layoffs_staging
)
select *
from duplicate_cte
where row_num>1; -- This shows ONLY the duplicates because the row_num>1

-- code below just checks the company which have duplicates(row_num>2 just to verify the info
select *
from layoffs_staging
where company ='Cazoo' ;

-- the code below just to DELETE DUPLICATES we create a table named layoffs_staging2
-- instructions click on top of table named layoff_staging > copy to clipboard > create statement> paste that to the scriipt and it will be as shown below and rename where you see layoffs_staging to layoffs_staging2

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2
where row_num>1;

INSERT INTO layoffs_staging2  
SELECT *,
Row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off, `date`, stage ,country, funds_raised_millions  ) as row_num
FROM layoffs_staging;

DELETE 
from layoffs_staging2
where row_num>1;

select *
from layoffs_staging2;

-- STANDARDIZING DATA

--
SELECT COMPANY, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

--
SELECT distinct industry
from layoffs_staging2;
-- where industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry ='Crypto'
WHERE industry LIKE 'Crypto%';

--
SELECT distinct country,TRIM(Trailing '.' FROM country)
from layoffs_staging2
-- where country LIKE '%United States%'
order by 1;

UPDATE layoffs_staging2
SET country = TRIM(Trailing '.' FROM country)
WHERE country LIKE '%United States%';


--
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y') 
from layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y') ;

SELECT `date`
from layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

select *
from layoffs_staging2;

-- REMOVING NULLS/BLANKS by filling them with info which we could find from the data on table( sometimes you couk do this from other sources)
select *
from layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL ;

 UPDATE layoffs_staging2
 SET industry = null
 WHERE industry = '';

select *
from layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
from layoffs_staging2
WHERE company LIKE 'Bally%' ;

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company =t2.company
SET t1.industry =t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

select *
from layoffs_staging2;

-- DELETING (Rows) what we wont need because it has some missing info which we cant replace/populate 
select *
from layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL ;

DELETE
from layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL ;

select *
from layoffs_staging2;

-- Dropping columns which is not needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- 






 