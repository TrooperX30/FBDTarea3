DROP TABLE audit_estadia;

CREATE TABLE audit_estadia(
                idop integer,
                accion char(1),
                fecha date,
                usuario text,
				cliente_documento integer,
                hotel_codigo integer,
                nro_habitacion smallint,
                check_in date,
                PRIMARY KEY(idop));--creo la tabla de los finguitos

DROP SEQUENCE logidseq;

CREATE SEQUENCE logidseq
    START WITH 1
    INCREMENT BY 1;
	
CREATE OR REPLACE FUNCTION trigf06() RETURNS trigger AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		IF NOT EXISTS (SELECT 1
					   FROM estadias_anteriores e
					   WHERE e.hotel_codigo = OLD.hotel_codigo AND
							 e.nro_habitacion = OLD.nro_habitacion AND
							 e.cliente_documento = OLD.cliente_documento AND
							 e.check_in = OLD.check_in) THEN
			INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
			VALUES (nextval('logidseq'), 'I', current_date, current_user, NEW.cliente_documento, NEW.hotel_codigo, NEW.nro_habitacion, NEW.check_in);
		END IF;
	ELSIF TG_OP = 'UPDATE' THEN
		IF OLD.cliente_documento != NEW.cliente_documento OR
		   OLD.hotel_codigo != NEW.hotel_codigo OR
		   OLD.nro_habitacion != NEW.nro_habitacion OR
		   OLD.check_in != NEW.check_in OR
		   OLD.check_out != NEW.check_out THEN
			INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
			VALUES (nextval('logidseq'), 'U', current_date, current_user, OLD.cliente_documento, OLD.hotel_codigo, OLD.nro_habitacion, OLD.check_in);
		END IF;
	ELSIF TG_OP = 'DELETE' THEN
		IF EXISTS (SELECT 1
				   FROM estadias_anteriores e
				   WHERE e.hotel_codigo = OLD.hotel_codigo AND
				  		 e.nro_habitacion = OLD.nro_habitacion AND
				 		 e.cliente_documento = OLD.cliente_documento AND
				  		 e.check_in = OLD.check_in) THEN
			INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
			VALUES (nextval('logidseq'), 'D', current_date, current_user, OLD.cliente_documento, OLD.hotel_codigo, OLD.nro_habitacion, OLD.check_in);
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_estadias BEFORE INSERT OR UPDATE OR DELETE ON estadias_anteriores
	FOR EACH ROW 
    EXECUTE FUNCTION trigf06();
	
--a que se refiere a operaciones que tienen efecto sobre la tabla, puede un IDU no tener efecto?
--que seria una operacion que no tiene efecto sobre la tabla?
--siempre se insertan cosas a la tabla?
--diferencia entre current_date y current_timestamp