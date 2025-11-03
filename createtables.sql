CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Phone VARCHAR(20)
);

INSERT INTO Patients (PatientID, Name, DOB, Phone) VALUES
(1, 'Alice Johnson', '1985-04-12', '555-1234'),
(2, 'Bob Smith', '1990-07-22', '555-5678'),
(3, 'Carla Reyes', '1978-11-03', '555-9012'),
(4, 'David Kim', '2000-01-15', '555-3456'),
(5, 'Eva Martinez', '1965-09-30', '555-7890');

CREATE TABLE Sessions (
    SessionID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    StaffID INT NOT NULL,
    SessionDate DATE NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Canceled', 'No-Show') DEFAULT 'Scheduled',
    PainPre TINYINT CHECK (PainPre BETWEEN 0 AND 10),
    PainPost TINYINT CHECK (PainPost BETWEEN 0 AND 10),
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

INSERT INTO Sessions (SessionID, PatientID, Therapist, SessionDate, Status, PainPre, PainPost, Notes) VALUES
(1, 1, 1, '2025-10-10', 'Completed', 7, 4, 'Initial evaluation and assessment'),
(2, 2, 3, '2025-10-11', 'Completed', 6, 3, 'Manual therapy and stretching'),
(3, 3, 5, '2025-10-12', 'Scheduled', 5, 5, 'Follow-up session planned'),
(4, 4, 4, '2025-10-13', 'Canceled', 0, 0, 'Patient canceled due to illness'),
(5, 5, 1, '2025-10-14', 'Completed', 8, 5, 'Pain management and mobility work');

CREATE TABLE Exercises (
    ExerciseID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    BodyRegion VARCHAR(30) NOT NULL,
    Difficulty TINYINT CHECK (Difficulty BETWEEN 1 AND 5)
);

INSERT INTO Exercises (ExerciseID, Name, BodyRegion, Difficulty) VALUES
(1, 'SLR', 'Knee', 2),
(2, 'Bridges', 'Lumbar', 3),
(3, 'Wall Angels', 'Shoulder', 4),
(4, 'Heel Slides', 'Hip', 1),
(5, 'Plank', 'Core', 5);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    StaffName VARCHAR(100) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Phone VARCHAR(20),
    DOB DATE
);

INSERT INTO Staff (StaffID, StaffName, Position, Phone, DOB) VALUES
(1, 'Dr. Sarah Lee', 'Therapist', '555-1111', '1980-05-10'),
(2, 'Tom Nguyen', 'Admin', '555-2222', '1988-08-08'),
(3, 'Rachel Green', 'Therapist', '555-3333', '1992-03-25'),
(4, 'Mike Brown', 'PTA', '555-4444', '1975-12-01'),
(5, 'Linda Park', 'Therapist', '555-5555', '1983-06-17');

CREATE TABLE Therapist (
    StaffID INT PRIMARY KEY,
    Specialty VARCHAR(50),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

INSERT INTO Therapist (StaffID, Specialty) VALUES
(1, 'Wrists'),
(3, 'Hips'),
(5, 'Knees'),
(4, 'Sports Rehab'),
(2, 'Shoulders');

CREATE TABLE Refferals (
    RefferalID  INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DxCode VARCHAR(20),
    ReferringProvider VARCHAR(50),
    ReferralDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

INSERT INTO Refferals (ReferralID, PatientID, DxCode, ReferringProvider, ReferralDate) VALUES
(1, 1, 'M54.5', 'Dr. Sarah Lee', '2025-10-01'),
(2, 2, 'G44.1', 'Dr. Rachel Brown', '2025-10-03'),
(3, 3, 'S83.2', 'Dr. Tom Nguyen', '2025-10-05'),
(4, 4, 'M25.5', 'Dr. Linda Park', '2025-10-07'),
(5, 5, 'R51', 'Dr. Harry James', '2025-10-09');

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

INSERT INTO SessionExercises (SessionExerciseID, SessionID, ExerciseID, Sets, Reps, Resistance) VALUES
(1, 1, 1, 3, 10, '5 lb'),
(2, 2, 2, 2, 15, 'Blue band'),
(3, 2, 3, 3, 12, 'Bodyweight'),
(4, 5, 4, 2, 20, 'None'),
(5, 5, 5, 3, 10, 'Green band');

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

INSERT INTO OutcomeMeasures (OutcomeID, PatientID, MeasureName, Score, TakenOn, Notes) VALUES
(1, 1, 'ODI', 24.5, '2025-10-15', 'Moderate disability noted'),
(2, 2, 'LEFS', 65.0, '2025-10-16', 'Improved mobility since last visit'),
(3, 3, 'TUG', 12.3, '2025-10-17', 'Within normal range'),
(4, 4, 'ODI', 30.0, '2025-10-18', 'Severe pain reported'),
(5, 5, 'LEFS', 70.0, '2025-10-19', 'Good progress in strength and endurance');
