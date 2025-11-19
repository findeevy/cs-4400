-- (Re)create in dependency-safe order
DROP TABLE IF EXISTS SessionExercises;
DROP TABLE IF EXISTS OutcomeMeasures;
DROP TABLE IF EXISTS Sessions;
DROP TABLE IF EXISTS Referrals;
DROP TABLE IF EXISTS Therapist;
DROP TABLE IF EXISTS Exercises;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Patients;


-- =========================
-- Core entities
-- =========================
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Phone VARCHAR(20)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    StaffName VARCHAR(100) NOT NULL,
    Position VARCHAR(50) NOT NULL, -- e.g., Therapist, PTA, Admin
    Phone VARCHAR(20),
    DOB DATE
);

-- Therapist is a strict subtype of Staff; only Specialty lives here.
CREATE TABLE Therapist (
    StaffID INT PRIMARY KEY,
    Specialty VARCHAR(50) NOT NULL,
    CONSTRAINT fk_therapist_staff
        FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Exercises (
    ExerciseID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    BodyRegion VARCHAR(30) NOT NULL,
    Difficulty TINYINT NOT NULL,
    CONSTRAINT chk_ex_difficulty CHECK (Difficulty BETWEEN 1 AND 5)
);

-- =========================
-- Clinical events / records
-- =========================
CREATE TABLE Sessions (
    SessionID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    TherapistID INT NOT NULL,               -- FK to Therapist (StaffID)
    SessionDate DATE NOT NULL,
    Status ENUM('Scheduled','Completed','Canceled','No-Show') NOT NULL DEFAULT 'Scheduled',
    PainPre TINYINT NULL,
    PainPost TINYINT NULL,
    Notes TEXT,
    CONSTRAINT chk_painpre  CHECK (PainPre  BETWEEN 0 AND 10 OR PainPre  IS NULL),
    CONSTRAINT chk_painpost CHECK (PainPost BETWEEN 0 AND 10 OR PainPost IS NULL),
    CONSTRAINT fk_session_patient
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_session_therapist
        FOREIGN KEY (TherapistID) REFERENCES Therapist(StaffID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Optional business rule: at most one session per patient per date
    CONSTRAINT uq_patient_sessiondate UNIQUE (PatientID, SessionDate)
);

CREATE TABLE Referrals (
    ReferralID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    DxCode VARCHAR(20) NOT NULL,
    ReferralDate DATE NOT NULL,
    ReferringProvider VARCHAR(100) NULL, -- external name/NPI optional
    CONSTRAINT fk_ref_patient
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_ref_one_source CHECK (
        ReferringProvider IS NOT NULL
    ),
    -- Optional de-dup rule
    INDEX idx_ref_patient_date_dx (PatientID, ReferralDate, DxCode)
);

CREATE TABLE SessionExercises (
    SessionExerciseID INT PRIMARY KEY AUTO_INCREMENT,
    SessionID INT NOT NULL,
    ExerciseID INT NOT NULL,
    Sets TINYINT NOT NULL,
    Reps TINYINT NOT NULL,
    Resistance VARCHAR(20),
    CONSTRAINT chk_sets CHECK (Sets > 0),
    CONSTRAINT chk_reps CHECK (Reps > 0),
    CONSTRAINT fk_se_session
        FOREIGN KEY (SessionID) REFERENCES Sessions(SessionID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_se_exercise
        FOREIGN KEY (ExerciseID) REFERENCES Exercises(ExerciseID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Avoid duplicate identical prescriptions within a session
    CONSTRAINT uq_se_nodup UNIQUE (SessionID, ExerciseID, Sets, Reps, Resistance)
);

CREATE TABLE OutcomeMeasures (
    OutcomeID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    MeasureName VARCHAR(50) NOT NULL,
    Score DECIMAL(5,2) NOT NULL,
    TakenOn DATE NOT NULL,
    Notes TEXT,
    CONSTRAINT fk_om_patient
        FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Prevent duplicate scoring of same instrument on same day
    CONSTRAINT uq_om_unique UNIQUE (PatientID, MeasureName, TakenOn),
    INDEX idx_patient_measure (PatientID, MeasureName)
);

-- =========================
-- Seed data (consistent with constraints)
-- =========================

-- Patients
INSERT INTO Patients (Name, DOB, Phone) VALUES
('Alice Johnson', '1985-04-12', '555-1234'),
('Bob Smith',     '1990-07-22', '555-5678'),
('Carla Reyes',   '1978-11-03', '555-9012'),
('David Kim',     '2000-01-15', '555-3456'),
('Eva Martinez',  '1965-09-30', '555-7890');

-- Staff (include both therapists and non-therapists)
INSERT INTO Staff (StaffName, Position, Phone, DOB) VALUES
('Dr. Sarah Lee', 'Therapist', '555-1111', '1980-05-10'),
('Tom Nguyen',    'Admin',     '555-2222', '1988-08-08'),
('Rachel Green',  'Therapist', '555-3333', '1992-03-25'),
('Mike Brown',    'PTA',       '555-4444', '1975-12-01'),
('Linda Park',    'Therapist', '555-5555', '1983-06-17');

-- Therapist (only true therapists should appear here)
INSERT INTO Therapist (StaffID, Specialty) VALUES
(1, 'Wrist Rehab'),
(3, 'Hip Rehab'),
(5, 'Knee Rehab');
-- Note: PTA (4) and Admin (2) are NOT inserted into Therapist.

-- Exercises
INSERT INTO Exercises (Name, BodyRegion, Difficulty) VALUES
('SLR',          'Knee',    2),
('Bridges',      'Lumbar',  3),
('Wall Angels',  'Shoulder',4),
('Heel Slides',  'Hip',     1),
('Plank',        'Core',    5);

-- Sessions (TherapistID must reference Therapist.StaffID: 1,3,5)
INSERT INTO Sessions (PatientID, TherapistID, SessionDate, Status, PainPre, PainPost, Notes) VALUES
(1, 1, '2025-10-10', 'Completed', 7, 4, 'Initial evaluation and assessment'),
(2, 3, '2025-10-11', 'Completed', 6, 3, 'Manual therapy and stretching'),
(3, 5, '2025-10-12', 'Scheduled', 5, 5, 'Follow-up session planned'),
(4, 3, '2025-10-13', 'Canceled',  0, 0, 'Patient canceled due to illness'),
(5, 1, '2025-10-14', 'Completed', 8, 5, 'Pain management and mobility work');

-- Referrals
-- Use internal referrer when it’s one of the therapists; otherwise use external name.
INSERT INTO Referrals (PatientID, DxCode, ReferralDate, ReferringProvider) VALUES
(1, 'M54.5', '2025-10-01', 'Dr. Kevin Lee'),                    
(2, 'G44.1', '2025-10-03', 'Dr. Rachel Brown'),    
(3, 'S83.2', '2025-10-05', 'Dr. Kevin Nguyen'),   
(4, 'M25.5', '2025-10-07', 'Dr. Lee Blue'),        
(5, 'R51',   '2025-10-09', 'Dr. Harry James');     

-- SessionExercises
INSERT INTO SessionExercises (SessionID, ExerciseID, Sets, Reps, Resistance) VALUES
(1, 1, 3, 10, '5 lb'),
(2, 2, 2, 15, 'Blue band'),
(2, 3, 3, 12, 'Bodyweight'),
(5, 4, 2, 20, 'None'),
(5, 5, 3, 10, 'Green band');

-- OutcomeMeasures
INSERT INTO OutcomeMeasures (PatientID, MeasureName, Score, TakenOn, Notes) VALUES
(1, 'ODI', 24.50, '2025-10-15', 'Moderate disability noted'),
(2, 'LEFS', 65.00, '2025-10-16', 'Improved mobility since last visit'),
(3, 'TUG', 12.30, '2025-10-17', 'Within normal range'),
(4, 'ODI', 30.00, '2025-10-18', 'Severe pain reported'),
(5, 'LEFS', 70.00, '2025-10-19', 'Good progress in strength and endurance');

-- Triggers (at least 3)
-- 1) AFTER INSERT on Sessions: if PainPost is NULL copy PainPre to PainPost (keeps data consistent)
-- 2) BEFORE INSERT on OutcomeMeasures: validate Score range (0-100)
-- 3) BEFORE INSERT on SessionExercises: Prevent exercise data from being inputed to a cancelled/no-show sessions
-- -------------------------
DELIMITER $$

CREATE TRIGGER trg_sessions_after_insert
AFTER INSERT ON Sessions
FOR EACH ROW
BEGIN
-- If a completed session has no PainPost recorded, default PainPost to PainPre for consistency
IF NEW.PainPost IS NULL AND NEW.PainPre IS NOT NULL THEN
UPDATE Sessions
SET PainPost = NEW.PainPre
WHERE SessionID = NEW.SessionID;
END IF;
END$$


CREATE TRIGGER trg_outcomemeasures_before_insert
BEFORE INSERT ON OutcomeMeasures
FOR EACH ROW
BEGIN
-- Enforce score range 0 - 100 (extra safety beyond app-level checks)
IF NEW.Score < 0 OR NEW.Score > 100 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Score must be between 0 and 100';
END IF;
END$$


CREATE TRIGGER trg_no_exercises_for_canceled_sessions
BEFORE INSERT ON SessionExercises
FOR EACH ROW
BEGIN
-- Prevent adding exercises to Canceled or No-Show sessions
IF (
SELECT Status
FROM Sessions
WHERE SessionID = NEW.SessionID
) IN ('Canceled', 'No-Show') THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Cannot add exercises to a canceled or no-show session';
END IF;
END$$

DELIMITER ;


-- Views (at least 2)
-- 1) PatientSummary: aggregated view per patient
-- 2) TherapistWorkload: therapist + count of sessions and distinct patients
-- -------------------------
CREATE VIEW PatientSummary AS
SELECT
p.PatientID,
p.Name,
COUNT(s.SessionID) AS NumSessions,
MAX(s.SessionDate) AS LastSession,
ROUND(AVG(om.Score),2) AS AvgOutcomeScore
FROM Patients p
LEFT JOIN Sessions s ON p.PatientID = s.PatientID
LEFT JOIN OutcomeMeasures om ON p.PatientID = om.PatientID
GROUP BY p.PatientID;

CREATE VIEW TherapistWorkload AS
SELECT
t.StaffID AS TherapistID,
st.StaffName,
t.Specialty,
COUNT(s.SessionID) AS NumSessions,
COUNT(DISTINCT s.PatientID) AS NumPatients
FROM Therapist t
JOIN Staff st ON t.StaffID = st.StaffID
LEFT JOIN Sessions s ON t.StaffID = s.TherapistID
GROUP BY t.StaffID;

-- Procedures and Functions
-- 1) Procedure: AddSession(IN ... ) - demonstrates input parameters
-- 2) Function: fn_avg_pain_reduction(patientid) - returns avg PainPre - PainPost
-- -------------------------
DELIMITER $$
CREATE PROCEDURE AddSession(
IN p_PatientID INT,
IN p_TherapistID INT,
IN p_SessionDate DATE,
IN p_Status VARCHAR(20),
IN p_PainPre TINYINT,
IN p_PainPost TINYINT,
IN p_Notes TEXT
)
BEGIN
-- Simple validation (raise error if therapist is not a valid therapist)
IF NOT EXISTS (SELECT 1 FROM Therapist WHERE StaffID = p_TherapistID) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Provided therapist id is not a valid Therapist';
END IF;
INSERT INTO Sessions (PatientID, TherapistID, SessionDate, Status, PainPre, PainPost, Notes)
VALUES (p_PatientID, p_TherapistID, p_SessionDate, p_Status, p_PainPre, p_PainPost, p_Notes);
END$$


CREATE FUNCTION fn_avg_pain_reduction(p_PatientID INT)
RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
DECLARE v_avg DECIMAL(6,2);
SELECT IFNULL(AVG(PainPre - PainPost), 0)
INTO v_avg
FROM Sessions
WHERE PatientID = p_PatientID
AND PainPre IS NOT NULL AND PainPost IS NOT NULL
AND Status = 'Completed';
RETURN ROUND(v_avg,2);
END$$
DELIMITER ;

-- Five required queries (meeting the constraints)
-- Query 1: Uses a VIEW. Show patients with average outcome score < 50 (aggregation + view)
-- Query 2: Join multiple tables and aggregate: number of exercises prescribed per session
-- Query 3: Uses a view + join: therapists and their workload (aggregate)
-- Query 4: Uses subquery: patients with at least one outcome score above overall average
-- Query 5: Join across referrals and patients to list referral details and indicate that all referral sources are external.

-- Query 1: uses view (PatientSummary) and aggregation already done in view
-- Description: List patients whose average outcome score (across instruments) is below 50
SELECT * FROM PatientSummary WHERE AvgOutcomeScore IS NOT NULL AND AvgOutcomeScore < 50;


-- Query 2: For each session, list the number of distinct exercises prescribed and total sets
-- Description: Shows exercise counts per session (useful to display session complexity)
SELECT
s.SessionID,
p.Name AS PatientName,
s.SessionDate,
COUNT(DISTINCT se.ExerciseID) AS DistinctExercises,
SUM(se.Sets) AS TotalSets
FROM Sessions s
JOIN Patients p ON s.PatientID = p.PatientID
LEFT JOIN SessionExercises se ON s.SessionID = se.SessionID
GROUP BY s.SessionID, p.Name, s.SessionDate;


-- Query 3: Therapist workload via view join (join + aggregation)
-- Description: Show therapist name, specialty, number of sessions and distinct patients
SELECT tw.TherapistID, tw.StaffName, tw.Specialty, tw.NumSessions, tw.NumPatients
FROM TherapistWorkload tw
ORDER BY tw.NumSessions DESC;


-- Query 4: Subquery example
-- Description: Return patients who have at least one outcome score above the overall average score
SELECT DISTINCT p.PatientID, p.Name
FROM Patients p
JOIN OutcomeMeasures om ON p.PatientID = om.PatientID
WHERE om.Score > (
SELECT AVG(Score) FROM OutcomeMeasures
);


-- Query 5: All Patient Referrals (Most Recent First)
-- Description: Displays all referrals, including patient name, diagnosis, date, and external referring provider, sorted by most recent.
SELECT 
    r.ReferralID,
    p.Name AS PatientName,
    r.DxCode,
    r.ReferralDate,
    'External' AS SourceType,
    r.ReferringProvider
FROM Referrals r
JOIN Patients p ON r.PatientID = p.PatientID
ORDER BY r.ReferralDate DESC;
