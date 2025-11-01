/*Identificar los clientes que hayan comprado canciones de m´as de un g´enero musical distinto.
Se debe mostrar: FirstName, LastName, CantidadGeneros (cantidad de g´eneros distintos
comprados). Ordenado por Cantidad de Generos en forma descendente.*/

select FirstName, LastName, COUNT(DISTINCT(g.GenreId)) as CantidadGeneros from Customer c
join Invoice i on i.CustomerId = c.CustomerId
join InvoiceLine il on il.InvoiceId = i.InvoiceId
join Track t on il.TrackId = t.TrackId
join Genre g on g.GenreId = t.GenreId -- kind of unnecessary join here, but in case there's a track id with an invalid GenreId...
GROUP BY FirstName, LastName
HAVING COUNT(DISTINCT g.GenreId) > 1
ORDER BY CantidadGeneros DESC