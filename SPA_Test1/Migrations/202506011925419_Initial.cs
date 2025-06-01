namespace SPA_Test1.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class Initial : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                    "dbo.Users",
                    c => new
                    {
                        Id = c.Int(nullable: false, identity: true),
                        Name = c.String(maxLength: 100),
                        Surname = c.String(maxLength: 100),
                        Date = c.DateTime(nullable: false, defaultValueSql: "GETDATE()"),
                    })
                .PrimaryKey(t => t.Id);

            CreateIndex("dbo.Users", "Date", name: "IX_Users_Date");
            CreateIndex("dbo.Users", "Surname", name: "IX_Users_Surname");
            CreateIndex("dbo.Users", "Name", name: "IX_Users_Name");
            CreateIndex("dbo.Users", new[] { "Name", "Surname" }, name: "IX_Users_Name_Surname");

            Sql(@"
                ;WITH Numbers AS (
                    SELECT TOP 100000 
                        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
                    FROM sys.objects a
                    CROSS JOIN sys.objects b
                    CROSS JOIN sys.objects c
                )
                INSERT INTO Users (Name, Surname, Date)
                SELECT 
                    'User-' + CAST(n AS NVARCHAR(10)),
                    'Surname-' + CAST(ABS(CHECKSUM(NEWID())) % 1000 + 1 AS NVARCHAR(10)),
                    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 3650, GETDATE())
                FROM Numbers
            ");
        }
        
        public override void Down()
        {
            DropIndex("dbo.Users", "IX_Users_Name_Surname");
            DropIndex("dbo.Users", "IX_Users_Name");
            DropIndex("dbo.Users", "IX_Users_Surname");
            DropIndex("dbo.Users", "IX_Users_Date");
            DropTable("dbo.Users");
        }
    }
}
