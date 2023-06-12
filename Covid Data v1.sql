select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ['covid deaths-data']
where location like '%state%'
order by location

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ['covid deaths-data']
where location like 'vietnam'

select location, date, population, total_cases, (total_cases/population)*100 as Percentage
from ['covid deaths-data']
--where location like '%state%'
order by 1,2


--looking at countries with highest infection rate compared to population
select location, population, Max((total_cases/population)*100) as HighestRate
from ['covid deaths-data']
--where location like '%state%'
group by location, population
order by HighestRate desc


-- showing COuntries with highest death count per population
select location, Max(total_deaths) as DeathCount
from ['covid deaths-data']
where continent is not null
group by location 
order by DeathCount desc

--let's breaking thing down by continent
select location, Max(total_deaths) as DeathCount
from ['covid deaths-data']
where continent is null
group by location
order by DeathCount desc

select continent, Max(total_deaths) as DeathCount
from ['covid deaths-data']
where continent is not null
group by continent
order by DeathCount desc

--global numbers per day
set arithabort off
set ansi_warnings off 

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Percentage
from ['covid deaths-data']
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as Percentage
from ['covid deaths-data']
where continent is not null
--group by date
order by 1,2


select*
from ['covid vaccinations-data$']

--total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingNew_Vaccinations
from ['covid deaths-data'] as Dea
join ['covid vaccinations-data$'] as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
order by 2,3


--use CTE

WITH CTE_PopVsVac (continent, location, date, population, new_vaccinations, RollingNew_Vaccinations) AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingNew_Vaccinations
from ['covid deaths-data'] as Dea
join ['covid vaccinations-data$'] as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
)

SELECT *, RollingNew_Vaccinations/population*100 as PercentageofVaccinations
FROM CTE_PopVsVac;


--temp table

drop table if exists #percentagePopulationVaccinated
create table #percentagePopulationVaccinated
( continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population float,
new_vaccinations float, 
RollingNew_Vaccinations float)

insert into #percentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingNew_Vaccinations
from ['covid deaths-data'] as Dea
join ['covid vaccinations-data$'] as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null

SELECT *
FROM #percentagePopulationVaccinated

--creating view to store date for visualising later

create view TotalNew_Vaccinations AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingNew_Vaccinations
from ['covid deaths-data'] as Dea
join ['covid vaccinations-data$'] as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null

select*
from TotalNew_Vaccinations