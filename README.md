#  World Layoffs: Advanced Data Cleaning in SQL

##  Project Overview
In this project, I performed a comprehensive data cleaning process on a raw dataset containing global company layoffs. The goal was to transform messy, inconsistent data into a structured format ready for exploratory data analysis (EDA).

---

##  Data Cleaning Steps Taken

### 1. Staging Data
Created a `layoffs_staging` table to ensure the raw source data remained untouched. I then created a second staging table (`layoffs_staging2`) with an added `row_num` column to facilitate duplicate removal.

### 2. Duplicate Removal
Identified and removed duplicate records by using **Window Functions** (`ROW_NUMBER`) partitioned across all columns to ensure data uniqueness.

### 3. Standardization
*   **Company Names:** Used `TRIM()` to remove leading/trailing whitespace.
*   **Industry Names:** Standardized varied entries (e.g., merging all "Crypto" variations into one uniform category).
*   **Country Names:** Fixed trailing punctuation issues (e.g., "United States.").
*   **Date Formats:** Converted the `date` column from a text string to a proper `DATE` data type using `STR_TO_DATE()`.

### 4. Handling Nulls & Blanks
*   Populated missing `industry` values by joining the table to itself and matching records based on `company` and `location`.
*   Removed rows where both `total_laid_off` and `percentage_laid_off` were null, as they lacked actionable data for analysis.

### 5. Final Schema Refinement
Dropped the auxiliary `row_num` column used during cleaning to finalize the dataset for production.

---

##  Key SQL Technique: Self-Join for Data Imputation
One of the most complex parts was filling in missing industry data. I used a **Self-Join** to populate null values from existing records of the same company :

```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

```

---

## Exploratory Data Analysis (EDA)
With the data cleaned and standardized, I explored the dataset to uncover trends and patterns in global layoffs. I focused on identifying chronological peaks, industry-specific volatility, and company rankings.

### Key Analytical Highlights
*   **Time-Series Analysis:** Created a **Monthly Rolling Total** of layoffs to visualize the progression of the "layoff wave."
*   **Company Rankings:** Identified the top 5 companies with the most layoffs per year using a **Double CTE** and **DENSE_RANK()**.
*   **Funding Impact:** Analyzed how `funds_raised_millions` correlated with the scale of workforce reductions.

### Advanced SQL Technique: Multi-CTE Ranking
To find the top 5 companies per year, I used a complex ranking logic that allows for yearly comparisons:

```sql
WITH Company_Year (company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
) 
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
``` 

*   **Part 1: Data Cleaning:** [View Cleaning Script](1_Data_Cleaning.sql)
*   **Part 2: Exploratory Analysis:** [View EDA Script](2_Exploratory_Analysis.sql)

## 👤 Author
**Kaone Edward**

*   [LinkedIn](https://www.linkedin.com/in/kaone-edward-bbb820197/)
*   [GitHub](https://github.com/KaoneData)

