SELECT *

FROM ProtfolioProject..Covid_Deaths
ORDER BY 3,4

--SELECT * 

--FROM ProtfolioProject..Covid_Vaccines
--ORDER BY 3,4

Select 
Location,date,total_cases,new_cases,total_deaths,population
From ProtfolioProject..Covid_Deaths
Order By 1,2

-- Total Cases vs Total Deaths
Select 
Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_ratio,new_cases
From ProtfolioProject..Covid_Deaths
Where Location = 'India'
Order By 1,2

--Total Cases vs Population
Select Location, date, total_cases,population,(total_cases/population)*100 As Net_Pop
From ProtfolioProject..Covid_Deaths
Where Location like '%India%'
Order by 2

-- Highest infectioncompared to population
Select Location, population, MAX(total_cases) As Max_cases,MAX((total_cases/population))*100 As Net_Pop
From ProtfolioProject..Covid_Deaths
Group By population,Location
Order by Net_Pop desc

--Highest Death Count as Population
Select Location, MAX(cast(total_deaths as bigint)) As Max_Deaths
From ProtfolioProject..Covid_Deaths
Where continent is not null
Group By Location
Order By Max_Deaths desc

--Reproduction Rate 
Select Location, MAX(reproduction_rate) As Reproduction_rate ,Max(Cast(total_deaths as int)) As Total_deaths 
From ProtfolioProject..Covid_Deaths
Where continent is not null
Group By Location
Order By Reproduction_rate desc

--Continent Vise
Select continent, Max(Cast(total_deaths as int)) As Total_deaths
From ProtfolioProject..Covid_Deaths
Where continent is not null
Group By continent
Order by Total_deaths desc

--Continents with the highest death counts
Select continent, Max(Cast(total_deaths as int)) As Total_deaths
From ProtfolioProject..Covid_Deaths
Where continent is not null
Group By continent
Order by Total_deaths desc

--Global numbers
Select 
	date,Sum(new_cases) as new_cases_per_day, Sum(Cast(new_deaths As int))--total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_ratio
From	ProtfolioProject..Covid_Deaths
Where 
	continent is not null
Group By 
	date
Order By 1,2

--Global Death percentaage 
Select 
	Sum(new_cases) as new_cases_per_day, Sum(Cast(new_deaths As int)),(Sum(Cast(new_deaths as int))/sum(new_cases))*100 AS Death_ratio
From	ProtfolioProject..Covid_Deaths
Where 
	continent is not null
--Group By 
	--date
Order By 1,2

--Vaccine Reports
Select * 
From ProtfolioProject..Covid_Vaccines

-- Joining the two tables 
Select *
From ProtfolioProject..Covid_Deaths Dea
Join ProtfolioProject..Covid_Vaccines Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date

-- Total Vaccination vs Poplation
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations
From ProtfolioProject..Covid_Deaths Dea
Join ProtfolioProject..Covid_Vaccines Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where --Dea.location = 'India'
Dea.continent is not null
Order By 2,3

-- Rolling people vaccinated
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
Sum(Cast(Vac.new_vaccinations As bigint)) Over(Partition By Dea.location Order By Dea.location,Dea.date) As Rolling_people_vaccinated
From ProtfolioProject..Covid_Deaths Dea
Join ProtfolioProject..Covid_Vaccines Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
Order By 2,3

--CTE
With Popvac (Continent,location,date,population,new_vaccines,Rolling_people_vaccinated)
As
(
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
Sum(Cast(Vac.new_vaccinations As bigint)) Over(Partition By Dea.location Order By Dea.location,Dea.date) As Rolling_people_vaccinated
From ProtfolioProject..Covid_Deaths Dea
Join ProtfolioProject..Covid_Vaccines Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null

)
Select * , (Rolling_people_vaccinated/population)*100 as Vaccine_percentage
From Popvac
Order By 2,3

-- Temp Table
Drop Table if exists #percentpopulation
Create table #percentpopulation
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccines float,
Rolling_people_vaccinated float
)
Insert into #percentpopulation
Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
Sum(Cast(Vac.new_vaccinations As bigint)) Over(Partition By Dea.location Order By Dea.location,Dea.date) As Rolling_people_vaccinated
From ProtfolioProject..Covid_Deaths Dea
Join ProtfolioProject..Covid_Vaccines Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where Dea.continent is not null
Select * , (Rolling_people_vaccinated/population)*100 as Vaccine_percentage
From #percentpopulation
Order By 2,3

-- Creating View
--use ProtfolioProject
--GO
--Create View percentagepopulation as
--Select Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
--Sum(Cast(Vac.new_vaccinations As bigint)) Over(Partition By Dea.location Order By Dea.location,Dea.date) As Rolling_people_vaccinated
--From ProtfolioProject..Covid_Deaths Dea
--Join ProtfolioProject..Covid_Vaccines Vac
--	On Dea.location = Vac.location
--	And Dea.date = Vac.date
--Where Dea.continent is not null

Select * 
From dbo.percentagepopulation
