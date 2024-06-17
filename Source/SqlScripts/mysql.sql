CREATE DATABASE flask;
USE flask;
ALTER USER satyam WITH ENCRYPTED password 'Password@12345';
CREATE TABLE user (
    name VARCHAR(100),
    age INT
);
show tables;
select * from user;