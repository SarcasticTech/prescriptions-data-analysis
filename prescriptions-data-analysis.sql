-- Advanced Database Task 2

-- Task 2.1

-- Drops Existing Database to Avoid Errors
DROP DATABASE IF EXISTS PrescriptionsDB;

-- Creates the Database
CREATE DATABASE PrescriptionsDB;

-- Uses the Database
USE PrescriptionsDB;
GO

-- Imported the Three CSV as Flat Files via Database > Task > Import Flat File
-- Chosen the Following Appropriate Data Types for Each Column to Reduce Storage Use
-- Medical_Practices (Data Type: NVARCHAR 10, NVARCHAR 50, NVARCHAR 10)
-- Drugs (Data Type: NVARCHAR 50, MAX, 100, MAX)
-- Prescriptions (Data Type: Int, NVARCHAR 10, NVARCHAR 50, Float, SmallInt, Float)

-- Initial Analysis of the Imported Data
SELECT *
FROM Medical_Practice

SELECT *
FROM Drugs

SELECT *
FROM Prescriptions

-- Identifies the Rows in Prescription with a Decimal Quantity
SELECT *
FROM Prescriptions
WHERE QUANTITY LIKE '%.%';

-- Creates the Primary Key s
ALTER TABLE Medical_Practice
ADD CONSTRAINT PK_Medical_Practice PRIMARY KEY (PRACTICE_CODE);

ALTER TABLE Drugs
ADD CONSTRAINT PK_Drugs PRIMARY KEY (BNF_CODE);

ALTER TABLE Prescriptions
ADD CONSTRAINT PK_Prescriptions PRIMARY KEY (PRESCRIPTION_CODE);

-- Creates a Foreign Key Constraint for the Prescriptions Table to Reference Medical_Practice Table
ALTER TABLE Prescriptions
ADD CONSTRAINT FK_Prescriptions_Medical_Practice
FOREIGN KEY (PRACTICE_CODE) REFERENCES Medical_Practice(PRACTICE_CODE);

-- Creates a Foreign Key Constraint for the Prescriptions Table to Reference the Drugs Table
ALTER TABLE Prescriptions
ADD CONSTRAINT FK_Prescriptions_Drugs
FOREIGN KEY (BNF_CODE) REFERENCES Drugs(BNF_CODE);

-- Task 2.2 -- Query to Return Details of All Drugs 
SELECT *
FROM Drugs
WHERE BNF_DESCRIPTION LIKE '%tablet%' OR BNF_DESCRIPTION LIKE '%capsule%';

-- Task 2.3 -- Query to Return Total Quantity for Each Prescription 
SELECT PRESCRIPTION_CODE, ROUND(SUM(QUANTITY*ITEMS), 0) AS TOTAL_QUANTITY
FROM Prescriptions
GROUP BY PRESCRIPTION_CODE;

-- Task 2.4 -- Query to List Distinct Chemical Substances
SELECT DISTINCT CHEMICAL_SUBSTANCE_BNF_DESCR
FROM Drugs;

-- Task 2.5 -- Query to Return Number, Average Cost, Min & Max Cost for Each Prescription
SELECT a.BNF_CHAPTER_PLUS_CODE,
	COUNT(b.BNF_CODE) AS TOTAL_PRESCRIPTIONS, 
	AVG(ACTUAL_COST) AS AVERAGE_COST, 
	MIN(ACTUAL_COST) AS MINIMUM_COST, 
	MAX(ACTUAL_COST) AS MAXIMUM_COST
FROM Prescriptions b
JOIN Drugs a ON b.BNF_CODE = a.BNF_CODE
GROUP BY (a.BNF_CHAPTER_PLUS_CODE)
ORDER BY (a.BNF_CHAPTER_PLUS_CODE);

-- Task 2.5 -- Round Up Version
SELECT a.BNF_CHAPTER_PLUS_CODE,
	COUNT(b.BNF_CODE) AS TOTAL_PRESCRIPTIONS, 
	ROUND(AVG(ACTUAL_COST), 2) AS AVERAGE_COST, 
	ROUND(MIN(ACTUAL_COST), 2) AS MINIMUM_COST, 
	ROUND(MAX(ACTUAL_COST), 2) AS MAXIMUM_COST
FROM Prescriptions b
JOIN Drugs a ON b.BNF_CODE = a.BNF_CODE
GROUP BY (a.BNF_CHAPTER_PLUS_CODE)
ORDER BY (a.BNF_CHAPTER_PLUS_CODE);

-- Task 2.6 -- Query to Return the Most Expensive Prescription from Each Practice
SELECT PRACTICE_NAME, MAX(ACTUAL_COST) AS PRESCRIPTION_COST
FROM Medical_Practice a
JOIN Prescriptions b ON a.PRACTICE_CODE = b.PRACTICE_CODE
GROUP BY PRACTICE_NAME
HAVING MAX(ACTUAL_COST) > 4000
ORDER BY PRESCRIPTION_COST DESC;

-- Task 2.6 -- Round Up Version
SELECT PRACTICE_NAME, ROUND(MAX(ACTUAL_COST), 2) AS PRESCRIPTION_COST
FROM Medical_Practice a
JOIN Prescriptions b ON a.PRACTICE_CODE = b.PRACTICE_CODE
GROUP BY PRACTICE_NAME
HAVING MAX(ACTUAL_COST) > 4000
ORDER BY PRESCRIPTION_COST DESC;

-- Task 2.7

-- Query 1 -- Created a Query to Return the Total Number of Prescriptions with 'Substance' from Each Medical Practice (Utilizes Join & Group/Order, System Function 'COUNT')
SELECT a.PRACTICE_NAME, b.CHEMICAL_SUBSTANCE_BNF_DESCR, COUNT(c.PRESCRIPTION_CODE) AS TOTAL_PRESCRIPTIONS
FROM Medical_Practice a
JOIN Prescriptions c ON a.PRACTICE_CODE = c.PRACTICE_CODE
JOIN Drugs b ON c.BNF_CODE = b.BNF_CODE
WHERE b.CHEMICAL_SUBSTANCE_BNF_DESCR LIKE '%eye%'
GROUP BY a.PRACTICE_NAME, b.CHEMICAL_SUBSTANCE_BNF_DESCR
ORDER BY TOTAL_PRESCRIPTIONS DESC;

-- Query 2 - Created a Query to Return the List of Practices with 'Substance' from an 'Address' (Utilizes Join)
SELECT DISTINCT a.PRACTICE_NAME, b.CHEMICAL_SUBSTANCE_BNF_DESCR
FROM Medical_Practice a
JOIN Prescriptions c ON a.PRACTICE_CODE = c.PRACTICE_CODE
JOIN Drugs b ON c.BNF_CODE = b.BNF_CODE
WHERE b.CHEMICAL_SUBSTANCE_BNF_DESCR LIKE '%domperidone%'
AND (a.ADDRESS_3 LIKE '%bolton%' OR a.ADDRESS_4 LIKE '%bolton%');

-- Query 3 -- Created a Query to Return the List of Practices & Number of Prescriptions with Specific 'Chapter' 
-- (Utilizes Join, Order, Nested Query, System Function 'COUNT')
SELECT a.PRACTICE_NAME, c.BNF_CHAPTER_PLUS_CODE, COUNT(DISTINCT b.BNF_CODE) AS NUM_PRESCRIPTIONS
FROM Medical_Practice a
JOIN Prescriptions b ON a.PRACTICE_CODE = b.PRACTICE_CODE
JOIN Drugs c ON b.BNF_CODE = c.BNF_CODE
WHERE c.BNF_CHAPTER_PLUS_CODE LIKE '%08%'
AND b.BNF_CODE IN (
	SELECT d.BNF_CODE
	FROM Prescriptions d
	GROUP BY d.BNF_CODE
	HAVING COUNT(DISTINCT d.PRESCRIPTION_CODE) >= 2)
GROUP BY a.PRACTICE_NAME, c.BNF_CHAPTER_PLUS_CODE
ORDER BY NUM_PRESCRIPTIONS DESC;

-- Query 4 -- Created a Query to Return the Top 10 Most Commonly Prescribed Drugs w/ Total Prescription Count, 
-- Average Items Per Prescription, & Total Cost (Utilizes Join, Group/Order, System Function 'COUNT', 'AVG', 'ROUND', 'SUM)
SELECT TOP 10 b.CHEMICAL_SUBSTANCE_BNF_DESCR,
	COUNT(a.PRESCRIPTION_CODE) AS TOTAL_PRESCRIPTIONS,
	AVG(a.ITEMS) AS AVG_ITEMS_PER_PRESCRIPTION,
	ROUND(SUM(a.ACTUAL_COST), 2) AS TOTAL_COST
FROM Prescriptions a
JOIN Drugs b ON a.BNF_CODE = b.BNF_CODE
GROUP BY b.CHEMICAL_SUBSTANCE_BNF_DESCR
ORDER BY TOTAL_PRESCRIPTIONS DESC;

-- Query 5 -- Created a Query to Concat Addresses 1 to 4 (Utilizes System Function 'CONCAT_WS')
SELECT DISTINCT PRACTICE_NAME, 
	CONCAT_WS(' / ', ADDRESS_1, ADDRESS_2) AS PRACTICE_ADDRESS1,
    CONCAT_WS(' / ', ADDRESS_3, ADDRESS_4) AS PRACTICE_ADDRESS2,
	POSTCODE
FROM Medical_Practice;