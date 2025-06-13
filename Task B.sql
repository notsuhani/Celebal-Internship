USE AdventureWorks2022;
GO

-- Drop existing procedures
IF OBJECT_ID('InsertOrderDetails', 'P') IS NOT NULL DROP PROCEDURE InsertOrderDetails;
GO

IF OBJECT_ID('UpdateOrderDetails', 'P') IS NOT NULL DROP PROCEDURE UpdateOrderDetails;
GO

IF OBJECT_ID('GetOrderDetails', 'P') IS NOT NULL DROP PROCEDURE GetOrderDetails;
GO

IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL DROP PROCEDURE DeleteOrderDetails;
GO

-- Create UpdateOrderDetails procedure
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    -- Variable declarations to store original values
    DECLARE @OriginalUnitPrice MONEY;
    DECLARE @OriginalQuantity INT;
    DECLARE @OriginalDiscount DECIMAL(5, 2);

    -- Fetch original values if input values are NULL
    SELECT 
        @OriginalUnitPrice = UnitPrice,
        @OriginalQuantity = OrderQty,
        @OriginalDiscount = UnitPriceDiscount
    FROM 
        Sales.SalesOrderDetail
    WHERE 
        SalesOrderID = @OrderID 
        AND ProductID = @ProductID;

    -- If input parameters are NULL, use original values
    SET @UnitPrice = ISNULL(@UnitPrice, @OriginalUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @OriginalQuantity);
    SET @Discount = ISNULL(@Discount, @OriginalDiscount);

    -- Update the order details
    UPDATE Sales.SalesOrderDetail
    SET 
        UnitPrice = @UnitPrice, 
        OrderQty = @Quantity, 
        UnitPriceDiscount = @Discount
    WHERE 
        SalesOrderID = @OrderID 
        AND ProductID = @ProductID;

    -- Adjust inventory
    DECLARE @QuantityDifference INT = @Quantity - @OriginalQuantity;
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @QuantityDifference
    WHERE ProductID = @ProductID;
END;
GO

-- Create GetOrderDetails procedure
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        RAISERROR('The OrderID %d does not exist', 16, 1, @OrderID);
        RETURN;
    END
    
    SELECT * 
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;
GO

-- Create DeleteOrderDetails procedure
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters';
        RETURN -1;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;
END;
GO



CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT,
    @Discount DECIMAL(5, 2) = 0
AS
BEGIN
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @UnitPrice = ListPrice
        FROM Production.Product
        WHERE ProductID = @ProductID;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

        UPDATE Production.ProductInventory
        SET Quantity = Quantity - @Quantity
        WHERE ProductID = @ProductID;

        IF EXISTS (SELECT 1 FROM Production.ProductInventory WHERE ProductID = @ProductID AND Quantity < 0)
        BEGIN
            RAISERROR('Not enough stock', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Failed to place the order. Please try again.', 16, 1);
    END CATCH
END;
GO

-- Create UpdateOrderDetails procedure
CREATE PROCEDURE UpdateOrderDetailss
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5, 2) = NULL
AS
BEGIN
    -- Variable declarations to store original values
    DECLARE @OriginalUnitPrice MONEY;
    DECLARE @OriginalQuantity INT;
    DECLARE @OriginalDiscount DECIMAL(5, 2);

    -- Fetch original values if input values are NULL
    SELECT 
        @OriginalUnitPrice = UnitPrice,
        @OriginalQuantity = OrderQty,
        @OriginalDiscount = UnitPriceDiscount
    FROM 
        Sales.SalesOrderDetail
    WHERE 
        SalesOrderID = @OrderID 
        AND ProductID = @ProductID;

    -- If input parameters are NULL, use original values
    SET @UnitPrice = ISNULL(@UnitPrice, @OriginalUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @OriginalQuantity);
    SET @Discount = ISNULL(@Discount, @OriginalDiscount);

    -- Update the order details
    UPDATE Sales.SalesOrderDetail
    SET 
        UnitPrice = @UnitPrice, 
        OrderQty = @Quantity, 
        UnitPriceDiscount = @Discount
    WHERE 
        SalesOrderID = @OrderID 
        AND ProductID = @ProductID;

    -- Adjust inventory
    DECLARE @QuantityDifference INT = @Quantity - @OriginalQuantity;
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @QuantityDifference
    WHERE ProductID = @ProductID;
END;
GO