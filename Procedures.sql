USE GIU_Germany_Connect;
GO

CREATE OR ALTER FUNCTION GetRemainingCapacity (@opp_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @capacity INT, @accepted INT;

    SELECT @capacity = capacity FROM Opportunity WHERE opp_id = @opp_id;
    IF @capacity IS NULL
        RETURN 0;

    SELECT @accepted = COUNT(*)
    FROM Application
    WHERE opp_id = @opp_id AND status = 'Accepted';

    RETURN @capacity - @accepted;
END
GO

CREATE OR ALTER FUNCTION HasAcceptedThesis (@student_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    IF EXISTS (SELECT 1
               FROM Application a
               JOIN Opportunity o ON o.opp_id = a.opp_id
               WHERE a.student_id = @student_id
                 AND a.status = 'Accepted'
                 AND o.type = 'Thesis')
        SET @result = 1;

    RETURN @result;
END
GO

CREATE OR ALTER FUNCTION CheckEligibility (@student_id INT, @opp_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @ok BIT = 1;

    IF EXISTS (SELECT 1 FROM Opp_Eligible_Program WHERE opp_id = @opp_id)
       AND NOT EXISTS (SELECT 1
                       FROM Opp_Eligible_Program e
                       JOIN Student s ON s.program_id = e.program_id
                       WHERE e.opp_id = @opp_id AND s.person_id = @student_id)
        SET @ok = 0;

    IF EXISTS (SELECT 1
               FROM Opp_Prereq_Course pc
               WHERE pc.opp_id = @opp_id
                 AND NOT EXISTS (SELECT 1 FROM Completed_Course cc
                                 WHERE cc.student_id = @student_id AND cc.course_id = pc.course_id))
        SET @ok = 0;

    IF EXISTS (SELECT 1
               FROM Opp_Skill os
               WHERE os.opp_id = @opp_id
                 AND NOT EXISTS (SELECT 1 FROM Student_Skill ss
                                 WHERE ss.student_id = @student_id AND ss.skill_id = os.skill_id))
        SET @ok = 0;

    RETURN @ok;
END
GO

CREATE OR ALTER FUNCTION ViewPersonInfo (@person_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.person_id, p.full_name, p.email, p.phone, p.account_status,
           CASE WHEN s.person_id IS NOT NULL THEN 'Student'
                WHEN a.person_id IS NOT NULL THEN 'GIU Academic'
                WHEN pp.person_id IS NOT NULL THEN 'Partner Professor'
                WHEN c.person_id IS NOT NULL THEN 'Company Representative'
                ELSE 'No role' END AS role,
           CASE WHEN tp.person_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_topic_provider,
           CASE WHEN i.person_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_interviewer,
           s.student_no, s.current_semester, s.gpa, s.language_level, s.cv,
           pr.name AS program_name,
           a.academic_rank, d.name AS giu_department,
           pp.title AS partner_title, pd.name AS partner_department,
           c.company_name, c.sector, c.position, c.location
    FROM Person p
    LEFT JOIN Student s ON s.person_id = p.person_id
    LEFT JOIN Program pr ON pr.program_id = s.program_id
    LEFT JOIN GIU_Academic a ON a.person_id = p.person_id
    LEFT JOIN Department d ON d.dept_id = a.dept_id
    LEFT JOIN Partner_Professor pp ON pp.person_id = p.person_id
    LEFT JOIN Partner_Department pd ON pd.pdept_id = pp.pdept_id
    LEFT JOIN Company_Rep c ON c.person_id = p.person_id
    LEFT JOIN Topic_Provider tp ON tp.person_id = p.person_id
    LEFT JOIN Interviewer i ON i.person_id = p.person_id
    WHERE p.person_id = @person_id
);
GO

CREATE OR ALTER PROCEDURE AddStudent
    @full_name VARCHAR(150), @email VARCHAR(150), @phone VARCHAR(30),
    @student_no VARCHAR(20), @current_semester INT, @gpa DECIMAL(3,2),
    @language_level VARCHAR(30), @cv VARCHAR(300), @program_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Person WHERE email = @email)
    BEGIN SELECT 'This email is already used' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Student WHERE student_no = @student_no)
    BEGIN SELECT 'This student number already exists' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Program WHERE program_id = @program_id)
    BEGIN SELECT 'Program not found' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Person (full_name, email, phone, account_status)
        VALUES (@full_name, @email, @phone, 'Active');

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Student (person_id, student_no, current_semester, gpa, language_level, cv, program_id)
        VALUES (@new_id, @student_no, @current_semester, @gpa, @language_level, @cv, @program_id);
        COMMIT;

        SELECT 'Student added successfully' AS message, @new_id AS person_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddGIUAcademic
    @full_name VARCHAR(150), @email VARCHAR(150), @phone VARCHAR(30),
    @academic_rank VARCHAR(50), @dept_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Person WHERE email = @email)
    BEGIN SELECT 'This email is already used' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Department WHERE dept_id = @dept_id)
    BEGIN SELECT 'Department not found' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Person (full_name, email, phone, account_status)
        VALUES (@full_name, @email, @phone, 'Active');

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO GIU_Academic (person_id, academic_rank, dept_id)
        VALUES (@new_id, @academic_rank, @dept_id);
        COMMIT;

        SELECT 'GIU academic added successfully' AS message, @new_id AS person_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddPartnerProfessor
    @full_name VARCHAR(150), @email VARCHAR(150), @phone VARCHAR(30),
    @title VARCHAR(50), @pdept_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Person WHERE email = @email)
    BEGIN SELECT 'This email is already used' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Partner_Department WHERE pdept_id = @pdept_id)
    BEGIN SELECT 'Partner department not found' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Person (full_name, email, phone, account_status)
        VALUES (@full_name, @email, @phone, 'Active');

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Partner_Professor (person_id, title, pdept_id)
        VALUES (@new_id, @title, @pdept_id);
        COMMIT;

        SELECT 'Partner professor added successfully' AS message, @new_id AS person_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddCompanyRep
    @full_name VARCHAR(150), @email VARCHAR(150), @phone VARCHAR(30),
    @company_name VARCHAR(150), @sector VARCHAR(100), @position VARCHAR(100),
    @location VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Person WHERE email = @email)
    BEGIN SELECT 'This email is already used' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Person (full_name, email, phone, account_status)
        VALUES (@full_name, @email, @phone, 'Active');

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Company_Rep (person_id, company_name, sector, position, location)
        VALUES (@new_id, @company_name, @sector, @position, @location);
        COMMIT;

        SELECT 'Company representative added successfully' AS message, @new_id AS person_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE UpdatePersonContact
    @person_id INT, @email VARCHAR(150), @phone VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN SELECT 'Person not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Person WHERE email = @email AND person_id <> @person_id)
    BEGIN SELECT 'This email belongs to another person' AS message; RETURN; END

    UPDATE Person
    SET email = @email, phone = @phone
    WHERE person_id = @person_id;

    SELECT 'Contact details updated' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateAccountStatus
    @person_id INT, @account_status VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN SELECT 'Person not found' AS message; RETURN; END

    IF @account_status NOT IN ('Active', 'Inactive', 'Suspended')
    BEGIN SELECT 'Status must be Active, Inactive or Suspended' AS message; RETURN; END

    UPDATE Person SET account_status = @account_status WHERE person_id = @person_id;

    SELECT 'Account status updated to ' + @account_status AS message;
END
GO

CREATE OR ALTER PROCEDURE RegisterTopicProvider
    @person_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @person_id)
       AND NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @person_id)
       AND NOT EXISTS (SELECT 1 FROM Company_Rep WHERE person_id = @person_id)
    BEGIN
        SELECT 'Only a GIU academic, partner professor or company representative can be a topic provider' AS message;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Topic_Provider WHERE person_id = @person_id)
    BEGIN SELECT 'This person is already a topic provider' AS message; RETURN; END

    INSERT INTO Topic_Provider (person_id) VALUES (@person_id);

    SELECT 'Topic provider registered' AS message;
END
GO

CREATE OR ALTER PROCEDURE RegisterInterviewer
    @person_id INT, @role VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @person_id)
       AND NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @person_id)
       AND NOT EXISTS (SELECT 1 FROM Company_Rep WHERE person_id = @person_id)
    BEGIN
        SELECT 'Only a GIU academic, partner professor or company representative can be an interviewer' AS message;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Interviewer WHERE person_id = @person_id)
    BEGIN SELECT 'This person is already an interviewer' AS message; RETURN; END

    INSERT INTO Interviewer (role, person_id) VALUES (@role, @person_id);

    SELECT 'Interviewer registered' AS message, SCOPE_IDENTITY() AS interviewer_id;
END
GO

CREATE OR ALTER PROCEDURE AddFaculty
    @name VARCHAR(150), @description VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Faculty WHERE name = @name)
    BEGIN SELECT 'A faculty with this name already exists' AS message; RETURN; END

    INSERT INTO Faculty (name, description) VALUES (@name, @description);

    SELECT 'Faculty added' AS message, SCOPE_IDENTITY() AS faculty_id;
END
GO

CREATE OR ALTER PROCEDURE AddDepartment
    @name VARCHAR(150), @description VARCHAR(500), @faculty_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Faculty WHERE faculty_id = @faculty_id)
    BEGIN SELECT 'Faculty not found' AS message; RETURN; END

    INSERT INTO Department (name, description, faculty_id)
    VALUES (@name, @description, @faculty_id);

    SELECT 'Department added' AS message, SCOPE_IDENTITY() AS dept_id;
END
GO

CREATE OR ALTER PROCEDURE AddProgram
    @name VARCHAR(150), @degree_level VARCHAR(30), @total_credit_hours INT,
    @description VARCHAR(500), @dept_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Department WHERE dept_id = @dept_id)
    BEGIN SELECT 'Department not found' AS message; RETURN; END

    INSERT INTO Program (name, degree_level, total_credit_hours, description, dept_id)
    VALUES (@name, @degree_level, @total_credit_hours, @description, @dept_id);

    SELECT 'Program added' AS message, SCOPE_IDENTITY() AS program_id;
END
GO

CREATE OR ALTER PROCEDURE ClassifyProgram
    @program_id INT, @field_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Program WHERE program_id = @program_id)
    BEGIN SELECT 'Program not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Field WHERE field_id = @field_id)
    BEGIN SELECT 'Field not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Program_Field WHERE program_id = @program_id AND field_id = @field_id)
    BEGIN SELECT 'Program is already classified under this field' AS message; RETURN; END

    INSERT INTO Program_Field (program_id, field_id) VALUES (@program_id, @field_id);

    SELECT 'Program classified under the field' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddCourse
    @code VARCHAR(20), @title VARCHAR(150), @credit_hours INT,
    @level INT, @program_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Program WHERE program_id = @program_id)
    BEGIN SELECT 'Program not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Course WHERE code = @code)
    BEGIN SELECT 'A course with this code already exists' AS message; RETURN; END

    INSERT INTO Course (code, title, credit_hours, [level], program_id)
    VALUES (@code, @title, @credit_hours, @level, @program_id);

    SELECT 'Course added' AS message, SCOPE_IDENTITY() AS course_id;
END
GO

CREATE OR ALTER PROCEDURE AddPrerequisite
    @course_id INT, @prereq_course_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @course_id = @prereq_course_id
    BEGIN SELECT 'A course cannot be its own prerequisite' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course_id)
       OR NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @prereq_course_id)
    BEGIN SELECT 'Course not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Prerequisite WHERE course_id = @course_id AND prereq_course_id = @prereq_course_id)
    BEGIN SELECT 'This prerequisite is already recorded' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Prerequisite WHERE course_id = @prereq_course_id AND prereq_course_id = @course_id)
    BEGIN SELECT 'This would create a circular prerequisite' AS message; RETURN; END

    INSERT INTO Prerequisite (course_id, prereq_course_id) VALUES (@course_id, @prereq_course_id);

    SELECT 'Prerequisite added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddField
    @name VARCHAR(100), @description VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Field WHERE name = @name)
    BEGIN SELECT 'A field with this name already exists' AS message; RETURN; END

    INSERT INTO Field (name, description) VALUES (@name, @description);

    SELECT 'Field added' AS message, SCOPE_IDENTITY() AS field_id;
END
GO

CREATE OR ALTER PROCEDURE AddResearchArea
    @name VARCHAR(150), @description VARCHAR(500), @field_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Field WHERE field_id = @field_id)
    BEGIN SELECT 'Field not found' AS message; RETURN; END

    INSERT INTO Research_Area (name, description, field_id)
    VALUES (@name, @description, @field_id);

    SELECT 'Research area added' AS message, SCOPE_IDENTITY() AS area_id;
END
GO

CREATE OR ALTER PROCEDURE AddSkill
    @name VARCHAR(100), @category VARCHAR(50), @description VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Skill WHERE name = @name)
    BEGIN SELECT 'This skill already exists' AS message; RETURN; END

    INSERT INTO Skill (name, category, description) VALUES (@name, @category, @description);

    SELECT 'Skill added' AS message, SCOPE_IDENTITY() AS skill_id;
END
GO

CREATE OR ALTER PROCEDURE AddPartnerUniversity
    @name VARCHAR(150), @country VARCHAR(60), @city VARCHAR(60),
    @description VARCHAR(500), @partnership_status VARCHAR(30), @contact_info VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM University WHERE name = @name)
    BEGIN SELECT 'A university with this name already exists' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO University (name, country, city, description)
        VALUES (@name, @country, @city, @description);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Partner_University (uni_id, partnership_status, contact_info)
        VALUES (@new_id, @partnership_status, @contact_info);
        COMMIT;

        SELECT 'Partner university added' AS message, @new_id AS uni_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddPartnerDepartment
    @name VARCHAR(150), @description VARCHAR(500), @partner_uni_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_University WHERE uni_id = @partner_uni_id)
    BEGIN SELECT 'Partner university not found' AS message; RETURN; END

    INSERT INTO Partner_Department (name, description, partner_uni_id)
    VALUES (@name, @description, @partner_uni_id);

    SELECT 'Partner department added' AS message, SCOPE_IDENTITY() AS pdept_id;
END
GO

CREATE OR ALTER PROCEDURE AddPartnerProgram
    @name VARCHAR(150), @degree_level VARCHAR(30), @description VARCHAR(500),
    @pdept_id INT, @field_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_Department WHERE pdept_id = @pdept_id)
    BEGIN SELECT 'Partner department not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Field WHERE field_id = @field_id)
    BEGIN SELECT 'Field not found' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Partner_Program (name, degree_level, description, pdept_id)
        VALUES (@name, @degree_level, @description, @pdept_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Partner_Program_Field (pprog_id, field_id) VALUES (@new_id, @field_id);
        COMMIT;

        SELECT 'Partner program added' AS message, @new_id AS pprog_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER FUNCTION GetUserStatsByRole ()
RETURNS TABLE
AS
RETURN
(
    SELECT 'Student' AS role,
           COUNT(*) AS number_of_persons,
           SUM(CASE WHEN p.account_status = 'Active' THEN 1 ELSE 0 END) AS active_accounts
    FROM Student s JOIN Person p ON p.person_id = s.person_id
    UNION ALL
    SELECT 'GIU Academic', COUNT(*),
           SUM(CASE WHEN p.account_status = 'Active' THEN 1 ELSE 0 END)
    FROM GIU_Academic a JOIN Person p ON p.person_id = a.person_id
    UNION ALL
    SELECT 'Partner Professor', COUNT(*),
           SUM(CASE WHEN p.account_status = 'Active' THEN 1 ELSE 0 END)
    FROM Partner_Professor pp JOIN Person p ON p.person_id = pp.person_id
    UNION ALL
    SELECT 'Company Representative', COUNT(*),
           SUM(CASE WHEN p.account_status = 'Active' THEN 1 ELSE 0 END)
    FROM Company_Rep c JOIN Person p ON p.person_id = c.person_id
);
GO

CREATE OR ALTER PROCEDURE SendNotification
    @recipient_id INT, @message VARCHAR(500), @category VARCHAR(30), @urgency VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @recipient_id)
    BEGIN SELECT 'Recipient not found' AS message; RETURN; END

    INSERT INTO Notification (message, category, urgency, recipient_id)
    VALUES (@message, @category, @urgency, @recipient_id);

    SELECT 'Notification sent' AS message;
END
GO

CREATE OR ALTER PROCEDURE CreateMobilityAgreement
    @title VARCHAR(200), @scope VARCHAR(500), @start_date DATE, @end_date DATE,
    @partner_uni_id INT, @coordinator_id INT, @exchange_terms VARCHAR(500),
    @double_degree_terms VARCHAR(500), @seat_quota INT, @tuition_arrangement VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_University WHERE uni_id = @partner_uni_id)
    BEGIN SELECT 'Partner university not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @coordinator_id)
    BEGIN SELECT 'Coordinator must be a GIU academic' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    IF @seat_quota <= 0
    BEGIN SELECT 'Seat quota must be greater than zero' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Cooperation_Agreement (title, scope, start_date, end_date, status, partner_uni_id, coordinator_id)
        VALUES (@title, @scope, @start_date, @end_date, 'Active', @partner_uni_id, @coordinator_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Mobility_Agreement (agreement_id, exchange_terms, double_degree_terms, seat_quota, tuition_arrangement)
        VALUES (@new_id, @exchange_terms, @double_degree_terms, @seat_quota, @tuition_arrangement);
        COMMIT;

        SELECT 'Mobility agreement created' AS message, @new_id AS agreement_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE CreateResearchAgreement
    @title VARCHAR(200), @scope VARCHAR(500), @start_date DATE, @end_date DATE,
    @partner_uni_id INT, @coordinator_id INT, @ip_terms VARCHAR(500),
    @funding_framework VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_University WHERE uni_id = @partner_uni_id)
    BEGIN SELECT 'Partner university not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @coordinator_id)
    BEGIN SELECT 'Coordinator must be a GIU academic' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Cooperation_Agreement (title, scope, start_date, end_date, status, partner_uni_id, coordinator_id)
        VALUES (@title, @scope, @start_date, @end_date, 'Active', @partner_uni_id, @coordinator_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Research_Agreement (agreement_id, ip_terms, funding_framework)
        VALUES (@new_id, @ip_terms, @funding_framework);
        COMMIT;

        SELECT 'Research agreement created' AS message, @new_id AS agreement_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE CreateGeneralMoU
    @title VARCHAR(200), @scope VARCHAR(500), @start_date DATE, @end_date DATE,
    @partner_uni_id INT, @coordinator_id INT, @intent VARCHAR(500),
    @collab_scope VARCHAR(500), @renewal_terms VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_University WHERE uni_id = @partner_uni_id)
    BEGIN SELECT 'Partner university not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @coordinator_id)
    BEGIN SELECT 'Coordinator must be a GIU academic' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Cooperation_Agreement (title, scope, start_date, end_date, status, partner_uni_id, coordinator_id)
        VALUES (@title, @scope, @start_date, @end_date, 'Active', @partner_uni_id, @coordinator_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO General_MoU (agreement_id, intent, collab_scope, renewal_terms)
        VALUES (@new_id, @intent, @collab_scope, @renewal_terms);
        COMMIT;

        SELECT 'General MoU created' AS message, @new_id AS agreement_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddAgreementProgram
    @agreement_id INT, @program_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mobility_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Mobility agreement not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Program WHERE program_id = @program_id)
    BEGIN SELECT 'Program not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Mob_Agr_Program WHERE agreement_id = @agreement_id AND program_id = @program_id)
    BEGIN SELECT 'Program is already part of this agreement' AS message; RETURN; END

    INSERT INTO Mob_Agr_Program (agreement_id, program_id) VALUES (@agreement_id, @program_id);

    SELECT 'Program added to the agreement' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddAgreementSemester
    @agreement_id INT, @semester VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mobility_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Mobility agreement not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Mob_Agr_Semester WHERE agreement_id = @agreement_id AND semester = @semester)
    BEGIN SELECT 'Semester is already part of this agreement' AS message; RETURN; END

    INSERT INTO Mob_Agr_Semester (agreement_id, semester) VALUES (@agreement_id, @semester);

    SELECT 'Semester added to the agreement' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddAgreementResearchArea
    @agreement_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Research agreement not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Area WHERE area_id = @area_id)
    BEGIN SELECT 'Research area not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Res_Agr_Area WHERE agreement_id = @agreement_id AND area_id = @area_id)
    BEGIN SELECT 'Research area is already covered by this agreement' AS message; RETURN; END

    INSERT INTO Res_Agr_Area (agreement_id, area_id) VALUES (@agreement_id, @area_id);

    SELECT 'Research area added to the agreement' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateAgreementStatus
    @agreement_id INT, @status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cooperation_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF @status NOT IN ('Active', 'Expired', 'Terminated', 'Pending')
    BEGIN SELECT 'Status must be Active, Expired, Terminated or Pending' AS message; RETURN; END

    UPDATE Cooperation_Agreement SET status = @status WHERE agreement_id = @agreement_id;

    SELECT 'Agreement status updated to ' + @status AS message;
END
GO

CREATE OR ALTER FUNCTION GetExpiringAgreements (@days_ahead INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ca.agreement_id,
           ca.title AS agreement,
           u.name AS partner_university,
           CASE WHEN ma.agreement_id IS NOT NULL THEN 'Mobility'
                WHEN ra.agreement_id IS NOT NULL THEN 'Research'
                WHEN g.agreement_id IS NOT NULL THEN 'General MoU'
                ELSE 'Unknown' END AS agreement_type,
           ca.end_date,
           DATEDIFF(DAY, CAST(GETDATE() AS DATE), ca.end_date) AS days_remaining
    FROM Cooperation_Agreement ca
    JOIN University u ON u.uni_id = ca.partner_uni_id
    LEFT JOIN Mobility_Agreement ma ON ma.agreement_id = ca.agreement_id
    LEFT JOIN Research_Agreement ra ON ra.agreement_id = ca.agreement_id
    LEFT JOIN General_MoU g ON g.agreement_id = ca.agreement_id
    WHERE ca.status = 'Active'
      AND ca.end_date >= CAST(GETDATE() AS DATE)
      AND ca.end_date <= DATEADD(DAY, @days_ahead, CAST(GETDATE() AS DATE))
);
GO

CREATE OR ALTER FUNCTION ViewPartnerHistory (@partner_uni_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 'Agreement' AS record_type, ca.agreement_id, ca.title,
           ca.start_date, ca.end_date, ca.status
    FROM Cooperation_Agreement ca
    WHERE ca.partner_uni_id = @partner_uni_id

    UNION ALL

    SELECT 'Opportunity', o.agreement_id, o.title,
           o.app_open_date, o.app_close_date, o.status
    FROM Opportunity o
    JOIN Cooperation_Agreement ca ON ca.agreement_id = o.agreement_id
    WHERE ca.partner_uni_id = @partner_uni_id

    UNION ALL

    SELECT 'Professor Visit', v.agreement_id, v.purpose,
           v.start_date, v.end_date, v.status
    FROM Professor_Visit v
    JOIN Cooperation_Agreement ca ON ca.agreement_id = v.agreement_id
    WHERE ca.partner_uni_id = @partner_uni_id

    UNION ALL

    SELECT 'Research Project', rp.res_agreement_id, rp.title,
           rp.start_date, rp.end_date, rp.status
    FROM Research_Project rp
    JOIN Cooperation_Agreement ca ON ca.agreement_id = rp.res_agreement_id
    WHERE ca.partner_uni_id = @partner_uni_id
);
GO

CREATE OR ALTER FUNCTION GetAgreementSeatUsage (@agreement_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @quota INT, @used INT;

    SELECT @quota = seat_quota FROM Mobility_Agreement WHERE agreement_id = @agreement_id;

    IF @quota IS NULL OR @quota = 0
        RETURN 0;

    SELECT @used = COUNT(*)
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE o.agreement_id = @agreement_id
      AND a.status = 'Accepted';

    RETURN CAST(@used * 100.0 / @quota AS DECIMAL(5,2));
END
GO

CREATE OR ALTER PROCEDURE ScheduleProfessorVisit
    @partner_prof_id INT, @host_faculty_id INT, @coordinator_id INT, @agreement_id INT,
    @start_date DATE, @end_date DATE, @purpose VARCHAR(300),
    @travel_arr VARCHAR(300), @accommodation_arr VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @partner_prof_id)
    BEGIN SELECT 'Partner professor not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Faculty WHERE faculty_id = @host_faculty_id)
    BEGIN SELECT 'Faculty not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @coordinator_id)
    BEGIN SELECT 'Coordinator must be a GIU academic' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Cooperation_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    INSERT INTO Professor_Visit (start_date, end_date, purpose, travel_arr, accommodation_arr, status,
                                 partner_prof_id, host_faculty_id, coordinator_id, agreement_id)
    VALUES (@start_date, @end_date, @purpose, @travel_arr, @accommodation_arr, 'Scheduled',
            @partner_prof_id, @host_faculty_id, @coordinator_id, @agreement_id);

    SELECT 'Visit scheduled' AS message, SCOPE_IDENTITY() AS visit_id;
END
GO

CREATE OR ALTER PROCEDURE AddAgendaItem
    @visit_id INT, @activity_type VARCHAR(30), @title VARCHAR(200),
    @date_time DATETIME, @location VARCHAR(100), @audience VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Professor_Visit WHERE visit_id = @visit_id)
    BEGIN SELECT 'Visit not found' AS message; RETURN; END

    DECLARE @seq_no INT;
    SELECT @seq_no = ISNULL(MAX(seq_no), 0) + 1 FROM Agenda_Item WHERE visit_id = @visit_id;

    INSERT INTO Agenda_Item (visit_id, seq_no, activity_type, title, date_time, location, audience)
    VALUES (@visit_id, @seq_no, @activity_type, @title, @date_time, @location, @audience);

    SELECT 'Agenda item added' AS message, @seq_no AS seq_no;
END
GO

CREATE OR ALTER PROCEDURE NotifyVisitAgenda
    @visit_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @prof INT, @coord INT;
    SELECT @prof = partner_prof_id, @coord = coordinator_id
    FROM Professor_Visit WHERE visit_id = @visit_id;

    IF @prof IS NULL
    BEGIN SELECT 'Visit not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Agenda_Item WHERE visit_id = @visit_id)
    BEGIN SELECT 'This visit has no agenda items yet' AS message; RETURN; END

    DECLARE @text VARCHAR(500);
    SELECT @text = LEFT('Agenda for visit ' + CAST(@visit_id AS VARCHAR(10)) + ': ' +
                        STRING_AGG(CAST(seq_no AS VARCHAR(10)) + '. ' + title, '; ')
                        WITHIN GROUP (ORDER BY seq_no), 500)
    FROM Agenda_Item
    WHERE visit_id = @visit_id;

    INSERT INTO Notification (message, category, urgency, recipient_id)
    VALUES (@text, 'Visit', 'Normal', @prof);

    IF @coord <> @prof
        INSERT INTO Notification (message, category, urgency, recipient_id)
        VALUES (@text, 'Visit', 'Normal', @coord);

    SELECT 'Agenda sent to the visiting professor and the coordinator' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateVisitStatus
    @visit_id INT, @status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Professor_Visit WHERE visit_id = @visit_id)
    BEGIN SELECT 'Visit not found' AS message; RETURN; END

    IF @status NOT IN ('Requested', 'Scheduled', 'Ongoing', 'Completed', 'Cancelled')
    BEGIN SELECT 'Status must be Requested, Scheduled, Ongoing, Completed or Cancelled' AS message; RETURN; END

    UPDATE Professor_Visit SET status = @status WHERE visit_id = @visit_id;

    SELECT 'Visit status updated to ' + @status AS message;
END
GO

CREATE OR ALTER PROCEDURE CompleteProfessorVisit
    @visit_id INT, @follow_up_report VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Professor_Visit WHERE visit_id = @visit_id)
    BEGIN SELECT 'Visit not found' AS message; RETURN; END

    UPDATE Professor_Visit
    SET status = 'Completed', follow_up_report = @follow_up_report
    WHERE visit_id = @visit_id;

    SELECT 'Visit closed with its follow-up report' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddVisitOutcome
    @visit_id INT, @outcome VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Professor_Visit WHERE visit_id = @visit_id)
    BEGIN SELECT 'Visit not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Visit_Outcome WHERE visit_id = @visit_id AND outcome = @outcome)
    BEGIN SELECT 'This outcome is already recorded' AS message; RETURN; END

    INSERT INTO Visit_Outcome (visit_id, outcome) VALUES (@visit_id, @outcome);

    SELECT 'Outcome recorded' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewVisitsInPeriod (@start_date DATE, @end_date DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT v.visit_id,
           p.full_name AS professor,
           u.name AS university,
           f.name AS host_faculty,
           v.start_date, v.end_date, v.status,
           (SELECT COUNT(*) FROM Agenda_Item ai WHERE ai.visit_id = v.visit_id) AS agenda_items
    FROM Professor_Visit v
    JOIN Person p ON p.person_id = v.partner_prof_id
    JOIN Partner_Professor pp ON pp.person_id = v.partner_prof_id
    JOIN Partner_Department pd ON pd.pdept_id = pp.pdept_id
    JOIN University u ON u.uni_id = pd.partner_uni_id
    JOIN Faculty f ON f.faculty_id = v.host_faculty_id
    WHERE v.start_date >= @start_date AND v.end_date <= @end_date
);
GO

CREATE OR ALTER FUNCTION GetFacultyDashboard (@faculty_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT f.faculty_id, f.name AS faculty,
           (SELECT COUNT(*)
            FROM Student s
            JOIN Program pr ON pr.program_id = s.program_id
            JOIN Department d ON d.dept_id = pr.dept_id
            WHERE d.faculty_id = f.faculty_id) AS number_of_students,
           (SELECT COUNT(*)
            FROM Application a
            JOIN Student s ON s.person_id = a.student_id
            JOIN Program pr ON pr.program_id = s.program_id
            JOIN Department d ON d.dept_id = pr.dept_id
            WHERE d.faculty_id = f.faculty_id) AS number_of_applications,
           (SELECT COUNT(*)
            FROM Application a
            JOIN Student s ON s.person_id = a.student_id
            JOIN Program pr ON pr.program_id = s.program_id
            JOIN Department d ON d.dept_id = pr.dept_id
            WHERE d.faculty_id = f.faculty_id AND a.status = 'Accepted') AS accepted_applications,
           (SELECT COUNT(*)
            FROM Participation pa
            JOIN Application a ON a.app_id = pa.app_id
            JOIN Student s ON s.person_id = a.student_id
            JOIN Program pr ON pr.program_id = s.program_id
            JOIN Department d ON d.dept_id = pr.dept_id
            WHERE d.faculty_id = f.faculty_id AND pa.status = 'Active') AS active_participations,
           (SELECT COUNT(*) FROM Professor_Visit v WHERE v.host_faculty_id = f.faculty_id) AS professor_visits,
           (SELECT COUNT(DISTINCT gp.project_id)
            FROM GIU_Participates gp
            JOIN GIU_Academic ga ON ga.person_id = gp.academic_id
            JOIN Department d ON d.dept_id = ga.dept_id
            WHERE d.faculty_id = f.faculty_id) AS research_projects
    FROM Faculty f
    WHERE f.faculty_id = @faculty_id
);
GO

CREATE OR ALTER FUNCTION GetPartnerDashboard ()
RETURNS TABLE
AS
RETURN
(
    SELECT u.uni_id, u.name AS partner_university,
           (SELECT COUNT(*) FROM Cooperation_Agreement ca
            WHERE ca.partner_uni_id = u.uni_id AND ca.status = 'Active') AS active_agreements,
           (SELECT COUNT(*) FROM Opportunity o
            JOIN Cooperation_Agreement ca ON ca.agreement_id = o.agreement_id
            WHERE ca.partner_uni_id = u.uni_id) AS opportunities,
           (SELECT COUNT(*) FROM Application a
            JOIN Opportunity o ON o.opp_id = a.opp_id
            JOIN Cooperation_Agreement ca ON ca.agreement_id = o.agreement_id
            WHERE ca.partner_uni_id = u.uni_id AND a.status = 'Accepted') AS accepted_students,
           (SELECT COUNT(*) FROM Professor_Visit v
            JOIN Cooperation_Agreement ca ON ca.agreement_id = v.agreement_id
            WHERE ca.partner_uni_id = u.uni_id) AS visits,
           (SELECT COUNT(*) FROM Research_Project rp
            JOIN Cooperation_Agreement ca ON ca.agreement_id = rp.res_agreement_id
            WHERE ca.partner_uni_id = u.uni_id) AS research_projects
    FROM University u
    JOIN Partner_University pu ON pu.uni_id = u.uni_id
);
GO

CREATE OR ALTER FUNCTION GetTopPartners (@top_n INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@top_n) u.uni_id, u.name AS partner_university,
           (SELECT COUNT(*) FROM Application a
            JOIN Opportunity o ON o.opp_id = a.opp_id
            JOIN Cooperation_Agreement ca ON ca.agreement_id = o.agreement_id
            WHERE ca.partner_uni_id = u.uni_id AND a.status = 'Accepted') AS accepted_students
    FROM University u
    JOIN Partner_University pu ON pu.uni_id = u.uni_id
    ORDER BY accepted_students DESC
);
GO

CREATE OR ALTER FUNCTION RankPartnersByActivity ()
RETURNS TABLE
AS
RETURN
(
    SELECT t.uni_id, t.partner_university, t.total_activities,
           RANK() OVER (ORDER BY t.total_activities DESC) AS activity_rank
    FROM (
        SELECT u.uni_id, u.name AS partner_university,
               (SELECT COUNT(*) FROM Cooperation_Agreement ca WHERE ca.partner_uni_id = u.uni_id)
             + (SELECT COUNT(*) FROM Opportunity o
                JOIN Cooperation_Agreement ca ON ca.agreement_id = o.agreement_id
                WHERE ca.partner_uni_id = u.uni_id)
             + (SELECT COUNT(*) FROM Professor_Visit v
                JOIN Cooperation_Agreement ca ON ca.agreement_id = v.agreement_id
                WHERE ca.partner_uni_id = u.uni_id)
             + (SELECT COUNT(*) FROM Research_Project rp
                JOIN Cooperation_Agreement ca ON ca.agreement_id = rp.res_agreement_id
                WHERE ca.partner_uni_id = u.uni_id) AS total_activities
        FROM University u
        JOIN Partner_University pu ON pu.uni_id = u.uni_id
    ) t
);
GO

CREATE OR ALTER FUNCTION GetMobilityTrend ()
RETURNS TABLE
AS
RETURN
(
    SELECT y.mobility_year AS [year],
           y.number_of_mobilities,
           y.number_of_mobilities - LAG(y.number_of_mobilities) OVER (ORDER BY y.mobility_year) AS change_from_previous_year
    FROM (
        SELECT YEAR(pa.start_date) AS mobility_year, COUNT(*) AS number_of_mobilities
        FROM Mobility m
        JOIN Participation pa ON pa.part_id = m.part_id
        GROUP BY YEAR(pa.start_date)
    ) y
);
GO

CREATE OR ALTER PROCEDURE CreateShortProgram
    @title VARCHAR(200), @description VARCHAR(1000), @app_open_date DATE, @app_close_date DATE,
    @capacity INT, @location_mode VARCHAR(30), @agreement_id INT, @duration VARCHAR(50),
    @location VARCHAR(100), @hosting_arrangements VARCHAR(300), @host_uni_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @app_close_date < @app_open_date
    BEGIN SELECT 'Closing date cannot be before the opening date' AS message; RETURN; END

    IF @capacity <= 0
    BEGIN SELECT 'Capacity must be greater than zero' AS message; RETURN; END

    IF @agreement_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Cooperation_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM University WHERE uni_id = @host_uni_id)
    BEGIN SELECT 'Host university not found' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Opportunity (title, description, type, status, app_open_date, app_close_date,
                                 capacity, location_mode, agreement_id)
        VALUES (@title, @description, 'Short Program', 'Open', @app_open_date, @app_close_date,
                @capacity, @location_mode, @agreement_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Short_Program (opp_id, duration, location, hosting_arrangements, host_uni_id)
        VALUES (@new_id, @duration, @location, @hosting_arrangements, @host_uni_id);
        COMMIT;

        SELECT 'Short program created' AS message, @new_id AS opp_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE CreateMobilityProgram
    @title VARCHAR(200), @description VARCHAR(1000), @app_open_date DATE, @app_close_date DATE,
    @capacity INT, @location_mode VARCHAR(30), @agreement_id INT, @mobility_type VARCHAR(50),
    @duration VARCHAR(50), @sending_uni_id INT, @host_uni_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @app_close_date < @app_open_date
    BEGIN SELECT 'Closing date cannot be before the opening date' AS message; RETURN; END

    IF @capacity <= 0
    BEGIN SELECT 'Capacity must be greater than zero' AS message; RETURN; END

    IF @agreement_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Cooperation_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM University WHERE uni_id = @sending_uni_id)
       OR NOT EXISTS (SELECT 1 FROM University WHERE uni_id = @host_uni_id)
    BEGIN SELECT 'Sending or host university not found' AS message; RETURN; END

    IF @sending_uni_id = @host_uni_id
    BEGIN SELECT 'Sending and host university must be different' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Opportunity (title, description, type, status, app_open_date, app_close_date,
                                 capacity, location_mode, agreement_id)
        VALUES (@title, @description, 'Mobility', 'Open', @app_open_date, @app_close_date,
                @capacity, @location_mode, @agreement_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Mobility_Program (opp_id, mobility_type, duration, sending_uni_id, host_uni_id)
        VALUES (@new_id, @mobility_type, @duration, @sending_uni_id, @host_uni_id);
        COMMIT;

        SELECT 'Mobility program created' AS message, @new_id AS opp_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddOpportunityField
    @opp_id INT, @field_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Field WHERE field_id = @field_id)
    BEGIN SELECT 'Field not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Field WHERE opp_id = @opp_id AND field_id = @field_id)
    BEGIN SELECT 'Opportunity is already classified under this field' AS message; RETURN; END

    INSERT INTO Opp_Field (opp_id, field_id) VALUES (@opp_id, @field_id);

    SELECT 'Field added to the opportunity' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddEligibleProgram
    @opp_id INT, @program_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Program WHERE program_id = @program_id)
    BEGIN SELECT 'Program not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Eligible_Program WHERE opp_id = @opp_id AND program_id = @program_id)
    BEGIN SELECT 'Program is already eligible for this opportunity' AS message; RETURN; END

    INSERT INTO Opp_Eligible_Program (opp_id, program_id) VALUES (@opp_id, @program_id);

    SELECT 'Eligible program added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddOpportunityPrerequisite
    @opp_id INT, @course_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course_id)
    BEGIN SELECT 'Course not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Prereq_Course WHERE opp_id = @opp_id AND course_id = @course_id)
    BEGIN SELECT 'This prerequisite is already added' AS message; RETURN; END

    INSERT INTO Opp_Prereq_Course (opp_id, course_id) VALUES (@opp_id, @course_id);

    SELECT 'Prerequisite course added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddRequiredSkill
    @opp_id INT, @skill_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Skill WHERE skill_id = @skill_id)
    BEGIN SELECT 'Skill not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Skill WHERE opp_id = @opp_id AND skill_id = @skill_id)
    BEGIN SELECT 'This skill is already required' AS message; RETURN; END

    INSERT INTO Opp_Skill (opp_id, skill_id) VALUES (@opp_id, @skill_id);

    SELECT 'Required skill added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddLanguageRequirement
    @opp_id INT, @language_req VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Language_Req WHERE opp_id = @opp_id AND language_req = @language_req)
    BEGIN SELECT 'This language requirement is already added' AS message; RETURN; END

    INSERT INTO Opp_Language_Req (opp_id, language_req) VALUES (@opp_id, @language_req);

    SELECT 'Language requirement added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddRelevantDate
    @opp_id INT, @relevant_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opp_Relevant_Date WHERE opp_id = @opp_id AND relevant_date = @relevant_date)
    BEGIN SELECT 'This date is already added' AS message; RETURN; END

    INSERT INTO Opp_Relevant_Date (opp_id, relevant_date) VALUES (@opp_id, @relevant_date);

    SELECT 'Relevant date added' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateOpportunityStatus
    @opp_id INT, @status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF @status NOT IN ('Open', 'Closed', 'Cancelled')
    BEGIN SELECT 'Status must be Open, Closed or Cancelled' AS message; RETURN; END

    UPDATE Opportunity SET status = @status WHERE opp_id = @opp_id;

    SELECT 'Opportunity status updated to ' + @status AS message;
END
GO

CREATE OR ALTER FUNCTION ViewOpportunityApplications (@opp_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT a.app_id AS application,
           p.full_name AS student_name,
           pr.name AS program,
           s.gpa,
           a.app_date AS application_date,
           a.status,
           (SELECT COUNT(*) FROM Application_Document d WHERE d.app_id = a.app_id) AS uploaded_documents
    FROM Application a
    JOIN Student s ON s.person_id = a.student_id
    JOIN Person p ON p.person_id = s.person_id
    JOIN Program pr ON pr.program_id = s.program_id
    WHERE a.opp_id = @opp_id
);
GO

CREATE OR ALTER PROCEDURE ScheduleInterview
    @app_id INT, @date DATE, @time TIME, @location_mode VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Application WHERE app_id = @app_id;

    IF @status IS NULL
    BEGIN SELECT 'Application not found' AS message; RETURN; END

    IF @status <> 'Pending'
    BEGIN SELECT 'Interviews can only be scheduled for pending applications' AS message; RETURN; END

    INSERT INTO Interview ([date], [time], location_mode, outcome, app_id)
    VALUES (@date, @time, @location_mode, 'Pending', @app_id);

    SELECT 'Interview scheduled' AS message, SCOPE_IDENTITY() AS interview_id;
END
GO

CREATE OR ALTER PROCEDURE AssignInterviewer
    @interview_id INT, @interviewer_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Interview WHERE interview_id = @interview_id)
    BEGIN SELECT 'Interview not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Interviewer WHERE interviewer_id = @interviewer_id)
    BEGIN SELECT 'Interviewer not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Conducts_Interview
               WHERE interview_id = @interview_id AND interviewer_id = @interviewer_id)
    BEGIN SELECT 'This interviewer is already assigned' AS message; RETURN; END

    INSERT INTO Conducts_Interview (interviewer_id, interview_id) VALUES (@interviewer_id, @interview_id);

    SELECT 'Interviewer assigned' AS message;
END
GO

CREATE OR ALTER PROCEDURE DecideApplication
    @app_id INT, @status VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @opp_id INT, @student_id INT, @current VARCHAR(20), @type VARCHAR(30), @title VARCHAR(200);

    SELECT @opp_id = a.opp_id, @student_id = a.student_id, @current = a.status,
           @type = o.type, @title = o.title
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE a.app_id = @app_id;

    IF @opp_id IS NULL
    BEGIN SELECT 'Application not found' AS message; RETURN; END

    IF @status NOT IN ('Accepted', 'Rejected')
    BEGIN SELECT 'Status must be Accepted or Rejected' AS message; RETURN; END

    IF @current <> 'Pending'
    BEGIN SELECT 'Only pending applications can be decided' AS message; RETURN; END

    IF @status = 'Accepted'
    BEGIN
        IF dbo.GetRemainingCapacity(@opp_id) <= 0
        BEGIN SELECT 'Cannot accept: the opportunity is already full' AS message; RETURN; END

        IF @type = 'Thesis' AND dbo.HasAcceptedThesis(@student_id) = 1
        BEGIN SELECT 'Cannot accept: the student already holds an accepted thesis' AS message; RETURN; END
    END

    UPDATE Application
    SET status = @status, decision_date = CAST(GETDATE() AS DATE)
    WHERE app_id = @app_id;

    INSERT INTO Notification (message, category, urgency, recipient_id)
    VALUES (LEFT('Your application for ' + @title + ' is now ' + @status + '.', 500),
            'Application', 'Normal', @student_id);

    SELECT 'Application ' + LOWER(@status) AS message;
END
GO

CREATE OR ALTER PROCEDURE CreateParticipation
    @app_id INT, @start_date DATE, @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @status VARCHAR(20), @opp_id INT, @type VARCHAR(30);

    SELECT @status = a.status, @opp_id = a.opp_id, @type = o.type
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE a.app_id = @app_id;

    IF @status IS NULL
    BEGIN SELECT 'Application not found' AS message; RETURN; END

    IF @status <> 'Accepted'
    BEGIN SELECT 'Participation can only be created for accepted applications' AS message; RETURN; END

    IF @type = 'Thesis'
    BEGIN SELECT 'Thesis topics do not have a mobility or program participation' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Participation WHERE app_id = @app_id)
    BEGIN SELECT 'Participation already exists for this application' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Participation (status, start_date, end_date, app_id)
        VALUES ('Active', @start_date, @end_date, @app_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        IF @type = 'Mobility'
            INSERT INTO Mobility (part_id, pre_travel_status, during_status, post_status, host_uni_id)
            SELECT @new_id, 'Not started', 'Not started', 'Not started', mp.host_uni_id
            FROM Mobility_Program mp
            WHERE mp.opp_id = @opp_id;
        ELSE
            INSERT INTO Program_Participation (part_id, payment_status, visa_status, travel_status)
            VALUES (@new_id, 'Pending', 'Pending', 'Pending');
        COMMIT;

        SELECT 'Participation created' AS message, @new_id AS part_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE UpdateMobilityStatus
    @part_id INT, @pre_travel_status VARCHAR(50), @during_status VARCHAR(50),
    @post_status VARCHAR(50), @final_outcome VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mobility WHERE part_id = @part_id)
    BEGIN SELECT 'Mobility not found' AS message; RETURN; END

    UPDATE Mobility
    SET pre_travel_status = @pre_travel_status,
        during_status = @during_status,
        post_status = @post_status,
        final_outcome = @final_outcome
    WHERE part_id = @part_id;

    SELECT 'Mobility status updated' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateProgramParticipation
    @part_id INT, @payment_status VARCHAR(30), @visa_status VARCHAR(30), @travel_status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Program_Participation WHERE part_id = @part_id)
    BEGIN SELECT 'Program participation not found' AS message; RETURN; END

    UPDATE Program_Participation
    SET payment_status = @payment_status,
        visa_status = @visa_status,
        travel_status = @travel_status
    WHERE part_id = @part_id;

    SELECT 'Program participation updated' AS message;
END
GO

CREATE OR ALTER PROCEDURE RecordCourseEquivalency
    @part_id INT, @host_course_title VARCHAR(150), @host_credits DECIMAL(4,1),
    @transferred_credits DECIMAL(4,1), @giu_course_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mobility WHERE part_id = @part_id)
    BEGIN SELECT 'Mobility not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @giu_course_id)
    BEGIN SELECT 'GIU course not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Course_Equivalency WHERE part_id = @part_id AND host_course_title = @host_course_title)
    BEGIN SELECT 'This host course is already recorded for the mobility' AS message; RETURN; END

    IF @transferred_credits > @host_credits
    BEGIN SELECT 'Transferred credits cannot exceed the host credits' AS message; RETURN; END

    INSERT INTO Course_Equivalency (part_id, host_course_title, host_credits, transferred_credits,
                                    approval_status, giu_course_id)
    VALUES (@part_id, @host_course_title, @host_credits, @transferred_credits, 'Pending', @giu_course_id);

    SELECT 'Course equivalency recorded' AS message;
END
GO

CREATE OR ALTER PROCEDURE DecideCourseEquivalency
    @part_id INT, @host_course_title VARCHAR(150), @approval_status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Course_Equivalency WHERE part_id = @part_id AND host_course_title = @host_course_title)
    BEGIN SELECT 'Course equivalency not found' AS message; RETURN; END

    IF @approval_status NOT IN ('Approved', 'Rejected')
    BEGIN SELECT 'Status must be Approved or Rejected' AS message; RETURN; END

    UPDATE Course_Equivalency
    SET approval_status = @approval_status
    WHERE part_id = @part_id AND host_course_title = @host_course_title;

    SELECT 'Course equivalency ' + LOWER(@approval_status) AS message;
END
GO

CREATE OR ALTER FUNCTION GetTransferredCredits (@part_id INT)
RETURNS DECIMAL(5,1)
AS
BEGIN
    DECLARE @total DECIMAL(5,1);

    SELECT @total = SUM(transferred_credits)
    FROM Course_Equivalency
    WHERE part_id = @part_id AND approval_status = 'Approved';

    RETURN ISNULL(@total, 0);
END
GO

CREATE OR ALTER PROCEDURE LinkFundingToMobility
    @fund_id INT, @part_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Funding_Opportunity WHERE fund_id = @fund_id)
    BEGIN SELECT 'Funding opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Mobility WHERE part_id = @part_id)
    BEGIN SELECT 'Mobility not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Fund_Supports_Mobility WHERE fund_id = @fund_id AND part_id = @part_id)
    BEGIN SELECT 'This funding is already linked to the mobility' AS message; RETURN; END

    INSERT INTO Fund_Supports_Mobility (fund_id, part_id) VALUES (@fund_id, @part_id);

    SELECT 'Funding linked to the mobility' AS message;
END
GO

CREATE OR ALTER FUNCTION GetOpportunityFillRates ()
RETURNS TABLE
AS
RETURN
(
    SELECT x.opp_id, x.title AS opportunity, x.type, x.capacity, x.accepted_applications,
           CAST(x.accepted_applications * 100.0 / x.capacity AS DECIMAL(5,2)) AS fill_percentage
    FROM (
        SELECT o.opp_id, o.title, o.type, o.capacity,
               (SELECT COUNT(*) FROM Application a
                WHERE a.opp_id = o.opp_id AND a.status = 'Accepted') AS accepted_applications
        FROM Opportunity o
        WHERE o.status = 'Open'
    ) x
);
GO

CREATE OR ALTER FUNCTION GetApplicationStatsByType ()
RETURNS TABLE
AS
RETURN
(
    SELECT o.type AS opportunity_type,
           SUM(CASE WHEN a.status = 'Pending' THEN 1 ELSE 0 END) AS pending_applications,
           SUM(CASE WHEN a.status = 'Accepted' THEN 1 ELSE 0 END) AS accepted_applications,
           SUM(CASE WHEN a.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected_applications
    FROM Opportunity o
    LEFT JOIN Application a ON a.opp_id = o.opp_id
    GROUP BY o.type
);
GO

CREATE OR ALTER PROCEDURE NotifyUpcomingDeadlines
    @days_ahead INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Notification (message, category, urgency, recipient_id)
    SELECT LEFT('Reminder: applications for "' + o.title + '" close on ' +
                CONVERT(VARCHAR(10), o.app_close_date, 120) + '.', 500),
           'Deadline', 'High', s.person_id
    FROM Opportunity o
    CROSS JOIN Student s
    JOIN Person p ON p.person_id = s.person_id
    WHERE o.status = 'Open'
      AND o.app_close_date >= CAST(GETDATE() AS DATE)
      AND o.app_close_date <= DATEADD(DAY, @days_ahead, CAST(GETDATE() AS DATE))
      AND p.account_status = 'Active'
      AND dbo.CheckEligibility(s.person_id, o.opp_id) = 1
      AND NOT EXISTS (SELECT 1 FROM Application a
                      WHERE a.student_id = s.person_id AND a.opp_id = o.opp_id);

    SELECT 'Notifications sent: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) AS message;
END
GO

CREATE OR ALTER PROCEDURE DeclareResearchInterest
    @academic_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @academic_id)
    BEGIN SELECT 'GIU academic not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Area WHERE area_id = @area_id)
    BEGIN SELECT 'Research area not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM GIU_Interest WHERE academic_id = @academic_id AND area_id = @area_id)
    BEGIN SELECT 'This research interest is already declared' AS message; RETURN; END

    INSERT INTO GIU_Interest (academic_id, area_id) VALUES (@academic_id, @area_id);

    SELECT 'Research interest added' AS message;
END
GO

CREATE OR ALTER PROCEDURE RemoveResearchInterest
    @academic_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM GIU_Interest WHERE academic_id = @academic_id AND area_id = @area_id)
    BEGIN SELECT 'This research interest was not declared' AS message; RETURN; END

    DELETE FROM GIU_Interest WHERE academic_id = @academic_id AND area_id = @area_id;

    SELECT 'Research interest removed' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewSupervisedTopics (@supervisor_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS topic,
           cp.full_name AS co_supervisor,
           o.capacity,
           (SELECT COUNT(*) FROM Application a WHERE a.opp_id = o.opp_id) AS number_of_applications,
           (SELECT COUNT(*) FROM Application a
            WHERE a.opp_id = o.opp_id AND a.status = 'Accepted') AS accepted_students
    FROM Thesis_Topic t
    JOIN Opportunity o ON o.opp_id = t.opp_id
    LEFT JOIN Person cp ON cp.person_id = t.co_supervisor_id
    WHERE t.supervisor_id = @supervisor_id
);
GO

CREATE OR ALTER FUNCTION FindPartnerCollaborators (@academic_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT pp.person_id AS partner_prof_id,
           p.full_name AS partner_professor,
           u.name AS partner_university,
           COUNT(*) AS shared_research_areas
    FROM GIU_Interest gi
    JOIN PP_Interest ppi ON ppi.area_id = gi.area_id
    JOIN Partner_Professor pp ON pp.person_id = ppi.partner_prof_id
    JOIN Person p ON p.person_id = pp.person_id
    JOIN Partner_Department pd ON pd.pdept_id = pp.pdept_id
    JOIN University u ON u.uni_id = pd.partner_uni_id
    WHERE gi.academic_id = @academic_id
    GROUP BY pp.person_id, p.full_name, u.name
);
GO

CREATE OR ALTER FUNCTION FindCoSupervisors (@opp_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           pp.person_id AS partner_prof_id,
           p.full_name AS partner_professor,
           COUNT(*) AS shared_research_areas
    FROM Thesis_Area ta
    JOIN PP_Interest ppi ON ppi.area_id = ta.area_id
    JOIN Partner_Professor pp ON pp.person_id = ppi.partner_prof_id
    JOIN Person p ON p.person_id = pp.person_id
    WHERE ta.opp_id = @opp_id
    GROUP BY pp.person_id, p.full_name
    ORDER BY COUNT(*) DESC
);
GO

CREATE OR ALTER FUNCTION ViewTopicApplicants (@opp_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT a.app_id, p.full_name AS applicant, pr.name AS program, s.gpa, s.language_level,
           a.status AS application_status,
           (SELECT COUNT(*)
            FROM Opp_Skill os
            JOIN Student_Skill ss ON ss.skill_id = os.skill_id AND ss.student_id = s.person_id
            WHERE os.opp_id = a.opp_id) AS required_skills_owned
    FROM Application a
    JOIN Student s ON s.person_id = a.student_id
    JOIN Person p ON p.person_id = s.person_id
    JOIN Program pr ON pr.program_id = s.program_id
    WHERE a.opp_id = @opp_id
);
GO

CREATE OR ALTER PROCEDURE EvaluateInterview
    @interview_id INT, @outcome VARCHAR(50), @notes VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Interview WHERE interview_id = @interview_id)
    BEGIN SELECT 'Interview not found' AS message; RETURN; END

    UPDATE Interview
    SET outcome = @outcome, notes = @notes
    WHERE interview_id = @interview_id;

    SELECT 'Interview outcome recorded' AS message;
END
GO

CREATE OR ALTER PROCEDURE CreateResearchProject
    @title VARCHAR(200), @description VARCHAR(1000), @start_date DATE, @end_date DATE,
    @res_agreement_id INT, @academic_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Agreement WHERE agreement_id = @res_agreement_id)
    BEGIN SELECT 'Research agreement not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @academic_id)
    BEGIN SELECT 'GIU academic not found' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Research_Project (title, description, status, start_date, end_date, res_agreement_id)
        VALUES (@title, @description, 'Active', @start_date, @end_date, @res_agreement_id);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO GIU_Participates (academic_id, project_id, role)
        VALUES (@academic_id, @new_id, 'Principal Investigator');
        COMMIT;

        SELECT 'Research project created' AS message, @new_id AS project_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddProjectArea
    @project_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Area WHERE area_id = @area_id)
    BEGIN SELECT 'Research area not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Project_Area WHERE project_id = @project_id AND area_id = @area_id)
    BEGIN SELECT 'This area is already linked to the project' AS message; RETURN; END

    INSERT INTO Project_Area (project_id, area_id) VALUES (@project_id, @area_id);

    SELECT 'Research area added to the project' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddGIUParticipant
    @academic_id INT, @project_id INT, @role VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @academic_id)
    BEGIN SELECT 'GIU academic not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM GIU_Participates WHERE academic_id = @academic_id AND project_id = @project_id)
    BEGIN SELECT 'This academic already takes part in the project' AS message; RETURN; END

    INSERT INTO GIU_Participates (academic_id, project_id, role)
    VALUES (@academic_id, @project_id, @role);

    SELECT 'Participant added to the project' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddProjectDeadline
    @project_id INT, @deadline DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Project_Deadline WHERE project_id = @project_id AND deadline = @deadline)
    BEGIN SELECT 'This deadline is already added' AS message; RETURN; END

    INSERT INTO Project_Deadline (project_id, deadline) VALUES (@project_id, @deadline);

    SELECT 'Deadline added' AS message;
END
GO

CREATE OR ALTER PROCEDURE RecordResearchOutput
    @project_id INT, @type VARCHAR(30), @title VARCHAR(200), @date DATE,
    @reference VARCHAR(200), @status VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF @type NOT IN ('Publication', 'Deliverable', 'Dataset', 'Report')
    BEGIN SELECT 'Type must be Publication, Deliverable, Dataset or Report' AS message; RETURN; END

    INSERT INTO Research_Output (type, title, [date], reference, status, project_id)
    VALUES (@type, @title, @date, @reference, @status, @project_id);

    SELECT 'Research output recorded' AS message, SCOPE_IDENTITY() AS output_id;
END
GO

CREATE OR ALTER PROCEDURE LinkProjectToFunding
    @project_id INT, @fund_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Funding_Opportunity WHERE fund_id = @fund_id)
    BEGIN SELECT 'Funding opportunity not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Project_Targets_Fund WHERE project_id = @project_id AND fund_id = @fund_id)
    BEGIN SELECT 'The project already targets this funding' AS message; RETURN; END

    INSERT INTO Project_Targets_Fund (project_id, fund_id) VALUES (@project_id, @fund_id);

    SELECT 'Project linked to the funding opportunity' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewProjectOutputs (@project_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           output_id, type, title, [date], reference, status
    FROM Research_Output
    WHERE project_id = @project_id
    ORDER BY [date]
);
GO

CREATE OR ALTER FUNCTION GetMyProjectDeadlines (@academic_id INT, @days_ahead INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           rp.project_id, rp.title AS project, pd.deadline,
           DATEDIFF(DAY, CAST(GETDATE() AS DATE), pd.deadline) AS days_remaining
    FROM GIU_Participates gp
    JOIN Research_Project rp ON rp.project_id = gp.project_id
    JOIN Project_Deadline pd ON pd.project_id = rp.project_id
    WHERE gp.academic_id = @academic_id
      AND pd.deadline >= CAST(GETDATE() AS DATE)
      AND pd.deadline <= DATEADD(DAY, @days_ahead, CAST(GETDATE() AS DATE))
    ORDER BY pd.deadline
);
GO

CREATE OR ALTER FUNCTION ViewMyCoordinatedVisits (@coordinator_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT v.visit_id,
           p.full_name AS visiting_professor,
           v.start_date, v.end_date, v.status,
           (SELECT COUNT(*) FROM Agenda_Item ai WHERE ai.visit_id = v.visit_id) AS agenda_items
    FROM Professor_Visit v
    JOIN Person p ON p.person_id = v.partner_prof_id
    WHERE v.coordinator_id = @coordinator_id
);
GO

CREATE OR ALTER PROCEDURE DeclarePartnerInterest
    @partner_prof_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @partner_prof_id)
    BEGIN SELECT 'Partner professor not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Area WHERE area_id = @area_id)
    BEGIN SELECT 'Research area not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM PP_Interest WHERE partner_prof_id = @partner_prof_id AND area_id = @area_id)
    BEGIN SELECT 'This research interest is already declared' AS message; RETURN; END

    INSERT INTO PP_Interest (partner_prof_id, area_id) VALUES (@partner_prof_id, @area_id);

    SELECT 'Research interest added' AS message;
END
GO

CREATE OR ALTER FUNCTION FindGIUCollaborators (@partner_prof_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ga.person_id AS academic_id,
           p.full_name AS giu_academic,
           d.name AS department,
           COUNT(*) AS shared_research_areas
    FROM PP_Interest ppi
    JOIN GIU_Interest gi ON gi.area_id = ppi.area_id
    JOIN GIU_Academic ga ON ga.person_id = gi.academic_id
    JOIN Person p ON p.person_id = ga.person_id
    JOIN Department d ON d.dept_id = ga.dept_id
    WHERE ppi.partner_prof_id = @partner_prof_id
    GROUP BY ga.person_id, p.full_name, d.name
);
GO

CREATE OR ALTER PROCEDURE AcceptCoSupervision
    @opp_id INT, @co_supervisor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Thesis_Topic WHERE opp_id = @opp_id)
    BEGIN SELECT 'Thesis topic not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @co_supervisor_id)
    BEGIN SELECT 'Co-supervisor must be a partner professor' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Thesis_Topic WHERE opp_id = @opp_id AND co_supervisor_id IS NOT NULL)
    BEGIN SELECT 'This topic already has a co-supervisor' AS message; RETURN; END

    UPDATE Thesis_Topic SET co_supervisor_id = @co_supervisor_id WHERE opp_id = @opp_id;

    SELECT 'Co-supervision accepted' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewCoSupervisedTopics (@co_supervisor_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS topic,
           sp.full_name AS giu_supervisor,
           sp2.full_name AS accepted_student
    FROM Thesis_Topic t
    JOIN Opportunity o ON o.opp_id = t.opp_id
    JOIN Person sp ON sp.person_id = t.supervisor_id
    LEFT JOIN Application a ON a.opp_id = o.opp_id AND a.status = 'Accepted'
    LEFT JOIN Person sp2 ON sp2.person_id = a.student_id
    WHERE t.co_supervisor_id = @co_supervisor_id
);
GO

CREATE OR ALTER PROCEDURE RequestVisit
    @partner_prof_id INT, @agreement_id INT, @host_faculty_id INT,
    @start_date DATE, @end_date DATE, @purpose VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @partner_prof_id)
    BEGIN SELECT 'Partner professor not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Faculty WHERE faculty_id = @host_faculty_id)
    BEGIN SELECT 'Faculty not found' AS message; RETURN; END

    DECLARE @coordinator INT;
    SELECT @coordinator = coordinator_id FROM Cooperation_Agreement WHERE agreement_id = @agreement_id;

    IF @coordinator IS NULL
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF @end_date < @start_date
    BEGIN SELECT 'End date cannot be before start date' AS message; RETURN; END

    INSERT INTO Professor_Visit (start_date, end_date, purpose, status,
                                 partner_prof_id, host_faculty_id, coordinator_id, agreement_id)
    VALUES (@start_date, @end_date, @purpose, 'Requested',
            @partner_prof_id, @host_faculty_id, @coordinator, @agreement_id);

    SELECT 'Visit requested' AS message, SCOPE_IDENTITY() AS visit_id;
END
GO

CREATE OR ALTER FUNCTION ViewVisitAgenda (@visit_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           seq_no, activity_type, title, date_time, location, audience
    FROM Agenda_Item
    WHERE visit_id = @visit_id
    ORDER BY seq_no
);
GO

CREATE OR ALTER PROCEDURE JoinResearchProject
    @partner_prof_id INT, @project_id INT, @role VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @partner_prof_id)
    BEGIN SELECT 'Partner professor not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Project WHERE project_id = @project_id)
    BEGIN SELECT 'Research project not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM PP_Participates WHERE partner_prof_id = @partner_prof_id AND project_id = @project_id)
    BEGIN SELECT 'You already take part in this project' AS message; RETURN; END

    INSERT INTO PP_Participates (partner_prof_id, project_id, role)
    VALUES (@partner_prof_id, @project_id, @role);

    SELECT 'Joined the research project' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewMyResearchProjects (@partner_prof_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT rp.project_id, rp.title AS project, pp.role AS my_role, rp.status,
           (SELECT STRING_AGG(ra.name, ', ')
            FROM Project_Area pa
            JOIN Research_Area ra ON ra.area_id = pa.area_id
            WHERE pa.project_id = rp.project_id) AS research_areas,
           (SELECT COUNT(*) FROM Research_Output ro WHERE ro.project_id = rp.project_id) AS number_of_outputs
    FROM PP_Participates pp
    JOIN Research_Project rp ON rp.project_id = pp.project_id
    WHERE pp.partner_prof_id = @partner_prof_id
);
GO

CREATE OR ALTER FUNCTION ViewMyUniversityPrograms (@partner_prof_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT pd.name AS department,
           ppr.name AS program,
           ppr.degree_level,
           (SELECT STRING_AGG(f.name, ', ')
            FROM Partner_Program_Field ppf
            JOIN Field f ON f.field_id = ppf.field_id
            WHERE ppf.pprog_id = ppr.pprog_id) AS fields
    FROM Partner_Professor me
    JOIN Partner_Department mydept ON mydept.pdept_id = me.pdept_id
    JOIN Partner_Department pd ON pd.partner_uni_id = mydept.partner_uni_id
    JOIN Partner_Program ppr ON ppr.pdept_id = pd.pdept_id
    WHERE me.person_id = @partner_prof_id
);
GO

CREATE OR ALTER PROCEDURE UpdateCompanyProfile
    @person_id INT, @company_name VARCHAR(150), @sector VARCHAR(100),
    @position VARCHAR(100), @location VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Company_Rep WHERE person_id = @person_id)
    BEGIN SELECT 'Company representative not found' AS message; RETURN; END

    UPDATE Company_Rep
    SET company_name = @company_name, sector = @sector,
        position = @position, location = @location
    WHERE person_id = @person_id;

    SELECT 'Company details updated' AS message;
END
GO

CREATE OR ALTER PROCEDURE OfferPlacement
    @opp_id INT, @offered_by_rep_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id)
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Company_Rep WHERE person_id = @offered_by_rep_id)
    BEGIN SELECT 'Company representative not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id AND offered_by_rep_id IS NOT NULL
                                           AND offered_by_rep_id <> @offered_by_rep_id)
    BEGIN SELECT 'This opportunity is already offered by another company' AS message; RETURN; END

    UPDATE Opportunity SET offered_by_rep_id = @offered_by_rep_id WHERE opp_id = @opp_id;

    SELECT 'Opportunity offered as an industry placement' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewMyPlacements (@offered_by_rep_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS opportunity, o.status, o.capacity,
           (SELECT COUNT(*) FROM Application a WHERE a.opp_id = o.opp_id) AS applications,
           (SELECT COUNT(*) FROM Application a
            WHERE a.opp_id = o.opp_id AND a.status = 'Accepted') AS accepted_students
    FROM Opportunity o
    WHERE o.offered_by_rep_id = @offered_by_rep_id
);
GO

CREATE OR ALTER FUNCTION ViewPlacementApplicants (@opp_id INT, @offered_by_rep_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT a.app_id, p.full_name AS applicant, pr.name AS program, s.gpa,
           (SELECT STRING_AGG(sk.name, ', ')
            FROM Student_Skill ss
            JOIN Skill sk ON sk.skill_id = ss.skill_id
            WHERE ss.student_id = s.person_id) AS skills,
           a.status AS application_status
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    JOIN Student s ON s.person_id = a.student_id
    JOIN Person p ON p.person_id = s.person_id
    JOIN Program pr ON pr.program_id = s.program_id
    WHERE a.opp_id = @opp_id
      AND o.offered_by_rep_id = @offered_by_rep_id
);
GO

CREATE OR ALTER FUNCTION GetSkillMatch (@student_id INT, @opp_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @required INT, @owned INT;

    SELECT @required = COUNT(*) FROM Opp_Skill WHERE opp_id = @opp_id;

    IF @required = 0
        RETURN 100;

    SELECT @owned = COUNT(*)
    FROM Opp_Skill os
    JOIN Student_Skill ss ON ss.skill_id = os.skill_id AND ss.student_id = @student_id
    WHERE os.opp_id = @opp_id;

    RETURN CAST(@owned * 100.0 / @required AS DECIMAL(5,2));
END
GO

CREATE OR ALTER PROCEDURE ClosePlacement
    @opp_id INT, @offered_by_rep_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Opportunity WHERE opp_id = @opp_id AND offered_by_rep_id = @offered_by_rep_id)
    BEGIN SELECT 'This placement was not found among your placements' AS message; RETURN; END

    UPDATE Opportunity SET status = 'Closed' WHERE opp_id = @opp_id;

    SELECT 'Placement closed to new applications' AS message;
END
GO

CREATE OR ALTER PROCEDURE SubmitThesisTopic
    @provider_id INT, @title VARCHAR(200), @description VARCHAR(1000),
    @app_open_date DATE, @app_close_date DATE, @capacity INT, @location_mode VARCHAR(30),
    @agreement_id INT, @expected_outcomes VARCHAR(500), @funding_info VARCHAR(300),
    @travel_info VARCHAR(300), @accommodation_info VARCHAR(300),
    @supervisor_id INT, @co_supervisor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Topic_Provider WHERE person_id = @provider_id)
    BEGIN SELECT 'This person is not registered as a topic provider' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM GIU_Academic WHERE person_id = @supervisor_id)
    BEGIN SELECT 'Supervisor must be a GIU academic' AS message; RETURN; END

    IF @co_supervisor_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Partner_Professor WHERE person_id = @co_supervisor_id)
    BEGIN SELECT 'Co-supervisor must be a partner professor' AS message; RETURN; END

    IF @agreement_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Cooperation_Agreement WHERE agreement_id = @agreement_id)
    BEGIN SELECT 'Agreement not found' AS message; RETURN; END

    IF @app_close_date < @app_open_date
    BEGIN SELECT 'Closing date cannot be before the opening date' AS message; RETURN; END

    IF @capacity <= 0
    BEGIN SELECT 'Capacity must be greater than zero' AS message; RETURN; END

    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Opportunity (title, description, type, status, app_open_date, app_close_date,
                                 capacity, location_mode, agreement_id, offered_by_rep_id)
        VALUES (@title, @description, 'Thesis', 'Open', @app_open_date, @app_close_date,
                @capacity, @location_mode, @agreement_id,
                CASE WHEN EXISTS (SELECT 1 FROM Company_Rep WHERE person_id = @provider_id)
                     THEN @provider_id ELSE NULL END);

        DECLARE @new_id INT = SCOPE_IDENTITY();

        INSERT INTO Thesis_Topic (opp_id, expected_outcomes, funding_info, travel_info, accommodation_info,
                                  provider_id, supervisor_id, co_supervisor_id)
        VALUES (@new_id, @expected_outcomes, @funding_info, @travel_info, @accommodation_info,
                @provider_id, @supervisor_id, @co_supervisor_id);
        COMMIT;

        SELECT 'Thesis topic submitted' AS message, @new_id AS opp_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE AddThesisArea
    @opp_id INT, @area_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Thesis_Topic WHERE opp_id = @opp_id)
    BEGIN SELECT 'Thesis topic not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Research_Area WHERE area_id = @area_id)
    BEGIN SELECT 'Research area not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Thesis_Area WHERE opp_id = @opp_id AND area_id = @area_id)
    BEGIN SELECT 'The topic is already classified under this area' AS message; RETURN; END

    INSERT INTO Thesis_Area (opp_id, area_id) VALUES (@opp_id, @area_id);

    SELECT 'Research area added to the topic' AS message;
END
GO

CREATE OR ALTER PROCEDURE UpdateThesisTopic
    @opp_id INT, @description VARCHAR(1000), @capacity INT, @app_close_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Thesis_Topic WHERE opp_id = @opp_id)
    BEGIN SELECT 'Thesis topic not found' AS message; RETURN; END

    IF @capacity IS NOT NULL AND @capacity <= 0
    BEGIN SELECT 'Capacity must be greater than zero' AS message; RETURN; END

    IF @capacity IS NOT NULL
       AND @capacity < (SELECT COUNT(*) FROM Application WHERE opp_id = @opp_id AND status = 'Accepted')
    BEGIN SELECT 'Capacity cannot be lower than the number of accepted students' AS message; RETURN; END

    UPDATE Opportunity
    SET description = ISNULL(@description, description),
        capacity = ISNULL(@capacity, capacity),
        app_close_date = ISNULL(@app_close_date, app_close_date)
    WHERE opp_id = @opp_id;

    SELECT 'Thesis topic updated' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewMySubmittedTopics (@provider_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS topic, o.status,
           sp.full_name AS supervisor,
           cp.full_name AS co_supervisor,
           (SELECT COUNT(*) FROM Application a WHERE a.opp_id = o.opp_id) AS applications,
           (SELECT COUNT(*) FROM Application a
            WHERE a.opp_id = o.opp_id AND a.status = 'Accepted') AS accepted_students
    FROM Thesis_Topic t
    JOIN Opportunity o ON o.opp_id = t.opp_id
    JOIN Person sp ON sp.person_id = t.supervisor_id
    LEFT JOIN Person cp ON cp.person_id = t.co_supervisor_id
    WHERE t.provider_id = @provider_id
);
GO

CREATE OR ALTER FUNCTION ViewTopicsWithoutCoSupervisor ()
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS topic,
           pv.full_name AS provider,
           sp.full_name AS supervisor,
           (SELECT STRING_AGG(ra.name, ', ')
            FROM Thesis_Area ta
            JOIN Research_Area ra ON ra.area_id = ta.area_id
            WHERE ta.opp_id = o.opp_id) AS research_areas
    FROM Thesis_Topic t
    JOIN Opportunity o ON o.opp_id = t.opp_id
    JOIN Person pv ON pv.person_id = t.provider_id
    JOIN Person sp ON sp.person_id = t.supervisor_id
    WHERE t.co_supervisor_id IS NULL
);
GO

CREATE OR ALTER FUNCTION ViewMyProfile (@person_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.person_id, p.full_name, p.email, p.phone, p.account_status,
           s.student_no, s.current_semester, s.gpa, s.language_level, s.cv,
           pr.name AS program, d.name AS department, f.name AS faculty
    FROM Student s
    JOIN Person p ON p.person_id = s.person_id
    JOIN Program pr ON pr.program_id = s.program_id
    JOIN Department d ON d.dept_id = pr.dept_id
    JOIN Faculty f ON f.faculty_id = d.faculty_id
    WHERE s.person_id = @person_id
);
GO

CREATE OR ALTER FUNCTION ViewMyFields (@person_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT f.name AS field_name, f.description
    FROM Student s
    JOIN Program_Field pf ON pf.program_id = s.program_id
    JOIN Field f ON f.field_id = pf.field_id
    WHERE s.person_id = @person_id
);
GO

CREATE OR ALTER PROCEDURE UpdateStudentProfile
    @person_id INT, @current_semester INT, @language_level VARCHAR(30), @cv VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE person_id = @person_id)
    BEGIN SELECT 'Student not found' AS message; RETURN; END

    UPDATE Student
    SET current_semester = @current_semester,
        language_level = @language_level,
        cv = @cv
    WHERE person_id = @person_id;

    SELECT 'Profile updated' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddInterest
    @person_id INT, @interest VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE person_id = @person_id)
    BEGIN SELECT 'Student not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Student_Interest WHERE person_id = @person_id AND interest = @interest)
    BEGIN SELECT 'You already added this interest' AS message; RETURN; END

    INSERT INTO Student_Interest (person_id, interest) VALUES (@person_id, @interest);

    SELECT 'Interest added' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddCompletedCourse
    @student_id INT, @course_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE person_id = @student_id)
    BEGIN SELECT 'Student not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE course_id = @course_id)
    BEGIN SELECT 'Course not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Completed_Course WHERE student_id = @student_id AND course_id = @course_id)
    BEGIN SELECT 'This course is already recorded' AS message; RETURN; END

    INSERT INTO Completed_Course (student_id, course_id) VALUES (@student_id, @course_id);

    SELECT 'Completed course recorded' AS message;
END
GO

CREATE OR ALTER PROCEDURE AddMySkill
    @student_id INT, @skill_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE person_id = @student_id)
    BEGIN SELECT 'Student not found' AS message; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Skill WHERE skill_id = @skill_id)
    BEGIN SELECT 'Skill not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Student_Skill WHERE student_id = @student_id AND skill_id = @skill_id)
    BEGIN SELECT 'You already have this skill recorded' AS message; RETURN; END

    INSERT INTO Student_Skill (student_id, skill_id) VALUES (@student_id, @skill_id);

    SELECT 'Skill recorded' AS message;
END
GO

CREATE OR ALTER FUNCTION BrowseOpenOpportunities (@type VARCHAR(30))
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS opportunity, o.location_mode, o.app_close_date AS closing_date,
           dbo.GetRemainingCapacity(o.opp_id) AS remaining_seats
    FROM Opportunity o
    WHERE o.type = @type
      AND o.status = 'Open'
      AND CAST(GETDATE() AS DATE) BETWEEN o.app_open_date AND o.app_close_date
);
GO

CREATE OR ALTER FUNCTION ViewOpportunityDetails (@opp_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title, o.description, o.type, o.status,
           o.app_open_date, o.app_close_date, o.capacity, o.location_mode,
           t.expected_outcomes, t.funding_info, t.travel_info, t.accommodation_info,
           sp.duration AS short_program_duration, sp.location AS short_program_location,
           sp.hosting_arrangements, shu.name AS short_program_host,
           mp.mobility_type, mp.duration AS mobility_duration,
           su.name AS sending_university, hu.name AS host_university,
           (SELECT STRING_AGG(f.name, ', ')
            FROM Opp_Field ofl JOIN Field f ON f.field_id = ofl.field_id
            WHERE ofl.opp_id = o.opp_id) AS fields,
           (SELECT STRING_AGG(pr.name, ', ')
            FROM Opp_Eligible_Program oep JOIN Program pr ON pr.program_id = oep.program_id
            WHERE oep.opp_id = o.opp_id) AS eligible_programs,
           (SELECT STRING_AGG(c.code + ' ' + c.title, ', ')
            FROM Opp_Prereq_Course opc JOIN Course c ON c.course_id = opc.course_id
            WHERE opc.opp_id = o.opp_id) AS prerequisite_courses,
           (SELECT STRING_AGG(sk.name, ', ')
            FROM Opp_Skill os JOIN Skill sk ON sk.skill_id = os.skill_id
            WHERE os.opp_id = o.opp_id) AS required_skills,
           (SELECT STRING_AGG(olr.language_req, ', ')
            FROM Opp_Language_Req olr
            WHERE olr.opp_id = o.opp_id) AS language_requirements
    FROM Opportunity o
    LEFT JOIN Thesis_Topic t ON t.opp_id = o.opp_id
    LEFT JOIN Short_Program sp ON sp.opp_id = o.opp_id
    LEFT JOIN University shu ON shu.uni_id = sp.host_uni_id
    LEFT JOIN Mobility_Program mp ON mp.opp_id = o.opp_id
    LEFT JOIN University su ON su.uni_id = mp.sending_uni_id
    LEFT JOIN University hu ON hu.uni_id = mp.host_uni_id
    WHERE o.opp_id = @opp_id
);
GO

CREATE OR ALTER FUNCTION ViewEligibleOpportunities (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT o.opp_id, o.title AS opportunity, o.type, o.app_close_date AS closing_date,
           dbo.GetRemainingCapacity(o.opp_id) AS remaining_seats
    FROM Opportunity o
    WHERE o.status = 'Open'
      AND CAST(GETDATE() AS DATE) BETWEEN o.app_open_date AND o.app_close_date
      AND dbo.CheckEligibility(@student_id, o.opp_id) = 1
);
GO

CREATE OR ALTER FUNCTION ViewMissingRequirements (@student_id INT, @opp_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 'Course' AS requirement_type, c.code + ' ' + c.title AS missing_requirement
    FROM Opp_Prereq_Course opc
    JOIN Course c ON c.course_id = opc.course_id
    WHERE opc.opp_id = @opp_id
      AND NOT EXISTS (SELECT 1 FROM Completed_Course cc
                      WHERE cc.student_id = @student_id AND cc.course_id = opc.course_id)

    UNION ALL

    SELECT 'Skill', sk.name
    FROM Opp_Skill os
    JOIN Skill sk ON sk.skill_id = os.skill_id
    WHERE os.opp_id = @opp_id
      AND NOT EXISTS (SELECT 1 FROM Student_Skill ss
                      WHERE ss.student_id = @student_id AND ss.skill_id = os.skill_id)
);
GO

CREATE OR ALTER FUNCTION RecommendThesisTopics (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           x.opp_id, x.title AS topic, x.matching_fields, x.matching_skills,
           x.matching_fields + x.matching_skills AS match_score
    FROM (
        SELECT o.opp_id, o.title,
               (SELECT COUNT(*)
                FROM Opp_Field ofl
                JOIN Student s ON s.person_id = @student_id
                JOIN Program_Field pf ON pf.program_id = s.program_id AND pf.field_id = ofl.field_id
                WHERE ofl.opp_id = o.opp_id) AS matching_fields,
               (SELECT COUNT(*)
                FROM Opp_Skill os
                JOIN Student_Skill ss ON ss.skill_id = os.skill_id AND ss.student_id = @student_id
                WHERE os.opp_id = o.opp_id) AS matching_skills
        FROM Opportunity o
        JOIN Thesis_Topic t ON t.opp_id = o.opp_id
        WHERE o.status = 'Open'
          AND CAST(GETDATE() AS DATE) BETWEEN o.app_open_date AND o.app_close_date
    ) x
    ORDER BY x.matching_fields + x.matching_skills DESC
);
GO

CREATE OR ALTER PROCEDURE SubmitApplication
    @student_id INT, @opp_id INT, @info VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @status VARCHAR(30), @open_date DATE, @close_date DATE;

    IF NOT EXISTS (SELECT 1 FROM Student WHERE person_id = @student_id)
    BEGIN SELECT 'Student not found' AS message; RETURN; END

    SELECT @status = status, @open_date = app_open_date, @close_date = app_close_date
    FROM Opportunity WHERE opp_id = @opp_id;

    IF @status IS NULL
    BEGIN SELECT 'Opportunity not found' AS message; RETURN; END

    IF @status <> 'Open'
       OR CAST(GETDATE() AS DATE) < @open_date
       OR CAST(GETDATE() AS DATE) > @close_date
    BEGIN SELECT 'This opportunity is not open for applications' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Application WHERE student_id = @student_id AND opp_id = @opp_id)
    BEGIN SELECT 'You have already applied to this opportunity' AS message; RETURN; END

    IF dbo.CheckEligibility(@student_id, @opp_id) = 0
    BEGIN SELECT 'You do not meet the requirements of this opportunity' AS message; RETURN; END

    INSERT INTO Application (app_date, status, info, student_id, opp_id)
    VALUES (CAST(GETDATE() AS DATE), 'Pending', @info, @student_id, @opp_id);

    SELECT 'Application submitted' AS message, SCOPE_IDENTITY() AS app_id;
END
GO

CREATE OR ALTER PROCEDURE UploadApplicationDocument
    @app_id INT, @doc_type VARCHAR(50), @file_ref VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Application WHERE app_id = @app_id)
    BEGIN SELECT 'Application not found' AS message; RETURN; END

    IF EXISTS (SELECT 1 FROM Application_Document
               WHERE app_id = @app_id AND doc_type = @doc_type AND file_ref = @file_ref)
    BEGIN SELECT 'This document is already uploaded' AS message; RETURN; END

    INSERT INTO Application_Document (app_id, doc_type, file_ref, upload_date)
    VALUES (@app_id, @doc_type, @file_ref, CAST(GETDATE() AS DATE));

    SELECT 'Document uploaded' AS message;
END
GO

CREATE OR ALTER PROCEDURE WithdrawApplication
    @app_id INT, @student_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Application WHERE app_id = @app_id AND student_id = @student_id;

    IF @status IS NULL
    BEGIN SELECT 'Application not found for this student' AS message; RETURN; END

    IF @status <> 'Pending'
    BEGIN SELECT 'Only pending applications can be withdrawn' AS message; RETURN; END

    UPDATE Application SET status = 'Withdrawn' WHERE app_id = @app_id;

    SELECT 'Application withdrawn' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewMyApplications (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT a.app_id, o.title AS opportunity, o.type, a.app_date AS application_date,
           a.status, a.decision_date,
           (SELECT MIN(i.[date]) FROM Interview i
            WHERE i.app_id = a.app_id AND i.[date] >= CAST(GETDATE() AS DATE)) AS next_interview
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE a.student_id = @student_id
);
GO

CREATE OR ALTER FUNCTION ViewMyInterviews (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT i.interview_id, o.title AS opportunity, i.[date] AS interview_date, i.[time] AS interview_time,
           i.location_mode AS mode, i.outcome
    FROM Interview i
    JOIN Application a ON a.app_id = i.app_id
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE a.student_id = @student_id
);
GO

CREATE OR ALTER FUNCTION ViewMyParticipations (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT pa.part_id, o.title AS opportunity,
           CASE WHEN m.part_id IS NOT NULL THEN 'Mobility' ELSE 'Short Program' END AS participation_type,
           pa.start_date, pa.end_date, pa.status AS current_status
    FROM Participation pa
    JOIN Application a ON a.app_id = pa.app_id
    JOIN Opportunity o ON o.opp_id = a.opp_id
    LEFT JOIN Mobility m ON m.part_id = pa.part_id
    WHERE a.student_id = @student_id
);
GO

CREATE OR ALTER FUNCTION ViewMyCourseEquivalencies (@student_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ce.host_course_title AS host_course, ce.host_credits,
           c.code + ' ' + c.title AS giu_course,
           ce.transferred_credits, ce.approval_status
    FROM Course_Equivalency ce
    JOIN Participation pa ON pa.part_id = ce.part_id
    JOIN Application a ON a.app_id = pa.app_id
    JOIN Course c ON c.course_id = ce.giu_course_id
    WHERE a.student_id = @student_id
);
GO

CREATE OR ALTER FUNCTION BrowseFunding (@type VARCHAR(30))
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           fund_id, name, agency, type, amount, deadline, eligibility_conditions
    FROM Funding_Opportunity
    WHERE type = @type
      AND status = 'Open'
      AND deadline >= CAST(GETDATE() AS DATE)
    ORDER BY deadline
);
GO

CREATE OR ALTER PROCEDURE NotifyApplicationStatus
    @app_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @student INT, @status VARCHAR(20), @title VARCHAR(200);

    SELECT @student = a.student_id, @status = a.status, @title = o.title
    FROM Application a
    JOIN Opportunity o ON o.opp_id = a.opp_id
    WHERE a.app_id = @app_id;

    IF @student IS NULL
    BEGIN SELECT 'Application not found' AS message; RETURN; END

    INSERT INTO Notification (message, category, urgency, recipient_id)
    VALUES (LEFT('Your application for ' + @title + ' is now ' + @status + '.', 500),
            'Application', 'Normal', @student);

    SELECT 'Notification sent to the student' AS message;
END
GO

CREATE OR ALTER FUNCTION ViewMyNotifications (@recipient_id INT, @unread_only BIT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 100 PERCENT
           notif_id, message, [timestamp], category, urgency, read_status
    FROM Notification
    WHERE recipient_id = @recipient_id
      AND (@unread_only = 0 OR read_status = 0)
    ORDER BY [timestamp] DESC
);
GO

CREATE OR ALTER FUNCTION GetUnreadCount (@recipient_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;

    SELECT @count = COUNT(*)
    FROM Notification
    WHERE recipient_id = @recipient_id AND read_status = 0;

    RETURN @count;
END
GO

CREATE OR ALTER PROCEDURE MarkNotificationRead
    @notif_id INT, @recipient_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Notification WHERE notif_id = @notif_id AND recipient_id = @recipient_id)
    BEGIN SELECT 'Notification not found' AS message; RETURN; END

    UPDATE Notification SET read_status = 1 WHERE notif_id = @notif_id;

    SELECT 'Notification marked as read' AS message;
END
GO

CREATE OR ALTER PROCEDURE MarkAllNotificationsRead
    @recipient_id INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Notification
    SET read_status = 1
    WHERE recipient_id = @recipient_id AND read_status = 0;

    SELECT 'Notifications updated: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) AS message;
END
GO
