Use DBUniv;

--Read uncommitted
Set transaction isolation level read uncommitted;

Select cupos_disponibles
From Asignaturas
Where asignatura_id = 5;

Select * From Asignaturas
Where asignatura_id = 5;

--Read Committed
Set transaction isolation level read committed;

Select cupos_disponibles
From Asignaturas
Where asignatura_id = 5;


--Repeatable Read
Set transaction isolation level repeatable read;

Begin transaction;

Select * From Asignaturas
Where asignatura_id = 5;

Commit;

--Serializable
Set Transaction isolation level serializable;

Begin transaction;

Select * from Asignaturas
Where cupos_disponibles >= 5;

Commit;