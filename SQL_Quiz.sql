-- SQl Quiz
-- By Mohid Ahmed


-- Question1

SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM dbo.Customer c
JOIN dbo.SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC;

-- Question2

SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM dbo.Supplier s
JOIN dbo.PurchaseOrder po
    ON s.SupplierID = po.SupplierID
JOIN dbo.PurchaseOrderDetail pod
    ON po.OrderID = pod.OrderID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(DISTINCT pod.ProductID) > 10;

-- Question3

SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM dbo.Product p
JOIN dbo.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
LEFT JOIN dbo.ReturnDetail rd
    ON p.ProductID = rd.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(rd.ReturnID) = 0;

-- Question4

SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM dbo.Product p
JOIN dbo.Category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM dbo.Product p2
    WHERE p2.CategoryID = p.CategoryID
);

-- Question5

SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM dbo.SalesOrder so
JOIN dbo.Customer c
    ON so.CustomerID = c.CustomerID
JOIN dbo.SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
JOIN dbo.Product p
    ON sod.ProductID = p.ProductID
JOIN dbo.Category cat
    ON p.CategoryID = cat.CategoryID
JOIN dbo.PurchaseOrderDetail pod
    ON p.ProductID = pod.ProductID
JOIN dbo.PurchaseOrder po
    ON pod.OrderID = po.OrderID
JOIN dbo.Supplier s
    ON po.SupplierID = s.SupplierID;

-- Question6

SELECT
    sh.ShipmentID,
    w.WarehouseID,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM dbo.Shipment sh
JOIN dbo.Warehouse w
    ON sh.WarehouseID = w.WarehouseID
JOIN dbo.Employee e
    ON w.ManagerID = e.EmployeeID
JOIN dbo.ShipmentDetail sd
    ON sh.ShipmentID = sd.ShipmentID
JOIN dbo.Product p
    ON sd.ProductID = p.ProductID;

-- Question7

SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM (
    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER (
            PARTITION BY c.CustomerID
            ORDER BY so.TotalAmount DESC
        ) AS OrderRank
    FROM dbo.Customer c
    JOIN dbo.SalesOrder so
        ON c.CustomerID = so.CustomerID
) ranked
WHERE OrderRank <= 3;

-- Question8

SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS NextQuantity
FROM dbo.Product p
JOIN dbo.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
JOIN dbo.SalesOrder so
    ON sod.OrderID = so.OrderID;

-- Question9

GO
CREATE VIEW dbo.vw_CustomerOrderSummary
AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    ISNULL(SUM(so.TotalAmount), 0) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM dbo.Customer c
LEFT JOIN dbo.SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name;
GO

-- Question10

GO
CREATE PROCEDURE dbo.sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT
        s.SupplierID,
        s.Name AS SupplierName,
        SUM(sod.TotalAmount) AS TotalSalesAmount
    FROM dbo.Supplier s
    JOIN dbo.PurchaseOrder po
        ON s.SupplierID = po.SupplierID
    JOIN dbo.PurchaseOrderDetail pod
        ON po.OrderID = pod.OrderID
    JOIN dbo.Product p
        ON pod.ProductID = p.ProductID
    JOIN dbo.SalesOrderDetail sod
        ON p.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID, s.Name;
END;
GO