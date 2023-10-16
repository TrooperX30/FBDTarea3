CREATE OR REPLACE FUNCTION trigf04() RETURNS trigger AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM estadias_anteriores) THEN--si no hay estadias siempre se puede modificar
		IF EXISTS (SELECT 1--hay otros costos ademas del que se modifica
			FROM costos_habitacion ch
			WHERE ch.hotel_codigo = OLD.hotel_codigo AND 
				  ch.nro_habitacion = OLD.nro_habitacion AND 
				  ch.fecha_desde != OLD.fecha_desde) THEN
			IF OLD.fecha_desde != NEW.fecha_desde AND--si se actualizo la fecha
			   OLD.fecha_desde < NEW.fecha_desde AND--la fecha nueva es mayor que la anterior
			   NOT EXISTS (SELECT 1--no existe un costo de habitacion tal que su fecha sea menor al de todas las estadias
						   FROM costos_habitacion ch2
						   WHERE ch2.hotel_codigo = OLD.hotel_codigo AND 
								 ch2.nro_habitacion = OLD.nro_habitacion AND 
								 ch2.fecha_desde != OLD.fecha_desde AND
								 ch2.fecha_desde <= (SELECT MIN(e.check_in)--minimo check_in de las estadias de la habitacion del hotel
													FROM estadias_anteriores e
													WHERE e.hotel_codigo = OLD.hotel_codigo AND
														  e.nro_habitacion = OLD.nro_habitacion)) THEN
				IF TG_OP = 'UPDATE' THEN
					RAISE NOTICE 'La actualización no es correcta';
					RETURN NULL;
				ELSIF TG_OP = 'DELETE' THEN
					RAISE NOTICE 'La operación de borrado no es correcta';
					RETURN NULL;
				END IF;
			END IF;
		ELSE--no hay otros costos ademas del que se modifica
				IF TG_OP = 'UPDATE' THEN
					IF EXISTS (SELECT 1--si existe alguna estadia menor que el unico precio al ser updateado da error
					   FROM estadias_anteriores e
					   WHERE e.hotel_codigo = NEW.hotel_codigo AND
							 e.nro_habitacion = NEW.nro_habitacion AND
					  	 	 e.check_in < NEW.fecha_desde) THEN
						RAISE NOTICE 'La actualización no es correcta';
						RETURN NULL;
					END IF;
				ELSIF TG_OP = 'DELETE' THEN
					RAISE NOTICE 'La operación de borrado no es correcta';
					RETURN NULL;
				END IF;
		END IF;
	END IF;
	RETURN NEW;-- dudoso
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER control_costos BEFORE UPDATE OR DELETE ON costos_habitacion
    FOR EACH ROW 
    EXECUTE FUNCTION trigf04();	