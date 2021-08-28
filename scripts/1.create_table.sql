CREATE TABLE Autores (id SERIAL PRIMARY KEY,
                                        autor TEXT NOT NULL);


CREATE TABLE Materiais (id SERIAL PRIMARY KEY,
                                          tipo_material CHARACTER varying(25) NOT NULL);


CREATE TABLE Editoras (id SERIAL PRIMARY KEY,
                                         editora CHARACTER varying(300) NOT NULL);


CREATE TABLE Livros (id SERIAL PRIMARY KEY,
                                       registro_sistema integer, titulo TEXT NOT NULL,
                                                                             sub_titulo TEXT, assunto TEXT NOT NULL,
                                                                                                           edicao TEXT, ano TEXT, issn TEXT, isbn TEXT, id_autor integer REFERENCES Autores(id),
                                                                                                                                                                                    id_material integer NOT NULL REFERENCES Materiais(id),
                                                                                                                                                                                                                            id_editora integer REFERENCES Editoras(id));


CREATE TABLE Estoque (id SERIAL PRIMARY KEY,
                                        quantidade integer, id_livro integer NOT NULL REFERENCES Livros(id));


CREATE TABLE LIVROS_FTS (id_livro integer REFERENCES Livros(id),
						 texto_vetor
                         TSVECTOR);


CREATE INDEX IDX_TEXTO_VECTOR ON LIVROS_FTS USING GIN(TEXTO_VETOR);


CREATE OR REPLACE FUNCTION create_ts_vector_livro() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
declare
EDITORA character varying(300);
AUTOR TEXT;
begin
	SELECT E.EDITORA into editora FROM EDITORAS E WHERE E.ID = NEW.ID_EDITORA;
	SELECT A.AUTOR into autor FROM AUTORES A WHERE a.ID = NEW.ID_AUTOR;
	INSERT INTO LIVROS_FTS (TEXTO_VETOR, ID_LIVRO) VALUES (to_TSVECTOR(NEW.TITULO||' '||NEW.SUB_TITULO||' '||NEW.ASSUNTO||' '||NEW.ANO||' '||EDITORA||' '||AUTOR), NEW.ID);
	return new;
end;$$;

CREATE OR REPLACE FUNCTION update_ts_vector_livro() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
declare
EDITORA character varying(300);
AUTOR TEXT;
begin
	SELECT E.EDITORA into editora FROM EDITORAS E WHERE E.ID = NEW.ID_EDITORA;
	SELECT A.AUTOR into autor FROM AUTORES A WHERE a.ID = NEW.ID_AUTOR;
	UPDATE LIVROS_FTS SET TEXTO_VETOR = to_TSVECTOR(NEW.TITULO||' '||NEW.SUB_TITULO||' '||NEW.ASSUNTO||' '||NEW.ANO||' '||EDITORA||' '||AUTOR) WHERE LIVROS_FTS.ID_LIVRO = NEW.ID;
	return new;
end;$$;

CREATE TRIGGER tg_livro_vetor_CREATE
after
INSERT
OR
UPDATE ON LIVROS
FOR EACH ROW EXECUTE FUNCTION create_ts_vector_livro();

CREATE TRIGGER tg_livro_vetor_UPDATE
after
UPDATE ON LIVROS
FOR EACH ROW EXECUTE FUNCTION UPDATE_ts_vector_livro();