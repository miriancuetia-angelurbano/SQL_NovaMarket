-- 💻 LABORATORIO SESIÓN 8 Y 9 EXPRESS: EL VEREDICTO EN SQL
-- ═══════════════════════════════════════════════════════════════
-- Guía de Referencia: 01_Guia_S08S09_Conceptual.md
-- Base de Datos: Novamarket_S08S09.db (500 registros, lista para usar)
-- ═══════════════════════════════════════════════════════════════
-- INSTRUCCIONES:
-- 1. Asegúrate de estar conectado a la base de datos `Novamarket_S08S09.db`
-- 2. Selecciona cada bloque de consulta y presiona Cmd + E (Mac) o Ctrl + E (Win).
-- ══ PARTE 1 — GROUP BY (Comprimiendo filas) ════════════════════
-- Paso 1: El problema de las 500 filas
-- Si listamos, vemos 500:
SELECT CiudadID,
    Precio_Venta,
    Costo_Envio
FROM FactVentas
LIMIT 5;
--Respuesta paso 1:
-- 1. ¿Cuántas filas retorna GROUP BY? Retorna 6 filas.
-- 2. ¿Por qué? Porque agrupa los 500 registros de la tabla en 6 grupos únicos, uno por cada CiudadID que existe.
-- Si agrupamos, vemos el total:
SELECT CiudadID,
    COUNT(*) AS Filas
FROM FactVentas
GROUP BY CiudadID;
-- Paso 2: El veredicto de Leticia con GROUP BY (Usando IDs)
SELECT CiudadID,
    COUNT(*) AS Transacciones,
    ROUND(
        SUM(Precio_Venta * Cantidad * (1 - Descuento_Pct)),
        2
    ) AS Venta_Neta,
    ROUND(SUM(Costo_Envio), 2) AS Costo_Envio_Total,
    ROUND(
        SUM(
            Precio_Venta * Cantidad * (1 - Descuento_Pct) - Costo_Envio
        ),
        2
    ) AS Margen_Aproximado
FROM FactVentas
GROUP BY CiudadID
ORDER BY Margen_Aproximado ASC;
-- Respuesta paso 2:
-- 1. ¿Qué CiudadID tiene Margen_Aproximado negativo? Ninguno en esta consulta original sin multiplicar el envío, pero al multiplicarlo por cantidad, Leticia (2) sería el único.
-- 2. ¿Cuánto es esa pérdida? Con el ajuste, la pérdida es -131,330.0 (un margen de -52.55%).
-- 3. ¿Coincide con el número de Power BI de S4? SÍ, coincide al ajustar la multiplicación.
-- Paso 3: SUM vs AVG
SELECT CiudadID,
    ROUND(SUM(Costo_Envio), 2) AS Costo_TOTAL,
    ROUND(AVG(Costo_Envio), 2) AS Costo_PROMEDIO
FROM FactVentas
WHERE CiudadID = 6
GROUP BY CiudadID;
-- Respuesta paso 3:
-- ¿Para decidir si cerrar Leticia, cuál usarías: SUM o AVG?
-- Usaría SUM para ver el impacto financiero total (el hueco que deja en la rentabilidad general), aunque el AVG es útil para ver qué tan caro es un solo envío.
-- ══ PARTE 2 — JOIN (Nombres Reales) ════════════════════════════
-- Paso 4: El primer JOIN: 'Leticia' en lugar de '6'
SELECT f.TransaccionID,
    c.Ciudad AS Ciudad,
    -- viene de DimCiudad
    f.Costo_Envio
FROM FactVentas f
    INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
WHERE c.Ciudad = 'Leticia'
LIMIT 5;
-- Respuesta paso 4:
-- 1. ¿Qué columna une las dos tablas? La columna CiudadID.
-- 2. ¿Por qué ahora aparece 'Leticia' y no '6'? Porque gracias al INNER JOIN traemos el nombre real (c.Ciudad) desde la tabla DimCiudad.
-- Paso 5: Doble JOIN: ciudad Y producto
SELECT f.TransaccionID,
    c.Ciudad AS Ciudad,
    p.Producto AS Producto,
    f.Cantidad,
    ROUND(
        f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct),
        2
    ) AS Venta_Neta
FROM FactVentas f
    INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
    INNER JOIN DimProducto p ON f.ProductoID = p.ProductoID
LIMIT 10;
-- Paso 6: Doble Agrupación (Ciudad y Producto)
-- ¿Cuánto vendió cada producto en cada ciudad?
SELECT c.Ciudad AS Ciudad,
    p.Producto AS Producto,
    COUNT(*) AS Transacciones,
    ROUND(
        SUM(
            f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct)
        ),
        2
    ) AS Venta_Neta
FROM FactVentas f
    INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
    INNER JOIN DimProducto p ON f.ProductoID = p.ProductoID
GROUP BY c.Ciudad,
    p.Producto
ORDER BY c.Ciudad ASC,
    Venta_Neta DESC;
-- ══ LA CONSULTA MAESTRA (JOIN + GROUP BY) ══════════════════════
-- Reproduciendo el dashboard de S4
SELECT c.Ciudad AS Ciudad,
    COUNT(*) AS Transacciones,
    ROUND(
        SUM(
            f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct)
        ),
        2
    ) AS Venta_Neta,
    ROUND(SUM(f.Costo_Envio * f.Cantidad), 2) AS Costo_Envio_Total,
    ROUND(
        SUM(
            f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct) - (f.Costo_Envio * f.Cantidad)
        ),
        2
    ) AS Margen_Aproximado
FROM FactVentas f
    INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
GROUP BY c.Ciudad
ORDER BY Margen_Aproximado ASC;
-- Respuesta consulta maestra:
-- 1. ¿Aparece 'Leticia' con Margen_Aproximado negativo? SÍ, aparece con margen negativo.
-- 2. ¿Cuánto es esa pérdida? Es de -131,330.0 (lo que representa un margen de -52.55%).
-- 3. ¿Coincide este resultado con el dashboard de Power BI de S4? SÍ, coincide con la pérdida observada.
-- ═══════════════════════════════════════════════════════════════
-- 🚀 PRÁCTICA AUTÓNOMA (ENTREGABLES)
-- Escribe tus consultas debajo de cada enunciado.
-- ═══════════════════════════════════════════════════════════════
-- E1: (Fácil) Muestra nombre del producto, categoría y venta neta total de cada producto. Ordena de mayor a menor.
SELECT p.Producto, 
       p.Categoria, 
       ROUND(SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct)), 2) AS Venta_Neta
FROM FactVentas f
INNER JOIN DimProducto p ON f.ProductoID = p.ProductoID
GROUP BY p.Producto, p.Categoria
ORDER BY Venta_Neta DESC;
-- E2: (Medio) ¿Cuál producto vendió más en Leticia? Usa JOIN + WHERE + GROUP BY.
SELECT p.Producto, 
       ROUND(SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct)), 2) AS Venta_Neta
FROM FactVentas f
INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
INNER JOIN DimProducto p ON f.ProductoID = p.ProductoID
WHERE c.Ciudad = 'Leticia'
GROUP BY p.Producto
ORDER BY Venta_Neta DESC
LIMIT 1;
-- E3: (Difícil) Reproduce la tabla del dashboard de S4 completa: Ciudad, Ventas, Utilidad, Margen%. Con nombres reales.
SELECT c.Ciudad AS Ciudad,
       ROUND(SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct)), 2) AS Ventas,
       ROUND(SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct) - (f.Costo_Envio * f.Cantidad)), 2) AS Utilidad,
       ROUND((SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct) - (f.Costo_Envio * f.Cantidad)) / 
              SUM(f.Precio_Venta * f.Cantidad * (1 - f.Descuento_Pct))) * 100, 2) AS "Margen%"
FROM FactVentas f
INNER JOIN DimCiudad c ON f.CiudadID = c.CiudadID
GROUP BY c.Ciudad
ORDER BY Utilidad DESC;
-- ═══════════════════════════════════════════════════════════════
-- ¡Fin de la Unidad 2! Prepárate para Python en la Unidad 3.
-- ═══════════════════════════════════════════════════════════════