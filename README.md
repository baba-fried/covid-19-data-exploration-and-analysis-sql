# COVID-19 Data Analysis Using SQL

## Project Overview

This project performs an in-depth **exploratory data analysis (EDA)** on global COVID-19 data using **SQL**. The analysis focuses on understanding infection trends, mortality rates, and vaccination coverage across countries and continents. By leveraging advanced SQL techniques such as **CTEs, window functions, views, and temporary tables**, the project transforms raw pandemic data into meaningful insights that can support data-driven decision-making.

---

## Objectives

* Analyze COVID-19 **cases, deaths, and population impact** over time
* Calculate **infection rates** and **mortality percentages** at country and global levels
* Identify countries and continents with the **highest infection and death counts**
* Evaluate **vaccination progress** and population coverage
* Demonstrate strong SQL querying and analytical skills

---

## Dataset

The raw COVID-19 dataset was obtained from [Our World in Data](https://ourworldindata.org) and preprocessed to create two analytical tables— 
* [**CovidDeaths**](Datasets/CovidDeaths.xlsx) – contains data on cases, deaths, population, location, and dates
* [**CovidVaccinations**](Datasets/CovidVaccinations.xlsx) – contains vaccination data by location and date

contains only the fields necessary for exploratory data analysis, mortality assessment, and vaccination trend evaluation.

---

## Tools & Technologies

* **SQL Server**
* **SQL** - Joins, Aggregations, CTEs, Window Functions
* **Views & Temporary Tables**

---

## Key Analyses Performed

### 1. Data Exploration

* Retrieved and filtered relevant COVID-19 case and vaccination data
* Selected key columns such as location, date, total cases, deaths, and population

### 2. Mortality Analysis

* Calculated **death percentage** for COVID-19 infections (case fatality rate)
* Focused analysis on **India** to assess likelihood of death after infection
```sql
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%India%'
and continent is not null 
order by date
```
### 3. Infection Rate Analysis

* Computed the **percentage of population infected** by country
* Identified countries with the **highest infection rates relative to population**
```sql
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
order by date
-------------------------------------------------------------------------------------------------------------------------------------
Select Location, Population, MAX(total_cases) as InfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc
```
### 4. Death Count Analysis

* Ranked countries by **total death count**
* Aggregated death counts by **continent** to identify the most affected regions
```sql
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc
----------------------------------------------------------------------
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc
```
### 5. Global Impact Summary

* Generated a **global overview** of cumulative cases, deaths, and overall mortality percentage
```sql
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalMoralityPercentage
From CovidProject..CovidDeaths
where continent is not null
```
### 6. Vaccination Analysis

* Joined death and vaccination datasets to analyze rollout progress
* Calculated **rolling vaccination totals** using window functions
* Determined **vaccination coverage as a percentage of population**
```sql
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by location, date
```
### 7. Advanced SQL Techniques

* Used **CTEs** to structure complex vaccination analysis queries
* Created **temporary tables** for intermediate calculations
* Built a **SQL view** for reusable vaccination analytics and future visualizations
```sql
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
--------------------------------------------------------------------------------------------------------------------------------------------
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
-----------------------------------------------------------------------------------------------------------------------------------------------
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
-----------------------------------------------------------------------------------------------------------------------------------------------
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
```
---

## Insights

* Countries with higher populations do not always have higher infection rates
* Significant variation exists in mortality percentages across regions
* Vaccination rollout trends vary widely by country and continent
* Window functions enable clear tracking of cumulative vaccination progress over time

---

## Skills Demonstrated

* Data cleaning and filtering
* Exploratory data analysis (EDA)
* Analytical thinking and problem solving
* Writing optimized and readable SQL queries
* Using CTEs, window functions, views, and temp tables effectively

---

## Future Enhancements

* Visualize insights using **Power BI or Tableau**
* Automate data ingestion and refresh pipelines
* Extend analysis to include **time-series forecasting** or **trend prediction**
