
USE EcommerceData

--Check NULLS
 SELECT * 
 FROM ['Order Details$']
 WHERE Amount IS NULL
   AND Profit IS NULL
   AND Quantity IS NULL

--- Check Duplicates
SELECT *
FROM (
      SELECT OrderID
             ,COUNT(*) OVER(PARTITION BY OrderID) AS CheckPK
	  FROM ['List of Orders$']
	  ) AS CheckTable
WHERE CheckPK > 1


--Min, Max, Avg by category
SELECT Category
      ,MAX(Amount) AS MaxAmount
	  ,MIN(Amount) AS MinAmount
	  ,AVG(Amount) AS AvgAmount
	  ,MIN(Profit) AS MinProfit
	  ,Max(Profit) AS MaxProfit
	  ,AVG(Profit) AS AvgProfit
FROM ['Order Details$']
GROUP BY Category
ORDER BY MaxAmount DESC


--Min, Max, Avg by SubCategory
SELECT SubCategory
      ,MAX(Amount) AS MaxAmount
	  ,MIN(Amount) AS MinAmount
	  ,AVG(Amount) AS AvgAmount
	  ,MIN(Profit) AS MinProfit
	  ,Max(Profit) AS MaxPofit
	  ,AVG(Profit) AS AvgProfit
FROM ['Order Details$']
GROUP BY SubCategory
ORDER BY MaxAmount DESC

--ADD Date COlumns
 ALTER TABLE ['List of Orders$']
 ADD MonthYear AS (
    CONVERT(VARCHAR(4), YEAR(OrderDate)) + '-' + 
    RIGHT('0' + CONVERT(VARCHAR(2), MONTH(OrderDate)), 2) 
)

--Min, Max, Avg By Year
SELECT lo.OrderYear
      ,od.Category
      ,MAX(od.Amount) AS MaxAmount
	  ,MIN(od.Amount) AS MinAmount
	  ,AVG(od.Amount) AS AvgAmount
	  ,SUM(od.Amount) AS TotalAmountByYear
	  ,MIN(od.Profit) AS MinProfit
	  ,Max(od.Profit) AS MaxPofit
	  ,AVG(od.Profit) AS AvgProfit
	  ,SUM(od.Profit) AS TotalProfitByYear
FROM ['Order Details$'] AS od
LEFT JOIN ['List of Orders$'] AS lo
ON od.OrderID = lo.OrderID
GROUP BY lo.OrderYear, 
         od.Category
ORDER BY lo.OrderYear


-- Create a view that joins the [Order Details] table and the [List of Orders] table

CREATE VIEW OrderDetailsView AS
SELECT od.OrderID,
       lo.OrderDate,
	   lo.OrderYear,
	   lo.MonthYear,
	   lo.CustomerName,
	   lo.State,
	   lo.City,
	   od.Category,
	   od.SubCategory,
       od.Amount,
	   od.Profit,
	   od.Quantity
From ['Order Details$'] AS od
JOIN ['List of Orders$'] AS lo
ON od.OrderID = lo.OrderID

SELECT * 
FROM OrderDetailsView

-- Rank Customer by their total amount in 2018

SELECT CustomerName 
      ,RANK() OVER(ORDER BY SUM(Amount) DESC) AS RunkCustomer2018
	  ,SUM(Amount) AS TotalAmount2018
FROM OrderDetailsView
WHERE OrderYear = 2018
GROUP BY CustomerName

--Rank Customer by their total amount in 2019

SELECT CustomerName 
      ,RANK() OVER(ORDER BY SUM(Amount) DESC) AS RunkCustomer2019
	  ,SUM(Amount) AS TotalAmount2019
FROM OrderDetailsView
WHERE OrderYear = 2019
GROUP BY CustomerName

--Rank State by their total amount
SELECT State
      ,RANK() OVER(ORDER BY SUM(Amount) DESC) AS RunkState
	  ,SUM(Amount) AS TotalAmountByState
FROM OrderDetailsView
GROUP BY State

--Rank City by their total amount
SELECT City
      ,RANK() OVER(ORDER BY SUM(Amount) DESC) AS RankCity 
	  ,SUM(Amount) AS TotalAmountByCity
FROM OrderDetailsView
GROUP BY City

--Calculate the percentage contribution of each subcategory's amount to the total amount.
--Calculate the percentage contribution of each subcategory's profit to the total profit.
SELECT SubCategory
      ,SUM(Amount) AS SubCategoryAmount
	  ,CAST(ROUND(SUM(Amount)/SUM(SUM(Amount)) OVER() * 100, 2) AS DECIMAL(10,2)) AS PercentageOfTotal
	  ,SUM(Profit) AS SubCategoryProfit
	  ,CAST(ROUND(SUM(Profit)/SUM(SUM(Profit)) OVER() * 100, 2) AS DECIMAL(10,2)) AS PercentageOfProfit
FROM ['Order Details$']
GROUP BY SubCategory
ORDER BY PercentageOfTotal DESC

-- Select orders where the amount is higher than the average amount

WITH OrderAvg AS (
      SELECT  OrderID
	         ,Amount
             ,AVG(Amount) OVER() AS AvgAmount 
      FROM ['Order Details$']
 )
 SELECT *
 FROM OrderAvg
 WHERE Amount > AvgAmount

 --Select orders where the profit is higher than the average profit

 WITH ProfitAvg AS (
      SELECT  OrderID
	         ,Profit
             ,AVG(Profit) OVER() AS AvgProfit 
      FROM ['Order Details$']
 )
 SELECT *
 FROM ProfitAvg
 WHERE Profit > AvgProfit

 -- Compute the moving average over a 7-day period
 WITH AmountByDate AS (
      SELECT OrderDate
	        ,SUM(Amount) as TotalAmount
      From OrderDetailsView
	  GROUP BY OrderDate
)
SELECT OrderDate
      ,TotalAmount
	  ,AVG(TotalAmount) OVER(ORDER BY OrderDate
	  Rows BETWEEN 6 PRECEDING AND CURRENT ROW) AS RollingAvg7days
FROM AmountByDate
ORDER BY OrderDate

      
---Compute the moving average over a 3-month period
WITH AmountByMonth AS (
     SELECT MonthYear
	       ,SUM(Amount) AS TotalAmount
     FROM OrderDetailsView
     GROUP BY MonthYear
)
SELECT MonthYear
      ,TotalAmount
      ,AVG(TotalAmount) OVER(ORDER BY MonthYear
	  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS RollingAvg3months
FROM AmountByMonth
ORDER BY MonthYear


--Classify the amount into 'low,' 'medium,' and 'high' categories.
SELECT OrderID
      ,OrderDate
	  ,Category
	  ,SubCategory
	  ,CustomerName
	  ,Amount
	  ,CASE WHEN Amount <= 1900 THEN 'LOW'
	        WHEN Amount BETWEEN 1901 AND 3800 THEN 'Medium'
			ELSE 'High'
	   END AS AmountCatehory
FROM OrderDetailsView