CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Phone VARCHAR(20)
);

CREATE TABLE Sessions (
    SessionID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    Therapist INT NOT NULL,
    SessionDate DATE NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Canceled', 'No-Show') DEFAULT 'Scheduled',
    PainPre TINYINT CHECK (PainPre BETWEEN 0 AND 10),
    PainPost TINYINT CHECK (PainPost BETWEEN 0 AND 10),
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

CREATE TABLE Exercises (
    ExerciseID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    BodyRegion VARCHAR(30) NOT NULL,
    Difficulty TINYINT CHECK (Difficulty BETWEEN 1 AND 5)
);
