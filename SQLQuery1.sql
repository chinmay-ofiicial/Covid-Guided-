--Testing if the dataset is right

SELECT * 
FROM Guided1..CovidDeaths


-- Data we actually need

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Data for a specific country in our case Germany

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM CovidDeaths
WHERE location like 'Germany'
ORDER BY 1,2

--Now for India

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM CovidDeaths
WHERE location like 'India'
ORDER BY 1,2


--Death percentage(Deaths per Cases) in Germany
SELECT location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like 'Germany'
ORDER BY 1,2

--Death percentage(Deaths per Cases) in India
SELECT location, date, total_cases, total_deaths, (1.0*total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

--Total Infected population(Germany)
SELECT location, date, total_cases, population, (1.0*total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths
WHERE location like 'Germany'
ORDER BY 1,2

--Total Infected population(India)
SELECT location, date, total_cases, population, (1.0*total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

--Total cases in each country
SELECT location, MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalCases desc

-- Continent wise total cases
SELECT location, MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent is NULL AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalCases desc

--Countrywise total deaths
SELECT location, MAX(total_deaths) as TotalDeaths
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeaths desc

--Continent wise total deaths
SELECT location, MAX(total_deaths) as TotalDeaths
FROM CovidDeaths
WHERE continent is NULL AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeaths desc

--Numbers across the world
SELECT date,SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (1.0*SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date

--Now about vaccinations(First check the columns)

SELECT * 
FROM CovidVaccinations

--Now we will join the two tables i.e. CovidDeaths and CovidVaccinations

SELECT *
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location

--New Vaccination data

SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL 
AND dea.location like 'India'
ORDER BY 1,2

--Sum of Vaccinated people

SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 1,2

--Since we cannot use the recently created column in the same query, we will have to make a CTE(common table expression) to perform the further analysis

WITH PercentPopulationVaccinated (Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
Select *, (RollingPeopleVaccinated*1.0/Population)*100 as PercentVaccinated
From PercentPopulationVaccinated

--Creating data view

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 