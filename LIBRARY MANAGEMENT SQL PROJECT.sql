--Library Management System using SQL Project

--OBJECTIVE
--Set up the Library Management System Database: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
--1) Operations: Perform Create, Read, Update, and Delete operations on the data.
--2)CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.
--3)Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

--Project Structure
--1. Database Setup
--Database Creation: Created a database named `library_db`.
--Table Creation: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

--project Library Mangement System
--1) CREATE DATABASE library;

--create table

DROP TABLE IF EXISTS Branch;
CREATE TABLE Branch
(
		branch_id VARCHAR(10) PRIMARY KEY,
		manager_id VARCHAR(10),
		branch_address VARCHAR(30),
		contact_no VARCHAR(20)
);

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees
(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(20),
		position VARCHAR(15),
		salary INT,
		branch_id VARCHAR(25)		
);

--add foreign key if table was created early
ALTER TABLE Employees
ADD CONSTRAINT PK_Branch
FOREIGN KEY (branch_id) REFERENCES  branch(branch_id);


DROP TABLE IF EXISTS Members;
CREATE TABLE Members 
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

DROP TABLE IF EXISTS Books;
CREATE TABLE Books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

DROP TABLE IF EXISTS Issued_status;
CREATE TABLE Issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
			FOREIGN KEY (issued_member_id) REFERENCES Members(member_id),
			FOREIGN KEY (issued_book_isbn) REFERENCES Books(isbn),
			FOREIGN KEY (issued_emp_id) REFERENCES Employees(emp_id)      
);


DROP TABLE IF EXISTS Return_status;
CREATE TABLE Return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
			FOREIGN KEY (return_book_isbn) REFERENCES Books(isbn)
);

SELECT * from Branch
SELECT * from Employees
SELECT * from Books
SELECT * from Members
SELECT * from Issued_status
SELECT * from Return_status

-- Project TASK

-- 2)CRUD Operations
-- CRUD Operations
Create: Inserted sample records into the `books` table.
Read: Retrieved and displayed data from various tables.
Update: Updated records in the `employees` table.
Delete: Removed records from the `members` table as needed.


-- Task 1. Create a New Book Record("978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')")
INSERT INTO Books (isbn, book_title, category, rental_price, status, author, publisher)
		   VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
--VERIFY
SELECT * from Books
WHERE isbn='978-1-60156-2'29-4;

-- Task 2: Update an Existing Member's Address
UPDATE Members
SET Member_address= '125 Oak St'
WHERE member_id='C103';

--VERIFY
SELECT * from Members
WHERE member_id='C103';

-- Task 3: Delete a Record from the Issued Status Table(Objective: Delete the record with issued_id = 'IS121'  from the issued_status table.)

DELETE FROM Issued_status
WHERE issued_id = 'IS121';

--VERFY
SELECT * from Issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee (Objective: Select all books issued by the employee with emp_id = 'E101'.)

SELECT * from Issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book (Objective: Use GROUP BY to find members who have issued more than one book.)

SELECT issued_emp_id
		--COUNT(issued_emp_id)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_emp_id) > 1
ORDER BY issued_emp_id;

--3)CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE BOOK_ISSUED_COUNT
AS
SELECT B.isbn, B.book_title,
	COUNT(I.issued_id) as ISSUE_COUNT
From Issued_status AS I 
JOIN Books AS B
	ON I.issued_book_isbn = B.isbn
GROUP BY B.isbn, B.book_title;

--VERIFY
SELECT * FROM BOOK_ISSUED_COUNT;


--4) Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
SELECT * FROM BOOKS
WHERE CATEGORY = 'History';

-- Task 8: Find Total Rental Income by Category OF ALL BOOKS:
SELECT CATEGORY, COUNT(Category), SUM(RENTAL_PRICE) AS TOTAL_RENTAL_INCOME
FROM BOOKS
GROUP BY CATEGORY;

-- Task 8(B): Find Total Rental Income by Category OF ISSUED BOOKS
SELECT B.CATEGORY,
		SUM(B.RENTAL_PRICE) AS TOTAL_RENTAL_ICOME,
		COUNT(*)
FROM ISSUED_STATUS AS I
JOIN BOOKS AS B
ON I.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9. List Members Who Registered in the Last 180 Days:
SELECT JUSTIFY_DAYS(INTERVAL '180 DAYS')
--6MONTHS
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT E.EMP_ID, E.EMP_NAME, E.POSITION, E.SALARY,
		B.BRANCH_ID, B.MANAGER_ID, B.BRANCH_ADDRESS,
    	E2.EMP_NAME as manager
From Employees AS E
JOIN Branch AS B
ON E.BRANCH_ID = B.BRANCH_ID
JOIN EMPLOYEES AS E2
ON E2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE expensive_books
AS
SELECT *
FROM BOOKS
WHERE Rental_price > 7;

--VERIFY
SELECT * FROM EXPENSIVE_BOOKS;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT I.ISSUED_BOOK_NAME
FROM ISSUED_STATUS AS I
LEFT JOIN RETURN_STATUS AS R
ON I.issued_id = R.issued_id
WHERE R.return_id IS NULL;

--INSERTING NEW DATA INTO ISSUED_STATUS
 INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

SELECT * from Issued_status;

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;


-- Advanced SQL Operations
SELECT * from Books
SELECT * from Branch
SELECT * from Employees
SELECT * from Members
SELECT * from Return_status
SELECT * from Issued_status
--Task 13: Identify Members with Overdue Books (Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue).

SELECT I.issued_member_id,
		M.member_name,
		B.book_title,
		I.issued_date,
		--R.Return_date,
		--(CURRENT_DATE)
		'2024-08-24' - I.issued_date AS OVER_DUE
FROM Issued_status AS I
JOIN Members AS M
	ON I.Issued_member_id = M.Member_id
JOIN BOOKS AS B
	ON B.isbn = I.issued_book_isbn
LEFT JOIN Return_status AS R
	ON R.issued_id = I.issued_id
where 
	R.Return_date is NULL
	AND 
	('2024-08-24' - I.issued_date) > 30
ORDER BY I.Issued_member_id

/* Task 14: Update Book Status on Return
(Write a query to update the status of books in the books table to "available" when they are returned
(based on entries in the return_status table)).
*/

--STORE PROCEDURES

CREATE OR REPLACE PROCEDURE ADD_RETURN_RECORDS(P_RETURN_ID VARCHAR(10), P_ISSUED_ID VARCHAR(10), P_BOOK_QUALITY VARCHAR(15))
-- data type based on issued_status table
LANGUAGE plpgsql
AS $$

DECLARE
	V_isbn VARCHAR(50) ;  --Auto updated book table
	V_book_name VARCHAR(80) ; --raise notice

BEGIN
	--Inserting data into Return_status based on user input.
	INSERT INTO Return_status (RETURN_ID, ISSUED_ID, RETURN_DATE, BOOK_QUALITY)
	VALUES (P_RETURN_ID, P_ISSUED_ID, CURRENT_DATE, P_BOOK_QUALITY);

	SELECT
			issued_book_isbn, --Auto updated book table
			issued_book_name --raise notice
			INTO
			V_isbn,
			V_book_name
	FROM Issued_status
	WHERE issued_id = P_ISSUED_ID;

	UPDATE books
	SET status = 'YES'
	WHERE isbn = V_isbn;

	RAISE NOTICE 'Thaank you for returning the book: %', V_book_name;

END;
$$;

--TESTING FUNCTION FOR add-return_records

SELECT * from Books
WHERE isbn = '978-0-307-58837-1' ;

SELECT * from Issued_status
WHERE issued_id = 'IS135' ;

SELECT * from Return_status
WHERE issued_id = 'IS135' ;

--Parameters P_RETURN_ID'(manually set), 'P_ISSUED_ID',' P_BOOK_QUALITY'
CALL add_return_records ('RS138', 'IS135', 'GOOD');
CALL add_return_records ('RS148', 'IS140', 'Good');


/* Task 15: Branch Performance Report 
(Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals).
*/
--Use the CREATE TABLE AS (CTAS)

CREATE TABLE  BRANCH_REPORTS
AS
SELECT 
	BR.branch_id,
	BR.manager_id,
	COUNT(I.issued_id) AS TOTAL_BOOKS_ISSUED,
	COUNT(R.return_id) AS TOTAL_BOOK_RETURNED,
	SUM(rental_price) AS TOTAL_REVENUE
FROM Issued_status AS I
JOIN Employees AS E
	ON I.issued_Emp_id = E.Emp_id
JOIN Branch AS BR
	ON BR.branch_id = E.branch_id
LEFT JOIN Return_status AS R
	ON R.issued_id = I.issued_id
JOIN Books AS B
	ON B.isbn = I.issued_book_isbn
GROUP BY 1, 2 
ORDER BY 1 ;

SELECT * FROM BRANCH_REPORTS
	

/* Task 16: CTAS: Create a Table of Active Members
(Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.)
*/


CREATE TABLE Active_members
AS
SELECT 
	M.member_id,
	M.member_name,
	I.issued_book_name,
	I.issued_date
FROM Members AS M
JOIN Issued_status AS I
	ON M.Member_id = I.issued_member_id
WHERE I.issued_date >= CURRENT_DATE - INTERVAL '24 month'
GROUP BY 1, 2, 3, 4
ORDER BY 1

SELECT * FROM Active_members

--OR

CREATE TABLE active_members_1
AS
SELECT * FROM members
WHERE member_id IN (SELECT --SUBQUERY
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '24 month'
                    )
SELECT * FROM Active_members_1



/* Task 17: Find Employees with the Most Book Issues Processed
(Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.)
*/

SELECT 
	E.emp_name,
	BR.*,
	COUNT(I.issued_id) AS TOTAL_BOOKS_ISSUED
FROM Employees AS E 
JOIN Branch AS BR
ON E.branch_id = BR.branch_id
JOIN Issued_status AS I
ON I.issued_emp_id = E.emp_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;
	

/* Task 18: Identify Members Issuing High-Risk Books 
(Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.)   
*/

SELECT 
	M.member_name,
	I.issued_book_name,
	R.BOOK_QUALITY,
	COUNT(I.issued_id) AS number_of_book_issued
FROM Issued_status AS I
JOIN Members AS M
	ON I.issued_member_id = M.member_id
JOIN Return_status  AS R
	ON I.issued_ID = R.ISSUED_ID
WHERE R.BOOK_QUALITY = 'Damaged'
GROUP BY 1,2,3
HAVING COUNT(I.issued_id)>2;

	
SELECT * FROM BOOKS
SELECT * from Members
SELECT * from Issued_status
SELECT * from Return_status

/* Task 19: Stored Procedure (Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return.
	Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.)
The procedure should function as follows:
	The stored procedure should take the book_id as an input parameter.
	The procedure should first check if the book is available (status = 'yes').
	If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
	If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

*/
CREATE OR REPLACE PROCEDURE ISSUE_BOOK (P_Issued_id VARCHAR(10), P_Issued_member_id VARCHAR(30), P_Issued_book_isbn VARCHAR(50), P_Issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	--ALL THE VARIABLE
	v_STATUS VARCHAR(10);
BEGIN
	--Checking If BOOK Is Available 'Yes'
	SELECT 
		STATUS INTO v_STATUS
	FROM BOOKS
	WHERE isbn = P_Issued_book_isbn;

	IF v_STATUS = 'yes' THEN 
	INSERT INTO ISSUED_STATUS(Issued_id, Issued_member_id, Issued_date, Issued_book_isbn, Issued_emp_id)	
	VALUES (P_Issued_id, P_Issued_member_id, CURRENT_DATE, P_Issued_book_isbn, P_Issued_emp_id);

	UPDATE BOOKS
		SET STATUS = 'no'
		WHERE isbn = P_Issued_book_isbn;
		
		RAISE NOTICE 'BOOK RECORDS ADDDED SUCESSFULLY FOR BOOK ISBN : %',P_Issued_book_isbn;
	
	ELSE
		RAISE NOTICE 'Sorry to inform you the book isbn :% you have requested is currently not available',P_Issued_book_isbn;
	END IF;
END;
$$;

--Testing the function
SELECT * FROM BOOKS ''
SELECT * FROM ISSUED_STATUS

'978-0-525-47535-5' --YES
'978-0-375-41398-8' --NO

CALL ISSUE_BOOK ('ISI155', 'C108', '978-0-525-47535-5', 'E104')
CALL ISSUE_BOOK ('ISI156', 'C108', '978-0-375-41398-8', 'E104')


/* Task 20: Create Table As Select (CTAS)
(Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.)
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/
	