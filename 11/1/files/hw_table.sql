CREATE TABLE unit_types (
    unit_type_id SERIAL PRIMARY KEY,
    unit_type_name VARCHAR(50) NOT NULL
);

CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(255) NOT NULL,
    unit_type_id INTEGER NOT NULL REFERENCES unit_types(unit_type_id)
);

CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    address_text VARCHAR(255) NOT NULL,
    unit_id INTEGER NOT NULL REFERENCES units(unit_id)
);

CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(150) NOT NULL
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMERIC(12,2) NOT NULL,
    position_id INTEGER NOT NULL REFERENCES positions(position_id),
    branch_id INTEGER NOT NULL REFERENCES branches(branch_id)
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL
);

CREATE TABLE employee_projects (
    employee_project_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    project_id INTEGER NOT NULL REFERENCES projects(project_id)
);