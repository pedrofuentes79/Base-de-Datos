/*
Listar los artistas que tengan m´as de 10 ´albumes registrados.
Se debe mostrar: Name, CantidadAlbumes. Ordenado por cantidad de albunes en forma
descendente
*/

select ar.Name, COUNT(DISTINCT al.AlbumId) as CantidadAlbumes from Artist ar
join Album al on al.ArtistId = ar.ArtistId
GROUP BY ar.Name
HAVING COUNT(DISTINCT al.AlbumId) > 10
ORDER BY CantidadAlbumes DESC

select * from Album where ArtistId = 22
