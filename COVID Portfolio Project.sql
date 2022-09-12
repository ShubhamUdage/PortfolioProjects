select *
from [Portfolio Project]..CovidDeaths2022
where continent is not null
order by 3, 4

select * 
from [Portfolio Project]..CovidVaccinations2022
where continent is not null
order by 3, 4

select location, date, total_cases,new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths2022
where continent is not null
order by 1,2

-- Total Deaths VS Total Cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Percentage
from [Portfolio Project]..CovidDeaths2022
where location like '%India%' and continent is not null
order by 1,2

-- Total cases VS Population
select location, date, population, total_cases, (total_cases/population) * 100 as Covid_Population
from [Portfolio Project]..CovidDeaths2022
where location like '%India%' and continent is not null
order by 1,2

-- Countries with max covid rates
select location, population, MAX(total_cases) as HighestCovidCount, MAX((total_cases/population)) * 100 as 
Covid_Population
from [Portfolio Project]..CovidDeaths2022
-- where location = 'India'
where continent is not null
group by location, population
order by Covid_Population desc


-- Countries with Highest Death Count
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths2022
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents with highest Death Counts
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths2022
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeathCount, 
sum(cast(new_deaths as int))/ sum(new_cases) * 100 as Death_Percentage
from [Portfolio Project]..CovidDeaths2022
where continent is not null
order by 1,2


-- Total population Vs Total Vaccination
-- Use CTE

with PopvsVac (Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.location, D.Date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2022 D
Join [Portfolio Project]..CovidVaccinations2022 V
	On D.location = V.location 
	and D.date = V.date
where D.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population bigint,
New_vaccination bigint,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.location, D.Date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2022 D
Join [Portfolio Project]..CovidVaccinations2022 V
	On D.location = V.location 
	and D.date = V.date
where D.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for visualization

Create View PercentPopulationVaccinated as 
select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as bigint)) OVER (Partition by D.location Order by D.location, D.Date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths2022 D
Join [Portfolio Project]..CovidVaccinations2022 V
	On D.location = V.location 
	and D.date = V.date
where D.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated