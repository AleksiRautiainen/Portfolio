-- General look at the dataset
SELECT *
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Chance of dying from Covid after contracting it in the Nordic Countries daily
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location IN ('Finland','Sweden','Norway','Iceland','Denmark')
AND continent is not null
ORDER BY 1,2 -- order by columns 1 and 2

-- Percentage of population that has contracted Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM CovidProject..CovidDeaths
WHERE location IN ('Finland','Sweden','Norway','Iceland','Denmark')
AND continent is not null
AND total_cases is not null
ORDER BY 1,2

-- Which Nordic Country has the highest infection percentage
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM CovidProject..CovidDeaths
WHERE location IN ('Finland','Sweden','Norway','Iceland','Denmark')
GROUP BY Location, population
ORDER BY CasePercentage DESC

-- Highest death count
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE location IN ('Finland','Sweden','Norway','Iceland','Denmark')
AND continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- GLOBAL --


-- Sum of total cases, total deaths and global death percentage
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS INT)) as TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 -- order by columns 1 and 2


-- USING SECOND TABLE WITH VACCINATION DATA

--
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(CONVERT(BIGINT, vac.new_vaccinations_smoothed)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location IN ('Finland','Sweden','Norway','Iceland','Denmark')
AND dea.continent is not null
ORDER BY 2,3

-- New temp table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations_smoothed numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(CONVERT(BIGINT, vac.new_vaccinations_smoothed)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location IN ('Finland','Sweden','Norway','Iceland','Denmark')
AND dea.continent is not null
ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated