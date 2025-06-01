USE ShopDemo;
GO

DECLARE @StartDate DATETIME = DATEADD(DAY, -365, GETDATE());
DECLARE @EndDate DATETIME = GETDATE();

EXEC GetOrdersReport @StartDate, @EndDate;
GO