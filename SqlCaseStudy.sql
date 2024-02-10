--SQL Advance Case Study


-- List all the states in which we have customers who have bought cellphones from 2005 till today. 
	
	select distinct [State] from FACT_TRANSACTIONS t
	join DIM_LOCATION l
	on t.IDLocation = l.IDLocation
	where year(date) >= '2005'


--What state in the US is buying the most 'Samsung' cell phones?

	select top 1 [State], count(t.IDCustomer) as [count] from FACT_TRANSACTIONS t
	join DIM_LOCATION l
	on t.IDLocation = l.IDLocation
	join DIM_MODEL m
	on t.IDModel = m.IDModel
	join DIM_MANUFACTURER mm
	on m.IDManufacturer = mm.IDManufacturer
	where mm.Manufacturer_Name = 'Samsung' and Country = 'US'
	group by [State]
	order by count(idcustomer) desc


--Show the number of transactions for each model per zip code per state.    
	
	select m.Model_Name, [State], ZipCode, count(t.idmodel) as [count] from FACT_TRANSACTIONS t
	join DIM_LOCATION l 
	on t.IDLocation = l.IDLocation
	join DIM_MODEL m
	on m.IDModel = t.IDModel
	group by m.Model_Name, [state], ZipCode
	order by m.Model_Name, [state]

-- Show the cheapest cellphone (Output should contain the price also)

select top 1 Manufacturer_Name, Model_Name, min(Unit_price) price from DIM_MODEL m
join DIM_MANUFACTURER mm
on m.IDManufacturer = mm.IDManufacturer
group by Manufacturer_Name, Model_Name

--Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

select Manufacturer_Name, t.IDModel, Model_Name, format(avg(TotalPrice), 'N', 'EN-US') avg_price from FACT_TRANSACTIONS t
join DIM_MODEL m 
on t.IDModel = m.IDModel
join DIM_MANUFACTURER mm
on m.IDManufacturer = mm.IDManufacturer
where mm.IDManufacturer in (
							select top 5 mm.IDManufacturer from FACT_TRANSACTIONS t
							join DIM_MODEL m 
							on t.IDModel = m.IDModel
							join DIM_MANUFACTURER mm 
							on m.IDManufacturer = mm.IDManufacturer
							group by mm.IDManufacturer
							order by sum(Quantity) desc
						)
group by Manufacturer_Name, t.IDModel, Model_Name
order by avg(totalprice)

--Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

select c.IDCustomer, Customer_Name, format(avg(TotalPrice), 'N', 'EN-US') as avg_spent from FACT_TRANSACTIONS t
join DIM_CUSTOMER c
on t.IDCustomer = c.IDCustomer
where Year(date) = '2009'
group by c.IDCustomer, Customer_Name
having avg(totalprice) >= 500
order by avg(totalprice) desc

--. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010 
	
select * from (
	select top 5 Model_Name from FACT_TRANSACTIONS t
	join DIM_MODEL m
	on t.IDModel = m.IDModel
	where YEAR(date) = '2008'
	group by Model_Name
	order by sum(quantity) desc

	intersect

	select top 5 Model_Name from FACT_TRANSACTIONS t
	join DIM_MODEL m
	on t.IDModel = m.IDModel
	where YEAR(date) = '2009'
	group by Model_Name
	order by sum(quantity) desc

	intersect
	 
	select top 5 Model_Name from FACT_TRANSACTIONS t
	join DIM_MODEL m
	on t.IDModel = m.IDModel
	where YEAR(Date) = '2010'
	group by Model_Name
	order by sum(quantity) desc) a
	
--. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010. 

select ts.* from (
select mm.Manufacturer_Name, YEAR(date) [year], sum(totalprice) as totalsales,
dense_rank() over(partition by year(date) order by sum(totalprice) desc) ranking
from 
FACT_TRANSACTIONS t
join DIM_MODEL m 
on t.IDModel = m.IDModel
join DIM_MANUFACTURER mm
on m.IDManufacturer = mm.IDManufacturer
where YEAR(date) in ('2009','2010')
group by mm.Manufacturer_Name, YEAR(date)
) ts
where ranking = 2

--Show the manufacturers that sold cellphones in 2010 but did not in 2009.

	select distinct Manufacturer_Name from FACT_TRANSACTIONS t
	join DIM_MODEL m
	on t.IDModel = m.IDModel
	join DIM_MANUFACTURER mm
	on m.IDManufacturer = mm.IDManufacturer
	where Manufacturer_Name not in (
										select distinct Manufacturer_Name from FACT_TRANSACTIONS t
										join DIM_MODEL m 
										on t.IDModel = m.idmodel
										join DIM_MANUFACTURER mm
										on m.IDManufacturer = mm.IDManufacturer
										where YEAR(date) = '2009'
									)
	and YEAR(date) = '2010'













-- Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

	select top 100 c.IDCustomer, c.Customer_Name, YEAR(date) [year],
	(sum(t.Quantity)/count(c.IDCustomer)) as avg_quantity,
	format(avg(totalprice), 'N', 'EN-US') as avg_spent,
	(((avg(totalprice)-lag(avg(totalprice))
						over(partition by c.Customer_Name order by c.Customer_Name, Year(date)))
	/lag(avg(totalprice)) 
			over(partition by c.customer_name order by c.customer_name, year(date)))*100) as percent_change
	from FACT_TRANSACTIONS t
	join DIM_CUSTOMER c
	on t.IDCustomer = c.IDCustomer
	group by c.IDCustomer, c.Customer_Name, YEAR(date)
	order by c.IDCustomer, c.Customer_Name ,YEAR(date), avg(totalprice) desc

















	