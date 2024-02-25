Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, Date, Total_cases, New_cases, Total_deaths, Population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%romania%'
Order by 1,2

--Looking at Total cases vs Population
--What % of population got Covid

Select Location, Date, population, Total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%romania%'
Order by 1,2

--Looking at countries with Highest infection rate compared to population

Select Location, population, MAX(Total_cases) As HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%romania%'
Group by Location, population
Order by PercentPopulationInfected desc

--The countries with the highest deathcount per population

Select Location, MAX(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%romania%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--break things down by continent


--showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%romania%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--global numbers

Select Date, SUM(New_cases) AS TOTAL_CASES, SUM(cast(New_deaths as int)) AS TOTAL_DEATHS, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%romania%'
Where continent is not null
Group by date
Order by 1,2

--=>

Select SUM(New_cases) AS TOTAL_CASES, SUM(cast(New_deaths as int)) AS TOTAL_DEATHS, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%romania%'
Where continent is not null
--Group by date
Order by 1,2



--Total population vs vaccination
--cast (... ) as int / convert (int, ...)


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

	--, (RollingPeopleVaccinated/population)*100 --=> CTE

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--=> 1.use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--=> 1.use TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated -- FOR MULTIPLE ALTERATIONS --Where dea.continent is not null

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create view to store data for later visualisation

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

