using System;
using System.Collections.Generic;
using SPA_Test1.Models;
using SPA_Test1.Models.Helpers;

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
        /// Отображаемые имена столбцов таблицы
        /// </summary>
        public IEnumerable<string> DisplayNames => Extensions.GetDisplayNames(typeof(User));

        /// <summary>
        /// Общее количество страниц
        /// </summary>
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);

        /// <summary>
        /// Признак того, что страница не первая
        /// </summary>
        public bool NotFirst => PageNumber > 1;

        /// <summary>
        /// Признак того, что страница не последняя
        /// </summary>
        public bool NotLast => PageNumber < TotalPages;

        /// <summary>
        /// Первая доступная страница
        /// </summary>
        public int StartNumber => Math.Max(1, PageNumber - 3);

        /// <summary>
        /// Последняя доступная страница
        /// </summary>
        public int EndNumber => Math.Min(PageNumber + 3, TotalPages);

        /// <summary>
        /// Доступные размеры страницы
        /// </summary>
        public int[] AvailablePageSizes => new[] { 5, 10, 25, 50, 100 };

        /// <summary>
        /// Получение значения по отображаемому имени свойства
        /// </summary>
        /// <param name="user"></param>
        /// <param name="displayName"></param>
        /// <returns></returns>
        public string GetValueFromDisplayName(User user, string displayName)
        {
            return user.GetFieldValueByDisplayName(displayName);
        }
    }
}