USE AdventureWorks2022;
GO
--QUESTION 1
SELECT * FROM Sales.Customer;

--QUESTION 2
SELECT * 
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';


--QUESTION 3
SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Person.Person p
JOIN Sales.Customer c ON p.BusinessEntityID = c.PersonID
JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = c.PersonID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');


--QUESTION 4
SELECT DISTINCT p.FirstName, p.LastName, sp.Name AS Country
FROM Person.Person p
JOIN Sales.Customer c ON p.BusinessEntityID = c.PersonID
JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = c.PersonID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
WHERE st.CountryRegionCode IN ('GB', 'US');


--QUESTION 5
SELECT Name 
FROM Production.Product 
ORDER BY Name;

--QUESTION 6
SELECT Name
FROM Production.Product
WHERE Name LIKE 'A%';


--QUESTION 7
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;


--QUESTION 8
SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = c.PersonID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prod ON sod.ProductID = prod.ProductID
WHERE a.City = 'London' AND prod.Name LIKE '%Chai%';

--QUESTION 9
SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;


--QUESTION 10
SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prod ON sod.ProductID = prod.ProductID
WHERE prod.Name LIKE '%Tofu%';


--QUESTION 11
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(sod.LineTotal) AS TotalSales
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSales DESC;


--QUESTION 12
SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh ON e.BusinessEntityID = soh.SalesPersonID
WHERE soh.SalesOrderID IS NULL;


--QUESTION 13
SELECT TOP 5 
    p.Name, 
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY TotalQuantitySold DESC;

--QUESTION 14
SELECT AVG(UnitPrice) AS AverageUnitPrice
FROM Sales.SalesOrderDetail;

--QUESTION 15
SELECT 
    c.CustomerID, 
    p.FirstName, 
    p.LastName,
    COUNT(DISTINCT sod.ProductID) AS ProductCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT sod.ProductID) > 3;

--QUESTION 16
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--QUESTION 17
SELECT c.CustomerID, p.FirstName, p.LastName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 5;

--QUESTION 18
SELECT prd.Name, SUM(sod.LineTotal) AS TotalRevenue
FROM Production.Product prd
JOIN Sales.SalesOrderDetail sod ON prd.ProductID = sod.ProductID
GROUP BY prd.Name
ORDER BY TotalRevenue DESC;

--QUESTION 19
SELECT e.BusinessEntityID, p.FirstName, p.LastName
FROM HumanResources.Employee e
JOIN Sales.SalesPerson sp ON e.BusinessEntityID = sp.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

--QUESTION 20
SELECT DISTINCT p.FirstName, p.LastName, prd.Name
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prd ON sod.ProductID = prd.ProductID
WHERE prd.Name = 'Mountain-100 Silver, 44';

--QUESTION 21
SELECT TOP 3 a.City, COUNT(DISTINCT c.CustomerID) AS CustomerCount
FROM Sales.Customer c
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
GROUP BY a.City
ORDER BY CustomerCount DESC;

--QUESTION 22
SELECT p.Name AS ProductName, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

--QUESTION 23
SELECT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;

--QUESTION 24
SELECT p.Name, SUM(sod.OrderQty) AS TotalQuantitySold
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name
HAVING SUM(sod.OrderQty) > 1000;

--QUESTION 25
SELECT TOP 1 p.FirstName, p.LastName, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
ORDER BY OrderCount DESC;

--QUESTION 26
SELECT c.CustomerID, p.FirstName, p.LastName, AVG(soh.TotalDue) AS AvgOrderValue
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName;

--QUESTION 27
SELECT TOP 1 Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

--QUESTION 28
SELECT COUNT(DISTINCT ProductID) AS DistinctProductsSold
FROM Sales.SalesOrderDetail;

--QUESTION 29
WITH BestCustomer AS (
    SELECT TOP 1 c.CustomerID
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    GROUP BY c.CustomerID
    ORDER BY SUM(soh.TotalDue) DESC
)

SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    p.FirstName,
    p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID = (SELECT CustomerID FROM BestCustomer)
ORDER BY soh.OrderDate DESC;

--QUESTION 30
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE c.CustomerID NOT IN (
    SELECT c2.CustomerID
    FROM Sales.Customer c2
    JOIN Person.Person p2 ON c2.PersonID = p2.BusinessEntityID
    JOIN Person.PersonPhone pp ON p2.BusinessEntityID = pp.BusinessEntityID
    JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
    WHERE pnt.Name = 'Fax'
);


--QUESTION 31
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

--QUESTION 32
SELECT DISTINCT p.Name AS ProductName
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

--QUESTION 33
SELECT 
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
JOIN Production.Product p ON pv.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

--QUESTION 34
SELECT p.Name AS ProductName
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--QUESTION 35
SELECT 
    p.Name AS ProductName,
    SUM(pi.Quantity) AS TotalUnitsInStock
FROM Production.Product p
JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID
GROUP BY p.Name
HAVING SUM(pi.Quantity) < 10;

--QUESTION 36
SELECT TOP 10 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

--QUESTION 37
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN HumanResources.Employee e ON soh.SalesPersonID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE c.AccountNumber BETWEEN 'A' AND 'AO'
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY NumberOfOrders DESC;

--QUESTION 38
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--QUESTION 39
SELECT
    v.BusinessEntityID AS SupplierID,
    v.Name AS SupplierName,
    COUNT(DISTINCT pv.ProductID) AS NumberOfProductsOffered
FROM
    Purchasing.ProductVendor pv
JOIN
    Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
GROUP BY
    v.BusinessEntityID, v.Name
ORDER BY
    NumberOfProductsOffered DESC;


--QUESTION 41
SELECT TOP 10
    c.CustomerID,
    c.AccountNumber,
    SUM(soh.TotalDue) AS TotalBusiness
FROM
    Sales.Customer c
JOIN
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY
    c.CustomerID,
    c.AccountNumber
ORDER BY
    TotalBusiness DESC;

--QUESTION 42
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;



