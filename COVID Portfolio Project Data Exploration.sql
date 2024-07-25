Select *
From Portfolioproject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From Portfolioproject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths 
-- Also looking at the United States as it personally relates to me

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population 
-- Also looking at the United States as it personally relates to me
-- Shows what percentage of populationgot Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
--Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population 
--Taking (nvarchar from total_deaths column) and converting it to an int

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Going to break it down by Continent 

--Showing continents with highest death count by population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent 
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 asDeathPercentage
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


--Total Numbers Global 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 asDeathPercentage
From Portfolioproject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Using Cast & Convert with a regular "int" ran me into an error. Took some research but
-- I found using "bigint" executed the query perfectly


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Looking at Total Population vs Vaccinations
-- In the below script, instead of using "Cast", I'll be using "CONVERT"
-- Using Cast & Convert with a regular "int" ran me into an error. Took some research but
-- I found using "bigint" executed the query perfectly

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE(Common Table Expression)

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
