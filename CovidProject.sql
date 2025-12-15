select * from CovidProject..CovidDeaths
select * from CovidProject..CovidVaccinations 


-- data used for time being
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null


-- Indicate the likelihood of death following a COVID-19 infection within India’s population
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%India%'
and continent is not null 
order by date


-- Calculate the percentage of the total population that has been infected with COVID-19
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
order by date


--Identify the countries with the highest COVID-19 infection rates relative to their total populations
Select Location, Population, MAX(total_cases) as InfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


--Top 5 countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--Identify which continents have the highest COVID-19 death counts relative to their total populations
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Generate a global overview showing cumulative cases, cumulative deaths, and the overall mortality percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalMoralityPercentage
From CovidProject..CovidDeaths
where continent is not null


--Provide an overview of the population coverage for atleast one dosage of COVID-19 vaccinations.
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by location, date


--Generate an overview of population coverage for at least one dose of COVID-19 vaccinations, including the percentage of vaccinations relative to each population, and structure the query using a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Create temporary table to perform calculations on Partition By from the previous query
--(drop if table name already exists/created) DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create a view to store the given data for later analysis/visualizations.
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
 

-- to choose the table for data
-- Select * from PercentPopulationVaccinated (which is created as a view)