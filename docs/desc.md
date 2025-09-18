## Physical Therapy (PT) Scheduling & Progress Tracker

**Goal: Manage referrals, scheduled sessions, exercises prescribed, and progress scores.**

*Tables*:

- Patients(PatientID PK, Name, DOB, Phone)

- Referrals(ReferralID PK, PatientID FK, DxCode, ReferringProvider, ReferralDate)

- Sessions(SessionID PK, PatientID FK, Therapist, SessionDate, Status, PainPre, PainPost, Notes)

- Exercises(ExerciseID PK, Name, BodyRegion, Difficulty)

- SessionExercises(SessionExerciseID PK, SessionID FK, ExerciseID FK, Sets, Reps, Resistance)

- OutcomeMeasures(OutcomeID PK, PatientID FK, MeasureName, Score, TakenOn)

*Core ops & forms*:

- Schedule/cancel/reschedule a session (update status).

- Document each session (pain scores, exercises performed).

- Record outcome measures over time.

- Queries to demonstrate:

- “No-show rate by therapist/month” (GROUP BY).

- “Change in outcome score from baseline” (self-join or window).

- “Top 5 most-prescribed exercises for shoulder” (aggregate + filter).
