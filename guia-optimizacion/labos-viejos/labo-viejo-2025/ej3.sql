-- Consulta A
SELECT * 
FROM Sales.SalesOrderDetail d
JOIN Production.Product p ON d.ProductID = p.ProductID
WHERE p.ProductID = 870;
-- Consulta B
SELECT * 
FROM Sales.SalesOrderDetail d
JOIN Production.Product p ON d.ProductID = p.ProductID
WHERE p.Color = 'Black';

/*
Las dos consultas ejecutan un JOIN entre SalesOrderDetail y Product, pero generan planes de ejecución con estrategias de junta diferentes: 
una usa Nested Loops y la otra Hash Match.
¿Cuál es la causa más probable de esta diferencia?
RTA:

La consulta A trae TODO de SalesOrderDetail y uno solo de Product 
(ya que pide un solo ProductID, y esta es la PK. Por eso también es un clustered index seek).
Luego, filtra las filas de SalesOrderDetail que tienen ese ProductID, y después les hace un nested loop join para que tengan toda la misma info.

La consulta B trae TODO de SalesOrderDetail y luego hace un hash join con los Products con ese nombre. Esta vez, se hace un clustered index scan
sobre los Products (porque no hay un índice color).

La elección de hash match por sobre nested loop join es que la consulta fue mucho menos selectiva. En la primera solo había que agregarle la info
de un Product. Es innecesario el overhead de crear la tabla de hash, etc. etc. solamente para agregarle a todas esas ~4688 filas los campos de 
este Product en específico.

Ahora, si el filtro no fue tan selectivo, (hay ~93 productos de color negro), sí va a tener sentido hacer un hash match, dado que van a ser 
muchas más filas
*/

