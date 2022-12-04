

------------------------------------ Queries for Tableau Project ------------------------------------

SELECT *
FROM PortofolioProject..CovidDeaths

-- 1.

-- The death percentage in over the world from 2020 until 2021
SELECT SUM(cast(new_cases as int)) total_of_new_cases, SUM(cast(new_deaths as int)) total_of_new_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 2) DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 2.

-- Counting the Total Deaths in every continent over the world
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.
-- This's will show you the percentage of population got Covid
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 4)) PopulationInfectPercentage
FROM PortofolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectPercentage DESC


--4.
-- This's will show you the percentage of population got Covid (with Date)
-- The column of data converted into DD/MM/YY for make it easier while copying to excel
SELECT location, population, CONVERT(varchar(10), date, 101) as new_date, MAX(total_cases) HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 4)) PopulationInfectPercentage
FROM PortofolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PopulationInfectPercentage DESC