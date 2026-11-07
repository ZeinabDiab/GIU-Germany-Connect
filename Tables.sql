IF DB_ID('GIU_Germany_Connect') IS NULL
    CREATE DATABASE GIU_Germany_Connect;
GO
  



USE GIU_Germany_Connect;
GO





CREATE TABLE Faculty (
    faculty_id INT IDENTITY(1,1) PRIMARY KEY,
            name VARCHAR(150) NOT NULL,
    description VARCHAR(500));

     CREATE TABLE Department (
    dept_id INT IDENTITY(1,1)   PRIMARY KEY,
        name VARCHAR(150) NOT NULL,   description VARCHAR(500),
    faculty_id INT NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id)  );


CREATE TABLE Program (
    program_id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
         degree_level VARCHAR(30),   total_credit_hours INT,
      description VARCHAR(500),
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id));





CREATE TABLE Course (
        course_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
              title VARCHAR(150) NOT NULL,   credit_hours INT,
    [level] INT,
    program_id INT NOT NULL,
         FOREIGN KEY (program_id) REFERENCES Program(program_id));

CREATE TABLE Prerequisite (
    course_id INT NOT NULL,
    prereq_course_id INT NOT NULL,
        PRIMARY KEY (course_id, prereq_course_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
                 FOREIGN KEY (prereq_course_id) REFERENCES Course(course_id),
    CHECK (course_id <> prereq_course_id));
CREATE TABLE Field (
          field_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
                 description VARCHAR(500));

CREATE TABLE Research_Area (
    area_id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
    description VARCHAR(500),   field_id INT NOT NULL,
    FOREIGN KEY (field_id) REFERENCES Field(field_id)
);

CREATE TABLE Skill (
 skill_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
            category VARCHAR(50),
    description VARCHAR(500));

CREATE TABLE Program_Field (
    program_id INT NOT NULL,   field_id INT NOT NULL,
    PRIMARY KEY (program_id, field_id),
        FOREIGN KEY (program_id) REFERENCES Program(program_id),
    FOREIGN KEY (field_id) REFERENCES Field(field_id)
);

CREATE TABLE University (
    uni_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,   country VARCHAR(60),
  city VARCHAR(60),
    description VARCHAR(500)
);

CREATE TABLE GIU (
    uni_id INT PRIMARY KEY,
        FOREIGN KEY (uni_id) REFERENCES University(uni_id)
);

CREATE TABLE Partner_University (
    uni_id INT PRIMARY KEY,
    partnership_status VARCHAR(30),
          contact_info VARCHAR(300),
    FOREIGN KEY (uni_id) REFERENCES University(uni_id)
);







CREATE TABLE Partner_Department (
    pdept_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,     description VARCHAR(500),
    partner_uni_id INT NOT NULL,
  FOREIGN KEY (partner_uni_id) REFERENCES Partner_University(uni_id));

CREATE TABLE Partner_Program (
    pprog_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
        degree_level VARCHAR(30),
    description VARCHAR(500),   pdept_id INT NOT NULL,
    FOREIGN KEY (pdept_id) REFERENCES Partner_Department(pdept_id)
);

CREATE TABLE Partner_Program_Field (
    pprog_id INT NOT NULL,
    field_id INT NOT NULL,
  PRIMARY KEY (pprog_id, field_id),
    FOREIGN KEY (pprog_id) REFERENCES Partner_Program(pprog_id),
        FOREIGN KEY (field_id) REFERENCES Field(field_id)
);

CREATE TABLE Person (
    person_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
            email VARCHAR(150) NOT NULL UNIQUE,   phone VARCHAR(30),
    account_status VARCHAR(20) NOT NULL DEFAULT 'Active',
  CHECK (account_status IN ('Active', 'Inactive', 'Suspended'))
);

CREATE TABLE Student (
    person_id INT PRIMARY KEY,
    student_no VARCHAR(20) NOT NULL UNIQUE,
      current_semester INT,   gpa DECIMAL(3,2),
    language_level VARCHAR(30),
    cv VARCHAR(300),
        program_id INT NOT NULL,
    FOREIGN KEY (person_id) REFERENCES Person(person_id),
    FOREIGN KEY (program_id) REFERENCES Program(program_id)
);

CREATE TABLE Student_Interest (
    person_id INT NOT NULL,   interest VARCHAR(100) NOT NULL,
    PRIMARY KEY (person_id, interest),
  FOREIGN KEY (person_id) REFERENCES Student(person_id)
);

CREATE TABLE GIU_Academic (
    person_id INT PRIMARY KEY,
        academic_rank VARCHAR(50),
    dept_id INT NOT NULL,
    FOREIGN KEY (person_id) REFERENCES Person(person_id),
  FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Partner_Professor (
    person_id INT PRIMARY KEY,
    title VARCHAR(50),   pdept_id INT NOT NULL,
    FOREIGN KEY (person_id) REFERENCES Person(person_id),
        FOREIGN KEY (pdept_id) REFERENCES Partner_Department(pdept_id));

CREATE TABLE Company_Rep (
    person_id INT PRIMARY KEY,
  company_name VARCHAR(150),
    sector VARCHAR(100),   position VARCHAR(100),
        location VARCHAR(100),
    FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Interviewer (
    interviewer_id INT IDENTITY(1,1) PRIMARY KEY,
    role VARCHAR(100),
  person_id INT NOT NULL UNIQUE,
    FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Topic_Provider (
    person_id INT PRIMARY KEY,
        FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE Notification (
    notif_id INT IDENTITY(1,1) PRIMARY KEY,
    message VARCHAR(500) NOT NULL,   [timestamp] DATETIME NOT NULL DEFAULT GETDATE(),
  category VARCHAR(30),
    urgency VARCHAR(20),
        read_status BIT NOT NULL DEFAULT 0,
    recipient_id INT NOT NULL,
    FOREIGN KEY (recipient_id) REFERENCES Person(person_id)
);

CREATE TABLE Completed_Course (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
      PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(person_id),
  FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

CREATE TABLE Student_Skill (
    student_id INT NOT NULL,   skill_id INT NOT NULL,
    PRIMARY KEY (student_id, skill_id),
        FOREIGN KEY (student_id) REFERENCES Student(person_id),
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)
);

CREATE TABLE GIU_Interest (
    academic_id INT NOT NULL,
  area_id INT NOT NULL,
    PRIMARY KEY (academic_id, area_id),
    FOREIGN KEY (academic_id) REFERENCES GIU_Academic(person_id),
        FOREIGN KEY (area_id) REFERENCES Research_Area(area_id)
);

CREATE TABLE PP_Interest (
    partner_prof_id INT NOT NULL,   area_id INT NOT NULL,
    PRIMARY KEY (partner_prof_id, area_id),
  FOREIGN KEY (partner_prof_id) REFERENCES Partner_Professor(person_id),
    FOREIGN KEY (area_id) REFERENCES Research_Area(area_id)
);

CREATE TABLE Cooperation_Agreement (
    agreement_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
        scope VARCHAR(500),
    start_date DATE NOT NULL,   end_date DATE NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Active',
    partner_uni_id INT NOT NULL,
        coordinator_id INT NOT NULL,
    FOREIGN KEY (partner_uni_id) REFERENCES Partner_University(uni_id),
    FOREIGN KEY (coordinator_id) REFERENCES GIU_Academic(person_id),
  CHECK (end_date >= start_date));

CREATE TABLE Mobility_Agreement (
    agreement_id INT PRIMARY KEY,
    exchange_terms VARCHAR(500),   double_degree_terms VARCHAR(500),
        seat_quota INT,
    tuition_arrangement VARCHAR(300),
    FOREIGN KEY (agreement_id) REFERENCES Cooperation_Agreement(agreement_id)
);

CREATE TABLE Mob_Agr_Semester (
    agreement_id INT NOT NULL,
  semester VARCHAR(30) NOT NULL,
    PRIMARY KEY (agreement_id, semester),
        FOREIGN KEY (agreement_id) REFERENCES Mobility_Agreement(agreement_id)
);

CREATE TABLE Mob_Agr_Program (
    agreement_id INT NOT NULL,   program_id INT NOT NULL,
    PRIMARY KEY (agreement_id, program_id),
  FOREIGN KEY (agreement_id) REFERENCES Mobility_Agreement(agreement_id),
    FOREIGN KEY (program_id) REFERENCES Program(program_id)
);

CREATE TABLE Research_Agreement (
    agreement_id INT PRIMARY KEY,
        ip_terms VARCHAR(500),
    funding_framework VARCHAR(300),
  FOREIGN KEY (agreement_id) REFERENCES Cooperation_Agreement(agreement_id)
);

CREATE TABLE Res_Agr_Area (
    agreement_id INT NOT NULL,
    area_id INT NOT NULL,   PRIMARY KEY (agreement_id, area_id),
    FOREIGN KEY (agreement_id) REFERENCES Research_Agreement(agreement_id),
        FOREIGN KEY (area_id) REFERENCES Research_Area(area_id)
);

CREATE TABLE General_MoU (
    agreement_id INT PRIMARY KEY,
  intent VARCHAR(500),
    collab_scope VARCHAR(500),   renewal_terms VARCHAR(300),
    FOREIGN KEY (agreement_id) REFERENCES Cooperation_Agreement(agreement_id));

CREATE TABLE Opportunity (
    opp_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
        description VARCHAR(1000),
    type VARCHAR(30) NOT NULL,   status VARCHAR(30) NOT NULL DEFAULT 'Open',
  app_open_date DATE,
    app_close_date DATE,
        capacity INT NOT NULL DEFAULT 1,
    location_mode VARCHAR(30),
  agreement_id INT NULL,   offered_by_rep_id INT NULL,
    FOREIGN KEY (agreement_id) REFERENCES Cooperation_Agreement(agreement_id),
    FOREIGN KEY (offered_by_rep_id) REFERENCES Company_Rep(person_id),
        CHECK (type IN ('Thesis', 'Short Program', 'Mobility')),
    CHECK (status IN ('Open', 'Closed', 'Cancelled')),
  CHECK (capacity > 0)
);

CREATE TABLE Opp_Language_Req (
    opp_id INT NOT NULL,
    language_req VARCHAR(50) NOT NULL,   PRIMARY KEY (opp_id, language_req),
        FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id)
);

CREATE TABLE Opp_Relevant_Date (
    opp_id INT NOT NULL,
  relevant_date DATE NOT NULL,
    PRIMARY KEY (opp_id, relevant_date),
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id)
);

CREATE TABLE Opp_Field (
    opp_id INT NOT NULL,   field_id INT NOT NULL,
        PRIMARY KEY (opp_id, field_id),
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
  FOREIGN KEY (field_id) REFERENCES Field(field_id));

CREATE TABLE Opp_Eligible_Program (
    opp_id INT NOT NULL,
    program_id INT NOT NULL,
  PRIMARY KEY (opp_id, program_id),
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),   FOREIGN KEY (program_id) REFERENCES Program(program_id)
);

CREATE TABLE Opp_Prereq_Course (
    opp_id INT NOT NULL,
        course_id INT NOT NULL,
    PRIMARY KEY (opp_id, course_id),
  FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

CREATE TABLE Opp_Skill (
    opp_id INT NOT NULL,   skill_id INT NOT NULL,
    PRIMARY KEY (opp_id, skill_id),
        FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
  FOREIGN KEY (skill_id) REFERENCES Skill(skill_id));

CREATE TABLE Thesis_Topic (
    opp_id INT PRIMARY KEY,
    expected_outcomes VARCHAR(500),
        funding_info VARCHAR(300),   travel_info VARCHAR(300),
  accommodation_info VARCHAR(300),
    provider_id INT NOT NULL,
    supervisor_id INT NOT NULL,
        co_supervisor_id INT NULL,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
    FOREIGN KEY (provider_id) REFERENCES Topic_Provider(person_id),
  FOREIGN KEY (supervisor_id) REFERENCES GIU_Academic(person_id),
    FOREIGN KEY (co_supervisor_id) REFERENCES Partner_Professor(person_id)
);

CREATE TABLE Thesis_Area (
    opp_id INT NOT NULL,
  area_id INT NOT NULL,
    PRIMARY KEY (opp_id, area_id),   FOREIGN KEY (opp_id) REFERENCES Thesis_Topic(opp_id),
        FOREIGN KEY (area_id) REFERENCES Research_Area(area_id)
);

CREATE TABLE Short_Program (
    opp_id INT PRIMARY KEY,
    duration VARCHAR(50),
        location VARCHAR(100),
  hosting_arrangements VARCHAR(300),
    host_uni_id INT NOT NULL,   FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
    FOREIGN KEY (host_uni_id) REFERENCES University(uni_id));

CREATE TABLE Mobility_Program (
    opp_id INT PRIMARY KEY,
    mobility_type VARCHAR(50),
  duration VARCHAR(50),
    sending_uni_id INT NOT NULL,
        host_uni_id INT NOT NULL,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
  FOREIGN KEY (sending_uni_id) REFERENCES University(uni_id),   FOREIGN KEY (host_uni_id) REFERENCES University(uni_id));

CREATE TABLE Application (
    app_id INT IDENTITY(1,1) PRIMARY KEY,
    app_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        status VARCHAR(20) NOT NULL DEFAULT 'Pending',
  decision_date DATE NULL,
    info VARCHAR(500),   student_id INT NOT NULL,
    opp_id INT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES Student(person_id),
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id),
  UNIQUE (student_id, opp_id),
    CHECK (status IN ('Pending', 'Accepted', 'Rejected', 'Withdrawn'))
);

CREATE TABLE Application_Document (
    app_id INT NOT NULL,
  doc_type VARCHAR(50) NOT NULL,
    file_ref VARCHAR(300) NOT NULL,   upload_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        PRIMARY KEY (app_id, doc_type, file_ref),
    FOREIGN KEY (app_id) REFERENCES Application(app_id));

CREATE TABLE Interview (
    interview_id INT IDENTITY(1,1) PRIMARY KEY,
    [date] DATE NOT NULL,
  [time] TIME NOT NULL,   location_mode VARCHAR(30),
        outcome VARCHAR(50),
    notes VARCHAR(500),
  app_id INT NOT NULL,
    FOREIGN KEY (app_id) REFERENCES Application(app_id)
);

CREATE TABLE Conducts_Interview (
    interviewer_id INT NOT NULL,
        interview_id INT NOT NULL,
    PRIMARY KEY (interviewer_id, interview_id),
  FOREIGN KEY (interviewer_id) REFERENCES Interviewer(interviewer_id),   FOREIGN KEY (interview_id) REFERENCES Interview(interview_id));

CREATE TABLE Participation (
    part_id INT IDENTITY(1,1) PRIMARY KEY,
    status VARCHAR(30) NOT NULL DEFAULT 'Active',
        start_date DATE,   end_date DATE,
  app_id INT NOT NULL UNIQUE,
    FOREIGN KEY (app_id) REFERENCES Application(app_id)
);






CREATE TABLE Mobility (
    part_id INT PRIMARY KEY,
    pre_travel_status VARCHAR(50),
  during_status VARCHAR(50),   post_status VARCHAR(50),
        final_outcome VARCHAR(300),
    host_uni_id INT NOT NULL,
  FOREIGN KEY (part_id) REFERENCES Participation(part_id),
    FOREIGN KEY (host_uni_id) REFERENCES University(uni_id)
);

CREATE TABLE Program_Participation (
    part_id INT PRIMARY KEY,
        payment_status VARCHAR(30),   visa_status VARCHAR(30),
  travel_status VARCHAR(30),
    FOREIGN KEY (part_id) REFERENCES Participation(part_id)
);



CREATE TABLE Course_Equivalency (
    part_id INT NOT NULL,
    host_course_title VARCHAR(150) NOT NULL,
        host_credits DECIMAL(4,1),
  transferred_credits DECIMAL(4,1),   approval_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    giu_course_id INT NOT NULL,
        PRIMARY KEY (part_id, host_course_title),
    FOREIGN KEY (part_id) REFERENCES Mobility(part_id),
  FOREIGN KEY (giu_course_id) REFERENCES Course(course_id),
    CHECK (approval_status IN ('Pending', 'Approved', 'Rejected'))
);











CREATE TABLE Professor_Visit (
    visit_id INT IDENTITY(1,1) PRIMARY KEY,
  start_date DATE NOT NULL,   end_date DATE NOT NULL,
    purpose VARCHAR(300),
        travel_arr VARCHAR(300),
    accommodation_arr VARCHAR(300),
  status VARCHAR(30) NOT NULL DEFAULT 'Scheduled',
    follow_up_report VARCHAR(1000),   partner_prof_id INT NOT NULL,
        host_faculty_id INT NOT NULL,
    coordinator_id INT NOT NULL,
  agreement_id INT NOT NULL,
    FOREIGN KEY (partner_prof_id) REFERENCES Partner_Professor(person_id),
        FOREIGN KEY (host_faculty_id) REFERENCES Faculty(faculty_id),
    FOREIGN KEY (coordinator_id) REFERENCES GIU_Academic(person_id),
  FOREIGN KEY (agreement_id) REFERENCES Cooperation_Agreement(agreement_id),
    CHECK (end_date >= start_date)
);

CREATE TABLE Visit_Outcome (
    visit_id INT NOT NULL,   outcome VARCHAR(200) NOT NULL,
        PRIMARY KEY (visit_id, outcome),
  FOREIGN KEY (visit_id) REFERENCES Professor_Visit(visit_id)
);










CREATE TABLE Agenda_Item (
    visit_id INT NOT NULL,
    seq_no INT NOT NULL,
        activity_type VARCHAR(30),
  title VARCHAR(200) NOT NULL,   date_time DATETIME,
    location VARCHAR(100),
        audience VARCHAR(100),
    PRIMARY KEY (visit_id, seq_no),
  FOREIGN KEY (visit_id) REFERENCES Professor_Visit(visit_id)
);






CREATE TABLE Research_Project (
    project_id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
  description VARCHAR(1000),   status VARCHAR(30) NOT NULL DEFAULT 'Active',
        start_date DATE,
    end_date DATE,
  res_agreement_id INT NOT NULL,
    FOREIGN KEY (res_agreement_id) REFERENCES Research_Agreement(agreement_id)
);







CREATE TABLE Project_Deadline (
    project_id INT NOT NULL,
        deadline DATE NOT NULL,
    PRIMARY KEY (project_id, deadline),   FOREIGN KEY (project_id) REFERENCES Research_Project(project_id)
);







CREATE TABLE Project_Area (
    project_id INT NOT NULL,
  area_id INT NOT NULL,
    PRIMARY KEY (project_id, area_id),
        FOREIGN KEY (project_id) REFERENCES Research_Project(project_id),
    FOREIGN KEY (area_id) REFERENCES Research_Area(area_id)
);





CREATE TABLE GIU_Participates (
    academic_id INT NOT NULL,   project_id INT NOT NULL,
    role VARCHAR(50),
  PRIMARY KEY (academic_id, project_id),
    FOREIGN KEY (academic_id) REFERENCES GIU_Academic(person_id),
        FOREIGN KEY (project_id) REFERENCES Research_Project(project_id)
);




CREATE TABLE PP_Participates (
    partner_prof_id INT NOT NULL,
  project_id INT NOT NULL,
    role VARCHAR(50),   PRIMARY KEY (partner_prof_id, project_id),
    FOREIGN KEY (partner_prof_id) REFERENCES Partner_Professor(person_id),
        FOREIGN KEY (project_id) REFERENCES Research_Project(project_id)
);

CREATE TABLE Research_Output (
    output_id INT IDENTITY(1,1) PRIMARY KEY,
    type VARCHAR(30),
  title VARCHAR(200) NOT NULL,
    [date] DATE,   reference VARCHAR(200),
        status VARCHAR(30),
    project_id INT NOT NULL,
  FOREIGN KEY (project_id) REFERENCES Research_Project(project_id)
);

CREATE TABLE Funding_Opportunity (
    fund_id INT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(150) NOT NULL,
    agency VARCHAR(150),   type VARCHAR(30),
  amount DECIMAL(12,2),
    deadline DATE,
        eligibility_conditions VARCHAR(500),
    status VARCHAR(30) NOT NULL DEFAULT 'Open'
);

CREATE TABLE Project_Targets_Fund (
    project_id INT NOT NULL,
  fund_id INT NOT NULL,
    PRIMARY KEY (project_id, fund_id),   FOREIGN KEY (project_id) REFERENCES Research_Project(project_id),
        FOREIGN KEY (fund_id) REFERENCES Funding_Opportunity(fund_id)
);

CREATE TABLE Fund_Supports_Mobility (
    fund_id INT NOT NULL,
    part_id INT NOT NULL,
  PRIMARY KEY (fund_id, part_id),
        FOREIGN KEY (fund_id) REFERENCES Funding_Opportunity(fund_id),   FOREIGN KEY (part_id) REFERENCES Mobility(part_id)
);
GO