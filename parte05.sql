DROP TABLE registro_uso;

CREATE TABLE registro_uso(
                usuario text,
                tabla name,
                fecha date,
                cantidad integer,
                PRIMARY KEY(usuario, tabla,fecha));

CREATE OR REPLACE FUNCTION trigf05() RETURNS trigger AS $$
DECLARE
	cant int;
BEGIN
    IF EXISTS (SELECT 1 
               FROM registro_uso 
               WHERE usuario = current_user AND 
               tabla = TG_TABLE_NAME AND
               fecha = current_date) THEN
        SELECT r.cantidad INTO cant
        FROM registro_uso r
        WHERE r.usuario = current_user AND 
              r.tabla = TG_TABLE_NAME AND
              r.fecha = current_date;
			  
        UPDATE registro_uso 
		SET cantidad = cant + 1 
		WHERE usuario = current_user AND tabla = TG_TABLE_NAME AND fecha = current_date;
    ELSE
        INSERT INTO registro_uso(usuario, tabla, fecha, cantidad) 
               VALUES (current_user, TG_TABLE_NAME, current_date, 1);
    END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER registro_operaciones BEFORE INSERT OR UPDATE OR DELETE ON estadias_anteriores
    FOR EACH ROW 
    EXECUTE FUNCTION trigf05();
    
CREATE OR REPLACE TRIGGER registro_operaciones BEFORE INSERT OR UPDATE OR DELETE ON reservas_anteriores
    FOR EACH ROW 
    EXECUTE FUNCTION trigf05();
    
CREATE OR REPLACE TRIGGER registro_operaciones BEFORE INSERT OR UPDATE OR DELETE ON clientes
    FOR EACH ROW 
    EXECUTE FUNCTION trigf05();