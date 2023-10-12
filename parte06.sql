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
		INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
		VALUES (currval('logidseq'), 'I', current_date, current_user, NEW.cliente_documento, NEW.hotel_codigo, NEW.nro_habitacion, NEW.check_in);
	ELSIF TG_OP = 'UPDATE' THEN
		INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
		VALUES (nextval('logidseq'), 'U', current_date, current_user, OLD.cliente_documento, OLD.hotel_codigo, OLD.nro_habitacion, OLD.check_in);
	ELSIF TG_OP = 'DELETE' THEN
		INSERT INTO audit_estadia(idop, accion, fecha, usuario, cliente_documento, hotel_codigo, nro_habitacion, check_in)
		VALUES (nextval('logidseq'), 'D', current_date, current_user, OLD.cliente_documento, OLD.hotel_codigo, OLD.nro_habitacion, OLD.check_in);
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auditoria_estadias BEFORE INSERT OR UPDATE OR DELETE ON estadias_anteriores
	FOR EACH ROW 
    EXECUTE FUNCTION trigf06();
	
--a que se refiere a operaciones que tienen efecto sobre la tabla, puede un IDU no tener efecto?
--que seria una operacion que no tiene efecto sobre la tabla?
--siempre se insertan cosas a la tabla?
--diferencia entre current_date y current_timestamp