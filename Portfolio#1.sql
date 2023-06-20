select *
from portfolioproject..CovidDeaths
order by 3,4
--select *
--from portfolioproject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths
from portfolioproject..CovidDeaths


--total cases vs total deaths

select location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as death_percentage
from portfolioproject..CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolioproject..CovidDeaths
where location like '%saudi%'
order by location,date

select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
where location like '%india%'
order by location,date

--Countries with Highest Infection Rate compared to Population

select location,population,Max(total_cases) as highestinfectionrate,max((total_cases/population)*100) as PercentPopulationInfected
from portfolioproject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

select location,Max(cast(total_deaths as int)) as highestdeathcount
from portfolioproject..CovidDeaths
group by location
order by highestdeathcount desc

--Countries with Highest Death Count per continent

select continent,Max(cast(total_deaths as int)) as highestdeathcount
from portfolioproject..CovidDeaths
where continent is not null
group by continent
order by highestdeathcount desc

--global cases 

select date,sum(new_cases) as totalnewcases,sum(cast(new_deaths as int)) as totalnewdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as totaldeathpercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by totaldeathpercentage asc

select date,sum(total_cases) as totalcases,sum(cast(total_deaths as int)) as totaldeaths,sum(cast(total_deaths as int))/sum(total_cases)*100 as totaldeathpercentage
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by totaldeathpercentage asc

--total population vs vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null
order by 2,3


--partition by

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over( 
Partition by dea.location,dea.date) as totalvaccinated
--(totalvaccinated/dea.population)*100 as totalvaccinatedrate
From portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
on dea.date = vac.date and
dea.location = vac.location
where dea.continent is not null
order by 2,3

--using CTE

with popvsvac(continent,location,date,population,new_vaccinations,totalvaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (totalvaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null )
--order by 2,3

select*,(totalvaccinated/population)*100
from popvsvac


--temp table

drop table if exists #totalvaccinatedrate
create table #totalvaccinatedrate
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
totalvaccinated numeric
)

insert into #totalvaccinatedrate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (totalvaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null )
--order by 2,3

select *,(totalvaccinated/population)*100
from #totalvaccinatedrate

--creating view

create view totalvaccinatedrate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as totalvaccinated
--, (totalvaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

