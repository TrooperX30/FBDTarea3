CREATE OR REPLACE FUNCTION ingreso_extra(codhotel integer, OUT tipohab smallint, OUT monto numeric(8,2)) RETURNS SETOF record AS $$
DECLARE
	th record;
	ee record;
BEGIN
	FOR th IN (SELECT DISTINCT h.tipo_habitacion_codigo-- itero por cada tipo de habitacion que tenga al menos 1 estadia espontanea
			   FROM habitaciones h
			   WHERE h.hotel_codigo = codhotel AND
			   		 EXISTS (SELECT 1
							 FROM estadias_anteriores e
							 WHERE e.hotel_codigo = codhotel AND
							 	   e.nro_habitacion = h.nro_habitacion AND
							 	   NOT EXISTS(SELECT 1
											  FROM reservas_anteriores r
											  WHERE e.hotel_codigo = r.hotel_codigo AND
												    e.nro_habitacion = r.nro_habitacion AND
												    e.check_in = r.check_in))) LOOP
		DECLARE
			suma_costos numeric(8,2) := 0;
		BEGIN
			FOR ee IN (SELECT * -- itero por cada estadia espontanea de th
					   FROM estadias_anteriores e NATURAL JOIN habitaciones h2
					   WHERE e.hotel_codigo = codhotel AND
					   		 h2.tipo_habitacion_codigo = th.tipo_habitacion_codigo AND
							 NOT EXISTS (SELECT 1
										 FROM reservas_anteriores r
										 WHERE r.hotel_codigo = codhotel AND
										 r.nro_habitacion = e.nro_habitacion AND
										 r.check_in = e.check_in)) LOOP
				IF EXISTS (SELECT 1-- que haya algun precio previamente establecido
						   FROM costos_habitacion ch
						   WHERE (ch.fecha_desde - ee.check_in) < 0 AND
								  ch.hotel_codigo = codhotel AND
								  ch.nro_habitacion = ee.nro_habitacion) THEN
					DECLARE
						precio numeric(8,2) := 0;
					BEGIN
						SELECT ch2.precio_noche INTO precio-- devuelve el precio que habia en la fecha mas cercana al check_in de la estadia
						FROM costos_habitacion ch2
						WHERE ch2.hotel_codigo = codhotel AND
							  ch2.nro_habitacion = ee.nro_habitacion AND
							  ch2.fecha_desde = (SELECT MAX(ch3.fecha_desde)-- costo de la habitacion de la estadia en la fecha mas cercana al checkin
												FROM costos_habitacion ch3
												WHERE (ch3.fecha_desde <= ee.check_in) AND
													   ch3.hotel_codigo = codhotel AND
							  						   ch3.nro_habitacion = ee.nro_habitacion);
						
						suma_costos := suma_costos + precio * (ee.check_out - ee.check_in);-- sumo cada costo calculado al total
					END;
				ELSE
					CONTINUE;
				END IF;
			END LOOP;
			tipohab := th.tipo_habitacion_codigo;
			monto := suma_costos;
			RETURN NEXT;-- devuelvo el tipo junto con el total acumulado
		END;
	END LOOP;
END
$$ LANGUAGE 'plpgsql';