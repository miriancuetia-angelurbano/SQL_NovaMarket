-- 💻 LABORATORIO SESIÓN 7: EL INTERROGATORIO (SQL en VS Code)
-- 🧑‍🎓 ESTUDIANTES: MIRIANCUETIA Y ANGELURBANO
-- ═══════════════════════════════════════════════════════════════
-- Guía de Referencia: 02_Guia_S07_Antigravity.md
-- Base de Datos: Novamarket_S07.db (500 registros)
-- ═══════════════════════════════════════════════════════════════

-- INSTRUCCIONES:
-- 1. Escribe tu código debajo de cada bloque.
-- 2. Asegúrate de estar conectado a 'Novamarket_S07.db'.
-- 3. Para ejecutar: Selecciona tu código con el mouse y presiona Cmd + E.

-- ══ BLOQUE A — Exploración Inicial ═════════════════════════════
-- A1 — Las primeras filas de FactVentas
SELECT * FROM FactVentas LIMIT 10;

-- A2 — ¿Cuántas transacciones hay en total?
SELECT COUNT(*) AS Total_Transacciones FROM FactVentas;

-- A3 — Explorar dimensiones principales
SELECT * FROM DimProducto LIMIT 5;
SELECT * FROM DimCiudad LIMIT 5;


-- ══ BLOQUE B — Columnas y Cálculos (Suma, Mult, Alias) ═════════
-- TIP: Si vas a dividir (ej. margen %), multiplica por 100.0 primero
-- para obligar a SQLite a trabajar con decimales.
-- Ejemplo: ROUND((Ganancia * 100.0) / Precio, 2) AS Porcentaje

-- B1 — Solo las columnas que necesito
SELECT TransaccionID, FechaID, CiudadID, Cantidad, Precio_Venta, Costo_Envio
FROM FactVentas
LIMIT 15;

-- B2 — Columnas calculadas con AS
SELECT 
    TransaccionID, 
    CiudadID, 
    Cantidad, 
    Precio_Venta, 
    Descuento_Pct,
    (Precio_Venta * Cantidad) AS Venta_Bruta,
    (Precio_Venta * Cantidad * Descuento_Pct) AS Descuento_Monto,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
FROM FactVentas
LIMIT 20;


-- ══ BLOQUE C — Filtros WHERE (Leticia, Descuentos) ═════════════
-- C1 — Igual (=) — Todas las ventas de Leticia (CiudadID = 6)
SELECT TransaccionID, FechaID, CiudadID, Cantidad, Precio_Venta, Costo_Envio
FROM FactVentas
WHERE CiudadID = 6
ORDER BY FechaID;

-- C2 — Mayor que (>) — Descuentos agresivos (mayores a 15%)
SELECT 
    TransaccionID, FechaID, CiudadID, Descuento_Pct,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
FROM FactVentas
WHERE Descuento_Pct > 0.15
ORDER BY Descuento_Pct DESC;

-- C3 — AND — El peor escenario: Leticia con descuento
SELECT 
    TransaccionID, CiudadID, Descuento_Pct, Costo_Envio,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta
FROM FactVentas
WHERE CiudadID = 6 AND Descuento_Pct > 0
ORDER BY Descuento_Pct DESC;

-- C4 — IN — Ciudades del Caribe (ej. CiudadID 4 y 5)
SELECT TransaccionID, CiudadID, Costo_Envio
FROM FactVentas
WHERE CiudadID IN (4, 5)
ORDER BY CiudadID, Costo_Envio DESC
LIMIT 15;

-- C5 — BETWEEN — Ventas de noviembre (mes del Black Friday)
SELECT TransaccionID, FechaID, CiudadID, Descuento_Pct, Precio_Venta
FROM FactVentas
WHERE FechaID BETWEEN 20231101 AND 20231130
ORDER BY FechaID
LIMIT 20;


-- ══ BLOQUE D — Orden y Límites (Top 10, Peores Márgenes) ══════
-- D1 — Las 10 ventas con mayor costo de envío
SELECT TransaccionID, CiudadID, Costo_Envio, Precio_Venta, Cantidad
FROM FactVentas
ORDER BY Costo_Envio DESC
LIMIT 10;

-- D2 — Las 10 transacciones con peor margen aproximado
SELECT 
    TransaccionID, CiudadID, Precio_Venta, Cantidad, Descuento_Pct, Costo_Envio,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct) - Costo_Envio, 2) AS Margen_Aproximado
FROM FactVentas
ORDER BY Margen_Aproximado ASC
LIMIT 10;

-- D3 — Combinando todo: las 5 ventas de Leticia con mayor costo de envío
SELECT 
    TransaccionID, FechaID, ProductoID, Cantidad,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct), 2) AS Venta_Neta,
    Costo_Envio,
    ROUND(Precio_Venta * Cantidad * (1 - Descuento_Pct) - Costo_Envio, 2) AS Margen_Aproximado
FROM FactVentas
WHERE CiudadID = 6
ORDER BY Costo_Envio DESC
LIMIT 5;


-- ══ BLOQUE E — Desafíos Autónomos (ENTREGABLES) ════════════════
-- DESAFÍO 1: ¿Cuántas ventas hubo en septiembre 2023?
SELECT COUNT(*) AS Ventas_Sep
FROM FactVentas
WHERE FechaID BETWEEN 20230901 AND 20230930;
-- Resultado: 153 filas

-- DESAFÍO 2: Muestra las 10 transacciones con mayor Descuento_Pct que no sean de Leticia (CiudadID <> 6).
SELECT TransaccionID, CiudadID, Descuento_Pct, Precio_Venta
FROM FactVentas
WHERE CiudadID <> 6
ORDER BY Descuento_Pct DESC
LIMIT 10;

-- DESAFÍO 3: ¿Cuántas ventas del mes de noviembre tuvieron un Descuento_Pct mayor al 20% Y un Costo_Envio mayor a 500?
SELECT COUNT(*) AS Ventas_Nov_Peligrosas
FROM FactVentas
WHERE FechaID BETWEEN 20231101 AND 20231130
  AND Descuento_Pct > 0.20
  AND Costo_Envio > 500;
-- Resultado: 6 filas


-- ═══════════════════════════════════════════════════════════════
-- Fin del Laboratorio 07
