/*Mostrar los t´ıtulos de los ´albumes donde todas las canciones tienen una duraci´on mayor
al promedio de duraci´on de todas las canciones de la base.
Se debe mostrar: Title. Ordenado por Title en forma ascendente*/

with album_to_min_duration (Title, MinTrackDuration) AS (
    SELECT a.Title, MIN(t.Milliseconds) From Album a
    join Track t on a.AlbumId = t.AlbumId
    group by a.Title
)

select Title from album_to_min_duration atmd
where atmd.MinTrackDuration > (select avg(Milliseconds) from Track)
order by Title ASC
