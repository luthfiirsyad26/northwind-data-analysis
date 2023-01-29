WITH Shipper_Summary AS (
	SELECT YEAR(ShippedDate) AS YEAR_, MONTH(ShippedDate) AS MONTH_,
		Shippers.CompanyName AS ShipperCompany,
		Customers.CompanyName AS CustomerCompany, City, Country,
		SUM(Quantity *([Order Details].UnitPrice - ( [Order Details].UnitPrice * Discount ))) AS Revenue,
		SUM(Quantity) AS Total_Item
	FROM Orders
	LEFT JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
	LEFT JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia
	LEFT JOIN Customers ON Orders.CustomerID = Customers.CustomerID
	WHERE YEAR(ShippedDate) IS NOT NULL
	GROUP BY YEAR(ShippedDate), MONTH(ShippedDate), Shippers.CompanyName,
		Customers.CompanyName, City, Country
	)
SELECT * FROM Shipper_Summary