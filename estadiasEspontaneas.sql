SELECT *, e.check_out - e.check_in
FROM estadias_anteriores e NATURAL JOIN habitaciones h NATURAL JOIN costos_habitacion
WHERE NOT EXISTS(SELECT 1
				 FROM reservas_anteriores r
				 WHERE e.hotel_codigo = r.hotel_codigo AND
					   e.nro_habitacion = r.nro_habitacion AND
					   e.check_in = r.check_in) AND e.hotel_codigo = '6255142'