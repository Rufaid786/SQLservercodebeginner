select * from Portfolioproject..CovidDeaths

--select * from Portfolioproject..CovidVaccinations

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Total cases v/s Total_deaths
--Death percentage
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as 'Death Percentage'
from CovidDeaths
where location like '%states%'
order by location,date

--Total cases v/s population 
--what percentage of population is affected by covid

select location,date,total_cases,population,(total_cases/population)*100 as 'Total Affceted Percentage'
from CovidDeaths
where location like '%states%'
order by location,date

--Highest infected country in a single day
select location,date,population,total_cases from CovidDeaths where total_cases=(select max(total_cases) from CovidDeaths)

--Highest
select distinct(location),population,MAX(total_cases) over(partition by location)
as 'Highest infected count',max((total_cases/population)*100) over(partition by location) as 'Highest infection percent count'
from CovidDeaths
order by 'Highest infection percent count' desc

--countries that are not infected
select distinct(location) from CovidDeaths where total_cases IS NULL



--showing countries with highest death count per population
select distinct(location),population,MAX(cast(total_deaths as int)) over(partition by location)
as TotalDeathCount
from CovidDeaths
where continent is not null
order by TotalDeathCount desc

drop table if exists #temp3
create table #temp3 (continent varchar(50),TotalDeath int)
insert into #temp3
select 
case
when continent='North America' then 'North America'
when continent='Asia' then 'Asia'
when continent='Africa' then 'Africa'
when continent='Oceania' then 'Oceania'
when continent='South America' then 'South America'
when continent='Europe' then 'Europe'
when location='North America' then 'North America'
when location='Asia' then 'Asia'
when location='Africa' then 'Africa'
when location='Oceania' then 'Oceania'
when location='South America' then 'South America'
when location='Europe' then 'Europe'			
end as
'continent',max(cast(total_deaths as int)) 'TotalDeath'
from CovidDeaths

group by continent,location
having max(cast(total_deaths as int)) is not null and continent is not null

select * from #temp3
select distinct(continent),sum(TotalDeath) over(partition by continent) as 'Continent Death Rate'
from #temp3


--world death percentage
select sum(new_cases) as Totalcases,sum(cast(new_deaths as int)) as TotalDeath,(sum(cast(new_deaths as int))/sum(new_cases))*100 Deathpercentage
from CovidDeaths where continent is not null

select location,population,TotalVaccination
from

with CTE_temp (location,population,Totalvaccinated)
as 
(
select distinct(dea.location),dea.population,sum(convert(int,cov.new_vaccinations)) over(partition by dea.location) as 'Total Vaccination'
from CovidDeaths as dea
join CovidVaccinations as cov on 
dea.location=cov.location and dea.date=cov.date
where dea.continent is not null
)

drop table if exists #temp
create table #temp(location varchar(50),population numeric,Totalvaccinated numeric)
insert into #temp
select distinct(dea.location),dea.population,sum(convert(int,cov.new_vaccinations)) over(partition by dea.location) as 'Total Vaccination'
from CovidDeaths as dea
join CovidVaccinations as cov on 
dea.location=cov.location and dea.date=cov.date
where dea.continent is not null
select * from #temp

select location,population,Totalvaccinated ,(Totalvaccinated/population)*100 'Vaccination Percentage' 
from #temp
where Totalvaccinated is not null and (Totalvaccinated/population)*100 <100
order by (Totalvaccinated/population)*100 desc


--creating views in order to use in tableu later
create view my_view as 
select distinct(dea.location),dea.population,sum(convert(int,cov.new_vaccinations)) over(partition by dea.location) as 'Total Vaccination'
from CovidDeaths as dea
join CovidVaccinations as cov on 
dea.location=cov.location and dea.date=cov.date
where dea.continent is not null
