--Проверяем, что БД не создана ранее
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'UsersDemo')
BEGIN
    CREATE DATABASE UsersDemo;
END

GO

USE UsersDemo;
GO

-- Проверяем, что таблицы Users нет
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users' AND type = 'U')
BEGIN
    -- Создаём таблицу
    CREATE TABLE Users (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100),
        Surname NVARCHAR(100),
        Date DATETIME
    );
    ALTER TABLE Users ADD CONSTRAINT DF_Users_Date DEFAULT GETDATE() FOR Date;
    -- Создаём индексы
    CREATE INDEX IX_Users_Date ON Users(Date);
    CREATE INDEX IX_Users_Surname ON Users(Surname);
    CREATE INDEX IX_Users_Name ON Users(Name);
    CREATE INDEX IX_Users_Name_Surname ON Users(Name, Surname);

    -- Генерируем 100000 записей
    WITH Numbers AS (
    SELECT TOP 100000 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM master.dbo.spt_values v1
    CROSS JOIN master.dbo.spt_values v2
)
INSERT INTO Users (Name, Surname, Date)
SELECT 
    'User-' + CAST(n AS NVARCHAR(10)),
    'Surname-' + CAST(ABS(CHECKSUM(NEWID())) % 1000 + 1 AS NVARCHAR(10)),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 3650, GETDATE())
FROM Numbers;
END