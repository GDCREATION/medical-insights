-- Migration: 008_insert_mock_data.sql
-- Description: Inserts realistic mock data for testing and development
-- Created: 2024

BEGIN;

-- ============================================================================
-- PATIENTS (10 records)
-- ============================================================================
INSERT INTO patients (patient_id, first_name, last_name, date_of_birth, sex_at_birth, gender_identity, phone_tokenized, email_tokenized, address_line1, address_line2, city, state, postal_code, country, is_active, created_at, updated_at) VALUES
('PAT001', 'John', 'Smith', '1985-03-15', 'Male', 'Male', 'TOKEN_PHONE_001', 'TOKEN_EMAIL_001', '123 Main Street', 'Apt 4B', 'Boston', 'MA', '02101', 'USA', true, '2024-01-10 08:00:00+00', '2024-01-10 08:00:00+00'),
('PAT002', 'Sarah', 'Johnson', '1992-07-22', 'Female', 'Female', 'TOKEN_PHONE_002', 'TOKEN_EMAIL_002', '456 Oak Avenue', NULL, 'New York', 'NY', '10001', 'USA', true, '2024-01-12 09:15:00+00', '2024-01-12 09:15:00+00'),
('PAT003', 'Michael', 'Chen', '1978-11-08', 'Male', 'Male', 'TOKEN_PHONE_003', 'TOKEN_EMAIL_003', '789 Pine Road', 'Suite 200', 'San Francisco', 'CA', '94102', 'USA', true, '2024-01-15 10:30:00+00', '2024-01-15 10:30:00+00'),
('PAT004', 'Emily', 'Rodriguez', '1995-02-28', 'Female', 'Female', 'TOKEN_PHONE_004', 'TOKEN_EMAIL_004', '321 Elm Street', NULL, 'Chicago', 'IL', '60601', 'USA', true, '2024-01-18 11:45:00+00', '2024-01-18 11:45:00+00'),
('PAT005', 'David', 'Williams', '1980-09-14', 'Male', 'Male', 'TOKEN_PHONE_005', 'TOKEN_EMAIL_005', '654 Maple Drive', 'Unit 5', 'Seattle', 'WA', '98101', 'USA', true, '2024-01-20 13:00:00+00', '2024-01-20 13:00:00+00'),
('PAT006', 'Jessica', 'Brown', '1988-05-03', 'Female', 'Female', 'TOKEN_PHONE_006', 'TOKEN_EMAIL_006', '987 Cedar Lane', NULL, 'Austin', 'TX', '78701', 'USA', true, '2024-01-22 14:20:00+00', '2024-01-22 14:20:00+00'),
('PAT007', 'Robert', 'Taylor', '1975-12-19', 'Male', 'Male', 'TOKEN_PHONE_007', 'TOKEN_EMAIL_007', '147 Birch Boulevard', 'Apt 12', 'Denver', 'CO', '80201', 'USA', true, '2024-01-25 15:30:00+00', '2024-01-25 15:30:00+00'),
('PAT008', 'Amanda', 'Martinez', '1990-04-07', 'Female', 'Female', 'TOKEN_PHONE_008', 'TOKEN_EMAIL_008', '258 Spruce Court', NULL, 'Miami', 'FL', '33101', 'USA', true, '2024-01-28 16:45:00+00', '2024-01-28 16:45:00+00'),
('PAT009', 'James', 'Anderson', '1983-08-25', 'Male', 'Male', 'TOKEN_PHONE_009', 'TOKEN_EMAIL_009', '369 Willow Way', 'Floor 3', 'Portland', 'OR', '97201', 'USA', false, '2024-02-01 08:00:00+00', '2024-02-15 10:00:00+00'),
('PAT010', 'Lisa', 'Garcia', '1997-01-11', 'Female', 'Female', 'TOKEN_PHONE_010', 'TOKEN_EMAIL_010', '741 Ash Street', NULL, 'Phoenix', 'AZ', '85001', 'USA', true, '2024-02-05 09:15:00+00', '2024-02-05 09:15:00+00');

-- ============================================================================
-- ENCOUNTERS (18 records)
-- ============================================================================
INSERT INTO encounters (id, patient_id, consent_token, encounter_ref, status, source_channel, created_at, updated_at, expires_at) VALUES
('ENC001', 'PAT001', 'CONSENT_TOKEN_001', 'ENC-REF-001', 'completed', 'web', '2024-02-10 08:00:00+00', '2024-02-10 12:30:00+00', '2024-02-11 08:00:00+00'),
('ENC002', 'PAT002', 'CONSENT_TOKEN_002', 'ENC-REF-002', 'reviewed', 'mobile', '2024-02-11 09:15:00+00', '2024-02-11 14:20:00+00', '2024-02-12 09:15:00+00'),
('ENC003', 'PAT003', 'CONSENT_TOKEN_003', 'ENC-REF-003', 'triaged', 'web', '2024-02-12 10:30:00+00', '2024-02-12 11:45:00+00', '2024-02-13 10:30:00+00'),
('ENC004', 'PAT001', 'CONSENT_TOKEN_004', 'ENC-REF-004', 'symptoms_captured', 'mobile', '2024-02-13 11:00:00+00', '2024-02-13 11:30:00+00', '2024-02-14 11:00:00+00'),
('ENC005', 'PAT004', 'CONSENT_TOKEN_005', 'ENC-REF-005', 'completed', 'web', '2024-02-14 12:15:00+00', '2024-02-14 16:00:00+00', '2024-02-15 12:15:00+00'),
('ENC006', 'PAT005', 'CONSENT_TOKEN_006', 'ENC-REF-006', 'reviewed', 'web', '2024-02-15 13:30:00+00', '2024-02-15 17:45:00+00', '2024-02-16 13:30:00+00'),
('ENC007', 'PAT006', 'CONSENT_TOKEN_007', 'ENC-REF-007', 'triaged', 'mobile', '2024-02-16 14:45:00+00', '2024-02-16 15:20:00+00', '2024-02-17 14:45:00+00'),
('ENC008', 'PAT002', 'CONSENT_TOKEN_008', 'ENC-REF-008', 'created', 'web', '2024-02-17 15:00:00+00', '2024-02-17 15:00:00+00', '2024-02-18 15:00:00+00'),
('ENC009', 'PAT007', 'CONSENT_TOKEN_009', 'ENC-REF-009', 'completed', 'mobile', '2024-02-18 16:15:00+00', '2024-02-18 20:30:00+00', '2024-02-19 16:15:00+00'),
('ENC010', 'PAT008', 'CONSENT_TOKEN_010', 'ENC-REF-010', 'symptoms_captured', 'web', '2024-02-19 17:30:00+00', '2024-02-19 18:00:00+00', '2024-02-20 17:30:00+00'),
('ENC011', 'PAT010', 'CONSENT_TOKEN_011', 'ENC-REF-011', 'triaged', 'mobile', '2024-02-20 18:45:00+00', '2024-02-20 19:15:00+00', '2024-02-21 18:45:00+00'),
('ENC012', 'PAT003', 'CONSENT_TOKEN_012', 'ENC-REF-012', 'reviewed', 'web', '2024-02-21 19:00:00+00', '2024-02-21 22:00:00+00', '2024-02-22 19:00:00+00'),
('ENC013', 'PAT004', 'CONSENT_TOKEN_013', 'ENC-REF-013', 'expired', 'mobile', '2024-02-10 08:00:00+00', '2024-02-10 08:30:00+00', '2024-02-11 08:00:00+00'),
('ENC014', 'PAT005', 'CONSENT_TOKEN_014', 'ENC-REF-014', 'cancelled', 'web', '2024-02-22 20:15:00+00', '2024-02-22 20:20:00+00', '2024-02-23 20:15:00+00'),
('ENC015', 'PAT006', 'CONSENT_TOKEN_015', 'ENC-REF-015', 'triaged', 'mobile', '2024-02-23 21:30:00+00', '2024-02-23 22:00:00+00', '2024-02-24 21:30:00+00'),
('ENC016', 'PAT007', 'CONSENT_TOKEN_016', 'ENC-REF-016', 'symptoms_captured', 'web', '2024-02-24 22:45:00+00', '2024-02-24 23:15:00+00', '2024-02-25 22:45:00+00'),
('ENC017', 'PAT008', 'CONSENT_TOKEN_017', 'ENC-REF-017', 'completed', 'mobile', '2024-02-25 23:00:00+00', '2024-02-26 03:00:00+00', '2024-02-26 23:00:00+00'),
('ENC018', 'PAT010', 'CONSENT_TOKEN_018', 'ENC-REF-018', 'reviewed', 'web', '2024-02-26 09:00:00+00', '2024-02-26 13:30:00+00', NULL);

-- ============================================================================
-- SYMPTOM_PAYLOADS (12 records)
-- ============================================================================
INSERT INTO symptom_payloads (encounter_id, symptoms_json, vitals_json, risk_factors_json, free_text, pregnancy_flag, language_code, captured_at) VALUES
('ENC001', '{"fever": true, "temperature": 38.5, "cough": true, "duration_days": 3, "severity": "moderate"}', '{"blood_pressure_systolic": 120, "blood_pressure_diastolic": 80, "heart_rate": 88, "temperature_celsius": 38.5, "oxygen_saturation": 98}', '{"diabetes": false, "hypertension": false, "smoking": false, "allergies": ["penicillin"]}', 'Patient reports fever and persistent cough for 3 days. Feeling tired and achy.', false, 'en', '2024-02-10 08:30:00+00'),
('ENC002', '{"chest_pain": true, "shortness_of_breath": true, "duration_hours": 2, "severity": "severe", "radiating": true}', '{"blood_pressure_systolic": 145, "blood_pressure_diastolic": 95, "heart_rate": 110, "temperature_celsius": 37.2, "oxygen_saturation": 94}', '{"diabetes": true, "hypertension": true, "smoking": true, "family_history_heart_disease": true, "medications": ["metformin", "lisinopril"]}', 'Severe chest pain started 2 hours ago, radiating to left arm. Shortness of breath. History of diabetes and hypertension.', false, 'en', '2024-02-11 09:45:00+00'),
('ENC003', '{"headache": true, "nausea": true, "vomiting": true, "duration_hours": 6, "severity": "moderate"}', '{"blood_pressure_systolic": 130, "blood_pressure_diastolic": 85, "heart_rate": 75, "temperature_celsius": 36.8, "oxygen_saturation": 99}', '{"migraine_history": true, "medications": ["sumatriptan"]}', 'Severe headache with nausea and vomiting. Patient has history of migraines.', false, 'en', '2024-02-12 10:45:00+00'),
('ENC004', '{"sore_throat": true, "fever": true, "temperature": 37.8, "duration_days": 2, "severity": "mild"}', '{"blood_pressure_systolic": 118, "blood_pressure_diastolic": 78, "heart_rate": 82, "temperature_celsius": 37.8, "oxygen_saturation": 98}', '{"allergies": ["sulfa"]}', 'Sore throat and low-grade fever for 2 days. No difficulty swallowing.', false, 'en', '2024-02-13 11:15:00+00'),
('ENC005', '{"abdominal_pain": true, "nausea": true, "duration_hours": 12, "severity": "moderate", "location": "right_lower_quadrant"}', '{"blood_pressure_systolic": 125, "blood_pressure_diastolic": 82, "heart_rate": 90, "temperature_celsius": 37.5, "oxygen_saturation": 98}', '{"appendectomy": false, "allergies": []}', 'Abdominal pain in right lower quadrant for 12 hours. Nausea present. No vomiting.', false, 'en', '2024-02-14 12:30:00+00'),
('ENC006', '{"dizziness": true, "fatigue": true, "duration_days": 5, "severity": "mild"}', '{"blood_pressure_systolic": 100, "blood_pressure_diastolic": 65, "heart_rate": 68, "temperature_celsius": 36.9, "oxygen_saturation": 99}', '{"anemia": true, "medications": ["iron_supplement"]}', 'Feeling dizzy and tired for past 5 days. Known history of anemia.', false, 'en', '2024-02-15 13:45:00+00'),
('ENC007', '{"rash": true, "itching": true, "duration_days": 3, "severity": "moderate", "location": "arms_and_chest"}', '{"blood_pressure_systolic": 122, "blood_pressure_diastolic": 80, "heart_rate": 76, "temperature_celsius": 37.1, "oxygen_saturation": 98}', '{"eczema": false, "allergies": ["latex", "nickel"]}', 'Rash on arms and chest with itching for 3 days. No known allergies to new products.', false, 'en', '2024-02-16 15:00:00+00'),
('ENC009', '{"back_pain": true, "duration_days": 7, "severity": "moderate", "location": "lower_back", "worse_with_movement": true}', '{"blood_pressure_systolic": 128, "blood_pressure_diastolic": 84, "heart_rate": 72, "temperature_celsius": 36.7, "oxygen_saturation": 99}', '{"previous_back_surgery": false, "medications": ["ibuprofen"]}', 'Lower back pain for 7 days, worse with movement. No radiation to legs.', false, 'en', '2024-02-18 16:30:00+00'),
('ENC010', '{"fever": true, "temperature": 39.2, "cough": true, "shortness_of_breath": true, "duration_days": 4, "severity": "severe"}', '{"blood_pressure_systolic": 135, "blood_pressure_diastolic": 88, "heart_rate": 105, "temperature_celsius": 39.2, "oxygen_saturation": 92}', '{"asthma": true, "copd": false, "smoking": false, "medications": ["albuterol_inhaler"]}', 'High fever, persistent cough, and increasing shortness of breath. Patient has asthma.', false, 'en', '2024-02-19 17:45:00+00'),
('ENC011', '{"nausea": true, "vomiting": true, "abdominal_pain": true, "duration_hours": 8, "severity": "moderate", "pregnancy_suspected": true}', '{"blood_pressure_systolic": 115, "blood_pressure_diastolic": 75, "heart_rate": 85, "temperature_celsius": 37.0, "oxygen_saturation": 98}', '{"pregnancy": true, "gestational_age_weeks": 12, "allergies": []}', 'Nausea and vomiting with mild abdominal pain. Patient is 12 weeks pregnant.', true, 'en', '2024-02-20 19:00:00+00'),
('ENC012', '{"joint_pain": true, "swelling": true, "duration_weeks": 2, "severity": "moderate", "affected_joints": ["knees", "wrists"]}', '{"blood_pressure_systolic": 130, "blood_pressure_diastolic": 85, "heart_rate": 78, "temperature_celsius": 37.3, "oxygen_saturation": 98}', '{"rheumatoid_arthritis": false, "medications": ["naproxen"]}', 'Joint pain and swelling in knees and wrists for 2 weeks.', false, 'en', '2024-02-21 19:30:00+00'),
('ENC015', '{"ear_pain": true, "hearing_loss": true, "duration_days": 2, "severity": "moderate", "ear_discharge": false}', '{"blood_pressure_systolic": 120, "blood_pressure_diastolic": 80, "heart_rate": 74, "temperature_celsius": 37.4, "oxygen_saturation": 99}', '{"recurrent_ear_infections": true, "allergies": []}', 'Ear pain and decreased hearing in right ear for 2 days. History of ear infections.', false, 'en', '2024-02-23 21:45:00+00'),
('ENC016', '{"urinary_frequency": true, "burning_sensation": true, "duration_days": 3, "severity": "moderate"}', '{"blood_pressure_systolic": 125, "blood_pressure_diastolic": 82, "heart_rate": 80, "temperature_celsius": 37.6, "oxygen_saturation": 98}', '{"uti_history": true, "diabetes": false, "allergies": []}', 'Frequent urination with burning sensation for 3 days. History of UTIs.', false, 'en', '2024-02-24 23:00:00+00'),
('ENC017', '{"chest_tightness": true, "wheezing": true, "duration_hours": 4, "severity": "moderate"}', '{"blood_pressure_systolic": 132, "blood_pressure_diastolic": 86, "heart_rate": 95, "temperature_celsius": 37.0, "oxygen_saturation": 95}', '{"asthma": true, "allergies": ["pollen", "dust"], "medications": ["albuterol_inhaler", "fluticasone"]}', 'Chest tightness and wheezing started 4 hours ago. Patient has asthma and allergies.', false, 'en', '2024-02-25 23:30:00+00');

-- ============================================================================
-- TRIAGE RESULTS (10 records)
-- ============================================================================
INSERT INTO triage_results (encounter_id, acuity, emergency_flag, confidence_score, rationale_internal, clarifying_questions, summary_for_clinician, safety_warnings, model_version, adapter_version, rule_version, trace_id, created_at) VALUES
('ENC001', 'routine', false, 0.85, 'Patient presents with fever and cough consistent with upper respiratory infection. Vital signs stable. No red flags for severe illness.', 'How long has the fever been present? Any difficulty breathing?', '38-year-old male with 3-day history of fever (38.5°C) and cough. Vital signs stable. Likely viral upper respiratory infection. Recommend symptomatic treatment and monitoring.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-001-20240210', '2024-02-10 09:00:00+00'),
('ENC002', 'emergent', true, 0.92, 'Severe chest pain with radiation, shortness of breath, and elevated heart rate in patient with diabetes and hypertension. High suspicion for acute coronary syndrome. Requires immediate evaluation.', 'Is the pain still present? Any history of similar episodes?', '45-year-old female with acute onset severe chest pain radiating to left arm, associated with shortness of breath. History of diabetes and hypertension. Vital signs show tachycardia and elevated BP. EMERGENCY: Rule out acute coronary syndrome. Immediate ED evaluation required.', 'High risk for acute coronary syndrome. Do not delay evaluation.', 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-002-20240211', '2024-02-11 10:00:00+00'),
('ENC003', 'urgent', false, 0.78, 'Severe headache with nausea and vomiting. Patient has migraine history. May need acute migraine treatment. Not immediately life-threatening but requires timely evaluation.', 'Any visual changes? Any neck stiffness?', '46-year-old male with severe headache, nausea, and vomiting. History of migraines. Vital signs normal. Likely migraine but rule out other causes. Urgent evaluation recommended within 4-6 hours.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-003-20240212', '2024-02-12 11:00:00+00'),
('ENC005', 'urgent', false, 0.88, 'Abdominal pain in right lower quadrant with mild fever. Clinical suspicion for appendicitis. Requires surgical evaluation.', 'Any rebound tenderness? Any changes in bowel movements?', '44-year-old female with 12-hour history of right lower quadrant abdominal pain and nausea. Mild fever present. Clinical features suggestive of appendicitis. Urgent surgical evaluation recommended within 4-6 hours.', 'Monitor for signs of peritonitis. Do not give pain medications that may mask symptoms.', 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-005-20240214', '2024-02-14 13:00:00+00'),
('ENC006', 'routine', false, 0.82, 'Dizziness and fatigue in patient with known anemia. Vital signs show mild hypotension. Likely related to anemia. Routine follow-up appropriate.', 'Are you taking iron supplements as prescribed? Any blood loss?', '43-year-old male with 5-day history of dizziness and fatigue. Known anemia. Vital signs show mild hypotension. Likely anemia-related. Routine evaluation and medication review recommended.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-006-20240215', '2024-02-15 14:00:00+00'),
('ENC007', 'routine', false, 0.75, 'Rash with itching. No systemic symptoms. Likely allergic or contact dermatitis. Routine dermatology evaluation appropriate.', 'Any new products, detergents, or medications?', '36-year-old female with 3-day history of rash on arms and chest with itching. No systemic symptoms. Vital signs normal. Likely allergic or contact dermatitis. Routine dermatology evaluation recommended.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-007-20240216', '2024-02-16 15:15:00+00'),
('ENC009', 'non_urgent', false, 0.80, 'Lower back pain for 7 days, worse with movement. No red flags. Likely musculoskeletal. Non-urgent evaluation appropriate.', 'Any numbness or tingling in legs? Any bowel or bladder changes?', '49-year-old male with 7-day history of lower back pain, worse with movement. No neurological symptoms. Vital signs normal. Likely musculoskeletal back pain. Non-urgent evaluation and physical therapy referral recommended.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-009-20240218', '2024-02-18 17:00:00+00'),
('ENC010', 'emergent', true, 0.95, 'High fever, persistent cough, and shortness of breath with decreased oxygen saturation in asthmatic patient. High suspicion for pneumonia or severe asthma exacerbation. Requires immediate evaluation.', 'Is the patient using rescue inhaler? Any improvement?', '28-year-old female with 4-day history of high fever (39.2°C), persistent cough, and increasing shortness of breath. Patient has asthma. Oxygen saturation decreased to 92%. EMERGENCY: Possible pneumonia or severe asthma exacerbation. Immediate ED evaluation required.', 'Monitor oxygen saturation closely. May require supplemental oxygen and bronchodilators.', 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-010-20240219', '2024-02-19 18:00:00+00'),
('ENC011', 'routine', false, 0.70, 'Nausea and vomiting in 12-week pregnant patient. Common in first trimester. Rule out hyperemesis gravidarum. Routine OB evaluation appropriate.', 'How many times per day are you vomiting? Can you keep fluids down?', '27-year-old female, 12 weeks pregnant, with nausea and vomiting. Mild abdominal pain. Common first trimester symptoms but rule out hyperemesis. Routine OB evaluation recommended.', 'Monitor for signs of dehydration. Consider antiemetics if severe.', 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-011-20240220', '2024-02-20 19:15:00+00'),
('ENC015', 'routine', false, 0.77, 'Ear pain and hearing loss. History of ear infections. Likely otitis media. Routine ENT evaluation appropriate.', 'Any ear discharge? Any recent upper respiratory infection?', '33-year-old male with 2-day history of ear pain and decreased hearing in right ear. History of recurrent ear infections. Vital signs show mild fever. Likely otitis media. Routine ENT evaluation recommended.', NULL, 'v2.1.0', 'adapter-v1.3', 'rules-v3.2', 'TRACE-015-20240223', '2024-02-23 22:00:00+00');

-- ============================================================================
-- CLINICIAN REVIEWS (6 records)
-- ============================================================================
INSERT INTO clinician_reviews (encounter_id, decision, override_flag, override_reason, notes, reviewer_id, reviewed_at) VALUES
('ENC001', 'approved', false, NULL, 'Agree with triage assessment. Patient can be managed with symptomatic treatment. Follow-up if symptoms worsen.', 'CLINICIAN_001', '2024-02-10 10:30:00+00'),
('ENC002', 'approved', false, NULL, 'Agree with emergent classification. Patient sent to ED immediately. ECG and cardiac enzymes ordered.', 'CLINICIAN_002', '2024-02-11 11:00:00+00'),
('ENC005', 'overridden', true, 'Patient reports pain has improved significantly. Will monitor as urgent but not immediate surgical consult.', 'Pain has decreased. Patient will follow up if worsens. Changed from urgent to routine follow-up.', 'CLINICIAN_003', '2024-02-14 14:00:00+00'),
('ENC006', 'approved', false, NULL, 'Agree with routine classification. Will check iron levels and adjust supplementation if needed.', 'CLINICIAN_001', '2024-02-15 15:00:00+00'),
('ENC010', 'approved', false, NULL, 'Agree with emergent classification. Patient sent to ED. Chest X-ray and blood work ordered. Started on antibiotics and bronchodilators.', 'CLINICIAN_004', '2024-02-19 19:00:00+00'),
('ENC012', 'needs_more_info', false, NULL, 'Need more details about joint pain pattern and morning stiffness. Requesting additional information from patient.', 'CLINICIAN_002', '2024-02-21 20:00:00+00');

-- ============================================================================
-- ENCOUNTER EVENTS (35 records)
-- ============================================================================
INSERT INTO encounter_events (encounter_id, event_type, actor, details_json, created_at) VALUES
('ENC001', 'encounter_created', 'system', '{"source": "web", "user_agent": "Mozilla/5.0"}', '2024-02-10 08:00:00+00'),
('ENC001', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_001", "method": "digital_signature"}', '2024-02-10 08:01:00+00'),
('ENC001', 'symptoms_captured', 'PAT001', '{"symptoms_count": 3, "vitals_captured": true}', '2024-02-10 08:30:00+00'),
('ENC001', 'triage_initiated', 'system', '{"trigger": "symptoms_captured"}', '2024-02-10 08:31:00+00'),
('ENC001', 'triage_completed', 'system', '{"acuity": "routine", "confidence": 0.85}', '2024-02-10 09:00:00+00'),
('ENC001', 'clinician_review_started', 'CLINICIAN_001', '{"reviewer_id": "CLINICIAN_001"}', '2024-02-10 09:15:00+00'),
('ENC001', 'clinician_review_completed', 'CLINICIAN_001', '{"decision": "approved", "review_duration_seconds": 120}', '2024-02-10 10:30:00+00'),
('ENC001', 'encounter_completed', 'system', '{"final_status": "completed", "total_duration_minutes": 270}', '2024-02-10 12:30:00+00'),
('ENC002', 'encounter_created', 'system', '{"source": "mobile", "app_version": "2.1.0"}', '2024-02-11 09:15:00+00'),
('ENC002', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_002", "method": "digital_signature"}', '2024-02-11 09:16:00+00'),
('ENC002', 'symptoms_captured', 'PAT002', '{"symptoms_count": 5, "vitals_captured": true, "emergency_indicators": true}', '2024-02-11 09:45:00+00'),
('ENC002', 'triage_initiated', 'system', '{"trigger": "symptoms_captured", "priority": "high"}', '2024-02-11 09:46:00+00'),
('ENC002', 'triage_completed', 'system', '{"acuity": "emergent", "confidence": 0.92, "emergency_flag": true}', '2024-02-11 10:00:00+00'),
('ENC002', 'clinician_review_started', 'CLINICIAN_002', '{"reviewer_id": "CLINICIAN_002", "priority": "urgent"}', '2024-02-11 10:05:00+00'),
('ENC002', 'clinician_review_completed', 'CLINICIAN_002', '{"decision": "approved", "action_taken": "sent_to_ed"}', '2024-02-11 11:00:00+00'),
('ENC002', 'encounter_completed', 'system', '{"final_status": "reviewed", "total_duration_minutes": 305}', '2024-02-11 14:20:00+00'),
('ENC003', 'encounter_created', 'system', '{"source": "web", "user_agent": "Chrome/120.0"}', '2024-02-12 10:30:00+00'),
('ENC003', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_003"}', '2024-02-12 10:31:00+00'),
('ENC003', 'symptoms_captured', 'PAT003', '{"symptoms_count": 4}', '2024-02-12 10:45:00+00'),
('ENC003', 'triage_initiated', 'system', '{"trigger": "symptoms_captured"}', '2024-02-12 10:46:00+00'),
('ENC003', 'triage_completed', 'system', '{"acuity": "urgent", "confidence": 0.78}', '2024-02-12 11:00:00+00'),
('ENC004', 'encounter_created', 'system', '{"source": "mobile"}', '2024-02-13 11:00:00+00'),
('ENC004', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_004"}', '2024-02-13 11:01:00+00'),
('ENC004', 'symptoms_captured', 'PAT001', '{"symptoms_count": 2}', '2024-02-13 11:30:00+00'),
('ENC005', 'encounter_created', 'system', '{"source": "web"}', '2024-02-14 12:15:00+00'),
('ENC005', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_005"}', '2024-02-14 12:16:00+00'),
('ENC005', 'symptoms_captured', 'PAT004', '{"symptoms_count": 3}', '2024-02-14 12:30:00+00'),
('ENC005', 'triage_initiated', 'system', '{"trigger": "symptoms_captured"}', '2024-02-14 12:31:00+00'),
('ENC005', 'triage_completed', 'system', '{"acuity": "urgent", "confidence": 0.88}', '2024-02-14 13:00:00+00'),
('ENC005', 'clinician_review_started', 'CLINICIAN_003', '{"reviewer_id": "CLINICIAN_003"}', '2024-02-14 13:30:00+00'),
('ENC005', 'clinician_review_completed', 'CLINICIAN_003', '{"decision": "overridden", "override_reason": "symptoms_improved"}', '2024-02-14 14:00:00+00'),
('ENC005', 'encounter_completed', 'system', '{"final_status": "completed"}', '2024-02-14 16:00:00+00'),
('ENC006', 'encounter_created', 'system', '{"source": "web"}', '2024-02-15 13:30:00+00'),
('ENC006', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_006"}', '2024-02-15 13:31:00+00'),
('ENC006', 'symptoms_captured', 'PAT005', '{"symptoms_count": 2}', '2024-02-15 13:45:00+00'),
('ENC006', 'triage_initiated', 'system', '{"trigger": "symptoms_captured"}', '2024-02-15 13:46:00+00'),
('ENC006', 'triage_completed', 'system', '{"acuity": "routine", "confidence": 0.82}', '2024-02-15 14:00:00+00'),
('ENC006', 'clinician_review_started', 'CLINICIAN_001', '{"reviewer_id": "CLINICIAN_001"}', '2024-02-15 14:30:00+00'),
('ENC006', 'clinician_review_completed', 'CLINICIAN_001', '{"decision": "approved"}', '2024-02-15 15:00:00+00'),
('ENC006', 'encounter_completed', 'system', '{"final_status": "reviewed"}', '2024-02-15 17:45:00+00'),
('ENC010', 'encounter_created', 'system', '{"source": "web"}', '2024-02-19 17:30:00+00'),
('ENC010', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_010"}', '2024-02-19 17:31:00+00'),
('ENC010', 'symptoms_captured', 'PAT008', '{"symptoms_count": 4, "emergency_indicators": true}', '2024-02-19 18:00:00+00'),
('ENC010', 'triage_initiated', 'system', '{"trigger": "symptoms_captured", "priority": "high"}', '2024-02-19 18:01:00+00'),
('ENC010', 'triage_completed', 'system', '{"acuity": "emergent", "confidence": 0.95, "emergency_flag": true}', '2024-02-19 18:15:00+00'),
('ENC013', 'encounter_created', 'system', '{"source": "mobile"}', '2024-02-10 08:00:00+00'),
('ENC013', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_013"}', '2024-02-10 08:01:00+00'),
('ENC013', 'symptoms_captured', 'PAT004', '{"symptoms_count": 2}', '2024-02-10 08:30:00+00'),
('ENC013', 'encounter_expired', 'system', '{"reason": "timeout", "expired_at": "2024-02-11 08:00:00+00"}', '2024-02-11 08:00:00+00'),
('ENC014', 'encounter_created', 'system', '{"source": "web"}', '2024-02-22 20:15:00+00'),
('ENC014', 'consent_verified', 'system', '{"consent_token": "CONSENT_TOKEN_014"}', '2024-02-22 20:16:00+00'),
('ENC014', 'encounter_cancelled', 'PAT005', '{"reason": "patient_requested", "cancelled_by": "patient"}', '2024-02-22 20:20:00+00');

COMMIT;
