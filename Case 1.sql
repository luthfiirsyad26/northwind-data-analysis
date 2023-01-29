WITH Employee_Summary AS (
			SELECT Employees.EmployeeID, LastName, FirstName, Title, 
				SUM(Quantity *([Order Details].UnitPrice - ( [Order Details].UnitPrice * Discount ))) AS Revenue, 
				BirthDate, MAX(OrderDate) LAST_ORDER_DATE, MIN(OrderDate) AS FIRST_ORDER_DATE,
				HireDate, COUNT(DISTINCT(OrderDate)) AS Total_Days_Trx, SUM(Quantity) AS TOTAL_ITEM, COUNT(*) AS Total_Trx
			FROM Employees
			LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
			LEFT JOIN Customers ON Orders.CustomerID = Customers.CustomerID
			LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
			LEFT JOIN Products ON Products.ProductID = [Order Details].ProductID
			--WHERE Title = 'Sales Representative'
			GROUP BY Employees.EmployeeID, LastName, FirstName, Title, BirthDate, HireDate
			)
SELECT LastName, CONCAT(LastName,', ', FirstName) AS Name, 
	DATEDIFF(year,BirthDate,'1998-05-06') AS Age,
	Title,
	Revenue,
	DATEDIFF(day,HireDate,'1998-05-06') AS Lifetime_day, 
	TOTAL_ITEM,
	Total_Trx,
	Total_Days_Trx,
	100*Total_Days_Trx/DATEDIFF(day,'1996-07-04','1998-05-06') [Perc. Day of Orders],
	Revenue/DATEDIFF(day,HireDate,'1998-05-06') AS [Rev/Day],
	Revenue/Total_Days_Trx AS [Rev/DTrx],
	Revenue/Total_Trx AS [Rev/Trx],
	TOTAL_ITEM/Total_Days_Trx AS [Trx/Day],
	Revenue/TOTAL_ITEM AS [Rev/Item]
FROM Employee_Summary
ORDER BY Revenue DESC;


WITH Employee_Month_Summary AS (
			SELECT Employees.EmployeeID, LastName, FirstName, Title, 
				SUM(Quantity *([Order Details].UnitPrice - ( [Order Details].UnitPrice * Discount ))) AS Revenue, 
				BirthDate, 
				HireDate,
				YEAR(OrderDate) AS YEAR_, 
				MONTH(OrderDate) AS MONTH_
			FROM Employees
			LEFT JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
			LEFT JOIN Customers ON Orders.CustomerID = Customers.CustomerID
			LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
			LEFT JOIN Products ON Products.ProductID = [Order Details].ProductID
			--WHERE Title = 'Sales Representative'
			GROUP BY Employees.EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, YEAR(OrderDate), MONTH(OrderDate)
			)
SELECT LastName, CONCAT(LastName,', ', FirstName) AS Name, 
	Title,
	CASE WHEN MONTH_ < 10
		THEN CONCAT(YEAR_, '-0', MONTH_, '-01')
		ELSE CONCAT(YEAR_, '-', MONTH_, '-01') END AS Order_Month,
	Revenue
FROM Employee_Month_Summary
ORDER BY Revenue DESC;