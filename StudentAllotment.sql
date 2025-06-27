/*0.  Start clean – create the database if it doesn’t exist*/
IF DB_ID(N'StudentAllotmentDB') IS NULL
    CREATE DATABASE StudentAllotmentDB;
GO

USE StudentAllotmentDB;
GO

/*1. Master data tables*/
IF OBJECT_ID(N'dbo.StudentDetails',    'U') IS NOT NULL DROP TABLE dbo.StudentDetails;
IF OBJECT_ID(N'dbo.SubjectDetails',    'U') IS NOT NULL DROP TABLE dbo.SubjectDetails;
IF OBJECT_ID(N'dbo.StudentPreference', 'U') IS NOT NULL DROP TABLE dbo.StudentPreference;
GO

CREATE TABLE dbo.StudentDetails
(
    StudentId   VARCHAR(20)  NOT NULL PRIMARY KEY,
    StudentName NVARCHAR(50),
    GPA         DECIMAL(4,2),
    Branch      NVARCHAR(10),
    Section     NVARCHAR(5)
);
GO

CREATE TABLE dbo.SubjectDetails
(
    SubjectId       VARCHAR(20)  NOT NULL PRIMARY KEY,
    SubjectName     NVARCHAR(100),
    MaxSeats        INT          NOT NULL,
    RemainingSeats  INT          NOT NULL
);
GO

CREATE TABLE dbo.StudentPreference
(
    StudentId  VARCHAR(20) NOT NULL,
    SubjectId  VARCHAR(20) NOT NULL,
    Preference INT         NOT NULL CHECK (Preference BETWEEN 1 AND 5),
    PRIMARY KEY (StudentId, Preference),
    UNIQUE (StudentId, SubjectId),               -- same subject only once
    CONSTRAINT FK_SP_Student FOREIGN KEY (StudentId) REFERENCES dbo.StudentDetails(StudentId),
    CONSTRAINT FK_SP_Subject FOREIGN KEY (SubjectId) REFERENCES dbo.SubjectDetails(SubjectId)
);
GO

/*2. Result tables*/
IF OBJECT_ID(N'dbo.Allotments',        'U') IS NOT NULL DROP TABLE dbo.Allotments;
IF OBJECT_ID(N'dbo.UnallotedStudents', 'U') IS NOT NULL DROP TABLE dbo.UnallotedStudents;
GO

CREATE TABLE dbo.Allotments
(
    SubjectId VARCHAR(20) NOT NULL,
    StudentId VARCHAR(20) NOT NULL,
    PRIMARY KEY (SubjectId, StudentId)
);
GO

CREATE TABLE dbo.UnallotedStudents
(
    StudentId VARCHAR(20) NOT NULL PRIMARY KEY
);
GO

/* 3. Sample data (from the PDF) :contentReference[oaicite:0]{index=0} */
INSERT INTO dbo.SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES
('PO1491','Basics of Political Science', 60,  2),
('PO1492','Basics of Accounting',        120,119),
('PO1493','Basics of Financial Markets', 90, 90),
('PO1494','Eco philosophy',              60, 50),
('PO1495','Automotive Trends',           60, 60);
GO

INSERT INTO dbo.StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES
('159103036','Mohit Agarwal',   8.90,'CCE','A'),
('159103037','Rohit Agarwal',   5.20,'CCE','A'),
('159103038','Shohit Garg',     7.10,'CCE','B'),
('159103039','Mrinal Malhotra', 7.90,'CCE','A'),
('159103040','Mehreet Singh',   5.60,'CCE','A'),
('159103041','Arjun Tehlan',    9.20,'CCE','B');
GO

/* Mohit’s five choices (example in the PDF) */
INSERT INTO dbo.StudentPreference VALUES
('159103036','PO1491',1),
('159103036','PO1492',2),
('159103036','PO1493',3),
('159103036','PO1494',4),
('159103036','PO1495',5);
GO

/*4. Stored procedure AllocateSubjects  (pure T-SQL) */
IF OBJECT_ID(N'dbo.AllocateSubjects', 'P') IS NOT NULL
    DROP PROCEDURE dbo.AllocateSubjects;
GO

CREATE PROCEDURE dbo.AllocateSubjects
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.Allotments;
    TRUNCATE TABLE dbo.UnallotedStudents;

    DECLARE @StudentId  VARCHAR(20),
            @SubjectId  VARCHAR(20),
            @Pref       INT,
            @Alloted    BIT;

    DECLARE curStudents CURSOR LOCAL FAST_FORWARD
    FOR SELECT StudentId
        FROM dbo.StudentDetails
        ORDER BY GPA DESC;

    OPEN curStudents;
    FETCH NEXT FROM curStudents INTO @StudentId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Pref    = 1;
        SET @Alloted = 0;

        WHILE @Pref <= 5 AND @Alloted = 0
        BEGIN
            SELECT @SubjectId = SubjectId
            FROM dbo.StudentPreference
            WHERE StudentId = @StudentId
              AND Preference = @Pref;

            IF @SubjectId IS NOT NULL
               AND EXISTS (SELECT 1
                           FROM dbo.SubjectDetails
                           WHERE SubjectId = @SubjectId
                             AND RemainingSeats > 0)
            BEGIN
                /* allot the seat */
                INSERT INTO dbo.Allotments (SubjectId, StudentId)
                VALUES (@SubjectId, @StudentId);

                UPDATE dbo.SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;

                SET @Alloted = 1;
            END

            SET @Pref = @Pref + 1;
        END

        IF @Alloted = 0
        BEGIN
            INSERT INTO dbo.UnallotedStudents (StudentId)
            VALUES (@StudentId);
        END

        FETCH NEXT FROM curStudents INTO @StudentId;
    END

    CLOSE curStudents;
    DEALLOCATE curStudents;
END
GO

/*5. Run the procedure and display results */
EXEC dbo.AllocateSubjects;
GO

SELECT * FROM dbo.Allotments       ORDER BY StudentId;
SELECT * FROM dbo.UnallotedStudents ORDER BY StudentId;
GO
