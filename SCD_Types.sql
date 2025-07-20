USE AdventureWorks2022;
GO

-- Drop tables if they already exist
IF OBJECT_ID('dbo.Dim_Person', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Person;
GO

IF OBJECT_ID('dbo.Dim_Person_History', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Person_History;
GO

-- Create Dim_Person with all required columns
CREATE TABLE dbo.Dim_Person (
    BusinessEntityID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Start_Date DATETIME DEFAULT GETDATE(),
    End_Date DATETIME NULL,
    Is_Current BIT DEFAULT 1,
    Previous_FirstName NVARCHAR(50) NULL,
    Version INT DEFAULT 1
);
GO

-- Create Dim_Person_History (for SCD Type 4)
CREATE TABLE dbo.Dim_Person_History (
    BusinessEntityID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Snapshot_Date DATETIME
);
GO

-- SCD Type 0: No change allowed
IF OBJECT_ID('dbo.sp_scd_type0', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type0;
GO
CREATE PROCEDURE dbo.sp_scd_type0
AS
BEGIN
    INSERT INTO dbo.Dim_Person (BusinessEntityID, FirstName, LastName)
    SELECT s.BusinessEntityID, s.FirstName, s.LastName
    FROM Person.Person s
    LEFT JOIN dbo.Dim_Person d ON s.BusinessEntityID = d.BusinessEntityID
    WHERE d.BusinessEntityID IS NULL;
END;
GO

-- SCD Type 1: Overwrite data
IF OBJECT_ID('dbo.sp_scd_type1', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type1;
GO
CREATE PROCEDURE dbo.sp_scd_type1
AS
BEGIN
    INSERT INTO dbo.Dim_Person (BusinessEntityID, FirstName, LastName)
    SELECT s.BusinessEntityID, s.FirstName, s.LastName
    FROM Person.Person s
    LEFT JOIN dbo.Dim_Person d ON s.BusinessEntityID = d.BusinessEntityID
    WHERE d.BusinessEntityID IS NULL;

    UPDATE d
    SET d.FirstName = s.FirstName,
        d.LastName = s.LastName
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.FirstName <> s.FirstName OR d.LastName <> s.LastName;
END;
GO

-- SCD Type 2: Keep full history
IF OBJECT_ID('dbo.sp_scd_type2', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type2;
GO
CREATE PROCEDURE dbo.sp_scd_type2
AS
BEGIN
    DECLARE @currentDate DATETIME = GETDATE();

    UPDATE d
    SET d.End_Date = @currentDate,
        d.Is_Current = 0
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.Is_Current = 1 AND (d.FirstName <> s.FirstName OR d.LastName <> s.LastName);

    INSERT INTO dbo.Dim_Person (BusinessEntityID, FirstName, LastName, Start_Date, End_Date, Is_Current)
    SELECT s.BusinessEntityID, s.FirstName, s.LastName, @currentDate, NULL, 1
    FROM Person.Person s
    LEFT JOIN dbo.Dim_Person d ON s.BusinessEntityID = d.BusinessEntityID AND d.Is_Current = 1
    WHERE d.BusinessEntityID IS NULL OR d.FirstName <> s.FirstName OR d.LastName <> s.LastName;
END;
GO

-- SCD Type 3: Keep only previous value
IF OBJECT_ID('dbo.sp_scd_type3', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type3;
GO
CREATE PROCEDURE dbo.sp_scd_type3
AS
BEGIN
    INSERT INTO dbo.Dim_Person (BusinessEntityID, FirstName, LastName)
    SELECT s.BusinessEntityID, s.FirstName, s.LastName
    FROM Person.Person s
    LEFT JOIN dbo.Dim_Person d ON s.BusinessEntityID = d.BusinessEntityID
    WHERE d.BusinessEntityID IS NULL;

    UPDATE d
    SET d.Previous_FirstName = d.FirstName,
        d.FirstName = s.FirstName
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.FirstName <> s.FirstName;
END;
GO

-- SCD Type 4: Use separate history table
IF OBJECT_ID('dbo.sp_scd_type4', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type4;
GO
CREATE PROCEDURE dbo.sp_scd_type4
AS
BEGIN
    INSERT INTO dbo.Dim_Person_History (BusinessEntityID, FirstName, LastName, Snapshot_Date)
    SELECT d.BusinessEntityID, d.FirstName, d.LastName, GETDATE()
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.FirstName <> s.FirstName OR d.LastName <> s.LastName;

    UPDATE d
    SET d.FirstName = s.FirstName,
        d.LastName = s.LastName
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.FirstName <> s.FirstName OR d.LastName <> s.LastName;
END;
GO

-- SCD Type 6: Hybrid (1+2+3)
IF OBJECT_ID('dbo.sp_scd_type6', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_scd_type6;
GO
CREATE PROCEDURE dbo.sp_scd_type6
AS
BEGIN
    DECLARE @currentDate DATETIME = GETDATE();

    UPDATE d
    SET d.End_Date = @currentDate,
        d.Is_Current = 0
    FROM dbo.Dim_Person d
    JOIN Person.Person s ON d.BusinessEntityID = s.BusinessEntityID
    WHERE d.Is_Current = 1 AND (d.FirstName <> s.FirstName OR d.LastName <> s.LastName);

    INSERT INTO dbo.Dim_Person (
        BusinessEntityID, FirstName, LastName, Previous_FirstName, Start_Date, End_Date, Is_Current, Version
    )
    SELECT s.BusinessEntityID, s.FirstName, s.LastName, d.FirstName,
           @currentDate, NULL, 1, ISNULL(d.Version, 0) + 1
    FROM Person.Person s
 LEFT JOIN dbo.Dim_Person d ON s.BusinessEntityID = d.BusinessEntityID AND d.Is_Current = 1
    WHERE d.BusinessEntityID IS NULL OR d.FirstName <> s.FirstName OR d.LastName <> s.LastName;
END;
GO