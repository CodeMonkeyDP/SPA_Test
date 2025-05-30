using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using SPA_Test1.Models;
using SPA_Test1.Models.Repository;
using SPA_Test1.ViewModels;

namespace SPA_Test1.Controllers
{
    public class HomeController : Controller
    {
        private readonly AppDbContext _context = new AppDbContext();
        private UsersRepository _users;
        

        /// <summary>
        /// Отображение домашней страницы
        /// </summary>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        public ActionResult Index(int? page, int? pageSize)
        {
            // Устанавливаем значения по умолчанию если null
            int currentPage = page ?? 1;
            int currentPageSize = pageSize ?? 10;

            // Проверяем допустимые значения
            int[] allowedPageSizes = { 5, 10, 25, 50, 100 };
            if (!allowedPageSizes.Contains(currentPageSize))
            {
                currentPageSize = 10;
            }
            
            if (_users == null)
                _users = new UsersRepository(_context);

            // Получаем пользователей для данной страницы
            var query = _users.Query(currentPage, currentPageSize);

            UsersViewModel viewModel = new UsersViewModel
            {
                Items = query.ToList(),
                PageNumber = currentPage,
                PageSize = currentPageSize,
                TotalCount = _users.GetTotalCount
            };

            return View(viewModel);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                // Очищаем память от DB Context
                _context.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}