using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace SPA_Test1.Models
{
    /// <summary>
    /// Контекст БД
    /// </summary>
    public class AppDbContext : DbContext
    {
        public AppDbContext() : base("name=AppDbContext")
        {
            // Логирование
            Database.Log = sql => System.Diagnostics.Debug.WriteLine(sql);

            Configuration.LazyLoadingEnabled = false;
            Configuration.ProxyCreationEnabled = false;
            //Database.CommandTimeout = 180;
            Database.CommandTimeout = 300;
        }

        public DbSet<User> Users { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            Database.SetInitializer<AppDbContext>(null);
            modelBuilder.Entity<User>()
                .ToTable("Users", "dbo")
                .HasKey(u => u.Id);
        }
    }
}