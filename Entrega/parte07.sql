CREATE TABLE finguitos_usuarios(
                cliente_documento integer,
                hotel_codigo integer,
                check_in date,
                check_out date,
				fecha_inicio date,
                fecha_fin date,
                finguitos int,
                fecha_operacion timestamp,
				estado smallint,
                PRIMARY KEY(cliente_documento, hotel_codigo, check_in));--creo la tabla de los finguitos

CREATE OR REPLACE FUNCTION trigf07() RETURNS trigger AS $$
DECLARE
	cant_finguitos int;
	precio numeric(8,2);
	estado_finguitos smallint;
	inicio date;
	fin date;
	timestamp_actual timestamp;
	mis_estadias_finguitos record;
BEGIN
    IF TG_OP = 'INSERT' THEN
		SELECT NEW.check_in + interval '1 month' INTO inicio;--calculo inicio
		SELECT NEW.check_out + interval '2 years' INTO fin;--calculo fin
		IF EXISTS (SELECT 1
				   FROM estadias_anteriores e
				   WHERE e.hotel_codigo = NEW.hotel_codigo AND 
				   		 e.cliente_documento = NEW.cliente_documento) THEN--si ya tiene otra estadia
			cant_finguitos := 5;--ya tiene estadia en el hotel
		ELSE
			cant_finguitos := 0;--no tiene estadia en el hotel
		END IF;
		SELECT ch.precio_noche INTO precio--precio mas reciente
		FROM costos_habitacion ch
		WHERE ch.hotel_codigo = NEW.hotel_codigo AND
			  ch.nro_habitacion = NEW.nro_habitacion AND
			  ch.fecha_desde = (SELECT MAX(ch2.fecha_desde)
			  				    FROM costos_habitacion ch2
			  				    WHERE ch2.hotel_codigo = NEW.hotel_codigo AND
			    				  	  ch2.nro_habitacion = NEW.nro_habitacion);
		cant_finguitos := cant_finguitos + floor((precio * (NEW.check_out - NEW.check_in))/10);--calculo finguitos
		SELECT NOW() INTO timestamp_actual;--fecha actual
		IF timestamp_actual < fin THEN--si fecha actual menor a fin
			estado_finguitos := 1;--activos
		ELSE
			estado_finguitos := 2;--vencidos
		END IF;
		INSERT INTO finguitos_usuarios(cliente_documento, hotel_codigo, check_in, check_out, fecha_inicio, fecha_fin, finguitos, fecha_operacion, estado) 
               VALUES (NEW.cliente_documento, NEW.hotel_codigo, NEW.check_in, NEW.check_out, inicio, fin, cant_finguitos, timestamp_actual, estado_finguitos);
		FOR mis_estadias_finguitos IN (SELECT * FROM finguitos_usuarios WHERE cliente_documento = NEW.cliente_documento) LOOP
			IF mis_estadias_finguitos.fecha_fin < current_timestamp THEN--actualizo las que se vencieron
				UPDATE finguitos_usuarios
				SET estado = 2
				WHERE cliente_documento = NEW.cliente_documento;
			END IF;
		END LOOP;
	ELSIF TG_OP = 'UPDATE' THEN
		IF EXISTS (SELECT 1
				   FROM finguitos_usuarios fu
				   WHERE fu.cliente_documento = OLD.cliente_documento AND
				   	     fu.hotel_codigo = OLD.hotel_codigo AND
				  		 fu.check_in = OLD.check_in) THEN--si existe la cosa
			--que es lo que puede ser updateado? cualquier campo de la estadia?
			IF EXISTS (SELECT 1
					   FROM estadias_anteriores e
					   WHERE e.hotel_codigo = NEW.hotel_codigo AND 
					   		 e.cliente_documento = NEW.cliente_documento AND 
					   		 e.check_in <> NEW.check_in) THEN--que tenga otra estadia en el mismo hotel
				cant_finguitos := 5;--ya tiene estadia en el hotel
			ELSE
				cant_finguitos := 0;--no tiene estadia en el hotel
			END IF;
			SELECT ch.precio_noche INTO precio--precio mas reciente
			FROM costos_habitacion ch
			WHERE ch.hotel_codigo = NEW.hotel_codigo AND
				  ch.nro_habitacion = NEW.nro_habitacion AND
				  ch.fecha_desde = (SELECT MAX(ch2.fecha_desde)
				  				    FROM costos_habitacion ch2
				  				    WHERE (ch2.hotel_codigo = NEW.hotel_codigo AND
				    				  	   ch2.nro_habitacion = NEW.nro_habitacion));
			cant_finguitos := cant_finguitos + floor((precio * (NEW.check_out - NEW.check_in))/10);--calculo finguitos
			SELECT NOW() INTO timestamp_actual;--fecha actual
			IF timestamp_actual < fin THEN--si fecha actual menor a fin
				estado_finguitos := 1;--activos
			ELSE
				estado_finguitos := 2;--vencidos
			END IF;
			UPDATE finguitos_usuarios
			SET cliente_documento = NEW.cliente_documento,
				hotel_codigo = NEW.hotel_codigo,
				check_in = NEW.check_in,
				check_out = NEW.check_out,
				fecha_inicio = NEW.check_in + interval '1 month',
                fecha_fin = NEW.check_out + interval '2 years',
                finguitos = cant_finguitos,
                fecha_operacion = timestamp_actual,
				estado = estado_finguitos
			WHERE cliente_documento = OLD.cliente_documento AND hotel_codigo = OLD.hotel_codigo AND check_in = OLD.check_in;
			FOR mis_estadias_finguitos IN (SELECT * FROM finguitos_usuarios WHERE cliente_documento = NEW.cliente_documento) LOOP
				IF mis_estadias_finguitos.fecha_fin < current_timestamp AND mis_estadias_finguitos.estado = 1 THEN--actualizo las que se vencieron
					UPDATE finguitos_usuarios
					SET estado = 2
					WHERE cliente_documento = NEW.cliente_documento;
				END IF;
			END LOOP;
		END IF;
	ELSIF TG_OP = 'DELETE' THEN
		RAISE NOTICE 'DELETEEEEEEEEEEEE';
		IF EXISTS (SELECT 1--si existe la cosa?????? no lo pide
				   FROM finguitos_usuarios fu
				   WHERE fu.cliente_documento = OLD.cliente_documento AND
				   	     fu.hotel_codigo = OLD.hotel_codigo AND
				  		 fu.check_in = OLD.check_in) THEN
			RAISE NOTICE 'LEASDFASDFASDFAS';
			UPDATE finguitos_usuarios--actualizo los finguitos a cancelados
			SET estado = 3
			WHERE cliente_documento = OLD.cliente_documento AND hotel_codigo = OLD.hotel_codigo AND check_in = OLD.check_in;
		END IF;
	END IF;
	RETURN coalesce(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER finguitos BEFORE INSERT OR UPDATE OR DELETE ON estadias_anteriores
	FOR EACH ROW 
    EXECUTE FUNCTION trigf07();