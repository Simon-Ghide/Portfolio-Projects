-- Your chance of dying if you contract covid in your country
SELECT location,date, total_cases, total_deaths, population, (convert(float,total_deaths)/convert(float,total_cases))*100 as DeathPercentage
From PortfolioAddition..CovidDeaths$
--Where Location like '%states%'
--Where location is not Africa -> Syntax error near Africa??
Order by 1,2


--How many people contracted covid?
SELECT location,date, total_cases, population, (convert(float,total_cases)/convert(float,population))*100 as PopulationPercentage
From PortfolioAddition..CovidDeaths$
Order by 1,2

--Highest Infection Count per Country
SELECT location,population,Max(cast(total_cases as float)) as HighestCount, Max((convert(float,total_cases)/convert(float,population)))*100 as MaxInfection
From PortfolioAddition..CovidDeaths$
Group by location,population
Order by MaxInfection desc

--Global Numbers
SELECT date, SUM(cast(total_cases as float)) as GlobalTotalCases, SUM(cast(total_deaths as float)) GlobalTotalDeaths, SUM(cast(total_deaths as float))/SUM(cast(total_cases as float))*100 as GlobalDeathPercentage
FROM PortfolioAddition..CovidDeaths$
where continent is not null
Group by date
Order by 1,2;


--Looking at Total Population vs Vaccinations
--Use a CTE
With PopvsVac (Continent, Location,Date, Population,New_Vaccinations, RollingVaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioAddition..CovidDeaths$ dea
JOIN PortfolioAddition..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
--Order by 2,3
)

SELECT *, (RollingVaccinations/Population)*100 as PercentVaccinations
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopVacced
Create Table #PercentPopVacced
(Continent nvarchar(255), Location nvarchar(255), date datetime, population numeric,New_Vaccinations numeric, RollingVaccinations numeric)

Insert Into #PercentPopVacced
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioAddition..CovidDeaths$ dea
JOIN PortfolioAddition..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
--Order by 2,3

SELECT *, (RollingVaccinations/Population)*100 as PercentVaccinations
From #PercentPopVacced

--Creating View to store data for later visualizations
Drop View if exists PercentPopVacced
Create View PercentPopVacced as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioAddition..CovidDeaths$ dea
JOIN PortfolioAddition..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations is not null
--Order by 2,3

Create View TestView as
SELECT location,date
FROM PortfolioAddition..CovidDeaths$