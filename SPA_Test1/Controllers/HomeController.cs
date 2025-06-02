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
        #region Constants

        private const int DEFAULT_PAGE = 1;
        private const int DEFAULT_PAGE_SIZE = 10;

        #endregion

        private readonly UsersRepository _users;

        public HomeController(UsersRepository usersRepository)
        {
            _users = usersRepository;
        }

        /// <summary>
        /// Отображение домашней страницы
        /// </summary>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <returns></returns>
        public ActionResult Index(int? page, int? pageSize)
        {
            // Устанавливаем значения по умолчанию если null
            int currentPage = page ?? DEFAULT_PAGE;
            int currentPageSize = pageSize ?? DEFAULT_PAGE_SIZE;

            // Проверяем допустимые значения
            int[] allowedPageSizes = UsersViewModel.ALLOWED_PAGE_SIZES;
            if (!allowedPageSizes.Contains(currentPageSize))
            {
                currentPageSize = DEFAULT_PAGE_SIZE;
            }

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
    }
}