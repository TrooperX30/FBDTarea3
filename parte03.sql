DROP TABLE resumen;
CREATE TABLE resumen (pais_codigo character(2),
                    cant_estrellas smallint,
                    total_extra numeric(10,2),
                     PRIMARY KEY (pais_codigo, cant_estrellas));



CREATE OR REPLACE FUNCTION generar_reporte()
RETURNS void AS $$
DECLARE estre record; pais_c record;  extra numeric(10,2);  
BEGIN
    FOR estre IN (SELECT DISTINCT estrellas FROM hoteles h)
    LOOP
    
        FOR pais_c IN (SELECT DISTINCT pais_codigo FROM paises p)
        LOOP
            
            SELECT SUM(subquery.monto) INTO extra
				FROM (SELECT (ingreso_extra(h2.hotel_codigo)).monto AS monto
					  FROM hoteles h2
					  WHERE h2.pais_codigo = pais_c.pais_codigo AND h2.estrellas = estre.estrellas
					  )AS subquery;
            
            IF extra IS NOT NULL THEN
                INSERT INTO resumen(pais_codigo, cant_estrellas, total_extra) VALUES (pais_c.pais_codigo, estre.estrellas, extra);
            ELSE INSERT INTO resumen(pais_codigo, cant_estrellas, total_extra) VALUES (pais_c.pais_codigo, estre.estrellas, 0);
          	END IF;
        END LOOP;
        
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT generar_reporte();

SELECT *
FROM resumen
ORDER BY pais_codigo;