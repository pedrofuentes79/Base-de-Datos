-- 2.1a: Listar los nombres de los clientes de brasil

-- select FirstName from Customer where Country='Brazil';

-- 2.1b: Para cada cliente las facturas que tiene (nombre del cliente, fecha y nro de factura)
-- select c.FirstName, i.InvoiceDate, i.InvoiceId from Customer c 
-- join Invoice i on i.CustomerId = c.CustomerId

-- 2.1c: Para cada track, el nombre del artista que hizo el album al que pertenece cada track

-- select t.TrackId, t.Name, ar.Name from Track t
-- join Album al on al.AlbumId = t.AlbumId
-- join Artist ar on al.ArtistId = ar.ArtistId

-- 2.1d: nombres de las playlists que tienen mas de un track cuyo media type es MPEG audio file
-- select DISTINCT p.Name from Playlist p
-- join PlaylistTrack pt on p.PlaylistId = pt.PlaylistId
-- join Track t on pt.TrackId = t.TrackId
-- join MediaType mt on t.MediaTypeId = mt.MediaTypeId
-- where mt.Name = 'MPEG audio file'

-- 2.1e: Obtener los nombres de las playlists que tienen > 10 tracks de albumes de 'Iron Maiden'
-- select p.Name, COUNT(DISTINCT t.TrackId) from Playlist p
-- join PlaylistTrack pt on p.PlaylistId = pt.PlaylistId
-- join Track t on pt.TrackId = t.TrackId
-- join Album al on al.AlbumId = t.AlbumId
-- join Artist ar on ar.ArtistId = al.ArtistId
-- where ar.Name = 'Iron Maiden'
-- GROUP BY p.Name
-- HAVING COUNT(t.TrackId) > 10

-- 2.1f Cuantos albumes tiene cada playlist. 
-- select p.Name, COUNT(DISTINCT al.AlbumId) as UniqueAlbumCount from Playlist p
-- join PlaylistTrack pt on p.PlaylistId = pt.PlaylistId
-- join Track t on pt.TrackId = t.TrackId
-- join Album al on al.AlbumId = t.AlbumId
-- group by p.Name
-- ORDER BY UniqueAlbumCount DESC

-- 2.1g Empleados mayores de 25 que tienen al menos una factura con mas de 10 items
-- select e.EmployeeId, i.InvoiceId FROM Employee e
-- join Customer c on c.SupportRepId = e.EmployeeId
-- join Invoice i on i.CustomerId = c.CustomerId
-- join InvoiceLine il on il.InvoiceId = i.InvoiceId
-- where 
--     e.BirthDate <= DATEADD(year, -25, GETDATE()) 
-- GROUP BY e.EmployeeId, i.InvoiceId
-- HAVING COUNT(DISTINCT il.InvoiceLineId) >= 10

-- 2.1h resolver b) incluyendo a los que no tienen ninguna factura. b) dice que: 
-- Para cada cliente las facturas que tiene (nombre del cliente, fecha y nro de factura)

-- select c.FirstName, i.InvoiceDate, i.InvoiceId from Customer c 
-- LEFT JOIN Invoice i on i.CustomerId = c.CustomerId

-- 2.1i nombres de los empleados que soportan clientes con mas de 10 facturas
-- select e.EmployeeId, COUNT(DISTINCT i.InvoiceId) FROM Employee e
-- join Customer c on c.SupportRepId = e.EmployeeId
-- join Invoice i on i.CustomerId = c.CustomerId
-- group by e.EmployeeId
-- HAVING count(distinct i.InvoiceId) > 10

-- 2.1j Listar los empleados junto a su jefe
-- select e.FirstName, e.LastName , boss.FirstName, boss.LastName FROM Employee e
-- join Employee boss on boss.EmployeeId = e.ReportsTo

-- 2.1k lo mismo pero que no falte ningun empleado
-- select e.FirstName, e.LastName , boss.FirstName, boss.LastName FROM Employee e
-- left join Employee boss on boss.EmployeeId = e.ReportsTo

-- 2.1l promedio de tracks comprados en las facturas de cada cliente.
-- with customer_to_invoice_to_ntracks AS (select c.CustomerId, i.InvoiceId, COUNT(DISTINCT il.TrackId) as TracksInInvoice from Customer c
--     join Invoice i on i.CustomerId = c.CustomerId
--     join InvoiceLine il on il.InvoiceId = i.InvoiceId
--     GROUP BY c.CustomerId, i.InvoiceId)

-- select CustomerId, AVG(CONVERT(DECIMAL(10, 2), TracksInInvoice)) from customer_to_invoice_to_ntracks
-- group by CustomerId;

-- 2.1m Para cada empleado el total  de tracks de genero rock comprados por los clientes que soporta
select e.EmployeeId, e.FirstName, e.LastName, COUNT(DISTINCT t.TrackId) TotalRockSongsSold FROM Employee e
join Customer c on c.SupportRepId = e.EmployeeId
join Invoice i on i.CustomerId = c.CustomerId
join InvoiceLine il on il.InvoiceId = i.InvoiceId
join Track t on t.TrackId = il.TrackId
join Genre g on g.GenreId = t.TrackId
where g.Name = 'Rock'
group by e.EmployeeId, e.FirstName, e.LastName