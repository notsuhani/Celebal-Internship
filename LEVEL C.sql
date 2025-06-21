                   ------------------------1-----------------------

CREATE TABLE Projects (
    Task_ID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

WITH ConsecutiveTasks AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        ROW_NUMBER() OVER (ORDER BY Start_Date) AS RowNum,
        DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY Start_Date), Start_Date) AS DateDiff
    FROM
        Projects
),
GroupedProjects AS (
    SELECT
        MIN(Start_Date) AS Project_Start_Date,
        MAX(End_Date) AS Project_End_Date,
        COUNT(*) AS Duration
    FROM
        ConsecutiveTasks
    GROUP BY
        DateDiff
)
SELECT
    Project_Start_Date,
    Project_End_Date
FROM
    GroupedProjects
ORDER BY
    Duration ASC,
    Project_Start_Date ASC;

   
                   ------------------------2-----------------------

CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(100)
);

CREATE TABLE Friends (
    ID INT PRIMARY KEY,
    Friend_ID INT,
    FOREIGN KEY (ID) REFERENCES Students(ID),
    FOREIGN KEY (Friend_ID) REFERENCES Students(ID)
);

CREATE TABLE Packages (
    ID INT PRIMARY KEY,
    Salary FLOAT
);


INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

SELECT S.Name
FROM Students S
JOIN Friends F ON S.ID = F.ID
JOIN Packages P1 ON S.ID = P1.ID
JOIN Packages P2 ON F.Friend_ID = P2.ID
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;

                   ------------------------3-----------------------

CREATE TABLE Functions (
    X INT,
    Y INT
);

INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);


SELECT DISTINCT
    f1.X, f1.Y
FROM
    Functions f1
JOIN
    Functions f2 ON f1.X = f2.Y AND f1.Y = f2.X
WHERE
    f1.X <= f1.Y
ORDER BY
    f1.X, f1.Y;

                   ------------------------4-----------------------

CREATE TABLE Contests (
    contest_id INT PRIMARY KEY,
    hacker_id INT,
    name VARCHAR(100)
);

CREATE TABLE Colleges (
    college_id INT PRIMARY KEY,
    contest_id INT,  
);

CREATE TABLE Challenges (
    challenge_id INT PRIMARY KEY,
    college_id INT,
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT,
   
);

CREATE TABLE Submission_Stats (
    challenge_id INT ,
    total_submissions INT,
    total_accepted_submissions INT,
    
);

INSERT INTO Contests (contest_id, hacker_id, name) VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

INSERT INTO Colleges (college_id, contest_id) VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

INSERT INTO Challenges (challenge_id, college_id) VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views) VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions) VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11); 

SELECT 
    c.contest_id, 
    c.hacker_id, 
    c.name, 
    COALESCE(SUM(ss.total_submissions), 0) AS total_submissions, 
    COALESCE(SUM(ss.total_accepted_submissions), 0) AS total_accepted_submissions, 
    COALESCE(SUM(vs.total_views), 0) AS total_views, 
    COALESCE(SUM(vs.total_unique_views), 0) AS total_unique_views
FROM 
    Contests c
JOIN 
    Colleges co ON c.contest_id = co.contest_id
JOIN 
    Challenges ch ON co.college_id = ch.college_id
LEFT JOIN 
    Submission_Stats ss ON ch.challenge_id = ss.challenge_id
LEFT JOIN 
    View_Stats vs ON ch.challenge_id = vs.challenge_id
GROUP BY 
    c.contest_id, c.hacker_id, c.name
HAVING 
    SUM(ss.total_submissions) <> 0 OR 
    SUM(ss.total_accepted_submissions) <> 0 OR 
    SUM(vs.total_views) <> 0 OR 
    SUM(vs.total_unique_views) <> 0
ORDER BY 
    c.contest_id;

                   ------------------------5-----------------------

CREATE TABLE Hackers (
    hacker_id INTEGER PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INTEGER PRIMARY KEY,
    hacker_id INTEGER,
    score INTEGER,
    FOREIGN KEY (hacker_id) REFERENCES Hackers(hacker_id)
);

INSERT INTO Hackers (hacker_id, name) VALUES 
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

WITH DailyUniqueHackers AS (
    SELECT 
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM 
        Submissions
    GROUP BY 
        submission_date
),
DailyMaxSubmissions AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(submission_id) AS submissions_count,
        RANK() OVER (PARTITION BY submission_date ORDER BY COUNT(submission_id) DESC, hacker_id ASC) AS rank
    FROM 
        Submissions
    GROUP BY 
        submission_date, hacker_id
)
SELECT
    du.submission_date,
    du.unique_hackers,
    dm.hacker_id,
    h.name
FROM
    DailyUniqueHackers du
JOIN
    DailyMaxSubmissions dm ON du.submission_date = dm.submission_date
JOIN
    Hackers h ON dm.hacker_id = h.hacker_id
WHERE
    dm.rank = 1
ORDER BY
    du.submission_date;

drop table Submissions;

                   ------------------------6-----------------------
CREATE TABLE STATION (
    ID INT PRIMARY KEY,
    CITY VARCHAR(21),
    STATE CHAR(2),
    LAT_N FLOAT,
    LONG_W FLOAT
);

INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (1, 'City1', 'A1', 39.0, 60.0);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (2, 'City2', 'A2', 52.0, 79.0);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (3, 'City3', 'A3', 40.0, 54.0);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (4, 'City4', 'A4', 41.0, 68.0);
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES (5, 'City5', 'A5', 30.0, 70.0);

WITH MinMaxValues AS (
    SELECT 
        MIN(LAT_N) AS min_lat_n,
        MAX(LAT_N) AS max_lat_n,
        MIN(LONG_W) AS min_long_w,
        MAX(LONG_W) AS max_long_w
    FROM 
        STATION
)

SELECT 
    ROUND(ABS(min_lat_n - max_lat_n) + ABS(min_long_w - max_long_w), 4) AS manhattan_distance
FROM 
    MinMaxValues;

                   ------------------------7-----------------------
CREATE TABLE Numbers (
    num INT
);

DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO Numbers (num) VALUES (@i);
    SET @i = @i + 1;
END;

WITH PrimeNumbers AS (
    SELECT num
    FROM Numbers
    WHERE num > 1 AND NOT EXISTS (
        SELECT 1 
        FROM Numbers AS Divisors
        WHERE Divisors.num > 1 
          AND Divisors.num < Numbers.num
          AND Numbers.num % Divisors.num = 0
    )
)

SELECT STRING_AGG(CAST(num AS VARCHAR), '&') AS primes
FROM PrimeNumbers;


                   ------------------------8-----------------------

CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Samantha', 'Doctor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Julia', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Maria', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Meera', 'Singer');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Ashely', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Ketty', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Christeen', 'Professor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Jane', 'Actor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Jenny', 'Doctor');
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES ('Priya', 'Singer');

WITH RankedNames AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS RowNum
    FROM 
        OCCUPATIONS
)
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM
    RankedNames
GROUP BY
    RowNum
ORDER BY
    RowNum;


                   ------------------------9-----------------------

CREATE TABLE BST (
    N INT,
    P INT
);

INSERT INTO BST (N, P) VALUES (1, 2);
INSERT INTO BST (N, P) VALUES (2, 5);
INSERT INTO BST (N, P) VALUES (3, 2);
INSERT INTO BST (N, P) VALUES (6, 8);
INSERT INTO BST (N, P) VALUES (8, 5);
INSERT INTO BST (N, P) VALUES (9, 8);
INSERT INTO BST (N, P) VALUES (5, NULL);

WITH NodeTypes AS (
    SELECT
        N,
        CASE
            WHEN P IS NULL THEN 'Root'
            WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
            ELSE 'Inner'
        END AS NodeType
    FROM BST
)
SELECT 
    N, 
    NodeType
FROM 
    NodeTypes
ORDER BY 
    N;

                   ------------------------10-----------------------

CREATE TABLE Company (
    company_code VARCHAR(10),
    founder VARCHAR(100)
);

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Manager (
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Employee (
    employee_code VARCHAR(10),
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Company (company_code, founder) VALUES ('C1', 'Monika'), ('C2', 'Samantha');

INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES ('LM1', 'C1'), ('LM2', 'C2');

INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES 
('SM1', 'LM1', 'C1'), 
('SM2', 'LM1', 'C1'), 
('SM3', 'LM2', 'C2');

INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES 
('M1', 'SM1', 'LM1', 'C1'), 
('M2', 'SM3', 'LM2', 'C2'), 
('M3', 'SM3', 'LM2', 'C2');

INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES 
('E1', 'M1', 'SM1', 'LM1', 'C1'), 
('E2', 'M1', 'SM1', 'LM1', 'C1'), 
('E3', 'M2', 'SM3', 'LM2', 'C2'), 
('E4', 'M3', 'SM3', 'LM2', 'C2');

SELECT 
    c.company_code,
    c.founder,
    COUNT(DISTINCT lm.lead_manager_code) AS total_lead_managers,
    COUNT(DISTINCT sm.senior_manager_code) AS total_senior_managers,
    COUNT(DISTINCT m.manager_code) AS total_managers,
    COUNT(DISTINCT e.employee_code) AS total_employees
FROM 
    Company c
LEFT JOIN 
    Lead_Manager lm ON c.company_code = lm.company_code
LEFT JOIN 
    Senior_Manager sm ON c.company_code = sm.company_code
LEFT JOIN 
    Manager m ON c.company_code = m.company_code
LEFT JOIN	
    Employee e ON c.company_code = e.company_code
GROUP BY 
    c.company_code, c.founder
ORDER BY 
    c.company_code;

                   ------------------------11-----------------------

CREATE TABLE Students (
    ID INTEGER,
    Name VARCHAR(100)
);

CREATE TABLE Friends (
    ID INTEGER,
    Friend_ID INTEGER
);

CREATE TABLE Packages (
    ID INTEGER,
    Salary FLOAT
);

INSERT INTO Students (ID, Name) VALUES (2, 'Ashley'), (3, 'Samantha'), (4, 'Julia'), (1, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES (1, 2), (2, 3), (3, 4), (4, 1);

INSERT INTO Packages (ID, Salary) VALUES (2, 15.20), (3, 10.06), (4, 11.55), (1, 12.12);

SELECT 
    s1.Name
FROM 
    Friends f
JOIN 
    Students s1 ON f.ID = s1.ID
JOIN 
    Packages p1 ON s1.ID = p1.ID
JOIN 
    Students s2 ON f.Friend_ID = s2.ID
JOIN 
    Packages p2 ON s2.ID = p2.ID
WHERE 
    p2.Salary > p1.Salary
ORDER BY 
    p2.Salary;

                   ------------------------12-----------------------

CREATE TABLE JobFamily (
    JobFamilyID INTEGER,
    JobFamilyName VARCHAR(100)
);

CREATE TABLE Cost (
    JobFamilyID INTEGER,
    Location VARCHAR(50),
    Cost FLOAT
);

INSERT INTO JobFamily (JobFamilyID, JobFamilyName) VALUES
(1, 'Network_Engineer'),
(2, 'Database_Administrator'),
(3, 'Software_Developer');

INSERT INTO Cost (JobFamilyID, Location, Cost) VALUES
(1, 'India', 50000),
(1, 'International', 70000),
(2, 'India', 100000),
(2, 'International', 500000),
(3, 'India', 400000),
(3, 'International', 600000);

WITH TotalCost AS (
    SELECT 
        Location,
        SUM(Cost) AS TotalCost
    FROM 
        Cost
    GROUP BY 
        Location
), CostPercentage AS (
    SELECT 
        JobFamilyID,
        Location,
        Cost,
        (Cost / (SELECT SUM(Cost) FROM Cost WHERE Location = c.Location)) * 100 AS CostPercentage
    FROM 
        Cost c
)
SELECT 
    jf.JobFamilyName,
    cp.Location,
    cp.CostPercentage
FROM 
    CostPercentage cp
JOIN 
    JobFamily jf ON cp.JobFamilyID = jf.JobFamilyID
ORDER BY 
    jf.JobFamilyName, cp.Location;

                   ------------------------13-----------------------
                   
CREATE TABLE BU (
    BU_ID INTEGER,
    BU_Name VARCHAR(100)
);

CREATE TABLE Cost (
    BU_ID INTEGER,
    Month DATE,
    Cost FLOAT
);

CREATE TABLE Revenue (
    BU_ID INTEGER,
    Month DATE,
    Revenue FLOAT
);

INSERT INTO BU (BU_ID, BU_Name) VALUES
(1, 'BU1'),
(2, 'BU2');

INSERT INTO Cost (BU_ID, Month, Cost) VALUES
(1, '2025-01-01', 60000),
(1, '2025-02-01', 80000),
(2, '2025-01-01', 40000),
(2, '2025-02-01', 50000);

INSERT INTO Revenue (BU_ID, Month, Revenue) VALUES
(1, '2025-01-01', 100000),
(1, '2025-02-01', 110000),
(2, '2025-01-01', 70000),
(2, '2025-02-01', 80000);

WITH CostRevenue AS (
    SELECT 
        c.BU_ID,
        c.Month,
        c.Cost,
        r.Revenue,
        (c.Cost / r.Revenue) AS CostRevenueRatio
    FROM 
        Cost c
    JOIN 
        Revenue r ON c.BU_ID = r.BU_ID AND c.Month = r.Month
)
SELECT 
    bu.BU_Name,
    cr.Month,
    cr.Cost,
    cr.Revenue,
    cr.CostRevenueRatio
FROM 
    CostRevenue cr
JOIN 
    BU bu ON cr.BU_ID = bu.BU_ID
ORDER BY 
    bu.BU_Name, cr.Month;


                   ------------------------14-----------------------

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    SubBand VARCHAR(10)
);

INSERT INTO Employee (EmployeeID, EmployeeName, SubBand) VALUES
(1, 'Alia', 'A1'),
(2, 'Bobby', 'A2'),
(3, 'Charles', 'A1'),
(4, 'David', 'A3'),
(5, 'Dhani', 'A2'),
(6, 'Emma', 'A1'),
(7, 'Frank', 'A3'),
(8, 'Heena', 'A2'),
(9, 'Jennie', 'A1'),
(10, 'Jisso', 'A2');

WITH TotalCount AS (
    SELECT COUNT(*) AS Total FROM Employee
)
SELECT 
    SubBand,
    COUNT(*) AS HeadCount,
    ROUND((COUNT(*) * 100.0 / (SELECT Total FROM TotalCount)), 2) AS Percentage
FROM Employee
GROUP BY SubBand;

                   ------------------------15-----------------------

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employee (EmployeeID, EmployeeName, Salary) VALUES
(1, 'Alia', 85000.00),
(2, 'Boby', 82000.00),
(3, 'Charles', 70000.00),
(4, 'David', 90000.00),
(5, 'Emma', 62000.00),
(6, 'France', 68000.00),
(7, 'Heena', 85000.00),
(8, 'Hira', 90000.00),
(9, 'Jennie', 85000.00),
(10, 'Jisso', 95000.00);

WITH RankedEmployees AS (
    SELECT 
        EmployeeID,
        EmployeeName,
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rank
    FROM Employee
)
SELECT 
    EmployeeID,
    EmployeeName,
    Salary
FROM RankedEmployees
WHERE Rank <= 5;

                   ------------------------16-----------------------

CREATE TABLE ExampleTable (
    ID INT PRIMARY KEY,
    Col1 INT,
    Col2 INT
);

INSERT INTO ExampleTable (ID, Col1, Col2) VALUES
(1, 12, 72),
(2, 35, 94),
(3, 56, 16);

UPDATE ExampleTable
SET Col1 = Col1 + Col2;
UPDATE ExampleTable
SET Col2 = Col1 - Col2;
UPDATE ExampleTable
SET Col1 = Col1 - Col2;

SELECT * FROM ExampleTable;

                   ------------------------17-----------------------

CREATE LOGIN userlog
WITH PASSWORD = 'user123';
USE celebal;
CREATE USER ExampleUser FOR LOGIN userlog;
ALTER ROLE db_owner ADD MEMBER ExampleUser;


                   ------------------------18-----------------------

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    BU VARCHAR(50)
);

CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY,
    EmployeeID INT,
    SalaryMonth DATE,
    SalaryAmount DECIMAL(10, 2),
    Weight DECIMAL(5, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Employees (EmployeeID, EmployeeName, BU) VALUES
(1, 'Alia', 'Sales'),
(2, 'Booby', 'Sales'),
(3, 'Charles', 'HR'),
(4, 'Dan', 'HR'),
(5, 'Ema', 'Sales');

INSERT INTO Salaries (SalaryID, EmployeeID, SalaryMonth, SalaryAmount, Weight) VALUES
(1, 1, '2025-01-01', 5500, 1.0),
(2, 1, '2025-02-01', 5200, 1.1),
(3, 2, '2025-01-01', 6400, 1.0),
(4, 2, '2025-02-01', 6100, 1.2),
(5, 3, '2025-01-01', 7100, 1.0),
(6, 3, '2025-02-01', 4500, 1.1),
(7, 4, '2025-01-01', 7000, 1.0),
(8, 4, '2025-02-01', 7100, 1.3),
(9, 5, '2025-01-01', 8400, 1.0),
(10, 5, '2025-02-01', 7000, 1.4);

SELECT 
    BU,
    SalaryMonth,
    SUM(SalaryAmount * Weight) / SUM(Weight) AS WeightedAverageCost
FROM 
    Employees e
JOIN 
    Salaries s ON e.EmployeeID = s.EmployeeID
GROUP BY 
    BU, SalaryMonth
ORDER BY 
    BU, SalaryMonth;

                   ------------------------19-----------------------

CREATE TABLE EMPLOYEES (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Salary DECIMAL(10, 2)
);

INSERT INTO EMPLOYEES (EmployeeID, EmployeeName, Salary) VALUES
(1, 'Alia', 5000.00),
(2, 'Bobby', 6000.00),
(3, 'Charles', 7000.00),
(4, 'Dan', 8000.00),
(5, 'Emma', 9000.00);

WITH ActualAverage AS (
    SELECT AVG(Salary) AS ActualAvgSalary
    FROM EMPLOYEES
),

MiscalculatedAverage AS (
    SELECT AVG(CAST(REPLACE(CAST(Salary AS VARCHAR(20)), '0', '') AS DECIMAL(10, 2))) AS MiscalculatedAvgSalary
    FROM EMPLOYEES
)

SELECT 
    CEILING(ActualAvgSalary - MiscalculatedAvgSalary) AS ErrorRoundedUp
FROM 
    ActualAverage, MiscalculatedAverage;


                   ------------------------20-----------------------

CREATE TABLE SourceTable (
    ID INT PRIMARY KEY,
    Data VARCHAR(100)
);

CREATE TABLE NewTable (
    ID INT PRIMARY KEY,
    Data VARCHAR(100)
);
INSERT INTO SourceTable (ID, Data) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

INSERT INTO NewTable (ID, Data) VALUES
(1, 'A'),
(2, 'B');

SELECT * FROM SourceTable;
SELECT * FROM NewTable;

INSERT INTO NewTable (ID, Data)
SELECT ID, Data
FROM SourceTable
EXCEPT
SELECT ID, Data
FROM NewTable;
SELECT * FROM SourceTable;
SELECT * FROM NewTable;
