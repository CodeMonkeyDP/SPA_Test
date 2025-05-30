using System;
using System.Collections.Generic;
using SPA_Test1.Models;

namespace SPA_Test1.ViewModels
{
    /// <summary>
    /// Модель представления многостраничного списка пользователей
    /// </summary>
    public class UsersViewModel : IPageListViewModel<User>
    {
        /// <summary>
        /// Элементы списка с текущей страницы
        /// </summary>
        public List<User> Items { get; set; }

        /// <summary>
        /// Всего элементов
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// Номер страницы
        /// </summary>
        public int PageNumber { get; set; }

        /// <summary>
        /// Количество элементов на странице
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Общее количество страниц
        /// </summary>
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
    }
}