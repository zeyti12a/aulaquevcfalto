DELIMITER //
CREATE TRIGGER insere_cliente_auditoria
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem)
    VALUES (CONCAT('Novo cliente inserido: ', NEW.nome, '. Data e hora: ', NOW()));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER tentativa_exclusao_auditoria
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem)
    VALUES (CONCAT('Tentativa de exclusão do cliente com ID ', OLD.id, '. Data e hora: ', NOW()));
  
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Exclusão de clientes não permitida.';
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER atualiza_nome_auditoria
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF OLD.nome != NEW.nome THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Nome do cliente com ID ', NEW.id, ' atualizado de "', OLD.nome, '" para "', NEW.nome, '". Data e hora: ', NOW()));
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER impede_nome_vazio_nulo
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Tentativa de atualização do nome para vazio ou NULL no cliente com ID ', NEW.id, '. Data e hora: ', NOW()));
       
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atualização do nome para vazio ou NULL não permitida.';
    END IF;
END;
//
DELIMITER ; 

DELIMITER //
CREATE TRIGGER atualiza_estoque_pedido
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    DECLARE produto_estoque INT;
    SELECT estoque INTO produto_estoque FROM Produtos WHERE id = NEW.produto_id;
    IF produto_estoque - NEW.quantidade < 5 THEN
        INSERT INTO Auditoria (mensagem)
        VALUES (CONCAT('Estoque baixo para o produto com ID ', NEW.produto_id, '. Estoque atual: ', produto_estoque - NEW.quantidade, '. Data e hora: ', NOW()));
    END IF;

    UPDATE Produtos SET estoque = produto_estoque - NEW.quantidade WHERE id = NEW.produto_id;
END;
//
DELIMITER ;

