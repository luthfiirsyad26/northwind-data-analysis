WITH Product_Summary AS (
	SELECT [Order Details].ProductID, Products.ProductName, CategoryName,
		YEAR(OrderDate) AS YEAR_, MONTH(OrderDate) AS MONTH_,
		SUM(Quantity *([Order Details].UnitPrice - ( [Order Details].UnitPrice * Discount ))) AS Revenue,
		SUM(Quantity) AS Total_Item
	FROM Orders
	LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
	LEFT JOIN Products ON Products.ProductID = [Order Details].ProductID
	LEFT JOIN Categories ON Categories.CategoryID = Products.CategoryID
	GROUP BY [Order Details].ProductID, Products.ProductName, CategoryName, YEAR(OrderDate), MONTH(OrderDate)
	)
SELECT * FROM Product_Summary

WITH ProdCat_Summary AS (
	SELECT CategoryName,
		YEAR(OrderDate) AS YEAR_, MONTH(OrderDate) AS MONTH_,
		SUM(Quantity *([Order Details].UnitPrice - ( [Order Details].UnitPrice * Discount ))) AS Revenue,
		SUM(Quantity) AS Total_Item
	FROM Orders
	LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
	LEFT JOIN Products ON Products.ProductID = [Order Details].ProductID
	LEFT JOIN Categories ON Categories.CategoryID = Products.CategoryID
	GROUP BY CategoryName, YEAR(OrderDate), MONTH(OrderDate)
	)
SELECT * FROM ProdCat_Summary