-- A script that prepare a MySql server for the project

-- Creating User
CREATE USER IF NOT EXISTS 'hbnb_test'@'localhost' IDENTIFIED BY 'hbnb_test_pwd';

-- Creating DataBase
CREATE DATABASE IF NOT EXISTS hbnb_test_db;

-- Granting Privileges
GRANT ALL PRIVILEGES ON hbnb_test_db.* TO 'hbnb_test'@'localhost';
GRANT SELECT ON performance_schema.* TO 'hbnb_test'@'localhost';
