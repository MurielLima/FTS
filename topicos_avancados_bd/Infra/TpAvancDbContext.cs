using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace topicos_avancados_bd.Infra
{
    public class TpAvancDbContext : DbContext
    {
        public TpAvancDbContext(DbContextOptions<TpAvancDbContext> options) : base(options)
        {
        }
        public DbSet<Livro> Livros { get; set; }

    }
}
