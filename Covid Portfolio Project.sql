SELECT *
from [Portfolio Project]..CovidDeaths
order by 3,4

--SELECT *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

Alter table dbo.CovidDeaths alter column total_deaths float;

Alter table dbo.CovidDeaths alter column total_cases float;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in Italy

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'Italy'
And continent is not null
Order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of Italian Population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location like 'Italy'
And continent is not null
Order by 1,2


-- Looking at countries with highest Infection rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
-- Where location like 'Italy'
Where continent is not null
Group by population, location
Order by PercentPopulationInfected desc


-- Showing Countries with the Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
-- Where location like 'Italy'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing Continents with the Highest Death Count per Population 

Select continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
-- Where location like 'Italy'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
-- Where location like 'Italy'
Where continent is not null
And new_cases is not null 
And new_cases <> 0
--Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

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
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

USE [Portfolio Project]
GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated