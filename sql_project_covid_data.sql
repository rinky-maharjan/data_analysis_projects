SELECT *
FROM coviddeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM covidvaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM coviddeaths
ORDER BY 1,2

--total cases vs total deaths
--shows the likelihood of dying if you contract covid

SELECT location,date,total_cases,total_deaths,(convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as death_percentage
FROM coviddeaths
where  location like 'nepal'
ORDER BY 1,2

--looking at total cases for population
--shows what percentage of population got covid
SELECT location,date,total_cases,population,(convert(float,total_cases)/nullif(convert(float,population),0))*100 as percent_of_pop_infected
FROM coviddeaths
where  location like 'nepal'
ORDER BY 1,2

--highest infection rate compared to population

SELECT location,population,max(total_cases) as highest_infection_count,(convert(float,max(total_cases))/nullif(convert(float,population),0))*100 as percent_of_pop_infected
FROM coviddeaths
--where  location like 'nepal'
group by population,location
ORDER BY percent_of_pop_infected desc

--highest deaths per population

SELECT location,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
--where  location like 'nepal'
where continent is  null
group by location
ORDER BY totaldeathcount desc

--deaths by continent

SELECT location,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
--where  location like 'nepal'
where continent is null
group by location
ORDER BY totaldeathcount desc

--continents with highest death count

SELECT location,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
--where  location like 'nepal'
where continent is null
group by location
ORDER BY totaldeathcount desc

--global

SELECT sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(convert(float,new_deaths))/sum(convert(float,new_cases))*100 as death_percentage
FROM coviddeaths
where  continent is not null
ORDER BY 1,2

--looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccination
FROM coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3


--use CTE

with popvsvacc(continent,location,date,population,new_vaccinations,rolling_people_vaccination)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccination
FROM coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * ,(rolling_people_vaccination/population)*100 from popvsvacc

--temp table

drop table if exists #percentpopvacc
create table #percentpopvacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccination numeric)

insert into  #percentpopvacc
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccination
FROM coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select * ,(rolling_people_vaccination/population)*100 from #percentpopvacc

--create view to store data fro visualisation

create view percentpopvacc as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccination
FROM coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from percentpopvacc

