-- Select data 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM project..CovidDeaths
Where continent is not null
order by 1,2




--looking at total cases and total death
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Death_Percentage
FROM project..CovidDeaths
Where continent is not null
and location like '%Vietnam%'
order by 1,2


--looking at total cases vs population
--shows the percentage of the population is infected 
SELECT Location, date, total_cases, population, (total_cases / population)*100 as infected_Percentage
FROM project..CovidDeaths
Where location like '%Vietnam%'
order by 1,2

--looking at countries with the highest infection rates compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases / population)*100) as percent_population_infected
FROM project..CovidDeaths
--Where location like '%Vietnam%'
Where continent is not null
Group by location, population
order by percent_population_infected desc

--looking at countries with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM project..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Break things into continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
SELECT date, SUM(new_cases) as global_new_cases, Sum(cast(new_deaths as int)) as global_new_death,
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercetage 
FROM project..CovidDeaths
where continent is not null
Group by date
order by 1,2

--looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

With popvsvac (continent, location, date, population, new_vaccination, RollingpeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
FROM popvsvac

--Temp table
Drop table if EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingpeopleVaccination numeric
)




Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--Creating views for data visualizations
Create View popvsvacv1 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null