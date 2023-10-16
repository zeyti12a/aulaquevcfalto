DELIMITER //
CREATE FUNCTION total_livros_por_genero(genero_nome VARCHAR(255)) RETURNS INT
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM Livro
    INNER JOIN Genero ON Livro.id_genero = Genero.id
    WHERE Genero.nome_genero = genero_nome;
    
    RETURN total;
END;
//
DELIMITER ;
DELIMITER //
CREATE FUNCTION listar_livros_por_autor(primeiro_nome VARCHAR(255), ultimo_nome VARCHAR(255)) RETURNS TEXT
BEGIN
    DECLARE livros TEXT;
    
    SELECT GROUP_CONCAT(Livro.titulo) INTO livros
    FROM Livro
    INNER JOIN Livro_Autor ON Livro.id = Livro_Autor.id_livro
    INNER JOIN Autor ON Livro_Autor.id_autor = Autor.id
    WHERE Autor.primeiro_nome = primeiro_nome AND Autor.ultimo_nome = ultimo_nome;
    
    RETURN livros;
END;
//
DELIMITER ;
DELIMITER //
CREATE PROCEDURE atualizar_resumos()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE livro_id INT;
    DECLARE livro_resumo TEXT;
    DECLARE cur CURSOR FOR SELECT id, resumo FROM Livro;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO livro_id, livro_resumo;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET livro_resumo = CONCAT(livro_resumo, ' Este é um excelente livro!');
        
        UPDATE Livro SET resumo = livro_resumo WHERE id = livro_id;
    END LOOP;
    
    CLOSE cur;
END;
//
DELIMITER ;
DELIMITER //
CREATE FUNCTION media_livros_por_editora() RETURNS DECIMAL(5,2)
BEGIN
    DECLARE total_editoras INT;
    DECLARE total_livros INT;
    DECLARE media DECIMAL(5,2);
    
    SELECT COUNT(DISTINCT id_editora) INTO total_editoras FROM Livro;
    SELECT COUNT(*) INTO total_livros FROM Livro;
    
    SET media = total_livros / total_editoras;
    
    RETURN media;
END;
//
DELIMITER ;
DELIMITER //
CREATE FUNCTION autores_sem_livros() RETURNS TEXT
BEGIN
    DECLARE autor_list TEXT;
    DECLARE done INT DEFAULT 0;
    DECLARE autor_id INT;
    
    DECLARE cur CURSOR FOR SELECT id FROM Autor;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    
    SET autor_list = '';
    
    read_loop: LOOP
        FETCH cur INTO autor_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM Livro_Autor WHERE id_autor = autor_id) THEN
            SET autor_list = CONCAT(autor_list, ',', autor_id);
        END IF;
    END LOOP;
    
    CLOSE cur;
    
    RETURN SUBSTRING(autor_list, 2);
END;
//
DELIMITER ;
