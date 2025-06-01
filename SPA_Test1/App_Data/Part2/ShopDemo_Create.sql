--���������, ��� �� �� ������� �����
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ShopDemo')
BEGIN
    CREATE DATABASE ShopDemo;
END

GO

USE ShopDemo;
GO

-- ���������, ��� ������� Customers ���
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers' AND type = 'U')
BEGIN
    -- ������ ������� Customers
    CREATE TABLE Customers (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100),
        Surname NVARCHAR(100),
        Birthdate DATETIME
    );
    ALTER TABLE Customers ADD CONSTRAINT DF_Customers_Date DEFAULT GETDATE() FOR Birthdate;
    -- ������ �������
    CREATE INDEX IX_Customers_Date ON Customers(Birthdate);
    CREATE INDEX IX_Customers_Surname ON Customers(Surname);
    CREATE INDEX IX_Customers_Name ON Customers(Name);
    CREATE INDEX IX_Customers_Name_Surname ON Customers(Name, Surname);

    INSERT INTO Customers (Name, Surname, Birthdate)
    VALUES
        ('�������', '��������', '19980520'),
        ('����', '������', '19950101'),
        ('������', '�������', '19910101'),
        ('�����', '������', '19870103'),
        ('�������', '�������', '20010401');
END

GO

-- ���������, ��� ������� Products ���
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products' AND type = 'U')
BEGIN
    -- ������ ������� Products
    CREATE TABLE Products (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100),
        Price DECIMAL(18, 2) NOT NULL DEFAULT 100.00
    );
    CREATE INDEX IX_Products_Name ON Products(Name);

    -- ���������� 1000 �������
    WITH Numbers AS (
        SELECT TOP 1000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM master.dbo.spt_values v1
        CROSS JOIN master.dbo.spt_values v2
    )

    INSERT INTO Products (Name, Price)
    SELECT
        'Product-' + CAST(n AS NVARCHAR(10)),
        50 + (ABS(CHECKSUM(NEWID())) % 1950) -- ��������� ���� �� 50 �� 2000
    FROM Numbers
END

GO

--������ ������� �������
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders' AND type = 'U')
BEGIN
    CREATE TABLE Orders (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        CustomerId INT NOT NULL,
        OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
        Status NVARCHAR(50) NOT NULL,
        TotalAmount DECIMAL(18, 2) NOT NULL,
        -- ������� ���� ��� ����� � �������� ����������
        CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
    );
    
    -- ������� ������� ��� ����� ������� � ������� (������ �� ������)
    CREATE TABLE OrderProducts (
        OrderId UNIQUEIDENTIFIER NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL DEFAULT 1,
        Price DECIMAL(18, 2) NOT NULL,
        CONSTRAINT PK_OrderProducts PRIMARY KEY (OrderId, ProductId),
        CONSTRAINT FK_OrderProducts_Orders FOREIGN KEY (OrderId) REFERENCES Orders(Id),
        CONSTRAINT FK_OrderProducts_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
    
    -- ������� ������ ��� ��������� ������ �� ���� ������
    CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
    CREATE INDEX IX_Orders_CustomerId ON Orders(CustomerId);
    CREATE INDEX IX_Orders_Status ON Orders(Status);
END

GO

ALTER TABLE OrderProducts ALTER COLUMN Price DECIMAL(18, 2) NOT NULL;
GO

-- ������ ������� ��� ������� OrderProducts, ����� ��� ���������� ������ ������������� �������������� ���� ������
CREATE OR ALTER TRIGGER tr_OrderProducts_Insert
ON OrderProducts
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ��������� ������ � �������������� ����������� ���� �� ������� Products
    INSERT INTO OrderProducts (OrderId, ProductId, Quantity, Price)
    SELECT 
        i.OrderId, 
        i.ProductId, 
        ISNULL(i.Quantity, 1), -- ���� ���������� �� �������, ������ 1
        p.Price -- ����� ���� �� ������� Products
    FROM 
        inserted i
        JOIN Products p ON i.ProductId = p.Id;
        
    -- ��������� ����� ����� � ������
    UPDATE o
    SET TotalAmount = (
        SELECT SUM(op.Price * op.Quantity)
        FROM OrderProducts op
        WHERE op.OrderId = o.Id
    )
    FROM 
        Orders o
        JOIN inserted i ON o.Id = i.OrderId;
END
GO

-- ������ ��������� ������
CREATE OR ALTER PROCEDURE GetOrdersReport
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        o.OrderDate AS '���� ������',
        o.TotalAmount AS '����� ������',
        o.Status AS '������ ������',
        c.Name + ' ' + c.Surname AS '��� ���������',
        STUFF((
            SELECT '; ' + g.Name + ' (' + CAST(op.Quantity AS VARCHAR(10)) + 'x' + CAST(op.Price AS VARCHAR(10)) + ')'
            FROM OrderProducts op
            JOIN Products g ON op.ProductId = g.Id
            WHERE op.OrderId = o.Id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS '������ �������',
        ROW_NUMBER() OVER (PARTITION BY o.CustomerId ORDER BY o.OrderDate DESC) AS '���������� ����� ������'
    FROM 
        Orders o
        JOIN Customers c ON o.CustomerId = c.Id
    WHERE 
        o.OrderDate BETWEEN @StartDate AND @EndDate
    ORDER BY 
        o.OrderDate DESC;
END
GO

-- ��������� �������� ������
DECLARE @Orders TABLE (Id UNIQUEIDENTIFIER, CustomerId INT, Status NVARCHAR(50), OrderDate DATETIME);

INSERT INTO @Orders
SELECT 
    NEWID(),
    CustomerId,
    Status,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
FROM (
    VALUES 
        (1, '� ���������'),
        (2, '��������'),
        (3, '���������'),
        (1, '�����'),
        (4, '�������')
) AS TempData(CustomerId, Status);

-- ��������� ������
INSERT INTO Orders (Id, CustomerId, Status, TotalAmount, OrderDate)
SELECT Id, CustomerId, Status, 0, OrderDate FROM @Orders;

-- ��� ������� ������ ��������� �� 1 �� 5 ��������� �������
INSERT INTO OrderProducts (OrderId, ProductId, Quantity)
SELECT 
    o.Id,
    g.Id,
    ABS(CHECKSUM(NEWID())) % 5 + 1 -- ���������� �� 1 �� 5
FROM 
    @Orders o
    CROSS JOIN (
        SELECT TOP 20 Id FROM Products ORDER BY NEWID() -- ����� 20 ��������� �������
    ) g
WHERE 
    (SELECT COUNT(*) FROM OrderProducts op WHERE op.OrderId = o.Id) < 5 -- �� ����� 5 ������� �� �����

GO