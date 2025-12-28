CREATE DATABASE sesion02;
USE sesion02;
CREATE TABLE Class (
    ClassID VARCHAR(10) PRIMARY KEY,
    ClassName VARCHAR(50) NOT NULL,
    SchoolYear VARCHAR(10)
);
CREATE TABLE Student (
    StudentID VARCHAR(10) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    BirthDate DATE,
    ClassID VARCHAR(10),
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
);
CREATE TABLE Teacher (
    TeacherID VARCHAR(10) PRIMARY KEY,
    TeacherName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE
);
CREATE TABLE Subject (
    SubjectID VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credit INT CHECK(Credit > 0),
    TeacherID VARCHAR(10),
    FOREIGN KEY (TeacherID) REFERENCES Teacher(TeacherID)
);
CREATE TABLE Enrollment (
    StudentID VARCHAR(10),
    SubjectID VARCHAR(10),
    EnrollDate DATE,
    PRIMARY KEY (StudentID, SubjectID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);
CREATE TABLE Score (
    StudentID VARCHAR(10),
    SubjectID VARCHAR(10),
    ProcessScore DECIMAL(3,1) CHECK (ProcessScore BETWEEN 0 AND 10),
    FinalScore DECIMAL(3,1) CHECK (FinalScore BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (SubjectID) REFERENCES Subject(SubjectID)
);
