SELECT *
FROM portfolioproject.portfolio.coviddeaths
ORDER BY 3,4

--SELECT *
--FROM portfolioproject.portfolio.covidvaccination
--ORDER BY 3,4

SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 
AS deathpercentage
FROM portfolioproject.portfolio.coviddeaths
WHERE location = 'Nigeria' AND date BETWEEN '2021-01-01' AND '2021-12-31'
ORDER BY 1,2

SELECT location, MAX(total_cases) as HighestInfectionCount
FROM portfolioproject.portfolio.coviddeaths
WHERE continent = 'Africa' AND date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY location
ORDER BY HighestInfectionCount DESC

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM portfolioproject.portfolio.coviddeaths
--WHERE continent = 'Africa' AND date BETWEEN '2021-01-01' AND '2021-12-31'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM portfolioproject.portfolio.coviddeaths
WHERE continent = 'Africa' AND date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, total_deaths
FROM portfolioproject.portfolio.coviddeaths
WHERE continent = 'Africa' AND location = 'Saint Helena' AND date BETWEEN '2021-01-01' AND '2021-12-31'
-- Saint Helena had null values as the totaldeaths in coviddeaths data

-- GLOBAL NUMBERS
SELECT continent, SUM(CAST(total_deaths AS BIGINT)) AS TotalDeaths, SUM(CAST(total_cases AS BIGINT)) AS TotalCases
FROM portfolioproject.portfolio.coviddeaths
--WHERE continent = 'Africa' AND date BETWEEN '2021-01-01' AND '2021-12-31'
WHERE continent IS NOT NULL AND date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY continent

--JOINING THE TWO TABLES
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
AS RollingPeopleVaccinated
FROM portfolioproject.portfolio.coviddeaths AS dea
JOIN portfolioproject.portfolio.covidvaccination AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent = 'Africa' AND dea.date BETWEEN '2021-01-01' AND '2021-12-31'
ORDER BY 2, 3

-- USING CTE
WITH Popvsvac (location, population, new_vaccination, RollingPeopleVaccinated) AS (SELECT dea.location, vac.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
AS RollingPeopleVaccinated
FROM portfolioproject.portfolio.coviddeaths AS dea
JOIN portfolioproject.portfolio.covidvaccination AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent = 'Africa')
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM Popvsvac

-- USING A TEMP TABLE
DROP TABLE IF EXISTS #PerPopulation
CREATE TABLE #PerPopulation
(
location NVARCHAR(255),
population NUMERIC,
new_vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PerPopulation
SELECT dea.location, vac.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location)
AS RollingPeopleVaccinated
FROM portfolioproject.portfolio.coviddeaths AS dea
JOIN portfolioproject.portfolio.covidvaccination AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent = 'Africa'
SELECT * 
FROM #PerPopulation


