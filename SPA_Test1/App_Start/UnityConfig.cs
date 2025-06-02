using System.Web.Mvc;
using SPA_Test1.Models;
using SPA_Test1.Models.Interfaces;
using SPA_Test1.Models.Repository;
using Unity;
using Unity.AspNet.Mvc;

namespace SPA_Test1
{
    public static class UnityConfig
    {
        public static IUnityContainer Container { get; private set; }

        public static void RegisterComponents()
        {
            Container = new UnityContainer();
            RegisterTypes(Container);
            DependencyResolver.SetResolver(new UnityDependencyResolver(Container));
        }

        public static void RegisterTypes(IUnityContainer container)
        {
            container.RegisterType<AppDbContext>(new PerRequestLifetimeManager());
            container.RegisterType<UsersRepository>();
            container.RegisterType<IRepository<User>, UsersRepository>();
        }
    }
}