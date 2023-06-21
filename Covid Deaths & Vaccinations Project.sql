--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--Order By 3,4

SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
Order By 3,4

--Select data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
Order BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%states%'
	AND continent IS NOT NULL
Order BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location LIKE '%states%'
	AND continent IS NOT NULL
Order BY 1,2

--Looking at Countries with Highest Infection rate compared to Population
SELECT location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location,  population
Order BY PercentPopInfected DESC

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
Order BY TotalDeathCount DESC

--Let's break things down by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NULL
GROUP BY location
Order BY TotalDeathCount DESC

--showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
Order BY TotalDeathCount DESC

--Global numbers
SELECT  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
Order BY 1,2

--global numbers by case
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
Order BY 1,2

--Looking at Total Population vs Vaccinations
SELECT CD.continent, CD.location, CD.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location 
ORDER BY CV.location, CV.date) AS RollingPplVaccd
FROM PortfolioProject.dbo.CovidDeaths$ AS CD
JOIN PortfolioProject.dbo.CovidVaccinations$ AS CV ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
Order BY 2,3


--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaccd)
AS
(
SELECT CD.continent, CD.location, CD.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location 
ORDER BY CV.location, CV.date) AS RollingPplVaccd
FROM PortfolioProject.dbo.CovidDeaths$ AS CD
JOIN PortfolioProject.dbo.CovidVaccinations$ AS CV ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (RollingPplVaccd/Population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopVaccd 
CREATE TABLE #PercentPopVaccd
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPplVaccd NUMERIC,
)

INSERT INTO #PercentPopVaccd
SELECT CD.continent, CD.location, CD.date, cd.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location 
ORDER BY CV.location, CV.date) AS RollingPplVaccd
FROM PortfolioProject.dbo.CovidDeaths$ AS CD
JOIN PortfolioProject.dbo.CovidVaccinations$ AS CV ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *, (RollingPplVaccd/Population)*100
FROM #PercentPopVaccd