-- Creating database
CREATE DATABASE employees_db
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1

-- Connecting to database
\c employees_db

-- CREATING ALL TABLES

CREATE TABLE public.employees(
    emp_no INTEGER NOT NULL,
    birthdate DATE,
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    gender CHAR,
    hire_date DATE,

    CONSTRAINT employees_pkey PRIMARY KEY (emp_no)
);

ALTER TABLE public.employees
    OWNER to postgres;

CREATE TABLE public.salaries(
    emp_no INTEGER REFERENCES employees(emp_no) NOT NULL,
    salary INTEGER,
    from_date DATE,
    to_date DATE
);

ALTER TABLE public.salaries
    OWNER to postgres;

CREATE TABLE public.departments(
    dept_no VARCHAR NOT NULL,
    dept_name VARCHAR NOT NULL,

    CONSTRAINT departments_pkey PRIMARY KEY (dept_no)
);

ALTER TABLE public.departments
    OWNER to postgres;

CREATE TABLE public.department_manager(
    dept_no VARCHAR NOT NULL,
    emp_no INTEGER NOT NULL,
    from_date DATE,
    to_date DATE,

    CONSTRAINT department_manager_dept_no_fkey FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
    CONSTRAINT department_manager_emp_no_fkey FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
);

ALTER TABLE public.department_manager
    OWNER TO postgres;

CREATE TABLE public.titles(
    emp_no INTEGER NOT NULL,
    title VARCHAR,
    from_date DATE,
    to_date DATE,

    CONSTRAINT titles_emp_no_fkey FOREIGN KEY (emp_no) REFERENCES employee(emp_no) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE public.titles
    OWNER TO postgres;

CREATE TABLE public.department_employee(
    emp_no INTEGER REFERENCES employees(emp_no) NOT NULL,
    dept_no VARCHAR REFERENCES departments(dept_no) NOT NULL,
    from_date DATE,
    to_date DATE,
);

ALTER TABLE public.department_employee
    OWNER to postgres;

-- Importing data from all csv

-- Used \copy command in order to have permissions to access to file
\copy employees FROM '/Users/fixingmind5/Desktop/sql-challenge/resources/employees.csv' DELIMITER ',' CSV HEADER;

\copy salaries FROM '~/Desktop/sql-challenge/resources/salaries.csv' DELIMITER ',' CSV HEADER;

\copy titles FROM '~/Desktop/sql-challenge/resources/titles.csv' DELIMITER ',' CSV HEADER;

\copy departments FROM '~/Desktop/sql-challenge/resources/departments.csv' DELIMITER ',' CSV HEADER;

\copy department_manager FROM '~/Desktop/sql-challenge/resources/dept_manager.csv' DELIMITER ',' CSV HEADER;

-- In order to copy correctly the following info to DB I use pandas to clean NULL values and then 
-- export it to a CSV file again.

\copy department_employee FROM '~/Desktop/sql-challenge/resources/dept_emp.csv' DELIMITER ',' CSV HEADER;

-- List detail
SELECT * FROM employees;

-- Employees hired in 1986
SELECT * FROM employees
    WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31';

-- Manager information
SELECT d.dept_no AS department_number,
    d.dept_name AS department_name, 
    e.emp_no AS employee_number, 
    e.first_name AS employe_name, 
    e.last_name AS employee_last_name, 
    d_m.from_date, 
    d_m.to_date
    FROM department_manager AS d_m
    JOIN departments AS d ON (d.dept_no = d_m.dept_no)
    JOIN employees AS e ON (e.emp_no = d_m.emp_no);

-- Employee information
SELECT e.emp_no, e.first_name, e.last_name, d.dept_name
    FROM employees AS e
    JOIN department_employee AS d_e
        ON (d_e.emp_no = e.emp_no)
    JOIN departments AS d
        ON (d.dept_no = d_e.dept_no);

-- B-liked names
SELECT * FROM employees AS e
    WHERE e.first_name = 'Hercules' 
        AND e.last_name LIKE 'B%';

-- Employee information from Sales department
SELECT b.dept_name, e.emp_no, e.first_name, e.last_name
    FROM employees AS e
    JOIN (
        SELECT d.dept_name, d_e.emp_no 
            FROM departments AS d
        JOIN (
            SELECT d_e.dept_no, d_e.emp_no 
                FROM department_employee AS d_e
                WHERE d_e.dept_no = 'd007'
        ) AS d_e 
            ON d.dept_no = d_e.dept_no
    ) AS b
        ON b.emp_no = e.emp_no;
        
-- Employee info from Sales and Development departments
SELECT b.dept_name, e.emp_no, e.first_name, e.last_name
    FROM employees AS e
    JOIN (
        SELECT d.dept_name, d_e.emp_no 
            FROM departments AS d
        JOIN (
            SELECT d_e.dept_no, d_e.emp_no 
                FROM department_employee AS d_e
                WHERE d_e.dept_no = 'd007'
                    OR d_e.dept_no = 'd005'
        ) AS d_e 
            ON d.dept_no = d_e.dept_no
    ) AS b
        ON b.emp_no = e.emp_no;

-- Last name frequencies
SELECT last_name, COUNT(*) AS alphabetic_count FROM employees
    GROUP BY employees.last_name
    ORDER BY alphabetic_count DESC;