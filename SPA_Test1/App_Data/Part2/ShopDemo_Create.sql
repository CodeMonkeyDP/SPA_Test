--Проверяем, что БД не создана ранее
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ShopDemo')
BEGIN
    CREATE DATABASE ShopDemo;
END

GO

USE ShopDemo;
GO

-- Проверяем, что таблицы Customers нет
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers' AND type = 'U')
BEGIN
    -- Создаём таблицу Customers
    CREATE TABLE Customers (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100),
        Surname NVARCHAR(100),
        Birthdate DATETIME
    );
    ALTER TABLE Customers ADD CONSTRAINT DF_Customers_Date DEFAULT GETDATE() FOR Birthdate;
    -- Создаём индексы
    CREATE INDEX IX_Customers_Date ON Customers(Birthdate);
    CREATE INDEX IX_Customers_Surname ON Customers(Surname);
    CREATE INDEX IX_Customers_Name ON Customers(Name);
    CREATE INDEX IX_Customers_Name_Surname ON Customers(Name, Surname);

    INSERT INTO Customers (Name, Surname, Birthdate)
    VALUES
        ('Дмитрий', 'Прокуров', '19980520'),
        ('Иван', 'Иванов', '19950101'),
        ('Сергей', 'Сергеев', '19910101'),
        ('Игорь', 'Петров', '19870103'),
        ('Василий', 'Сидоров', '20010401');
END

GO

-- Проверяем, что таблицы Products нет
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products' AND type = 'U')
BEGIN
    -- Создаём таблицу Products
    CREATE TABLE Products (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100),
        Price DECIMAL(18, 2) NOT NULL DEFAULT 100.00
    );
    CREATE INDEX IX_Products_Name ON Products(Name);

    -- Генерируем 1000 записей
    WITH Numbers AS (
        SELECT TOP 1000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM master.dbo.spt_values v1
        CROSS JOIN master.dbo.spt_values v2
    )

    INSERT INTO Products (Name, Price)
    SELECT
        'Product-' + CAST(n AS NVARCHAR(10)),
        50 + (ABS(CHECKSUM(NEWID())) % 1950) -- Случайная цена от 50 до 2000
    FROM Numbers
END

GO

--Создаём таблицу заказов
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Orders' AND type = 'U')
BEGIN
    CREATE TABLE Orders (
        Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
        CustomerId INT NOT NULL,
        OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
        Status NVARCHAR(50) NOT NULL,
        TotalAmount DECIMAL(18, 2) NOT NULL,
        -- Внешний ключ для связи с таблицей заказчиков
        CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
    );
    
    -- Создаем таблицу для связи товаров и заказов (многие ко многим)
    CREATE TABLE OrderProducts (
        OrderId UNIQUEIDENTIFIER NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL DEFAULT 1,
        Price DECIMAL(18, 2) NOT NULL,
        CONSTRAINT PK_OrderProducts PRIMARY KEY (OrderId, ProductId),
        CONSTRAINT FK_OrderProducts_Orders FOREIGN KEY (OrderId) REFERENCES Orders(Id),
        CONSTRAINT FK_OrderProducts_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
    
    -- Создаем индекс для ускорения поиска по дате заказа
    CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
    CREATE INDEX IX_Orders_CustomerId ON Orders(CustomerId);
    CREATE INDEX IX_Orders_Status ON Orders(Status);
END

GO

ALTER TABLE OrderProducts ALTER COLUMN Price DECIMAL(18, 2) NOT NULL;
GO

-- Создаём триггер для таблицы OrderProducts, чтобы при добавлении товара автоматически рассчитывалась цена заказа
CREATE OR ALTER TRIGGER tr_OrderProducts_Insert
ON OrderProducts
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Вставляем записи с автоматическим заполнением цены из таблицы Products
    INSERT INTO OrderProducts (OrderId, ProductId, Quantity, Price)
    SELECT 
        i.OrderId, 
        i.ProductId, 
        ISNULL(i.Quantity, 1), -- Если количество не указано, ставим 1
        p.Price -- Берем цену из таблицы Products
    FROM 
        inserted i
        JOIN Products p ON i.ProductId = p.Id;
        
    -- Обновляем общую сумму в заказе
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

-- Создаём процедуру отчёта
CREATE OR ALTER PROCEDURE GetOrdersReport
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        o.OrderDate AS 'Дата заказа',
        o.TotalAmount AS 'Сумма заказа',
        o.Status AS 'Статус заказа',
        c.Name + ' ' + c.Surname AS 'Имя заказчика',
        STUFF((
            SELECT '; ' + g.Name + ' (' + CAST(op.Quantity AS VARCHAR(10)) + 'x' + CAST(op.Price AS VARCHAR(10)) + ')'
            FROM OrderProducts op
            JOIN Products g ON op.ProductId = g.Id
            WHERE op.OrderId = o.Id
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS 'Список товаров',
        ROW_NUMBER() OVER (PARTITION BY o.CustomerId ORDER BY o.OrderDate DESC) AS 'Порядковый номер заказа'
    FROM 
        Orders o
        JOIN Customers c ON o.CustomerId = c.Id
    WHERE 
        o.OrderDate BETWEEN @StartDate AND @EndDate
    ORDER BY 
        o.OrderDate DESC;
END
GO

-- Добавляем тестовые заказы
DECLARE @Orders TABLE (Id UNIQUEIDENTIFIER, CustomerId INT, Status NVARCHAR(50), OrderDate DATETIME);

INSERT INTO @Orders
SELECT 
    NEWID(),
    CustomerId,
    Status,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
FROM (
    VALUES 
        (1, 'В обработке'),
        (2, 'Выполнен'),
        (3, 'Отправлен'),
        (1, 'Новый'),
        (4, 'Отменен')
) AS TempData(CustomerId, Status);

-- Вставляем заказы
INSERT INTO Orders (Id, CustomerId, Status, TotalAmount, OrderDate)
SELECT Id, CustomerId, Status, 0, OrderDate FROM @Orders;

-- Для каждого заказа добавляем от 1 до 5 случайных товаров
INSERT INTO OrderProducts (OrderId, ProductId, Quantity)
SELECT 
    o.Id,
    g.Id,
    ABS(CHECKSUM(NEWID())) % 5 + 1 -- Количество от 1 до 5
FROM 
    @Orders o
    CROSS JOIN (
        SELECT TOP 20 Id FROM Products ORDER BY NEWID() -- Берем 20 случайных товаров
    ) g
WHERE 
    (SELECT COUNT(*) FROM OrderProducts op WHERE op.OrderId = o.Id) < 5 -- Не более 5 товаров на заказ

GO