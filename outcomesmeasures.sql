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
(1, 1, 'ODI', 45.00, '2024-01-15', 'Oswestry Disability Index - Moderate disability'),
(2, 1, 'ODI', 38.00, '2024-02-15', 'Oswestry Disability Index - Moderate disability, improved'),
(3, 2, 'LEFS', 52.00, '2024-01-20', 'Lower Extremity Functional Scale'),
(4, 3, 'TUG', 12.50, '2024-01-25', 'Timed Up and Go test - seconds'),
(5, 2, 'LEFS', 65.00, '2024-02-20', 'Significant improvement in lower extremity function'),
(6, 4, 'NPRS', 7.00, '2024-01-30', 'Numeric Pain Rating Scale at rest'),
(7, 4, 'NPRS', 4.00, '2024-02-28', 'Numeric Pain Rating Scale - improved');
