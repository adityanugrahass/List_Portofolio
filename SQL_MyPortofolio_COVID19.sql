USE PortofolioProject

------------------------------------ DATA EXPLORATION ------------------------------------

-- Before we doing query on the data, its really important to check the data type, because if the data type is not relevant/support with the function/statement you’ll get some error.
-- Execute this one by one.
USE PortofolioProject
SP_HELP CovidDeaths
SP_HELP CovidVaccinations

-- Select all the data in every table and check it to make sure that we have all data that we need , with order by statement
SELECT *
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM PortofolioProject..CovidVaccinations
ORDER BY 3,4;

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Death Cases--

-- Total Deaths VS Total Cases
SELECT continent, COUNT(total_deaths) TotalDeaths, COUNT(total_cases) TotalCases
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- How many cases in every Continent, and sorted from largest
SELECT continent, SUM(total_cases) TotalCase, SUM(CONVERT(int, total_deaths)) TotalDeaths
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalCase DESC, TotalDeaths DESC


-- This's  will shows you about likelihood percentage of dying if you contract Covid in Asia and location in Indonesia
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location LIKE '%indo%'
AND continent IS NOT NULL
ORDER BY DeathPercentage DESC


-- Looking at Total Cases vs Population 
-- This's will show you the percentage of population got Covid
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 4)) PopulationInfectPercentage
FROM PortofolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectPercentage DESC


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS --
-- Showing the death percentage in over the world by date

SELECT date, SUM(cast(new_cases as int)) total_of_new_cases, SUM(cast(new_deaths as int)) total_of_new_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100, 2) DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DeathPercentage DESC


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100, 5) PercentageVaccinations
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continents nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert Into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, CAST(ROUND((RollingPeopleVaccinated/Population)*100, 5) as float) PercentageVaccinations
FROM #PercentagePopulationVaccinated



-- Creating View to store data for  visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentagePopulationVaccinated
DROP VIEW PercentagePopulationVaccinated