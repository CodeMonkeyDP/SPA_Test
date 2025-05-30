using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Reflection;

namespace SPA_Test1.Models.Helpers
{
    public static class Extensions
    {
        /// <summary>
        /// Получить список отображаемых имён для формирования заголовка таблицы
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static IEnumerable<string> GetDisplayNames(Type type)
        {
            var props = type.GetProperties();
            return from fi in props
                select fi.GetCustomAttribute<DisplayAttribute>()
                into attr
                where attr != null
                select attr.GetName();
        }

        /// <summary>
        /// Получить значение поля по отображаемому имени
        /// </summary>
        /// <param name="user"></param>
        /// <param name="displayName"></param>
        /// <returns></returns>
        public static string GetFieldValueByDisplayName(this User user, string displayName)
        {
            var type = typeof(User);
            var fi = type.GetProperties().FirstOrDefault(f =>
            {
                var attr = f.GetCustomAttribute<DisplayAttribute>();
                return attr != null && attr.GetName() == displayName;
            });
            var value = fi.GetValue(user);
            return value.ToString();
        }
    }
}