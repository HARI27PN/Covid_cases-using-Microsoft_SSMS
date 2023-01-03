Select *
From PortfolioProject..Covid_Deaths$
where continent is not null
order by 3,4


--Select *
--From PortfolioProject..Covid_Vaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths$
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths$
Where location like '%india%'
and continent is not null
order by 1,2

--Looking at total cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases,population, (total_cases/population)*100 as per_whogotcovid
From PortfolioProject..Covid_Deaths$
where location like '%states%'
order by 1,2


--Looking at countries at highest Infection rate compared to population
Select Location, MAX(total_cases) as HighestInfectioncount, population, Max(total_cases/population)*100 as PercentPopInfected
From PortfolioProject..Covid_Deaths$
where continent is not null
Group by location,population
order by PercentPopInfected desc

--Showing countries with highest death count
Select location, Max(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..Covid_Deaths$
where continent is not null
group by location
order by Total_Deaths_Count desc
--but there are slight isuues in data
--added where continent is not null to remove unwanted values in data such as Asia,Europe,Africa,Low income countries, Middle income countries

--Lets Break Things down by Continent
-- Showing continents with highest death count
Select continent, Max(cast(total_deaths as int)) as Total_Deaths_Count
From PortfolioProject..Covid_Deaths$
where continent is not null
group by continent
order by Total_Deaths_Count desc


--GLOBAL(WORLD) NUMBERS
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths$
--Where location like '%india%'
where continent is not null
group by date
order by 1,2
--removing date from select and grouping will give total cases and total death and deathpercentage

--COVID VACCINATIONS 

--Joining two excels on basis of location in one table (right side)
--dea and vac are aliases for deaths and vaccinations
Select *
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- This will show red line as u cant use column you created in next one so you have to create a cte or temp table
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE
With PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated	
-- The number of columns in With should be same as in Select otherwise it would show up an error
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100 as percentofPopulationVaccinated
From PopvsVac

--Use TEMP TABLE
DROP table if exists #percentofPopVacc
Create Table #percentofPopVacc
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentofPopVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated	
-- The number of columns in With should be same as in Select otherwise it would show up an error
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100 as percentofPopulationVaccinated
From #percentofPopVacc


--Creating view to store data for later visualization

Create view PPV as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated	
-- The number of columns in With should be same as in Select otherwise it would show up an error
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PPV 
