USE GIU_Germany_Connect;
GO

INSERT INTO Faculty (name, description) VALUES
('faculty of informatics and computer science', 'computer science, software engineering and data science programs'),
    ('faculty of engineering','mechatronics, electronics and communication engineering programs'),
  ('faculty of business informatics',   'information systems and digital business programs');

INSERT INTO Department (name, description, faculty_id) VALUES
('computer science', 'algorithms, artificial intelligence and data science', 1),
  ('software engineering','software design, testing and project delivery',1),
('mechatronics engineering', 'mechanical, electrical and embedded systems', 2),
     ('electronics and communication engineering', 'electronics, signals and communication networks',   2),
('business informatics', 'enterprise systems and digital transformation', 3);

INSERT INTO Program (name, degree_level, total_credit_hours, description, dept_id) VALUES
('bsc computer science and engineering', 'bachelor', 144, 'five year bachelor program with a german curriculum', 1),
 ('bsc software engineering','bachelor',144,'bachelor program focused on building large software systems', 2),
('bsc mechatronics engineering',   'bachelor', 150, 'bachelor program combining mechanics, electronics and control', 3),
  ('msc data science', 'master', 90,'master program in machine learning and data engineering', 1),
('bsc business informatics', 'bachelor', 140, 'bachelor program linking it with business processes',5);

INSERT INTO Course (code, title, credit_hours, [level], program_id) VALUES
('csen102', 'introduction to computer programming', 4, 1, 1),
   ('csen202','data structures and algorithms',4,2,1),
('csen501', 'databases', 4, 3, 1),
('csen503',   'design and analysis of algorithms', 4, 3, 1),
  ('csen604', 'machine learning', 4, 4, 1),
('seng201','software engineering i', 4, 2, 2),
('seng402', 'software architecture',4, 4, 2),
     ('mctr101', 'introduction to mechatronics', 4, 1, 3),
('dsen701','advanced machine learning', 6, 5, 4),
('binf201', 'enterprise information systems', 4, 2, 5);

INSERT INTO Prerequisite (course_id, prereq_course_id) VALUES
(2, 1), (3,2),   (4, 2), (5, 4),
  (7, 6),(9, 5);

INSERT INTO Field (name, description) VALUES
('artificial intelligence', 'machine learning, computer vision and language technology'),
   ('software engineering','design, testing and maintenance of software systems'),
('robotics', 'robots, automation and autonomous machines'),
  ('data management', 'databases and large scale data processing'),
('business informatics',   'information systems in organisations');

INSERT INTO Research_Area (name, description, field_id) VALUES
('machine learning', 'learning algorithms and statistical models', 1),
  ('natural language processing','machine understanding of arabic, english and german text',1),
('computer vision', 'image and video understanding', 1),
   ('software testing', 'automated testing and quality assurance', 2),
('autonomous systems','self driving vehicles and mobile robots', 3),
  ('big data analytics', 'analysis of very large datasets', 4),
('enterprise systems',   'erp and business process systems', 5);

INSERT INTO Skill (name, category, description) VALUES
('python', 'programming', 'python programming'),
  ('sql','programming','writing queries and designing relational databases'),
('java', 'programming',   'object oriented programming in java'),
 ('teamwork', 'soft skill', 'working in a project team'),
('data analysis','analytical', 'cleaning, exploring and visualising data'),
  ('machine learning', 'technical', 'training and evaluating machine learning models'),
('c++',   'programming', 'c++ programming');

INSERT INTO Program_Field (program_id, field_id) VALUES
(1, 1), (1,2), (1, 4),   (2, 2),
 (3, 3), (4,1),(4, 4), (5, 5);

INSERT INTO University (name, country, city, description) VALUES
('german international university', 'egypt', 'new administrative capital', 'private university in egypt offering german accredited programs in cooperation with german universities'),
  ('technical university of munich','germany','munich', 'leading technical university in bavaria'),
('university of stuttgart', 'germany',   'stuttgart', 'research university with strong engineering faculties'),
    ('rwth aachen university', 'germany', 'aachen','large technical university in north rhine-westphalia'),
('reutlingen university', 'germany', 'reutlingen', 'university of applied sciences with a business and technology focus');

INSERT INTO GIU (uni_id) VALUES (1);

INSERT INTO Partner_University (uni_id, partnership_status, contact_info) VALUES
(2, 'active', 'international@tum.de'),
   (3,'active','international@uni-stuttgart.de'),
(4, 'active', 'international@rwth-aachen.de'),
  (5, 'active',   'international@reutlingen-university.de');

INSERT INTO Partner_Department (name, description, partner_uni_id) VALUES
('tum school of computation, information and technology', 'computer science, informatics and data engineering', 2),
  ('faculty of mechanical engineering','mechanical engineering and robotics research',3),
('department of computer science', 'computer science teaching and research', 4),
   ('esb business school', 'business and management studies',5),
('department of electrical and computer engineering', 'electronics and embedded systems', 2);

INSERT INTO Partner_Program (name, degree_level, description, pdept_id) VALUES
('msc informatics', 'master', 'master program in informatics', 1),
  ('msc robotics','master','master program in robotics and autonomous systems', 2),
('bsc computer science',   'bachelor', 'bachelor program in computer science', 3),
 ('msc international business informatics', 'master', 'master program in business informatics',4),
('msc data engineering and analytics', 'master','master program in data engineering', 1);

INSERT INTO Partner_Program_Field (pprog_id, field_id) VALUES
(1, 1),   (2, 3), (3,1),
(4, 5), (5, 4);

INSERT INTO Person (full_name, email, phone, account_status) VALUES
('ahmed mohamed hassan', 'ahmed.hassan@student.giu-uni.de', '01001234567', 'active'),
  ('mariam khaled farouk','mariam.farouk@student.giu-uni.de','01012345678','active'),
('omar nabil sharaf', 'omar.sharaf@student.giu-uni.de',   '01023456789', 'active'),
('salma adel younis', 'salma.younis@student.giu-uni.de', '01034567890','active'),
   ('youssef tarek el-sayed', 'youssef.elsayed@student.giu-uni.de', '01045678901', 'active'),
('nour ibrahim gamal','nour.gamal@student.giu-uni.de', '01056789012', 'inactive'),
  ('dr. hany mostafa', 'hany.mostafa@giu-uni.de', '01067890123', 'active'),
('dr. rana fathy', 'rana.fathy@giu-uni.de',   '01078901234','active'),
 ('dr. karim samir', 'karim.samir@giu-uni.de', '01089012345', 'active'),
('dr. dina mahmoud','dina.mahmoud@giu-uni.de', '01090123456', 'active'),
   ('prof. klaus weber', 'klaus.weber@tum.de', '+49891234567', 'active'),
('prof. anna schmidt', 'anna.schmidt@uni-stuttgart.de','+49711234567','active'),
  ('prof. markus braun', 'markus.braun@rwth-aachen.de', '+492411234567', 'active'),
('laila mansour', 'laila.mansour@valeo.com',   '01101234567', 'active'),
('peter mueller', 'peter.mueller@bosch.com', '+49711811234', 'active');

INSERT INTO Student (person_id, student_no, current_semester, gpa, language_level, cv, program_id) VALUES
(1, '11001234', 7, 3.60, 'b2', 'cv/ahmed_hassan.pdf', 1),
   (2,'11001378',5,3.85,'c1','cv/mariam_farouk.pdf',1),
(3, '11002045', 6, 3.20, 'b1', 'cv/omar_sharaf.pdf',   2),
  (4, '11002290', 3, 3.75, 'b2','cv/salma_younis.pdf', 4),
(5,'11002517', 4, 2.90, 'a2', 'cv/youssef_elsayed.pdf', 3),
 (6, '11002833', 6, 3.40,'b2', 'cv/nour_gamal.pdf', 5);

INSERT INTO Student_Interest (person_id, interest) VALUES
(1, 'machine learning'), (1,'chess'),
  (2, 'natural language processing'),(2, 'reading'),
(3, 'web development'),
   (4,'data science'), (4, 'photography'),
(5, 'robotics'),
 (6, 'business analytics');

INSERT INTO GIU_Academic (person_id, academic_rank, dept_id) VALUES
(7, 'professor', 1),
   (8,'associate professor',2),
(9, 'assistant professor', 3),
  (10, 'associate professor',1);

INSERT INTO Partner_Professor (person_id, title, pdept_id) VALUES
(11, 'professor', 1),
  (12,'professor', 2),
(13,   'associate professor', 3);

INSERT INTO Company_Rep (person_id, company_name, sector, position, location) VALUES
(14, 'valeo egypt', 'automotive','hr manager', 'cairo'),
   (15, 'bosch engineering gmbh','automotive', 'head of talent','abstatt');

INSERT INTO Topic_Provider (person_id) VALUES (7), (8),   (11), (14);

INSERT INTO Interviewer (role, person_id) VALUES
('panel chair', 7),
  ('technical interviewer',8),
('industry interviewer', 14),
   ('academic interviewer', 11);

INSERT INTO Completed_Course (student_id, course_id) VALUES
(1, 1), (1,2),(1, 3), (1, 4),
  (2, 1), (2, 2), (2,3), (2, 4), (2, 5),
(3, 1),   (3, 2), (3, 6),
(4, 5),
  (5, 8),
(6,3), (6, 10);

INSERT INTO Student_Skill (student_id, skill_id) VALUES
(1, 1), (1, 2),   (1, 5),
 (2, 1), (2,2), (2, 5), (2, 6),
(3, 1),(3, 2), (3, 3),
   (4, 1), (4, 5), (4,6),
(5, 7),
  (6, 2), (6, 5);

INSERT INTO GIU_Interest (academic_id, area_id) VALUES
(7, 1), (7,2),   (8, 4), (9, 5), (10,1), (10, 6);

INSERT INTO PP_Interest (partner_prof_id, area_id) VALUES
(11, 1), (11, 2),(12, 5),   (13, 1), (13,6);

INSERT INTO Cooperation_Agreement (title, scope, start_date, end_date, status, partner_uni_id, coordinator_id) VALUES
('giu - tum semester exchange', 'semester exchange for computer science and software engineering students', '2025-01-01', '2027-12-31', 'active', 2, 7),
  ('giu - stuttgart autonomous systems research','joint research on autonomous vehicles and mobile robots','2024-09-01','2026-12-31','active',3,9),
('giu - rwth aachen general mou', 'general academic cooperation and staff exchange', '2023-06-01',   '2026-05-31', 'expired', 4, 7),
   ('giu - reutlingen double degree', 'double degree for computer science and business informatics students', '2025-03-01', '2028-02-28', 'active', 5, 10),
('giu - tum machine learning research', 'joint research in machine learning and medical imaging','2025-09-01', '2027-08-31','active', 2, 10);

INSERT INTO Mobility_Agreement (agreement_id, exchange_terms, double_degree_terms, seat_quota, tuition_arrangement) VALUES
(1, 'one semester exchange, credits transferred after approval by the program coordinator', NULL, 20, 'students keep paying tuition at giu'),
   (4,'exchange allowed in the last two years of study', 'two years at each university, both degrees awarded',10,'reduced tuition at reutlingen university');

INSERT INTO Mob_Agr_Semester (agreement_id, semester) VALUES
(1, 'fall 2026'),   (1, 'spring 2027'), (4,'fall 2026');

INSERT INTO Mob_Agr_Program (agreement_id, program_id) VALUES
(1, 1), (1,2),(4, 1),   (4, 5);

INSERT INTO Research_Agreement (agreement_id, ip_terms, funding_framework) VALUES
(2, 'results are owned jointly by both universities','co-funded by giu and the university of stuttgart'),
   (5, 'joint ownership, publications carry both affiliations', 'funded through external grants');

INSERT INTO Res_Agr_Area (agreement_id, area_id) VALUES
(2, 5),   (5, 1),(5, 2);

INSERT INTO General_MoU (agreement_id, intent, collab_scope, renewal_terms) VALUES
(3, 'strengthen academic ties between giu and rwth aachen',  'staff exchange and joint academic events','renewable every three years by mutual consent');

INSERT INTO Opportunity (title, description, type, status, app_open_date, app_close_date, capacity, location_mode, agreement_id, offered_by_rep_id) VALUES
('deep learning for medical image segmentation', 'bachelor or master thesis on segmentation of chest x-ray images', 'thesis', 'open', '2026-09-01', '2026-12-15', 2, 'hybrid', 5, NULL),
  ('path planning for autonomous vehicles','thesis on motion planning for vehicles in dense urban traffic','thesis','open','2026-10-01','2026-12-31',1,'on-site',2,14),
('neural machine translation for arabic and german',   'thesis on translation between arabic and german using transformer models', 'thesis', 'open', '2026-10-01', '2026-12-20', 1, 'online', 5, NULL),
 ('scalable streaming data pipelines', 'thesis on building fault tolerant streaming pipelines', 'thesis','closed', '2026-03-01', '2026-05-30', 1, 'hybrid', 5, NULL),
('fall 2026 exchange at tu munich', 'one semester exchange at the technical university of munich', 'mobility', 'open', '2026-10-01',   '2026-11-20', 5, 'on-site', 1, NULL),
  ('double degree at reutlingen university', 'double degree in computer science and business informatics','mobility', 'open','2026-09-15','2027-01-15', 3,'on-site', 4, NULL),
('munich summer school on artificial intelligence 2027', 'six week summer school on modern machine learning', 'short program', 'open', '2026-10-15', '2026-11-30', 30, 'on-site', 1, NULL),
   ('winter workshop on robotics and automation', 'two week hands on workshop at the giu campus', 'short program', 'open', '2026-10-01', '2026-12-01', 20, 'on-site', 2, 15);

INSERT INTO Thesis_Topic (opp_id, expected_outcomes, funding_info, travel_info, accommodation_info, provider_id, supervisor_id, co_supervisor_id) VALUES
(1, 'a working segmentation model and a short conference paper', 'monthly stipend from the research project', 'two week research visit to tum', 'student housing in munich', 7, 7, 11),
  (2,'a planner prototype evaluated in simulation', 'funded by valeo egypt','no travel','not needed',14,9,12),
(3, 'a translation system with an evaluation report',   'no funding', 'no travel', 'not needed', 7, 8, NULL),
 (4, 'a pipeline prototype and a benchmark report', 'no funding','no travel', 'not needed', 11, 10, 13);

INSERT INTO Thesis_Area (opp_id, area_id) VALUES
(1, 1), (1,3),   (2, 5), (3, 2),(4, 6);

INSERT INTO Short_Program (opp_id, duration, location, hosting_arrangements, host_uni_id) VALUES
(7, '6 weeks', 'munich', 'accommodation in student dormitories', 2),
   (8,'2 weeks','new administrative capital','held on the giu campus',1);

INSERT INTO Mobility_Program (opp_id, mobility_type, duration, sending_uni_id, host_uni_id) VALUES
(5, 'exchange', '1 semester', 1, 2),
  (6, 'double degree','4 semesters',1, 5);

INSERT INTO Opp_Language_Req (opp_id, language_req) VALUES
(1, 'english b2'),   (5, 'german b1'), (6,'german b2'), (7, 'english b2');

INSERT INTO Opp_Relevant_Date (opp_id, relevant_date) VALUES
(5, '2027-03-01'),(7, '2027-07-01');

INSERT INTO Opp_Field (opp_id, field_id) VALUES
(1, 1), (2,3),   (3, 1), (4, 4),
 (5, 1),(6, 5), (7, 1), (8,3);

INSERT INTO Opp_Eligible_Program (opp_id, program_id) VALUES
(1, 1), (1, 4),
  (2,1), (2, 3),
(3, 1),(3, 2), (3, 4),
   (4, 1), (4,4),
(5, 1), (5, 2),
 (6, 1),(6, 5),
(7, 1), (7, 2), (7,4),
   (8, 3);

INSERT INTO Opp_Prereq_Course (opp_id, course_id) VALUES
(1, 5), (2,4), (3, 2),   (5, 3), (6,3);

INSERT INTO Opp_Skill (opp_id, skill_id) VALUES
(1, 1),(1, 6), (2, 7),   (3, 1), (5,2), (7, 1);

INSERT INTO Application (app_date, status, decision_date, info, student_id, opp_id) VALUES
('2026-10-05', 'pending', NULL, 'i want to take distributed systems courses at tum during my seventh semester', 1, 5),
   ('2026-09-20','accepted','2026-10-10','i worked on a chest x-ray classifier in my machine learning course project', 2, 1),
('2026-10-02', 'accepted', '2026-10-18', 'i want to improve my german and study at a german university',2, 5),
  ('2026-10-12', 'pending', NULL,'i enjoyed the nlp elective and want to work on translation', 3, 3),
('2026-09-25', 'rejected',   '2026-10-12', 'my bachelor project was on data analysis for hospital records', 4, 1),
 ('2026-10-10','pending', NULL, 'i am interested in the double degree because of my business informatics courses', 6, 6),
('2026-10-20', 'pending', NULL, 'i would like to attend the summer school to learn deep learning',1, 7),
   ('2026-10-08', 'accepted', '2026-10-15','i built a line following robot in the mechatronics lab', 5, 8);

INSERT INTO Application_Document (app_id, doc_type, file_ref, upload_date) VALUES
(1, 'cv', 'docs/ahmed_hassan_cv.pdf', '2026-10-05'),
  (1,'transcript','docs/ahmed_hassan_transcript.pdf','2026-10-05'),
(2, 'cv',   'docs/mariam_farouk_cv.pdf', '2026-09-20'),
 (2, 'motivation letter', 'docs/mariam_farouk_letter.pdf','2026-09-21'),
(3, 'cv', 'docs/mariam_farouk_cv.pdf', '2026-10-02'),
   (4,'cv', 'docs/omar_sharaf_cv.pdf', '2026-10-12'),
(8, 'cv','docs/youssef_elsayed_cv.pdf', '2026-10-08');

INSERT INTO Interview ([date], [time], location_mode, outcome, notes, app_id) VALUES
('2026-10-01', '10:00', 'online', 'passed', 'strong background in machine learning and clear research plan', 2),
   ('2026-11-15','11:30','on-site','pending', NULL, 4),
('2026-10-05', '09:00', 'online',   'failed', 'limited experience with image segmentation', 5);

INSERT INTO Conducts_Interview (interviewer_id, interview_id) VALUES
(1, 1), (4,1),   (2, 2), (1,3);

INSERT INTO Participation (status, start_date, end_date, app_id) VALUES
('active', '2027-02-01', '2027-07-31', 3),
  ('active','2027-01-10','2027-01-24', 8);

INSERT INTO Mobility (part_id, pre_travel_status, during_status, post_status, final_outcome, host_uni_id) VALUES
(1, 'documents submitted',   'not started', 'not started', NULL, 2);

INSERT INTO Program_Participation (part_id, payment_status, visa_status, travel_status) VALUES
(2, 'paid', 'not required',  'not needed');

INSERT INTO Course_Equivalency (part_id, host_course_title, host_credits, transferred_credits, approval_status, giu_course_id) VALUES
(1, 'distributed systems', 6.0, 5.0, 'approved', 4),
   (1,'advanced database systems',6.0, 6.0,'pending', 3);

INSERT INTO Professor_Visit (start_date, end_date, purpose, travel_arr, accommodation_arr, status, follow_up_report, partner_prof_id, host_faculty_id, coordinator_id, agreement_id) VALUES
('2026-11-20', '2026-11-25', 'guest lecture and research meetings', 'flight booked by giu', 'hotel near the campus', 'scheduled', NULL, 11, 1, 10, 5),
  ('2026-03-10','2026-03-14','joint workshop on autonomous systems','flight booked by the university of stuttgart', 'giu guest house','completed', 'the workshop went well and two master theses were agreed', 12, 2, 9, 2),
('2026-12-05', '2026-12-08',   'curriculum alignment meetings for the exchange program', 'to be arranged','to be arranged', 'requested', NULL, 11, 1, 7, 1);

INSERT INTO Visit_Outcome (visit_id, outcome) VALUES
(2, 'agreed to co-supervise two master theses'),
   (2,'planned a joint grant proposal');

INSERT INTO Agenda_Item (visit_id, seq_no, activity_type, title, date_time, location, audience) VALUES
(1, 1, 'lecture', 'introduction to federated learning', '2026-11-21 10:00', 'lecture hall a', 'students'),
  (1, 2,'meeting','research collaboration meeting','2026-11-22 13:00','meeting room 3', 'faculty'),
(2, 1, 'workshop',   'autonomous systems workshop', '2026-03-11 09:00', 'robotics lab', 'researchers');

INSERT INTO Research_Project (title, description, status, start_date, end_date, res_agreement_id) VALUES
('federated learning for healthcare imaging', 'training models on medical images that stay in different hospitals', 'active', '2025-10-01', '2027-09-30', 5),
   ('safe navigation for autonomous robots','safety guarantees for robot navigation in shared spaces', 'active','2024-10-01', '2026-12-31', 2);

INSERT INTO Project_Deadline (project_id, deadline) VALUES
(1, '2026-12-01'),   (1,'2027-03-15'), (2, '2026-11-30');

INSERT INTO Project_Area (project_id, area_id) VALUES
(1, 1), (1,3),(2, 5);

INSERT INTO GIU_Participates (academic_id, project_id, role) VALUES
(10, 1, 'principal investigator'),   (7, 1,'researcher'), (9, 2, 'principal investigator');

INSERT INTO PP_Participates (partner_prof_id, project_id, role) VALUES
(11, 1, 'co-investigator'),  (12,2, 'co-investigator');

INSERT INTO Research_Output (type, title, [date], reference, status, project_id) VALUES
('publication', 'federated segmentation of chest x-rays', '2026-06-15', 'doi:10.1000/fl-2026-01', 'published', 1),
   ('dataset','anonymised chest x-ray benchmark','2026-08-01','repo/giu/datasets/cxr-bench','draft', 1),
('report', 'interim report year 2',   '2026-04-10', 'reports/safe-nav-y2', 'submitted', 2);

INSERT INTO Funding_Opportunity (name, agency, type, amount, deadline, eligibility_conditions, status) VALUES
('daad study scholarship', 'daad', 'scholarship', 10000.00, '2026-12-15', 'enrolled students with a gpa above 3.0', 'open'),
  ('erasmus+ mobility grant','european union','grant',6000.00,'2026-11-30','students on an approved exchange','open'),
('horizon europe research grant', 'european commission',   'research grant', 250000.00, '2027-02-01', 'joint research projects with european partners', 'open'),
 ('industry thesis award', 'valeo egypt', 'award', 2000.00,'2026-10-01', 'thesis students working on an industry topic', 'closed');

INSERT INTO Project_Targets_Fund (project_id, fund_id) VALUES
(1, 3),   (2,3);

INSERT INTO Fund_Supports_Mobility (fund_id, part_id) VALUES
(1, 1),(2, 1);

INSERT INTO Notification (message, [timestamp], category, urgency, read_status, recipient_id) VALUES
('your application for deep learning for medical image segmentation is now accepted.', '2026-10-10 09:30', 'application', 'normal', 1, 2),
   ('your application for fall 2026 exchange at tu munich is now accepted.','2026-10-18 11:00','application', 'normal', 0, 2),
('interview scheduled for 2026-11-15 at 11:30.', '2026-11-01 08:15', 'interview','high', 0, 3),
  ('a new visit has been scheduled for 2026-11-20.', '2026-11-02 14:00', 'visit', 'normal',0, 10);
GO