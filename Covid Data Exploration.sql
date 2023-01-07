select * 
from Covid_Analysis..Covid_deaths
where continent is not null
order by 3,4

--selecting data to be used
select location, date, total_cases, new_cases, total_deaths, population
from Covid_Analysis..Covid_deaths
where continent is not null
order by 1, 2

--total cases vs total deaths
--likelihood of death by country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from Covid_Analysis..Covid_deaths
where continent is not null
order by 1,2 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from Covid_Analysis..Covid_deaths
where location like '%states%'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Death
from Covid_Analysis..Covid_deaths
where location like 'Nigeria'
order by 1,2

--total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as Percetage_population
from Covid_Analysis..Covid_deaths
where location like 'Nigeria'
order by 1,2

--countries with highest infection rate compared to population
select location, population, MAX(total_cases) as Highest_Infection, MAX((total_cases/population)*100) as Percentage_population_infected
from Covid_Analysis..Covid_deaths
where continent is not null
group by location, population
order by Percentage_population_infected desc

--to filter for country; hence statement 'where continent is not null'
--cast (column as int) to change dataset in query


--countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as Total_death_count
from Covid_Analysis..Covid_deaths
where continent is not null
group by location
order by Total_death_count desc

--continent with highest death count per population
select location, MAX(cast(total_deaths as int)) as Total_death_count
from Covid_Analysis..Covid_deaths
where continent is null
group by location
order by Total_death_count desc

--OR

select continent, MAX(cast(total_deaths as int)) as Total_death_count
from Covid_Analysis..Covid_deaths
where continent is not null
group by continent
order by Total_death_count desc


--global figures
select date, SUM(new_cases) as cases_per_day_global, SUM(cast(new_deaths as int)) as deaths_per_day
from Covid_Analysis..Covid_deaths
where continent is not null
group by date
order by 2 desc

select  SUM(new_cases) as cases_per_day_global, 
SUM(cast(new_deaths as int)) as deaths_per_day, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as perc_death_per_day
from Covid_Analysis..Covid_deaths
where continent is not null
order by 3 



--joining both tables
select * 
from Covid_Analysis..Covid_deaths dea
join Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid_Analysis..Covid_deaths dea
join Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CONVERT(data_type, column) is alternative to cast(column, data_type)

--rolling count of people vaccinated
select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCt_Vac
from Covid_Analysis..Covid_deaths dea
join Covid_Analysis..Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte
With Pop_vs_Vac (continent, location, date, population, new_vaccination, RollingCt_Vac)
as
(
select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCt_Vac
from Covid_Analysis..Covid_deaths dea
join Covid_Analysis..Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 because ORDER BY clause cannot be used in cte/temptables/views
)
Select *, (RollingCt_Vac/population)*100 as perc_rollingct_vac
from Pop_vs_Vac

--using temptable
Create Table #Perc_Popu_Vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCt_Vac numeric
)

Insert into #Perc_Popu_Vac
select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCt_Vac
from Covid_Analysis..Covid_deaths dea
join Covid_Analysis..Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingCt_Vac/population)*100 
from #Perc_Popu_Vac


--in case of a need to do something else with same temp table
DROP Table if exists #Perc_Popu_Vac
Create Table #Perc_Popu_Vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCt_Vac numeric
)

Insert into #Perc_Popu_Vac
select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCt_Vac
from Covid_Analysis..Covid_deaths dea
join Covid_Analysis..Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

Select *, (RollingCt_Vac/population)*100 
from #Perc_Popu_Vac


--creating view to store data

Create View percentpopvac as
select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCt_Vac
from Covid_Analysis..Covid_deaths dea
join Covid_Analysis..Covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * 
from percentpopvac