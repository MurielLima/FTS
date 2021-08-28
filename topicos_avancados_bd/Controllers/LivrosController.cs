using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using topicos_avancados_bd.Infra;

namespace topicos_avancados_bd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LivrosController : ControllerBase
    {
        private readonly TpAvancDbContext _context;
        private readonly ILogger<LivrosController> _logger;

        public LivrosController(ILogger<LivrosController> logger, TpAvancDbContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        [Route("Search")]
        public IQueryable<object> Search([FromQuery] string text, [FromQuery] bool fts)
        {
            if (fts)
            {
                return _context.Livros.FromSqlRaw(@$"
                        SELECT L.ID,
                               L.TITULO, 
                               L.SUB_TITULO,
                               L.ASSUNTO,
                               A.AUTOR,
                               E.EDITORA,
                               L.ANO
                          FROM LIVROS L 
                          JOIN LIVROS_FTS LF
                            ON L.ID = LF.ID_LIVRO
                          JOIN AUTORES A
                            ON A.ID = L.ID_AUTOR
                          JOIN EDITORAS E
                            ON E.ID = L.ID_EDITORA
                         WHERE TO_TSQUERY('{text}') @@ LF.texto_vetor;"
                      );
            }
            else
            {
                return _context.Livros.FromSqlRaw(@$"
                        SELECT L.ID,
                               L.TITULO, 
                               L.SUB_TITULO,
                               L.ASSUNTO,
                               A.AUTOR,
                               E.EDITORA,
                               L.ANO
                          FROM LIVROS L 
                          JOIN LIVROS_FTS LF
                            ON L.ID = LF.ID_LIVRO
                          JOIN AUTORES A
                            ON A.ID = L.ID_AUTOR
                          JOIN EDITORAS E
                            ON E.ID = L.ID_EDITORA
                         WHERE A.AUTOR LIKE '%{text}%' 
                            OR E.EDITORA LIKE '%{text}%' 
                            OR L.TITULO LIKE '%{text}%' 
                            OR L.SUB_TITULO LIKE '%{text}%' 
                            OR L.ASSUNTO LIKE '%{text}%' 
                            OR L.ANO LIKE '%{text}%';");
            }
            
        }
    }
}
