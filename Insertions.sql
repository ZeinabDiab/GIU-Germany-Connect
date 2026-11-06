USE GIU_Germany_Connect;
GO

INSERT INTO Faculty (name, description) VALUES
('Faculty of Informatics and Computer Science', 'Computer science, software engineering and data science programs'),
('Faculty of Engineering', 'Mechatronics, electronics and communication engineering programs'),
('Faculty of Business Informatics', 'Information systems and digital business programs');

INSERT INTO Department (name, description, faculty_id) VALUES
('Computer Science', 'Algorithms, artificial intelligence and data science', 1),
('Software Engineering', 'Software design, testing and project delivery', 1),
('Mechatronics Engineering', 'Mechanical, electrical and embedded systems', 2),
('Electronics and Communication Engineering', 'Electronics, signals and communication networks', 2),
('Business Informatics', 'Enterprise systems and digital transformation', 3);

INSERT INTO Program (name, degree_level, total_credit_hours, description, dept_id) VALUES
('BSc Computer Science and Engineering', 'Bachelor', 144, 'Five year bachelor program with a German curriculum', 1),
('BSc Software Engineering', 'Bachelor', 144, 'Bachelor program focused on building large software systems', 2),
('BSc Mechatronics Engineering', 'Bachelor', 150, 'Bachelor program combining mechanics, electronics and control', 3),
('MSc Data Science', 'Master', 90, 'Master program in machine learning and data engineering', 1),
('BSc Business Informatics', 'Bachelor', 140, 'Bachelor program linking IT with business processes', 5);

INSERT INTO Course (code, title, credit_hours, [level], program_id) VALUES
('CSEN102', 'Introduction to Computer Programming', 4, 1, 1),
('CSEN202', 'Data Structures and Algorithms', 4, 2, 1),
('CSEN501', 'Databases', 4, 3, 1),
('CSEN503', 'Design and Analysis of Algorithms', 4, 3, 1),
('CSEN604', 'Machine Learning', 4, 4, 1),
('SENG201', 'Software Engineering I', 4, 2, 2),
('SENG402', 'Software Architecture', 4, 4, 2),
('MCTR101', 'Introduction to Mechatronics', 4, 1, 3),
('DSEN701', 'Advanced Machine Learning', 6, 5, 4),
('BINF201', 'Enterprise Information Systems', 4, 2, 5);

INSERT INTO Prerequisite (course_id, prereq_course_id) VALUES
(2, 1), (3, 2), (4, 2), (5, 4), (7, 6), (9, 5);

INSERT INTO Field (name, description) VALUES
('Artificial Intelligence', 'Machine learning, computer vision and language technology'),
('Software Engineering', 'Design, testing and maintenance of software systems'),
('Robotics', 'Robots, automation and autonomous machines'),
('Data Management', 'Databases and large scale data processing'),
('Business Informatics', 'Information systems in organisations');

INSERT INTO Research_Area (name, description, field_id) VALUES
('Machine Learning', 'Learning algorithms and statistical models', 1),
('Natural Language Processing', 'Machine understanding of Arabic, English and German text', 1),
('Computer Vision', 'Image and video understanding', 1),
('Software Testing', 'Automated testing and quality assurance', 2),
('Autonomous Systems', 'Self driving vehicles and mobile robots', 3),
('Big Data Analytics', 'Analysis of very large datasets', 4),
('Enterprise Systems', 'ERP and business process systems', 5);

INSERT INTO Skill (name, category, description) VALUES
('Python', 'Programming', 'Python programming'),
('SQL', 'Programming', 'Writing queries and designing relational databases'),
('Java', 'Programming', 'Object oriented programming in Java'),
('Teamwork', 'Soft Skill', 'Working in a project team'),
('Data Analysis', 'Analytical', 'Cleaning, exploring and visualising data'),
('Machine Learning', 'Technical', 'Training and evaluating machine learning models'),
('C++', 'Programming', 'C++ programming');

INSERT INTO Program_Field (program_id, field_id) VALUES
(1, 1), (1, 2), (1, 4), (2, 2), (3, 3), (4, 1), (4, 4), (5, 5);

INSERT INTO University (name, country, city, description) VALUES
('German International University', 'Egypt', 'New Administrative Capital', 'Private university in Egypt offering German accredited programs in cooperation with German universities'),
('Technical University of Munich', 'Germany', 'Munich', 'Leading technical university in Bavaria'),
('University of Stuttgart', 'Germany', 'Stuttgart', 'Research university with strong engineering faculties'),
('RWTH Aachen University', 'Germany', 'Aachen', 'Large technical university in North Rhine-Westphalia'),
('Reutlingen University', 'Germany', 'Reutlingen', 'University of applied sciences with a business and technology focus');

INSERT INTO GIU (uni_id) VALUES (1);

INSERT INTO Partner_University (uni_id, partnership_status, contact_info) VALUES
(2, 'Active', 'international@tum.de'),
(3, 'Active', 'international@uni-stuttgart.de'),
(4, 'Active', 'international@rwth-aachen.de'),
(5, 'Active', 'international@reutlingen-university.de');

INSERT INTO Partner_Department (name, description, partner_uni_id) VALUES
('TUM School of Computation, Information and Technology', 'Computer science, informatics and data engineering', 2),
('Faculty of Mechanical Engineering', 'Mechanical engineering and robotics research', 3),
('Department of Computer Science', 'Computer science teaching and research', 4),
('ESB Business School', 'Business and management studies', 5),
('Department of Electrical and Computer Engineering', 'Electronics and embedded systems', 2);

INSERT INTO Partner_Program (name, degree_level, description, pdept_id) VALUES
('MSc Informatics', 'Master', 'Master program in informatics', 1),
('MSc Robotics', 'Master', 'Master program in robotics and autonomous systems', 2),
('BSc Computer Science', 'Bachelor', 'Bachelor program in computer science', 3),
('MSc International Business Informatics', 'Master', 'Master program in business informatics', 4),
('MSc Data Engineering and Analytics', 'Master', 'Master program in data engineering', 1);

INSERT INTO Partner_Program_Field (pprog_id, field_id) VALUES
(1, 1), (2, 3), (3, 1), (4, 5), (5, 4);

INSERT INTO Person (full_name, email, phone, account_status) VALUES
('Ahmed Mohamed Hassan', 'ahmed.hassan@student.giu-uni.de', '01001234567', 'Active'),
('Mariam Khaled Farouk', 'mariam.farouk@student.giu-uni.de', '01012345678', 'Active'),
('Omar Nabil Sharaf', 'omar.sharaf@student.giu-uni.de', '01023456789', 'Active'),
('Salma Adel Younis', 'salma.younis@student.giu-uni.de', '01034567890', 'Active'),
('Youssef Tarek El-Sayed', 'youssef.elsayed@student.giu-uni.de', '01045678901', 'Active'),
('Nour Ibrahim Gamal', 'nour.gamal@student.giu-uni.de', '01056789012', 'Inactive'),
('Dr. Hany Mostafa', 'hany.mostafa@giu-uni.de', '01067890123', 'Active'),
('Dr. Rana Fathy', 'rana.fathy@giu-uni.de', '01078901234', 'Active'),
('Dr. Karim Samir', 'karim.samir@giu-uni.de', '01089012345', 'Active'),
('Dr. Dina Mahmoud', 'dina.mahmoud@giu-uni.de', '01090123456', 'Active'),
('Prof. Klaus Weber', 'klaus.weber@tum.de', '+49891234567', 'Active'),
('Prof. Anna Schmidt', 'anna.schmidt@uni-stuttgart.de', '+49711234567', 'Active'),
('Prof. Markus Braun', 'markus.braun@rwth-aachen.de', '+492411234567', 'Active'),
('Laila Mansour', 'laila.mansour@valeo.com', '01101234567', 'Active'),
('Peter Mueller', 'peter.mueller@bosch.com', '+49711811234', 'Active');

INSERT INTO Student (person_id, student_no, current_semester, gpa, language_level, cv, program_id) VALUES
(1, '11001234', 7, 3.60, 'B2', 'cv/ahmed_hassan.pdf', 1),
(2, '11001378', 5, 3.85, 'C1', 'cv/mariam_farouk.pdf', 1),
(3, '11002045', 6, 3.20, 'B1', 'cv/omar_sharaf.pdf', 2),
(4, '11002290', 3, 3.75, 'B2', 'cv/salma_younis.pdf', 4),
(5, '11002517', 4, 2.90, 'A2', 'cv/youssef_elsayed.pdf', 3),
(6, '11002833', 6, 3.40, 'B2', 'cv/nour_gamal.pdf', 5);

INSERT INTO Student_Interest (person_id, interest) VALUES
(1, 'Machine Learning'), (1, 'Chess'),
(2, 'Natural Language Processing'), (2, 'Reading'),
(3, 'Web Development'),
(4, 'Data Science'), (4, 'Photography'),
(5, 'Robotics'),
(6, 'Business Analytics');

INSERT INTO GIU_Academic (person_id, academic_rank, dept_id) VALUES
(7, 'Professor', 1),
(8, 'Associate Professor', 2),
(9, 'Assistant Professor', 3),
(10, 'Associate Professor', 1);

INSERT INTO Partner_Professor (person_id, title, pdept_id) VALUES
(11, 'Professor', 1),
(12, 'Professor', 2),
(13, 'Associate Professor', 3);

INSERT INTO Company_Rep (person_id, company_name, sector, position, location) VALUES
(14, 'Valeo Egypt', 'Automotive', 'HR Manager', 'Cairo'),
(15, 'Bosch Engineering GmbH', 'Automotive', 'Head of Talent', 'Abstatt');

INSERT INTO Topic_Provider (person_id) VALUES (7), (8), (11), (14);

INSERT INTO Interviewer (role, person_id) VALUES
('Panel Chair', 7),
('Technical Interviewer', 8),
('Industry Interviewer', 14),
('Academic Interviewer', 11);

INSERT INTO Completed_Course (student_id, course_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5),
(3, 1), (3, 2), (3, 6),
(4, 5),
(5, 8),
(6, 3), (6, 10);

INSERT INTO Student_Skill (student_id, skill_id) VALUES
(1, 1), (1, 2), (1, 5),
(2, 1), (2, 2), (2, 5), (2, 6),
(3, 1), (3, 2), (3, 3),
(4, 1), (4, 5), (4, 6),
(5, 7),
(6, 2), (6, 5);

INSERT INTO GIU_Interest (academic_id, area_id) VALUES
(7, 1), (7, 2), (8, 4), (9, 5), (10, 1), (10, 6);

INSERT INTO PP_Interest (partner_prof_id, area_id) VALUES
(11, 1), (11, 2), (12, 5), (13, 1), (13, 6);

INSERT INTO Cooperation_Agreement (title, scope, start_date, end_date, status, partner_uni_id, coordinator_id) VALUES
('GIU - TUM Semester Exchange', 'Semester exchange for computer science and software engineering students', '2025-01-01', '2027-12-31', 'Active', 2, 7),
('GIU - Stuttgart Autonomous Systems Research', 'Joint research on autonomous vehicles and mobile robots', '2024-09-01', '2026-12-31', 'Active', 3, 9),
('GIU - RWTH Aachen General MoU', 'General academic cooperation and staff exchange', '2023-06-01', '2026-05-31', 'Expired', 4, 7),
('GIU - Reutlingen Double Degree', 'Double degree for computer science and business informatics students', '2025-03-01', '2028-02-28', 'Active', 5, 10),
('GIU - TUM Machine Learning Research', 'Joint research in machine learning and medical imaging', '2025-09-01', '2027-08-31', 'Active', 2, 10);

INSERT INTO Mobility_Agreement (agreement_id, exchange_terms, double_degree_terms, seat_quota, tuition_arrangement) VALUES
(1, 'One semester exchange, credits transferred after approval by the program coordinator', NULL, 20, 'Students keep paying tuition at GIU'),
(4, 'Exchange allowed in the last two years of study', 'Two years at each university, both degrees awarded', 10, 'Reduced tuition at Reutlingen University');

INSERT INTO Mob_Agr_Semester (agreement_id, semester) VALUES
(1, 'Fall 2026'), (1, 'Spring 2027'), (4, 'Fall 2026');

INSERT INTO Mob_Agr_Program (agreement_id, program_id) VALUES
(1, 1), (1, 2), (4, 1), (4, 5);

INSERT INTO Research_Agreement (agreement_id, ip_terms, funding_framework) VALUES
(2, 'Results are owned jointly by both universities', 'Co-funded by GIU and the University of Stuttgart'),
(5, 'Joint ownership, publications carry both affiliations', 'Funded through external grants');

INSERT INTO Res_Agr_Area (agreement_id, area_id) VALUES
(2, 5), (5, 1), (5, 2);

INSERT INTO General_MoU (agreement_id, intent, collab_scope, renewal_terms) VALUES
(3, 'Strengthen academic ties between GIU and RWTH Aachen', 'Staff exchange and joint academic events', 'Renewable every three years by mutual consent');

INSERT INTO Opportunity (title, description, type, status, app_open_date, app_close_date, capacity, location_mode, agreement_id, offered_by_rep_id) VALUES
('Deep Learning for Medical Image Segmentation', 'Bachelor or master thesis on segmentation of chest X-ray images', 'Thesis', 'Open', '2026-09-01', '2026-12-15', 2, 'Hybrid', 5, NULL),
('Path Planning for Autonomous Vehicles', 'Thesis on motion planning for vehicles in dense urban traffic', 'Thesis', 'Open', '2026-10-01', '2026-12-31', 1, 'On-site', 2, 14),
('Neural Machine Translation for Arabic and German', 'Thesis on translation between Arabic and German using transformer models', 'Thesis', 'Open', '2026-10-01', '2026-12-20', 1, 'Online', 5, NULL),
('Scalable Streaming Data Pipelines', 'Thesis on building fault tolerant streaming pipelines', 'Thesis', 'Closed', '2026-03-01', '2026-05-30', 1, 'Hybrid', 5, NULL),
('Fall 2026 Exchange at TU Munich', 'One semester exchange at the Technical University of Munich', 'Mobility', 'Open', '2026-10-01', '2026-11-20', 5, 'On-site', 1, NULL),
('Double Degree at Reutlingen University', 'Double degree in computer science and business informatics', 'Mobility', 'Open', '2026-09-15', '2027-01-15', 3, 'On-site', 4, NULL),
('Munich Summer School on Artificial Intelligence 2027', 'Six week summer school on modern machine learning', 'Short Program', 'Open', '2026-10-15', '2026-11-30', 30, 'On-site', 1, NULL),
('Winter Workshop on Robotics and Automation', 'Two week hands on workshop at the GIU campus', 'Short Program', 'Open', '2026-10-01', '2026-12-01', 20, 'On-site', 2, 15);

INSERT INTO Thesis_Topic (opp_id, expected_outcomes, funding_info, travel_info, accommodation_info, provider_id, supervisor_id, co_supervisor_id) VALUES
(1, 'A working segmentation model and a short conference paper', 'Monthly stipend from the research project', 'Two week research visit to TUM', 'Student housing in Munich', 7, 7, 11),
(2, 'A planner prototype evaluated in simulation', 'Funded by Valeo Egypt', 'No travel', 'Not needed', 14, 9, 12),
(3, 'A translation system with an evaluation report', 'No funding', 'No travel', 'Not needed', 7, 8, NULL),
(4, 'A pipeline prototype and a benchmark report', 'No funding', 'No travel', 'Not needed', 11, 10, 13);

INSERT INTO Thesis_Area (opp_id, area_id) VALUES
(1, 1), (1, 3), (2, 5), (3, 2), (4, 6);

INSERT INTO Short_Program (opp_id, duration, location, hosting_arrangements, host_uni_id) VALUES
(7, '6 weeks', 'Munich', 'Accommodation in student dormitories', 2),
(8, '2 weeks', 'New Administrative Capital', 'Held on the GIU campus', 1);

INSERT INTO Mobility_Program (opp_id, mobility_type, duration, sending_uni_id, host_uni_id) VALUES
(5, 'Exchange', '1 semester', 1, 2),
(6, 'Double Degree', '4 semesters', 1, 5);

INSERT INTO Opp_Language_Req (opp_id, language_req) VALUES
(1, 'English B2'), (5, 'German B1'), (6, 'German B2'), (7, 'English B2');

INSERT INTO Opp_Relevant_Date (opp_id, relevant_date) VALUES
(5, '2027-03-01'), (7, '2027-07-01');

INSERT INTO Opp_Field (opp_id, field_id) VALUES
(1, 1), (2, 3), (3, 1), (4, 4), (5, 1), (6, 5), (7, 1), (8, 3);

INSERT INTO Opp_Eligible_Program (opp_id, program_id) VALUES
(1, 1), (1, 4),
(2, 1), (2, 3),
(3, 1), (3, 2), (3, 4),
(4, 1), (4, 4),
(5, 1), (5, 2),
(6, 1), (6, 5),
(7, 1), (7, 2), (7, 4),
(8, 3);

INSERT INTO Opp_Prereq_Course (opp_id, course_id) VALUES
(1, 5), (2, 4), (3, 2), (5, 3), (6, 3);

INSERT INTO Opp_Skill (opp_id, skill_id) VALUES
(1, 1), (1, 6), (2, 7), (3, 1), (5, 2), (7, 1);

INSERT INTO Application (app_date, status, decision_date, info, student_id, opp_id) VALUES
('2026-10-05', 'Pending', NULL, 'I want to take distributed systems courses at TUM during my seventh semester', 1, 5),
('2026-09-20', 'Accepted', '2026-10-10', 'I worked on a chest X-ray classifier in my machine learning course project', 2, 1),
('2026-10-02', 'Accepted', '2026-10-18', 'I want to improve my German and study at a German university', 2, 5),
('2026-10-12', 'Pending', NULL, 'I enjoyed the NLP elective and want to work on translation', 3, 3),
('2026-09-25', 'Rejected', '2026-10-12', 'My bachelor project was on data analysis for hospital records', 4, 1),
('2026-10-10', 'Pending', NULL, 'I am interested in the double degree because of my business informatics courses', 6, 6),
('2026-10-20', 'Pending', NULL, 'I would like to attend the summer school to learn deep learning', 1, 7),
('2026-10-08', 'Accepted', '2026-10-15', 'I built a line following robot in the mechatronics lab', 5, 8);

INSERT INTO Application_Document (app_id, doc_type, file_ref, upload_date) VALUES
(1, 'CV', 'docs/ahmed_hassan_cv.pdf', '2026-10-05'),
(1, 'Transcript', 'docs/ahmed_hassan_transcript.pdf', '2026-10-05'),
(2, 'CV', 'docs/mariam_farouk_cv.pdf', '2026-09-20'),
(2, 'Motivation Letter', 'docs/mariam_farouk_letter.pdf', '2026-09-21'),
(3, 'CV', 'docs/mariam_farouk_cv.pdf', '2026-10-02'),
(4, 'CV', 'docs/omar_sharaf_cv.pdf', '2026-10-12'),
(8, 'CV', 'docs/youssef_elsayed_cv.pdf', '2026-10-08');

INSERT INTO Interview ([date], [time], location_mode, outcome, notes, app_id) VALUES
('2026-10-01', '10:00', 'Online', 'Passed', 'Strong background in machine learning and clear research plan', 2),
('2026-11-15', '11:30', 'On-site', 'Pending', NULL, 4),
('2026-10-05', '09:00', 'Online', 'Failed', 'Limited experience with image segmentation', 5);

INSERT INTO Conducts_Interview (interviewer_id, interview_id) VALUES
(1, 1), (4, 1), (2, 2), (1, 3);

INSERT INTO Participation (status, start_date, end_date, app_id) VALUES
('Active', '2027-02-01', '2027-07-31', 3),
('Active', '2027-01-10', '2027-01-24', 8);

INSERT INTO Mobility (part_id, pre_travel_status, during_status, post_status, final_outcome, host_uni_id) VALUES
(1, 'Documents submitted', 'Not started', 'Not started', NULL, 2);

INSERT INTO Program_Participation (part_id, payment_status, visa_status, travel_status) VALUES
(2, 'Paid', 'Not required', 'Not needed');

INSERT INTO Course_Equivalency (part_id, host_course_title, host_credits, transferred_credits, approval_status, giu_course_id) VALUES
(1, 'Distributed Systems', 6.0, 5.0, 'Approved', 4),
(1, 'Advanced Database Systems', 6.0, 6.0, 'Pending', 3);

INSERT INTO Professor_Visit (start_date, end_date, purpose, travel_arr, accommodation_arr, status, follow_up_report, partner_prof_id, host_faculty_id, coordinator_id, agreement_id) VALUES
('2026-11-20', '2026-11-25', 'Guest lecture and research meetings', 'Flight booked by GIU', 'Hotel near the campus', 'Scheduled', NULL, 11, 1, 10, 5),
('2026-03-10', '2026-03-14', 'Joint workshop on autonomous systems', 'Flight booked by the University of Stuttgart', 'GIU guest house', 'Completed', 'The workshop went well and two master theses were agreed', 12, 2, 9, 2),
('2026-12-05', '2026-12-08', 'Curriculum alignment meetings for the exchange program', 'To be arranged', 'To be arranged', 'Requested', NULL, 11, 1, 7, 1);

INSERT INTO Visit_Outcome (visit_id, outcome) VALUES
(2, 'Agreed to co-supervise two master theses'),
(2, 'Planned a joint grant proposal');

INSERT INTO Agenda_Item (visit_id, seq_no, activity_type, title, date_time, location, audience) VALUES
(1, 1, 'Lecture', 'Introduction to Federated Learning', '2026-11-21 10:00', 'Lecture Hall A', 'Students'),
(1, 2, 'Meeting', 'Research collaboration meeting', '2026-11-22 13:00', 'Meeting Room 3', 'Faculty'),
(2, 1, 'Workshop', 'Autonomous Systems Workshop', '2026-03-11 09:00', 'Robotics Lab', 'Researchers');

INSERT INTO Research_Project (title, description, status, start_date, end_date, res_agreement_id) VALUES
('Federated Learning for Healthcare Imaging', 'Training models on medical images that stay in different hospitals', 'Active', '2025-10-01', '2027-09-30', 5),
('Safe Navigation for Autonomous Robots', 'Safety guarantees for robot navigation in shared spaces', 'Active', '2024-10-01', '2026-12-31', 2);

INSERT INTO Project_Deadline (project_id, deadline) VALUES
(1, '2026-12-01'), (1, '2027-03-15'), (2, '2026-11-30');

INSERT INTO Project_Area (project_id, area_id) VALUES
(1, 1), (1, 3), (2, 5);

INSERT INTO GIU_Participates (academic_id, project_id, role) VALUES
(10, 1, 'Principal Investigator'), (7, 1, 'Researcher'), (9, 2, 'Principal Investigator');

INSERT INTO PP_Participates (partner_prof_id, project_id, role) VALUES
(11, 1, 'Co-Investigator'), (12, 2, 'Co-Investigator');

INSERT INTO Research_Output (type, title, [date], reference, status, project_id) VALUES
('Publication', 'Federated Segmentation of Chest X-rays', '2026-06-15', 'doi:10.1000/fl-2026-01', 'Published', 1),
('Dataset', 'Anonymised Chest X-ray Benchmark', '2026-08-01', 'repo/giu/datasets/cxr-bench', 'Draft', 1),
('Report', 'Interim Report Year 2', '2026-04-10', 'reports/safe-nav-y2', 'Submitted', 2);

INSERT INTO Funding_Opportunity (name, agency, type, amount, deadline, eligibility_conditions, status) VALUES
('DAAD Study Scholarship', 'DAAD', 'Scholarship', 10000.00, '2026-12-15', 'Enrolled students with a GPA above 3.0', 'Open'),
('Erasmus+ Mobility Grant', 'European Union', 'Grant', 6000.00, '2026-11-30', 'Students on an approved exchange', 'Open'),
('Horizon Europe Research Grant', 'European Commission', 'Research Grant', 250000.00, '2027-02-01', 'Joint research projects with European partners', 'Open'),
('Industry Thesis Award', 'Valeo Egypt', 'Award', 2000.00, '2026-10-01', 'Thesis students working on an industry topic', 'Closed');

INSERT INTO Project_Targets_Fund (project_id, fund_id) VALUES
(1, 3), (2, 3);

INSERT INTO Fund_Supports_Mobility (fund_id, part_id) VALUES
(1, 1), (2, 1);

INSERT INTO Notification (message, [timestamp], category, urgency, read_status, recipient_id) VALUES
('Your application for Deep Learning for Medical Image Segmentation is now Accepted.', '2026-10-10 09:30', 'Application', 'Normal', 1, 2),
('Your application for Fall 2026 Exchange at TU Munich is now Accepted.', '2026-10-18 11:00', 'Application', 'Normal', 0, 2),
('Interview scheduled for 2026-11-15 at 11:30.', '2026-11-01 08:15', 'Interview', 'High', 0, 3),
('A new visit has been scheduled for 2026-11-20.', '2026-11-02 14:00', 'Visit', 'Normal', 0, 10);
GO
