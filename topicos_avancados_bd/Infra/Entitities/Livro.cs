using System;
using System.ComponentModel.DataAnnotations;

namespace topicos_avancados_bd
{
    public class Livro
    {
        [Key]
        public int id { get; set; }
        public string titulo { get; set; }
        public string sub_titulo { get; set; }
        public string assunto { get; set; }
        public string ano { get; set; }
        public string editora { get; set; }
        public string autor { get; set; }

    }
}
