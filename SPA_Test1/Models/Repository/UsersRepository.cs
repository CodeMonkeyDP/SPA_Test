using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using SPA_Test1.Models.Interfaces;

namespace SPA_Test1.Models.Repository
{
    /// <summary>
    /// Репозиторий для пользователей
    /// </summary>
    public class UsersRepository : IRepository<User>
    {
        private AppDbContext _dbContext;

        public UsersRepository(AppDbContext context)
        {
            _dbContext = context;
        }

        /// <summary>
        /// Добавить пользователя
        /// </summary>
        /// <param name="item"></param>
        public void Add(User item)
        {
            _dbContext.Users.Add(item);
        }

        /// <summary>
        /// Удалить пользователя
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public bool Remove(User item)
        {
            return _dbContext.Users.Remove(item) != null;
        }

        /// <summary>
        /// Список всех пользователей
        /// </summary>
        public IEnumerable<User> Items => _dbContext.Users;

        /// <summary>
        /// Получить список пользователей для конкретной страницы
        /// </summary>
        /// <param name="page"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        public IQueryable<User> Query(int page, int count)
        {
            return _dbContext.Users
                .OrderBy(u => u.Id)
                .Skip((page - 1) * count)
                .Take(count)
                .AsNoTracking();
        }

        /// <summary>
        /// Общее число пользователей
        /// </summary>
        public int GetTotalCount
        {
            get
            {
                return _dbContext.Users.Count();
            }
        }
    }
}