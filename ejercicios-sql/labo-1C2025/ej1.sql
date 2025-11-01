/*Listar los clientes que han gastado m´as que el promedio de todos los clientes en sus
compras. Se debe mostrar: FirstName, LastName y TotalGastado (total gastado por
cada cliente) . Ordenado por Total Gastado en forma descendente.*/

SELECT FirstName, LastName, SUM(il.UnitPrice * Quantity) as TotalGastado from Customer c
join Invoice i on i.CustomerId = c.CustomerId
join InvoiceLine il on il.InvoiceId = i.InvoiceId
GROUP BY FirstName, LastName
ORDER BY TotalGastado DESC


