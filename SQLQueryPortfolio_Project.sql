SELECT *
FROM Portfolio_Project..CovidDeaths
order by 3,4


SELECT *
FROM Portfolio_Project..CovidVaccinations
order by 3,4



SELECT location, date, total_cases, total_deaths
FROM Portfolio_Project..CovidDeaths
order by 1,2

--Looking at Total Case and Total Deaths

SELECT location, date, total_cases, total_deaths,
CAST(total_deaths AS int) / total_cases * 100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
order by 1,2


SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2        


SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2



--Looking at Countrties with Highest Inflation Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100
As PercentPopulationInfected
From Portfolio_Project..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population 

SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Group by location
order by TotalDeathCount desc


SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Group by location
order by TotalDeathCount desc



SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Showing continentes with the highest death count per population 

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) 
AS total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null 
Group By date
order by 1,2 


SELECT*
FROM Portfolio_Project..CovidVaccinations

--Looking at Total Population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3



Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
