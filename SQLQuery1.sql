select * 
from PortfolioProject..CovidDeaths
where continent is not NULL


select * 
from PortfolioProject..CovidVaccinations


--Analyze the data and select the data  that is to be used.

select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths

--totalcases vs totaldeaths
--shows the possibility of death if effected by covid
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--totalcases vs populaiton
--percentage of population who got effected by covid
select location,date,total_cases,population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
select location, population,MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected DESC

--Countries with highes death count per population
select location, MAX(cast(Total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by location
order by HighestDeathCount DESC

--For continents instead of location
select continent, MAX(cast(Total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
group by continent
order by HighestDeathCount DESC

--Global numbers
select date,SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2 

select SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 

--total population in the world vs vacciantions
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3
 

 --USE CTE
 with PopvsVac (continent,location,date,population,new_vacciantions,RollingPeopleVaccinated)
 as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
on    dea.location=vac.location
and   dea.date=vac.date
where dea.continent is not null
)
select *,( RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PopvsVac



--creating views for later vizualizations
create view  PercentPeopleVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3