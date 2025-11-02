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
(1, 1, 1, 3, 10, '5 lbs'),
(2, 1, 2, 3, 15, 'Body Weight'),
(3, 2, 3, 4, 12, 'Yellow Band'),
(4, 3, 4, 3, 8, '15 lbs'),
(5, 4, 5, 2, 20, 'Body Weight'),
(6, 5, 1, 3, 12, '8 lbs'),
(7, 2, 2, 3, 15, 'Body Weight');
