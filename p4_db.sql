/*
2.- Elimina al alumno con email sortiz@hotmail.com. 

Para borrar un alumno con un email específico*/

DELETE FROM ALUMNO
WHERE email = 'sortiz@hotmail.com';

/*Para verificar si se ha borrado el email específico*/

SELECT * FROM ALUMNO WHERE email = 'sortiz@hotmail.com';

/*3.- Elimina a la alumna con email chuertas@gmail.com. ¿Qué ocurre? ¿Por qué?
Utiliza todas las instrucciones necesarias para poder borrarla de la BD. En los criterios de
selección de registros (en el WHERE) de la instrucción DELETE solamente puedes
comparar con el dato del email (es decir, no puedes buscar el DNI de esta alumna y escribir
directamente su valor en la instrucción). 

Si comprobamos la existencia de dicha tabla...

SQL> SELECT * FROM ALUMNO WHERE email = 'chuertas@gmail.com';

DNI        NOMBRE                    APELLIDO1
---------- ------------------------- -------------------------
TELEFONO                       FECHANAC S EMAIL
------------------------------ -------- - ------------------------------
33000555M  Cristina                  Huertas
649125467                      30/11/00 M chuertas@gmail.com

Si queremos borrar el registro...*/

DELETE FROM ALUMNO
WHERE email = 'chuertas@gmail.com';

/*No se podrá por lo siguiente...
ERROR at line 1:
ORA-02292: integrity constraint (USUARIO1.MAT_DNI_ALU_FK) violated - child
record found*/

/*Recordamos la tabla matricular...

desc MATRICULAR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 DNIALUMNO                                 NOT NULL VARCHAR2(10)
 NIVEL                                     NOT NULL NUMBER(2)
 CURSO                                     NOT NULL NUMBER(3)
 DIASASISTE                                         NUMBER(3)
 
 Observamos que lo que conecta ALUMNO y MATRICULAR es el DNIALUMNO... por lo tanto tenemos buscar
 el dni sin hacer un SELECT del email*/

 DELETE FROM MATRICULAR WHERE DNIALUMNO IN (SELECT dni FROM ALUMNO WHERE email = 'chuertas@gmail.com');

 /*Para comprobar si se ha borrado de manera correcta...*/

 SELECT * FROM MATRICULAR WHERE dnialumno = '33000555M';
/*Efectivamente ahora se han borrado los registros de matricular... Por lo tanto, procedemos a hacer el DELETE*/

DELETE FROM ALUMNO
WHERE email = 'chuertas@gmail.com';

/*FIN EJERCICIO 3*/

/*¿Hay algún alumno que no esté matriculado en ningún curso? Realiza una consulta que
obtenga los DNIs de dichos alumnos.
En caso de que haya alumnos no matriculados, elimínalos de la BD. (Una instrucción
DELETE con SELECT).*/

/*BUSCAMOS UN DNI QUE ESTÉ EN LA TABLA ALUMNO Y QUE NO ESTÉ EN LA TABLA MATRICULAR*/
SELECT DNI FROM ALUMNO WHERE DNI NOT IN(SELECT dnialumno FROM MATRICULAR);

/*DNI
----------
55111222X
33000666F
21000111M
55000222N*/

/*Ahora modificamos el SELECT y lo hacemos dentro de un DELETE*/
DELETE FROM ALUMNO WHERE DNI NOT IN(SELECT dnialumno FROM MATRICULAR);

/*DELETE FROM ALUMNO WHERE DNI NOT IN(SELECT dnialumno FROM MATRICULAR);

4 rows deleted.*/

/*5.- En esta actividad vas a trabajar sobre las vistas USER_CONSTRAINTS y
USER_CONS_COLUMNS del diccionario de datos en las que se guarda, respectivamente,
información sobre las restricciones de la BD y las columnas a las que afectan. Realiza las
instrucciones SQL que proporcionen la respuesta de cada pregunta. (solamente los
campos que se piden)
El modelo lógico de MATRICULAR es el siguiente:
MATRICULAR (dnialumno, nivel, curso, diasasiste)
C.P.: dnialumno, nivel, curso
C.Ajena: dnialumno  ALUMNO
C.Ajena: nivel, curso  CURSO*/

/*
5.1.- ¿Cómo se llama la restricción que es clave principal en MATRICULAR?*/

SELECT constraint_name, constraint_type, table_name FROM USER_CONSTRAINTS WHERE table_name = 'MATRICULAR' AND constraint_type ='P';

/*CONSTRAINT_NAME                C TABLE_NAME
------------------------------ - ------------------------------
MAT_DNI_NIV_CUR_PK             P MATRICULAR
*/


/*
5.2.- ¿Qué columnas forman parte de la clave principal en MATRICULAR y en qué orden?*/

SELECT COLUMN_NAME FROM USER_CONS_COLUMNS WHERE CONSTRAINT_NAME='MAT_DNI_NIV_CUR_PK' ORDER BY POSITION;

/*COLUMN_NAME
--------------------------------------------------------------------------------
DNIALUMNO
NIVEL
CURSO
*/

/*
5.3.- ¿Cómo se llama en la base de datos la restricción que hace referencia a la clave ajena
a ALUMNO?*/

SELECT 
    constraint_name
FROM 
    user_constraints
WHERE 
    table_name = 'MATRICULAR'
    AND constraint_type = 'R'  -- 'R' indicates a Referential (foreign key) constraint
    AND r_constraint_name IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'ALUMNO'
    );

/* resultado es:

CONSTRAINT_NAME
------------------------------
MAT_DNI_ALU_FK

*/


/* explicación...

Steps to Find the Foreign Key Constraint Name
Identify Foreign Key Constraints:

In Oracle, foreign key constraints are labeled with a constraint type of 'R' (for "Referential").
This means we are specifically looking for constraints in the MATRICULAR table that reference (refer) another table—in this case, ALUMNO.
Query Structure:

We query USER_CONSTRAINTS to locate all constraints related to MATRICULAR.
USER_CONSTRAINTS contains information about each constraint in the database, including:
constraint_name: The name of the constraint.
table_name: The table where the constraint is defined.
constraint_type: The type of constraint, where P is a primary key, U is a unique key, and R is a foreign key (referential constraint).
r_constraint_name: The name of the primary or unique key constraint in the referenced table (i.e., the constraint in ALUMNO that MATRICULAR points to).
Query Explanation:

The query filters USER_CONSTRAINTS to show only foreign key (R) constraints in the MATRICULAR table:
sql
Copiar código
SELECT constraint_name
FROM user_constraints
WHERE table_name = 'MATRICULAR'
  AND constraint_type = 'R'
To ensure it only shows the foreign key constraints that reference the ALUMNO table, we add a condition to match the r_constraint_name with the primary or unique constraint in ALUMNO:
sql
Copiar código
  AND r_constraint_name IN (
      SELECT constraint_name 
      FROM user_constraints 
      WHERE table_name = 'ALUMNO'
  )
Full Query and How It Works Together:
The complete query is:

sql
Copiar código
SELECT 
    constraint_name
FROM 
    user_constraints
WHERE 
    table_name = 'MATRICULAR'
    AND constraint_type = 'R'  -- Only foreign key constraints
    AND r_constraint_name IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'ALUMNO'  -- Constraints from the ALUMNO table
    );
What It Does:
The query looks in USER_CONSTRAINTS for any foreign key (R) constraints on the MATRICULAR table that reference constraints in the ALUMNO table.
It specifically identifies the name of the foreign key constraint in MATRICULAR that establishes a link to ALUMNO.
Result:
This query returns the name of the foreign key constraint in MATRICULAR that links to the ALUMNO table, confirming the exact constraint name for this relationship in your database.

*/

/*
5.4.- En MATRICULAR, ¿qué columna/s forman la clave ajena a ALUMNO?*/

SELECT 
    COLUMN_NAME
FROM 
    USER_CONS_COLUMNS
WHERE CONSTRAINT_NAME IN(SELECT 
    constraint_name
FROM 
    user_constraints
WHERE 
    table_name = 'MATRICULAR'
    AND constraint_type = 'R'  -- 'R' indicates a Referential (foreign key) constraint
    AND r_constraint_name IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'ALUMNO'
    ));
    
/*Resultado...

COLUMN_NAME
--------------------------------------------------------------------------------
DNIALUMNO

*/

/*
5.5.- En ALUMNO, ¿a qué columna/s hace referencia la clave ajena que va de
MATRICULAR a ALUMNO?*/

SELECT 
    column_name AS alumno_column
FROM 
    user_cons_columns
WHERE 
    constraint_name = (
        SELECT r_constraint_name 
        FROM user_constraints 
        WHERE table_name = 'MATRICULAR'
            AND constraint_type = 'R'
            AND r_constraint_name IN (
                SELECT constraint_name 
                FROM user_constraints 
                WHERE table_name = 'ALUMNO'
            )
    )
    AND table_name = 'ALUMNO';

/*column_name AS alumno_column: This selects the name of the column in ALUMNO that is being referenced by MATRICULAR.
user_cons_columns: This view contains information about each column involved in constraints.
WHERE constraint_name = (...): This filters the results to only the columns associated with a specific constraint, which we identify in the subquery.
AND table_name = 'ALUMNO': Ensures we are only looking at columns within the ALUMNO table.*/

/*r_constraint_name: This is the name of the referenced constraint in ALUMNO that the foreign key in MATRICULAR points to.
user_constraints: This view provides information about constraints in the database.
WHERE table_name = 'MATRICULAR': Filters for constraints related to the MATRICULAR table.
AND constraint_type = 'R': Restricts the results to foreign key (Referential) constraints.
AND r_constraint_name IN (...): Ensures the referenced constraint is a valid constraint in ALUMNO, as confirmed in the next subquery.*/






/*
5.6.- ¿Cómo se llama el campo de USER_CONSTRAINTS que indica el comportamiento
de una clave ajena ante borrados? ¿Cuál es el comportamiento de la restricción que es
clave ajena de MATRICULAR a ALUMNO?*/