/*    N1
Let's create a table of employees, where the following will be given: ID,
Full name, age, gender, position, salary, mobile number.
Add a column containing the salary level
Characterization: 'lowsalary', 'normal salary', 'highsalary'.
Sort the data according to salary decrease */

SELECT emp.BusinessEntityID
	   ,CONCAT(pers.FirstName, ' ', pers.LastName) AS FullName
       ,DATEDIFF(YEAR,emp.BirthDate,GETDATE()) AS Age
	   ,emp.Gender
	   ,emp.JobTitle
	   ,(emph.Rate*emph.PayFrequency) AS Salary
	   ,CASE WHEN  (emph.Rate*emph.PayFrequency) BETWEEN 10.00 AND 50.00  THEN 'lowsalary'
	         WHEN  (emph.Rate*emph.PayFrequency) BETWEEN 50.00 AND 80.00 THEN 'normalsalary'
			 WHEN  (emph.Rate*emph.PayFrequency) > 80.00 THEN 'highsalary'
			 ELSE 'other'
			 END AS SalaryLevel
	   ,phn.PhoneNumber
	   ,emph.ModifiedDate
  FROM [AdventureWorks2017].[HumanResources].[Employee] AS emp
  
  LEFT JOIN [AdventureWorks2017].[HumanResources].[EmployeePayHistory] AS emph
  ON emp.BusinessEntityID = emph.BusinessEntityID
    
  LEFT JOIN [AdventureWorks2017].[Person].[Person] AS pers
  ON emp.BusinessEntityID = pers.BusinessEntityID

  LEFT JOIN [AdventureWorks2017].[Person].[PersonPhone] AS phn
  ON pers.BusinessEntityID = phn.BusinessEntityID
  WHERE  emph.ModifiedDate IN ( '2014-06-30 00:00:00.000'
								,'2011-12-01 00:00:00.000'
								,'2012-04-16 00:00:00.000'
								,'2013-06-30 00:00:00.000'
								,'2011-12-18 00:00:00.000'
								,'2012-01-15 00:00:00.000'
								,'2012-06-30 00:00:00.000'
							   )
  ORDER BY Salary DESC


  /* Extract the ProductID and its name containing the word 'Short',
  Let's find the deviation between the standard price and the final cost, and thus find out
  Is there a profit left by selling the product at this price? */

  SELECT prod.ProductID
		,prod.Name
		,prdv.StandardPrice
		,prdv.LastReceiptCost
		,(prdv.LastReceiptCost-prdv.StandardPrice) AS ProductProfit
        ,CASE WHEN prdv.LastReceiptCost-prdv.StandardPrice < 0 THEN 'lost'
        WHEN  prdv.LastReceiptCost-prdv.StandardPrice >= 0 THEN 'profit'
		ELSE 'nonprofit'
		END AS 'Profitlevel'
  FROM [AdventureWorks2017].[Production].[Product] AS prod
  LEFT JOIN [AdventureWorks2017].[Purchasing].[ProductVendor] AS prdv
  ON prod.ProductID = prdv.ProductID

  WHERE prod.SellEndDate IS NOT NULL
        AND prdv.StandardPrice IS NOT NULL
        AND prdv.LastReceiptCost IS NOT NULL
        AND Name LIKE '%Short%'
  
  /* Find the sum of sales growth, and group
  By TerritoryID and Territory Names,
  Let's also bring out the given territorial
  Current year's maximum sales per units
  and sort TotalSalesGrowth in descending order*/

  SELECT sap.BusinessEntityID
      ,sap.TerritoryID
	  ,strt.Name
	  ,sap.SalesYTD
	  ,sap.SalesLastYear
      ,(sap.SalesYTD- sap.SalesLastYear) AS SalesGrowth
  INTO #table
  FROM [AdventureWorks2017].[Sales].[SalesPerson] AS sap
  LEFT JOIN [AdventureWorks2017].[Sales].[SalesTerritory] AS Strt
  ON sap.TerritoryID = strt.TerritoryID
  WHERE sap.TerritoryID IS NOT NULL

  SELECT TerritoryID
         ,Name
         ,SUM(SalesGrowth) AS TotalSaleGrowth
		 ,MAX(SalesYTD) AS MaxSalesYTD
 FROM #table
 GROUP BY TerritoryID, Name
 ORDER BY TotalSaleGrowth DESC

  

