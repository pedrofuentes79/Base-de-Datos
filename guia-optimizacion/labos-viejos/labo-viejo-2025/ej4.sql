-- Consulta A
SELECT * FROM Sales.SalesOrderDetail
WHERE ProductID = 870 OR ProductID = 897;
-- Consulta B
SELECT * FROM Sales.SalesOrderDetail 
WHERE ProductID = 870
UNION ALL
SELECT * FROM Sales.SalesOrderDetail 
WHERE ProductID = 897;

/*
Porque el optimizador elige un plan distinto para cada consutla?

Consulta A: el optimizador hace un clustered index scan para encontrar todos los SalesOrderDetail que tengan alguno de esos dos ProductID.
no hace un seek + lookup en el índice sobre ProductID porque le parece que va a ser más caro eso que hacer todo el scan. 
Tiene sentido, dado que estimó que los que van a cumplir esa condición son 4690 contra 121000 (recorrer toda la tabla)

Consulta B: El optimizador calcula que cada una de las consultas va a tener 4688 y 2 filas resultantes, respectivamente.
Por esto elige hacer un clustered index scan para la primera condición (dado que es más barato esto que hacer el key lookup)
Para la otra consulta (la del id 897) si elige usar el índice con el key lookup para traer los atributos. 
Luego hace la concatenación de ambos.

Al usar UNION ALL el optimizador separa la lógica de los pedidos y hace seek en uno y scan en otro, aunque esto termina siendo menos eficiente
que hacer el scan directamente, ya que el costo de pedir una condición más sobre la misma columna es negligible, 
comparado con los seek+lookup que hay que hacer en la otra.

*/