## Physical Therapy (PT) Scheduling & Progress Tracker

**Goal: Manage referrals, scheduled sessions, exercises prescribed, and progress scores.**

*Tables*:
- Staff(StaffID, Position, StaffName, Phone, DOB)

- Therapist (Specialty, StaffID, Position, StaffName, Phone, DOB)

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

*Assumptions*

1. General Data
- Each patient can have multiple referrals, each linked to one diagnosis and provider.
- Sessions are independent of referrals.
- Dates follow `YYYY-MM-DD` format.
- Multiple outcome scores per patient and measure are expected.

2. Sessions & Scheduling
- `Status` values include: `'Scheduled'`, `'Completed'`, `'Cancelled'`, `'No-show'`, `'Rescheduled'`.
- Rescheduled sessions are recorded as new rows; original marked `'Rescheduled'`.
- Pain scores are recorded on a 0–10 scale.

3. Exercise Tracking
- Exercises are only recorded if performed during a session.
- Resistance can be numeric (e.g., `5`) or descriptive (e.g., `"Red band"`).
- Each session may include multiple exercises.

4. Outcome Measures
- Standardized `MeasureName` values (e.g., `'DASH'`, `'LEFS'`).
- Multiple scores can exist for the same measure/patient.
- Interpretation (higher/lower is better) is handled in reporting.

*Scope of the Project*

In Scope
- Patient data: demographics, contact information.
- Referral Data: diagnoses codes, referring provider, referral date.
- Session Data: therapist, date, status, pain scores, and notes.
- Exercise Data: exercise name, body region, difficulty level.
- Session-Exercise Linkage: details of sets, reps, and resistance performed.
- Outcome measures: score values tied to a patient, measure name, and date recorded.

Out of Scope:
- Billing, payments, or insurance claims.
- Therapist payroll, staffing schedules, or time tracking.
- Inventory of clinic equipment or supply usage.
- Profit, loss, or other financial reporting.

*Team Assignments*

Zak Gilliam:
- Table(s)
    - Exercises
- Implementation focus: Build and test the *Exercises* table, ensuring standardized attributes.
- Front end: Lead development of the website interface where the database will be implemented.

Fin Deevy:
- Table(s)
    - SessionExercises, OutcomeMeasures
- Implementation focus: Manage the design and population of outcome measure data, plus the many-to-many link table (SessionExercise) to track prescribed sets, reps, and resistance.

Alexis Herman:
- Table(s)
    - Patients, Referrals, and Sessions
- Implementation focus: Build and test core patient/clinical scheduling tables, ensuring proper foreign key linkage between patients, referrals, and sessions

Shared Work:
- ER model
- Relational design with data dictionary
- Team presentation
