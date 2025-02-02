-- Table unicorn_companies 
SELECT *
FROM unicorn_companies uc
LIMIT 5;

-- Table unicorn_dates 
SELECT *
FROM unicorn_dates ud
LIMIT 5;

-- Table unicorn_funding 
SELECT *
FROM unicorn_funding uf
LIMIT 5;

-- Table unicorn_industries 
SELECT *
FROM unicorn_industries ui
LIMIT 5;

-- Sort the continents based on the largest number of companies. Which continent has the most unicorns?
SELECT 
	continent, 
	count(DISTINCT company_id) total_company
FROM unicorn_companies uc
GROUP BY continent 
ORDER BY company_count DESC;

-- Which countries have more than 100 unicorns? (Show amount)
SELECT 
	country, 
	count(DISTINCT company) total_company
FROM unicorn_companies uc 
GROUP BY country
HAVING count(DISTINCT company) > 100
ORDER BY count(DISTINCT company) DESC;

-- Which industry is the largest among unicorn companies based on total funding? What is the average valuation?
SELECT ui.industry, 
	sum(DISTINCT uf.funding) total_funding, 
	round(avg(DISTINCT uf.valuation),0) avg_valuation
FROM unicorn_industries ui 
INNER JOIN unicorn_funding uf 
	ON ui.company_id = uf.company_id
GROUP BY ui.industry
ORDER BY total_funding DESC
LIMIT 10;

-- Based on this dataset, for the answer industry number 3, how many companies are joining as unicorns each year in the 2016-2022 range?
SELECT 
	EXTRACT(YEAR FROM ud.date_joined) year_joined, 
	sum(DISTINCT uc.company_id) total_company 
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui
	ON uc.company_id = ui.company_id 
INNER JOIN unicorn_dates ud
	ON uc.company_id = ud.company_id
WHERE 
	EXTRACT(YEAR FROM ud.date_joined) BETWEEN 2016 AND 2022 
	AND ui.industry = 'Fintech'
GROUP BY year_joined 
ORDER BY total_company DESC;

-- Display company detail data (name of company, city of origin, country and continent of origin) along with industry and its valuation. 
-- Which country is the company with the largest valuation from and what is the industry?
SELECT 
	uc.*,
	ui.industry,
	uf.valuation 
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
INNER JOIN unicorn_funding uf 
	ON uc.company_id = uf.company_id 
ORDER BY uf.valuation DESC
LIMIT 5;

-- How about Indonesia? Which company has the highest valuation in Indonesia?
SELECT 
	uc.*,
	ui.industry,
	uf.valuation 
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
INNER JOIN unicorn_funding uf 
	ON uc.company_id = uf.company_id 
WHERE uc.country = 'Indonesia'
ORDER BY uf.valuation DESC;

-- How old was the oldest company when the company merged to become a unicorn company? Which country does the company come from?
SELECT 
	uc.country,
	ud.date_joined,
	ud.year_founded,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded age_of_company
FROM unicorn_companies uc
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id
ORDER BY age_of_company DESC
LIMIT 5;

-- For companies established between 1960 and 2000 (the upper and lower limits fall into the range), 
-- how old was the oldest company when the company merged to become a unicorn company (date_joined)? 
-- Which country does the company come from?
SELECT 
	uc.country,
	ud.date_joined,
	ud.year_founded,
	EXTRACT(YEAR FROM ud.date_joined) - ud.year_founded age_of_company
FROM unicorn_companies uc 
INNER JOIN unicorn_dates ud 
	ON uc.company_id = ud.company_id 
WHERE ud.year_founded BETWEEN 1960 AND 2000
ORDER BY age_of_company DESC
LIMIT 5;

-- How many companies are financed by at least one investor bearing the name 'venture’?
SELECT
	count(DISTINCT company_id) AS total_company
FROM unicorn_funding uf
WHERE lower(select_investors) LIKE '%venture%';

-- How many companies are financed by at least one investor with the names Venture, Capital, and Partner?
SELECT 
	count(DISTINCT 
		CASE
			WHEN lower(select_investors) LIKE '%venture%' THEN company_id 
		END) venture_investors,
	count(DISTINCT 
		CASE
			WHEN lower(select_investors) LIKE '%capital%' THEN company_id 
		END) capital_investors,
	count(DISTINCT 
		CASE
			WHEN lower(select_investors) LIKE '%partner%' THEN company_id 
		END) partner_investors
FROM unicorn_funding uf;

-- In Indonesia, there are many startups engaged in logistics services. 
-- How many logistics startups including unicorns are there in Asia? How many logistics startups are unicorns in Indonesia?
SELECT 
	count(DISTINCT 
		CASE
			WHEN ui.industry LIKE '%logistics%' 
				AND uc.continent = 'Asia' THEN uc.company_id  
		END) asian_company,
	count(DISTINCT 
		CASE
			WHEN ui.industry LIKE '%logistics%' 
				AND uc.country = 'Indonesia' THEN uc.company_id  
		END) indonesia_company
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id
;

-- In Asia there are three countries with the highest number of unicorns. 
-- Show data on the number of unicorns in each industry and country of origin in Asia, with the exception of these three countries. 
-- Sort by industry, number of companies, and country of origin.
WITH asianUnicorn (country, company_id)
AS 
(SELECT 
	uc.country,
	count(DISTINCT uc.company_id) total_company
FROM unicorn_companies uc 
WHERE uc.continent = 'Asia'
GROUP BY uc.country
ORDER BY total_company DESC
)
SELECT
	ui.industry,
	count(DISTINCT uc.company_id) total_company,
	uc.country 
FROM unicorn_companies uc
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id
LEFT JOIN asianUnicorn au 
	ON uc.country = au.country
WHERE au.country NOT IN ('China','India','Israel')
GROUP BY ui.industry, uc.country 
ORDER BY ui.industry, total_company DESC, uc.country ASC 

-- The United States, China, and India are the three countries with the highest number of unicorns. 
-- Is there an industry that doesn't have unicorns coming from India? Anything?
SELECT 
	DISTINCT ui.industry
FROM unicorn_companies uc 
INNER JOIN unicorn_industries ui 
	ON uc.company_id = ui.company_id 
WHERE ui.industry NOT IN (
	SELECT
		DISTINCT ui2.industry  
	FROM unicorn_companies uc2 
	INNER JOIN unicorn_industries ui2 
		ON uc2.company_id = ui2.company_id
	WHERE uc2.country IN ('India')
)
