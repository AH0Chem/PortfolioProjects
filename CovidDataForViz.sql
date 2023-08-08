-- Death percentage

Select location, date, total_cases, new_cases, total_deaths, population,
	(total_deaths/total_cases)*100 AS DeathPercentage
From Portfolio_Project.dbo.covid_death2
WHERE location like '%Egypt%'
Order By 1,2

-- Total Cases vs population

Select location, date, total_cases, population,
	(total_cases/population)*100 AS CasesPercentage
From Portfolio_Project.dbo.covid_death2
WHERE location like '%Egypt%'
Order By 1,2

-- Highest infection rate country

Select location, MAX(total_cases) As Highest_infection_count,
	MAX((total_cases/population)*100) AS MaxCasesPercentage
From Portfolio_Project.dbo.covid_death2
Group By Location, Population
Order By MaxCasesPercentage DESC

-- Breaking down by continent
-- Showing Highest Death Count per Population

Select
	location, Max(cast(Total_deaths As bigint)) As TotalDeathCount
From 
	Portfolio_Project.dbo.covid_death2
Where continent is null
Group by location
Order by TotalDeathCount Desc


-- Global numbers

Select SUM(new_cases) As SumNewCases, SUM(cast(new_deaths as bigint)) As SumNewDeaths,
	SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 As DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPerecentage
From Portfolio_Project..covid_death2
Where 
-- location like '%Egypt%'
	continent is not null
-- Group by date
Order by 1,2 


-- Covid Vacc

Select *
From Portfolio_Project..Covid_vacc


-- Total Population Vs Vaccination

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) As RollingVaccinated
From Portfolio_Project..covid_death2 Dea Join Portfolio_Project..Covid_vacc vac
	On dea.Location = vac.Location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (

Select
	dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVaccinated
From
	Portfolio_Project..covid_death dea Join Portfolio_Project..Covid_vacc vac
	On dea.Location = vac.Location and dea.date = vac.date
Where
	dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Views

Create View PercentPopulationVaccinated AS 
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) As RollingVaccinated
From Portfolio_Project..covid_death2 Dea Join Portfolio_Project..Covid_vacc vac
	On dea.Location = vac.Location and dea.date = vac.date
Where dea.continent is not null
