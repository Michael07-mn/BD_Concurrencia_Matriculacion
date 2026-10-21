Create database DBUniv;
Go

Use DBUniv;
Go

Create table Estudiantes (
	estudiante_id int identity(1,1) primary key,
	nombre varchar(60) not null,
	cedula varchar(10) not null unique,
	facultad varchar(100) not null
);

Create table Asignaturas (
	asignatura_id int identity(1,1) primary key,
	nombre_materia varchar(100) not null,
	docente varchar(100),
	cupos_disponibles int check (cupos_disponibles >= 0)
);

Create table Registros_Matricula (
	registro_id int identity(100,1) primary key,
	estudiante_id int not null,
	asignatura_id int not null,
	fecha_registro datetime not null default getdate(),
	estado varchar(20) not null
		check (estado in ('confirmada', 'pendiente')),

	Constraint fk_registro_estudiante
		Foreign key (estudiante_id)
		References Estudiantes(estudiante_id),

	Constraint fk_registro_asignatura
		Foreign key (asignatura_id)
		References Asignaturas(asignatura_id)
);

Insert into Estudiantes (nombre, cedula, facultad)
Values
('Thiago Mendoza', '0341517440', 'Facultad de Ciencias Económicas'),
('Mateo Serrano', '9819777591', 'Facultad de Ciencias Sociales'),
('Valentina Castillo', '6465363402', 'Facultad de Ingeniería'),
('Isabella Paredes', '0854497677', 'Facultad de Derecho'),
('Facundo Palacios', '9125712130', 'Facultad de Ciencias Naturales'),
('Lautaro Guevara', '1226162386', 'Facultad de Arquitectura y Diseño'),
('Camila Benítez', '0773956485', 'Facultad de Ciencias Naturales'),
('Jerónimo Miranda', '6892644265', 'Facultad de Ciencias Económicas'),
('Emiliano Salazar', '3343168862', 'Facultad de Ciencias de la Salud');

Select * From Estudiantes;

Insert into Asignaturas (nombre_materia, docente, cupos_disponibles)
Values
('Base de Datos', 'Dr. Carlos Méndez', 25),
('Derecho Constitucional I', 'Dra. Elena Rostova', 15),
('Macroeconomía Avanzada', 'Ing. Jorge Valenzuela', 30),
('Diseño de Interfaces (UX/UI)', 'Msc. Natalia Rossi', 12),
('Anatomía Humana II', 'Dr. Andrés Borja', 8),
('Introducción a la Psicología', 'Lic. Valeria Gomez', 40),
('Álgebra Lineal', 'Msc. Ricardo Solís', 22),
('Derecho Penal General', 'Abg. Roberto Novoa', 18),
('Microeconomía', 'Eco. Silvia Paredes', 35);

Select * From Asignaturas;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado) 
Values
(1, 3, '2026-10-15 08:30:00', 'confirmada'),  -- Thiago Mendoza en Macroeconomía Avanzada
(3, 1, '2026-10-15 09:15:00', 'confirmada'),  -- Valentina Castillo en Bases de Datos
(4, 2, '2026-10-15 10:00:00', 'pendiente'),   -- Isabella Paredes en Derecho Constitucional I
(9, 5, '2026-10-16 07:45:00', 'confirmada'),  -- Emiliano Salazar en Anatomía Humana II
(5, 7, '2026-10-16 11:20:00', 'confirmada'),  -- Facundo Palacios en Álgebra Lineal
(6, 4, '2026-10-17 14:10:00', 'pendiente'),   -- Lautaro Guevara en Diseño de Interfaces (UX/UI)
(8, 9, '2026-10-17 15:00:00', 'confirmada'),  -- Jerónimo Miranda en Microeconomía
(2, 6, '2026-10-18 08:00:00', 'confirmada'),  -- Mateo Serrano en Introducción a la Psicología
(7, 7, '2026-10-18 09:35:00', 'pendiente');   -- Camila Benítez en Álgebra Lineal

Select * From Registros_Matricula;

-- Transaccion A; Uso del commit

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id = 1;

Begin Transaction;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado)
Values
(1,1, '2026-10-18 09:35:00', 'confirmada');

Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 1;

Commit;

Select * From Registros_Matricula
Where estudiante_id = 1
	And asignatura_id = 1;


-- Transacción B: Uso de Rollback

Begin Transaction;

Insert into Registros_Matricula (estudiante_id, asignatura_id, fecha_registro, estado)
Values
(2,1, GETDATE(), 'confirmada');

Update Asignaturas
Set cupos_disponibl = cupos_disponibles - 1
Where asignatura_id = 2;

Select * From Registros_Matricula
Where estudiante_id = 2
	And asignatura_id = 2;

Rollback;

Select * From Registros_Matricula
Where estudiante_id = 2
	And asignatura_id = 2;

Select * From Asignaturas
Where asignatura_id = 2;


-- Transacción C: Matrícula Multimateria

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id In (1,2);

Begin Transaction;

-- Materia 1 (Exito)
Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 1;

-- Materia 2 (Exito)
Update Asignaturas
Set cupos_disponibles = cupos_disponibles - 1
Where asignatura_id = 2;

-- Materia 3 (Fracaso/Error)
Update Asignaturas
Set cupos_disponible = cupos_disponibles - 1
Where asignatura_id = 3;

Rollback;

Select asignatura_id, nombre_materia, cupos_disponibles
From Asignaturas
Where asignatura_id In (1,2);


--3 Control de bloqueos y niveles de aislamiento

Select * From Asignaturas
Where asignatura_id = 5;


-- Read Uncommitted
Set transaction isolation level read uncommitted;

Begin transaction;

Update Asignaturas
Set cupos_disponibles = 4
Where asignatura_id = 5;

Rollback;


-- Read committed
Set transaction isolation level read committed;

Begin Transaction;

Update Asignaturas
Set cupos_disponibles = 4
Where asignatura_id = 5;

Commit;


--Repeatable read
Update Asignaturas
Set cupos_disponibles = 3
Where asignatura_id = 5;


--Serializable
Insert into Asignaturas (nombre_materia , docente, cupos_disponibles)
Values
('Programacion', 'Msc. Gonzalez', 5);

Select * From Asignaturas;
