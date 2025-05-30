using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SPA_Test1.Models
{
    /// <summary>
    /// Данные пользователя
    /// </summary>
    public class User
    {
        /// <summary>
        /// Первичный ключ
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Имя
        /// </summary>
        [Display(Name = "Имя")]
        public string Name { get; set; }

        /// <summary>
        /// Фамилия
        /// </summary>
        [Display(Name = "Фамилия")]
        public string Surname { get; set; }

        /// <summary>
        /// День рождения
        /// </summary>
        [Display(Name = "Дата рождения")]
        public DateTime Date { get; set; }


    }
}