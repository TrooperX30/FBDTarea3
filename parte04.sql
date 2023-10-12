CREATE OR REPLACE FUNCTION trigf04() RETURNS trigger AS $$
BEGIN
    IF EXISTS (SELECT 1
               FROM estadias_anteriores e
               WHERE e.hotel_codigo = OLD.hotel_codigo AND
                     e.nro_habitacion = OLD.nro_habitacion AND
                     e.check_in >= OLD.fecha_desde AND
                     NOT EXISTS (SELECT 1
                             FROM costos_habitacion ch
                             WHERE e.hotel_codigo = ch.hotel_codigo AND
                                   e.nro_habitacion = ch.nro_habitacion AND
                                   OLD.fecha_desde < ch.fecha_desde AND
                                   ch.fecha_desde < e.check_in)) THEN
        IF TG_OP = 'UPDATE' THEN
            RAISE NOTICE 'La actualización no es correcta: afecta a estadías existentes';
        ELSIF TG_OP = 'DELETE' THEN
            RAISE NOTICE 'La operación de borrado no es correcta: afecta a estadías existentes';
        END IF;
    ELSE
        RETURN NEW;-- dudoso
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER control_costos BEFORE UPDATE OR DELETE ON costos_habitacion
    FOR EACH ROW 
    EXECUTE FUNCTION trigf04();