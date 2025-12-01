-- 1) Database creation
IF DB_ID('course_project') IS NULL
BEGIN
    PRINT 'Database not found.';
    PRINT 'Database created.';
    CREATE DATABASE course_project;
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END
GO

USE course_project; 

-- 1. CUSTOMERS TABLE

CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_created DATETIME DEFAULT GETDATE()
);
GO

-- Create index on customer name for search optimization
CREATE INDEX IX_customers_name ON customers(last_name, first_name);
GO


-- 2. VEHICLES TABLE

CREATE TABLE vehicles (
    vehicle_id INT IDENTITY(1,1) PRIMARY KEY,
    VIN VARCHAR(17) NOT NULL UNIQUE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'sold', 'reserved', 'maintenance')),
);
GO

-- Create indexes for vehicle searches
CREATE INDEX IX_vehicles_make_model ON vehicles(make, model);
CREATE INDEX IX_vehicles_status ON vehicles(status);
GO


-- 3. EMPLOYEES TABLE

CREATE TABLE employees (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL
);
GO

-- Create index on department for reporting
CREATE INDEX IX_employees_name ON employees(last_name, first_name);
GO

-- 4. SERVICE DEPARTMENTS TABLE

CREATE TABLE service_departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    manager_id INT FOREIGN KEY REFERENCES employees(employee_id),
);
GO

-- 5. SALES TABLE

CREATE TABLE sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT NOT NULL FOREIGN KEY REFERENCES vehicles(vehicle_id),
    customer_id INT NOT NULL FOREIGN KEY REFERENCES customers(customer_id),
    employee_id INT NOT NULL FOREIGN KEY REFERENCES employees(employee_id),
    sale_date DATETIME DEFAULT GETDATE(),
    sale_price DECIMAL(10,2) NOT NULL,
);
GO

-- Create indexes for sales reporting
CREATE INDEX IX_sales_date ON sales(sale_date);
CREATE INDEX IX_sales_employee ON sales(employee_id);
GO


-- 6. SERVICE APPOINTMENTS TABLE

CREATE TABLE service_appointments (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL FOREIGN KEY REFERENCES customers(customer_id),
    vehicle_id INT NOT NULL FOREIGN KEY REFERENCES vehicles(vehicle_id),
    department_id INT NOT NULL FOREIGN KEY REFERENCES service_departments(department_id),
    service_type VARCHAR(100) NOT NULL,
    scheduled_date DATETIME NOT NULL,
);
GO

-- Create indexes for appointment scheduling
CREATE INDEX IX_appointments_date ON service_appointments(scheduled_date);
CREATE INDEX IX_appointments_customer ON service_appointments(customer_id);
GO

-- 7. PARTS TABLE

CREATE TABLE parts (
    part_id INT IDENTITY(1,1) PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_number VARCHAR(50) NOT NULL UNIQUE,
    unit_price DECIMAL(8,2) NOT NULL,
);
GO

-- Create index for parts lookup
CREATE INDEX IX_parts_name ON parts(part_name);
GO

-- 8. APPOINTMENT_PARTS TABLE (Many-to-Many Junction Table)
-- This implements the many-to-many relationship between service_appointments and parts

CREATE TABLE appointment_parts (
    appointment_id INT NOT NULL FOREIGN KEY REFERENCES service_appointments(appointment_id),
    part_id INT NOT NULL FOREIGN KEY REFERENCES parts(part_id),
    quantity_used INT NOT NULL DEFAULT 1,
    PRIMARY KEY (appointment_id, part_id),
    CONSTRAINT CHK_quantity_positive CHECK (quantity_used > 0)
);
GO

-- Create index for parts usage reporting
CREATE INDEX IX_appointment_parts_part ON appointment_parts(part_id);
GO


-- 2) Data Manipulation 


-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, address)
VALUES 
    ('John', 'Smith', 'john.s@email.com', '88005553535', 'Sauletekio 10, Vilnius'),
    ('Sarah', 'Johnson', 'sarah.j@email.com', '88005553536', 'Sauletekio 19, Vilnius'),
    ('Michael', 'Brown', 'brown@email.com', '88005553537', 'Sauletekio 25, Vilnius');
GO

-- Insert sample employees
INSERT INTO employees (first_name, last_name, position, department)
VALUES 
    ('Rimantas', 'Karavicius', 'Sales Manager', 'Sales'),
    ('Ieva', 'Varlamova', 'Sales Associate', 'Sales'),
    ('Rokas', 'Kibinas', 'Service Manager', 'Service'),
    ('Anton', 'Gorin', 'Technician', 'Service');
GO

-- Insert service departments
INSERT INTO service_departments (department_name, manager_id)
VALUES 
    ('Oil Change & Maintenance', 3),
    ('Tire & Brake Service', 3),
    ('Engine Repair', 3);
GO

-- Insert sample vehicles
INSERT INTO vehicles (VIN, make, model, year, price, status)
VALUES  
    ('1HGBH41JXMN109186', 'Honda', 'Accord', 2023, 28500.00, 'available'),
    ('2FMDK3KC5DBA12345', 'Ford', 'Explorer', 2022, 42000.00, 'available'),
    ('3VWFE21C04M000001', 'Volkswagen', 'Jetta', 2023, 24900.00, 'sold'),
    ('5FNRL6H78MB012345', 'Honda', 'Odyssey', 2024, 38500.00, 'available'),
    ('5FNRL6H78MB012343', 'Chevy', 'Blazer', 2020, 18500.00, 'available'),
    ('6FNRL6H78MB043534', 'UAZ', 'Buhanka', 1984, 8500.00, 'available'),
    ('4VWFE21C04M000001', 'Ford', 'F150', 2023, 24300.00, 'sold');
GO

-- Insert sample sales
INSERT INTO sales (vehicle_id, customer_id, employee_id, sale_date, sale_price)
VALUES 
    (3, 1, 2, '2024-11-15', 24500.00),
    (6, 2, 3, '2025-11-15', 22000.00); 
GO

-- Update vehicle status after sale
UPDATE vehicles SET status = 'sold' WHERE vehicle_id = 3;
GO

-- Insert sample parts
INSERT INTO parts (part_name, part_number, unit_price)
VALUES 
    ('Engine Oil Filter', 'OF-1234', 12.99),
    ('Synthetic Oil', 'OIL-5W30', 45.00),
    ('Air Filter', 'AF-5678', 18.50),
    ('Brake Pads Front', 'BP-F-001', 89.99),
    ('Brake Pads Rear', 'BP-R-001', 79.99);
GO

-- Insert sample service appointments
INSERT INTO service_appointments (customer_id, vehicle_id, department_id, service_type, scheduled_date)
VALUES 
    (1, 3, 1, 'Oil Change', '2024-12-01 10:00:00'),
    (2, 1, 2, 'Brake Inspection', '2024-12-02 14:00:00');
GO

-- Insert appointment parts (many-to-many relationship)
INSERT INTO appointment_parts (appointment_id, part_id, quantity_used)
VALUES 
    (1, 1, 1),  -- Oil filter for appointment 1
    (1, 2, 5),  -- 5 quarts of oil for appointment 1
    (1, 3, 1);  -- Air filter for appointment 1
GO

-- See all tables
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

DELETE FROM service_appointments
WHERE scheduled_date < DATEADD(YEAR, -1, GETDATE());

TRUNCATE TABLE sales

-- 3) DAta retrieval
-- Average price of all vehicles
SELECT AVG(price)
AS avegare_price
FROM vehicles;

--Find employees who didn't make any sales
SELECT COUNT(*) AS no_sales
FROM employees
WHERE employee_id NOT IN (SELECT employee_id FROM sales);

--Price statistics for each make of the car
SELECT 
    make,
    COUNT(*) AS vehicles_number,
    SUM(price) AS total_price,
    AVG(price) AS average_price,
    MIN(price) AS cheapest_car,
    MAX(price) AS most_expensive_car
FROM vehicles
GROUP BY make
ORDER BY total_price DESC;

-- Pagination 
-- Get employees page by page (5 per page)
-- Page 1
SELECT 
    employee_id,
    first_name,
    last_name,
    position,
    department
FROM employees
ORDER BY employee_id  -- ORDER BY is REQUIRED for OFFSET/FETCH
OFFSET 0 ROWS         -- Skip 0 rows (start at beginning)
FETCH NEXT 5 ROWS ONLY;  

-- 4) Joins
-- Show employee names and their sales
SELECT 
    e.first_name,
    e.last_name,
    s.sale_id,
    s.sale_date,
    s.sale_price
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
ORDER BY s.sale_id DESC;

-- Complete information about each transaction 
CREATE VIEW transactions AS
SELECT 
    s.sale_id,
    c.first_name + ' ' + c.last_name AS CustomerName,
    c.email AS CustomerEmail,
    c.phone AS CustomerPhone,
    v.year,
    v.make,
    v.model,
    v.VIN,
    e.first_name + ' ' + e.last_name AS SalesPerson,
    e.position,
    s.sale_date,
    s.sale_price
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN vehicles v ON s.vehicle_id = v.vehicle_id
INNER JOIN employees e ON s.employee_id = e.employee_id;
GO

SELECT * FROM transactions

--5) Procedures/Triggers
-- Create a stored procedure to add a new customer
CREATE PROCEDURE sp_AddCustomer
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @Address VARCHAR(255)
AS
BEGIN
    -- Insert new customer
    INSERT INTO customers (first_name, last_name, email, phone, address, date_created)
    VALUES (@FirstName, @LastName, @Email, @Phone, @Address, GETDATE());
    
    -- Return the new customer ID
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;
GO

-- Execute the procedure
EXEC sp_AddCustomer 
    @FirstName = 'Roma',
    @LastName = 'Dolma',
    @Email = 'jane.doe@email.com',
    @Phone = '555-0199',
    @Address = '999 Oak Street, Springfield';

-- Verify it was added
SELECT * FROM customers WHERE email = 'jane.doe@email.com';

--Trigger 
--Trigger that sets vehicle status as sold after inserting data into sales table
CREATE TRIGGER trg_update_vehicle_status
ON sales
AFTER INSERT
AS
BEGIN
    UPDATE vehicles
    SET status = 'sold'
    FROM vehicles v
    INNER JOIN inserted i ON v.vehicle_id = i.vehicle_id
    WHERE v.status != 'sold';
    PRINT 'Vehicle status updated to sold';
END;
GO
