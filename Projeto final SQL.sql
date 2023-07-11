
-- Exploração de dados SQL de impacto da COVID-19 no mundo.
\* A pandemia do COVID-19 teve um grande impacto no mundo, e os dados são essenciais para entender sua disseminação e impacto. 
O banco de dados relacional SQLITE  é um poderoso sistema de gerenciamento de banco de dados que pode ser usado para armazenar 
e analisar grandes quantidades de dados. 
Exploraremos como usar o SQLITE para explorar um conjunto de dados COVID-19.

Primeiro, dois conjuntos de dados em Excel separados entre as de vacinação e as de óbitos. Esses dois arquivos 
foram importados para o servidor DBeaver e manipulado pelo SQLIYE e o conjunto de dados foi explorado usando as seguintes consultas:
*\

-- Faça uma tabela com uma coluna de total de casos.

SELECT SUM(total_cases) as total_casos_mundo, sum(new_cases) as total_novos_casos_mundo, SUM(new_cases_smoothed) as novos_casos_suavizados_mundo 
FROM CovidDeaths cd 


-- Faça uma tabela com total de mortes por país.

select location , SUM(total_deaths)  +  SUM(new_deaths) total_mortes
from CovidDeaths cd  
group by location 


--- Faça uma tabela com uma coluna de total de casos  e outra com total população por país.

SELECT location , SUM(population ) as total_populacao,  SUM(total_cases) as total_casos
FROM 	CovidDeaths cd 
group by location 


---  Mostre a probabilidade de morrer se contrair covid em cada país.

SELECT location , date , SUM(cast(total_deaths as float)) as total_mortes, SUM(cast(total_cases as float)) as total_casos, 
SUM(cast(total_deaths as float))/SUM(cast(total_cases as float))*100 as possibilidade_porcentagem
FROM CovidDeaths cd 
group by location 
order by possibilidade_porcentagem DESC


---  Quais são os países com maior taxa de morte? 

Select location, MAX(cast(total_deaths as int)) as contagem_mortes
From CovidDeaths cd 
Where continent is not null
Group by location
Order by contagem_mortes desc


---  Quais são os países com maior taxa de infecção? 

Select location, population, MAX(CAST(total_cases as int)) as contagem_infeccao
From CovidDeaths cd 
Group by location, population
Order by contagem_infeccao desc

---  Mostre os continentes com a maior taxa de morte.

SELECT location , MAX(CAST(total_deaths AS INT)) AS total_mortes 
from CovidDeaths cd
WHERE continent is not null 
group by location 
order by total_mortes DESC 


\* Reparei que os resultados estavam calculando números errados um exemplo a america no norte não estava 
adicionando números do canadá, reparei que os resultados estavam a apresentar várias categorias ao invés 
dos continentes.
Ex: A união europeia faz parte da europa e os rendimentos são locais, a consulta corrifida ficou assim:
*\

SELECT location , SUM(cast(new_deaths as int)) as contagem_mortes  
FROM CovidDeaths cd 
where continent is not null
and location not like '%income%'
and location not in ('World', 'European Union', 'Internacional')
GROUP by location 
ORDER by contagem_mortes DESC 


--  Mostre a probabilidade de se infectar com Covid por país.


SELECT location , date , SUM(cast(total_cases as float)) as total_casos, SUM(cast(population as float)) as total_populacao,
SUM(cast(total_cases as float))/SUM(cast(population as float))*100 as possibilidade_porcentagem
FROM CovidDeaths cd
group by location 
order by possibilidade_porcentagem desc

--  População Total vs Vacinações: mostre a porcentagem da população que recebeu pelo menos uma vacina contra a Covid.

select cd.location , SUM(cast(cv.new_vaccinations as float)) as total_novas_vacinas, SUM(cast(cd.population as float)) as total_populacao,
SUM(cast( cv.new_vaccinations as float))/SUM(cast(cd.population as float))*100 as pessoas_vacinadas
FROM CovidDeaths cd 
left join CovidVaccinations cv on
cd.location = cv.location 
and cd.date = cv.date 
WHERE cd.continent is not null
and cd.location not like '%income%'
and cd.location not in ('World', 'European Union', 'Internacional')
GROUP by cd.location  
ORDER by pessoas_vacinadas DESC


--  Crie uma view para armazenar dados para visualizações posteriores.

create view percentual_pessoas_vacinadas as
select cd.location , SUM(cast(cv.new_vaccinations as float)) as total_novas_vacinas, SUM(cast(cd.population as float)) as total_populacao,
SUM(cast( cv.new_vaccinations as float))/SUM(cast(cd.population as float))*100 as pessoas_vacinadas
FROM CovidDeaths cd 
left join CovidVaccinations cv on
cd.location = cv.location 
and cd.date = cv.date 
WHERE cd.continent is not null
and cd.location not like '%income%'
and cd.location not in ('World', 'European Union', 'Internacional')
GROUP by cd.location  
ORDER by pessoas_vacinadas DESC

SELECT *
FROM percentual_pessoas_vacinadas


Create View porcentagem_morte_data as
Select location , date, SUM(CAST(new_cases as float))as total_casos, SUM(cast(new_deaths as float)) as total_mortes, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as morte_percentual
From CovidDeaths cd 
where continent is not null and new_cases <> 0 and new_deaths <> 0
Group by location 
Order by 1,2

SELECT *
FROM porcentagem_morte_data


\*Estes são apenas alguns exemplos das muitas consultas que podemos usar para explorar o conjunto de dados COVID-19. 
  Ao usar o SQLITE, podemos obter informações valiosas sobre a pandemia e rastrear sua propagação e impacto.
\*







