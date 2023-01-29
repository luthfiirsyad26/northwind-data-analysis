--Tulis query untuk mendapatkan jumlah customer tiap bulan 
--yang melakukan order pada tahun 1997.
SELECT MONTH(OrderDate) AS mth,
	COUNT(CustomerID) AS total_cust,
	COUNT(DISTINCT(CustomerID)) AS total_unq_cust
FROM Orders ord
WHERE YEAR(OrderDate) = 1997
GROUP BY MONTH(OrderDate);

--Tulis query untuk mendapatkan nama 
--employee yang termasuk Sales Representative
SELECT LastName, FirstName, Title
FROM Employees
WHERE Title = 'Sales Representative';

--Tulis query untuk mendapatkan top 5 nama produk yang 
--quantitynya paling banyak diorder pada bulan Januari 1997.
SELECT TOP 5 ProductName, SUM(Quantity) AS total_prod
FROM [Order Details] as orde
LEFT JOIN Products as prod
	ON prod.ProductID = orde.ProductID
WHERE orde.OrderID IN (SELECT OrderID 
						FROM Orders 
						WHERE YEAR(OrderDate) = 1997 
							AND MONTH(OrderDate) = 1)
GROUP BY ProductName
ORDER BY total_prod DESC;

--Tulis query untuk mendapatkan nama company yang melakukan 
--order Chai pada bulan Juni 1997.
SELECT CompanyName
FROM [Order Details] as orde
LEFT JOIN Orders as ord 
	ON orde.OrderID = ord.OrderID
LEFT JOIN Customers as cus
	ON ord.CustomerID = cus.CustomerID
LEFT JOIN Products as prod
	ON prod.ProductID = orde.ProductID
WHERE orde.OrderID IN (SELECT OrderID 
						FROM Orders 
						WHERE YEAR(OrderDate) = 1997 
							AND MONTH(OrderDate) = 6)
	AND ProductName = 'Chai'
GROUP BY CompanyName;

--Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian 
--(unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
WITH A AS (
			SELECT OrderID, SUM(UnitPrice * Quantity) AS pembelian,
				CASE 
					WHEN SUM(UnitPrice * Quantity) <= 100 THEN '<=100'
					WHEN SUM(UnitPrice * Quantity) > 100 
						AND SUM(UnitPrice * Quantity) <= 250 THEN '100<x<=250'
					WHEN SUM(UnitPrice * Quantity) > 250 
						AND SUM(UnitPrice * Quantity) <= 500 THEN '250<x<=500'
					WHEN SUM(UnitPrice * Quantity) > 500 THEN '>500'
				ELSE NULL END AS cat_pembelian
			FROM [Order Details] 
			GROUP BY OrderID
		  )
SELECT cat_pembelian, COUNT(OrderID) AS total_order
FROM A
GROUP BY cat_pembelian;

--Tulis query untuk mendapatkan Company name pada tabel customer 
--yang melakukan pembelian di atas 500 pada tahun 1997.
WITH A AS (
			SELECT cus.CompanyName, 
				orde.OrderID, 
				SUM(UnitPrice * Quantity) AS pembelian
			FROM [Order Details] AS orde
			LEFT JOIN Orders as ord 
				ON orde.OrderID = ord.OrderID
			LEFT JOIN Customers as cus
				ON ord.CustomerID = cus.CustomerID
			WHERE orde.OrderID IN (SELECT OrderID 
						FROM Orders 
						WHERE YEAR(OrderDate) = 1997)
			GROUP BY cus.CompanyName, orde.OrderID
			HAVING SUM(UnitPrice * Quantity) > 500
		  )
SELECT CompanyName
FROM A
GROUP BY CompanyName;

--Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales 
--tertinggi tiap bulan di tahun 1997.
WITH A AS (
			SELECT ProductName, 
				SUM(Quantity) AS total_prod, 
				MONTH(OrderDate) AS mth,
				YEAR(OrderDate) AS yr,
				RANK() OVER (PARTITION BY MONTH(OrderDate)
							ORDER BY SUM(Quantity) DESC) AS Rank_
			FROM [Order Details] as orde
			LEFT JOIN Orders as ord 
				ON orde.OrderID = ord.OrderID
			LEFT JOIN Products as prod
				ON prod.ProductID = orde.ProductID
			WHERE orde.OrderID IN (SELECT OrderID 
									FROM Orders 
									WHERE YEAR(OrderDate) = 1997)
			GROUP BY ProductName, MONTH(OrderDate), YEAR(OrderDate)
		  )
SELECT ProductName, Rank_, mth, yr
FROM A
WHERE Rank_ <= 5
ORDER BY mth, Rank_;

--Buatlah view untuk melihat Order Details yang berisi OrderID, 
--ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
CREATE VIEW [View Order Details]
AS
SELECT OrderID, orde.ProductID, ProductName, 
	orde.UnitPrice, Quantity, Discount, 
	orde.UnitPrice - ( orde.UnitPrice * Discount ) AS [Harga setelah diskon]
FROM [Order Details] AS orde
LEFT JOIN Products as prod
	ON prod.ProductID = orde.ProductID;

--Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName/company name, 
--OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
CREATE PROCEDURE proc_Orders (
	@CustomerID AS varchar(5)
	) AS
BEGIN
IF @CustomerID IN (SELECT ord.CustomerID
				  FROM Orders AS ord
				  GROUP BY CustomerID)
BEGIN
SELECT ord.CustomerID, cus.CompanyName, OrderID, OrderDate, RequiredDate, ShippedDate 
FROM Orders AS ord
LEFT JOIN Customers as cus
	ON ord.CustomerID = cus.CustomerID
WHERE ord.CustomerID = @CustomerID;
END

ELSE 
BEGIN
    RETURN PRINT 'CustomerID not Exist in Table Orders';
END
END;