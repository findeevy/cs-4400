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

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    StaffName VARCHAR(100) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Phone VARCHAR(20),
    DOB DATE
);

CREATE TABLE Therapist (
    StaffID INT PRIMARY KEY,
    Specialty VARCHAR(50),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Refferals (
    RefferalID  INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DxCode VARCHAR(20),
    ReferringProvider VARCHAR(50),
    ReferralDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

CREATE TABLE SessionExercises (
    SessionExerciseID INT PRIMARY KEY AUTO_INCREMENT,
    SessionID INT NOT NULL,
    ExerciseID INT NOT NULL,
    Sets TINYINT NOT NULL CHECK (Sets > 0),
    Reps TINYINT NOT NULL CHECK (Reps > 0),
    Resistance VARCHAR(20),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (SessionID) REFERENCES Sessions(SessionID) ON DELETE CASCADE,
    FOREIGN KEY (ExerciseID) REFERENCES Exercises(ExerciseID) ON DELETE RESTRICT,
    
    UNIQUE KEY unique_exercise_per_session (SessionID, ExerciseID)
);

CREATE TABLE OutcomeMeasures (
    OutcomeID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    MeasureName VARCHAR(50) NOT NULL,
    Score DECIMAL(5,2) NOT NULL,
    TakenOn DATE NOT NULL,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    
    INDEX idx_patient_measure (PatientID, MeasureName)
);
