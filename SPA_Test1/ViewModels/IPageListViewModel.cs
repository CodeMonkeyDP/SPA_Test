using System.Collections.Generic;

namespace SPA_Test1.ViewModels
{
    /// <summary>
    /// Интерфейс модели многостраничного списка для представлений
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public interface IPageListViewModel<T>
    {
        /// <summary>
        /// Элементы списка с текущей страницы
        /// </summary>
        List<T> Items { get; }

        /// <summary>
        /// Всего элементов
        /// </summary>
        int TotalCount { get; }

        /// <summary>
        /// Номер страницы
        /// </summary>
        int PageNumber { get; }

        /// <summary>
        /// Количество элементов
        /// </summary>
        int PageSize { get; }
    }
}