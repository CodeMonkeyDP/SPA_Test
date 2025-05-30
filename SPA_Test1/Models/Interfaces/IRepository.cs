using System.Collections.Generic;
using System.Linq;

namespace SPA_Test1.Models.Interfaces
{
    /// <summary>
    /// Обёртка над AppDbContext для сущностей типа T
    /// </summary>
    /// <typeparam name="T">Тип элементов</typeparam>
    public interface IRepository<T>
    {
        /// <summary>
        /// Добавить сущность
        /// </summary>
        /// <param name="item"></param>
        void Add(T item);

        /// <summary>
        /// Удалить сущность
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        bool Remove(T item);

        /// <summary>
        /// Список всех сущностей
        /// </summary>
        IEnumerable<T> Items { get; }

        /// <summary>
        /// Получить список для конкретной страницы
        /// </summary>
        /// <param name="page">Страница</param>
        /// <param name="count">Количество</param>
        /// <returns></returns>
        IQueryable<T> Query(int page, int count);
    }
}