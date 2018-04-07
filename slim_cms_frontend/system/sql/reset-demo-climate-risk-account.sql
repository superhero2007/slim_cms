/* 
MYSQL Queries to reset demo account to default data
Run as a cron every hour

###### Climate Risk Demo Account ######
---- Start Deleting the Data ---- 
*/

/*
Delete the client_checklist_permission from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_checklist_permission WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the clent_checklist_score from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_checklist_score WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_commitment from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_commitment WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_metric from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_metric WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_page_note from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_page_note WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_result from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_result WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the owner_2_action from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_site WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_site_result from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_site_result WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the owner_2_action from the client_checklist
*/
DELETE FROM greenbiz_checklist.owner_2_action WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the audit from the account
*/
DELETE FROM greenbiz_audit.audit WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the document_2_client_checklist from the account
*/
DELETE FROM greenbiz_audit.document_2_client_checklist WHERE client_checklist_id IN ('18584', '18585');

/*
Delete the client_checklist from the client_checklist
*/
DELETE FROM greenbiz_checklist.client_checklist WHERE client_id = '4831';

/*
Delete the transaction from the account
*/
DELETE FROM greenbiz_pos.transaction WHERE client_id = '4831';

/*
Delete the invoice from the account
*/
DELETE FROM greenbiz_pos.invoice WHERE client_id = '4831';

/*
Delete the client_contacts from the account
*/
DELETE FROM greenbiz_core.client_contact WHERE client_id = '4831';

/*
Delete the client account
*/
DELETE FROM greenbiz_core.client WHERE client_id = '4831';

/*
Delete the client_contact_2_dashboard
*/
DELETE FROM greenbiz_dashboard.client_contact_2_dashboard WHERE client_contact_id = '4831';

/*
---- Start Inserting the Data ---- 
*/

/*
Insert the values into the greenbiz_core.client table
*/
INSERT INTO greenbiz_core.client (client_id, client_type_id, affiliate_id, consultant_id, associate_id, parent_id, associate_account_id, city_id, account_no, source, registered, username, password, company_name, department, address_line_1, address_line_2, suburb, state, postcode, country, industry, tmp_prospect_id, show_in_contact_us, temp_partner_url, refered_from, parent_company_id, nswbc_preferred_time, referer_url, complimentary_consult, business_owner_view_id, membership_number, anzsic_id, existing_business_owner_id, distributor_id, `status`)
VALUES 
('4831', '4', NULL, NULL, NULL, NULL, NULL, '0', '2016092000048319', '', '2016-09-20 14:57:45', '', '', 'Demo Climate Risk Pty LTD', NULL, '12 Queen Street', '', 'Brisbane', 'QLD', '4000', 'Australia', NULL, '0', '1', NULL, NULL, '0', NULL, NULL, '0', '1', NULL, NULL, NULL, NULL, '1');

/*
Insert the client_contacts into the client account
*/
INSERT INTO greenbiz_core.client_contact (client_contact_id, client_id, is_client_admin, sequence, salutation, firstname, lastname, position, email, password, phone, send_auto_emails, display_contact_photo, url, description, encrypted, locked_out, locked_out_expiry)
VALUES 
('4835', '4831', '1', '0', '', 'Demo', 'User', '', 'democr@greenbizcheck.com', '$2a$08$jEcN8xq8NfkJDVRS/aN/a.xcVMvUsVOMT9RyFDcOMm0KDCD6kZdvW', '', '0', '0', '', '', '1', '0', '0000-00-00 00:00:00');

/*
Insert the values into the client_checklist
*/
INSERT INTO greenbiz_checklist.client_checklist (client_checklist_id, checklist_id, checklist_variation_id, client_id, name, progress, initial_score, current_score, created, completed, expires, audit_required, fail_points, `status`, date_range_start, date_range_finish)
VALUES
('18584', '143', '0', '4831', 'Climate Risk Health Check', '0', NULL, NULL, '2017-05-12 15:18:19', NULL, NULL, '0', '0', '1', NULL, NULL),
('18585', '143', '0', '4831', 'Climate Risk Health Check', '100', '0.2', '0.571429', '2017-05-12 15:18:34', '2017-05-14 20:15:25', NULL, '0', '0', '2', NULL, NULL);


/*
Insert the values into client_checklist_score
*/
INSERT INTO greenbiz_checklist.client_checklist_score (client_checklist_score_id, client_checklist_id, timestamp, score)
VALUES
('48779', '18585', '2017-05-14 20:15:26', '0.228311'),
('48780', '18585', '2017-05-14 20:17:03', '0.225806'),
('48781', '18585', '2017-05-14 20:36:54', '0.225806'),
('48782', '18585', '2017-05-14 21:28:20', '0.2'),
('48783', '18585', '2017-05-14 21:28:45', '0.228571'),
('48784', '18585', '2017-05-14 21:30:30', '0.571429'),
('48785', '18585', '2017-05-15 08:51:21', '0.571429'),
('48788', '18585', '2017-05-15 09:21:07', '0.571429'),
('48789', '18585', '2017-05-15 09:26:07', '0.571429'),
('48790', '18585', '2017-05-15 11:03:43', '0.571429'),
('48791', '18585', '2017-05-15 11:08:46', '0.571429');


/*
Insert the values into client_commitment
*/
INSERT INTO greenbiz_checklist.client_commitment (client_commitment_id, client_checklist_id, action_id, commitment_id, timestamp)
VALUES
('1188480', '18585', '12335', '15290', '2017-05-14 21:28:45'),
('1188507', '18585', '12356', '0', '2017-05-14 21:30:30'),
('1188508', '18585', '12357', '15312', '2017-05-14 21:30:30'),
('1188509', '18585', '12363', '15318', '2017-05-14 21:30:30'),
('1188510', '18585', '12364', '15319', '2017-05-14 21:30:30'),
('1188511', '18585', '12365', '0', '2017-05-14 21:30:30'),
('1188513', '18585', '12366', '0', '2017-05-14 21:30:30'),
('1188514', '18585', '12367', '15322', '2017-05-14 21:30:30'),
('1188515', '18585', '12368', '15323', '2017-05-14 21:30:30'),
('1188516', '18585', '12370', '0', '2017-05-14 21:30:30'),
('1188517', '18585', '12375', '15330', '2017-05-14 21:30:30'),
('1188518', '18585', '12376', '15331', '2017-05-14 21:30:30'),
('1188519', '18585', '12379', '0', '2017-05-14 21:30:30'),
('1188520', '18585', '12380', '0', '2017-05-14 21:30:30'),
('1188521', '18585', '12381', '15336', '2017-05-14 21:30:30'),
('1188522', '18585', '12382', '0', '2017-05-14 21:30:30'),
('1188523', '18585', '12383', '15338', '2017-05-14 21:30:30'),
('1188524', '18585', '12384', '0', '2017-05-14 21:30:30'),
('1188525', '18585', '12385', '15340', '2017-05-14 21:30:30'),
('1188526', '18585', '12386', '0', '2017-05-14 21:30:30'),
('1188527', '18585', '12387', '0', '2017-05-14 21:30:30'),
('1188528', '18585', '12388', '15343', '2017-05-14 21:30:30'),
('1188529', '18585', '12389', '0', '2017-05-14 21:30:30'),
('1188530', '18585', '12390', '0', '2017-05-14 21:30:30'),
('1188531', '18585', '12391', '15346', '2017-05-14 21:30:30'),
('1188532', '18585', '12392', '0', '2017-05-14 21:30:30'),
('1188533', '18585', '12393', '0', '2017-05-14 21:30:30'),
('1188512', '18585', '12394', '0', '2017-05-14 21:30:30');


/*
Insert the values into the client_result page
*/
INSERT INTO greenbiz_checklist.client_result (client_result_id, client_checklist_id, question_id, answer_id, timestamp, arbitrary_value, `index`)
VALUES
('573454', '18585', '15350', '37477', '2017-05-14 19:32:53', '10.7679857,106.7037034', '0'),
('573453', '18585', '15349', '37476', '2017-05-14 19:32:53', 'Ho Chi Minh City, phường 12 Quận 4 Hồ Chí Minh, Vietnam', '0'),
('573452', '18585', '15348', '37475', '2017-05-14 19:32:53', 'Mong Bridge', '0'),
('573282', '18585', '15412', '37522', '2017-05-12 15:24:30', NULL, '0'),
('573283', '18585', '15413', '37524', '2017-05-12 15:24:30', NULL, '0'),
('573284', '18585', '15414', '37525', '2017-05-12 15:24:30', NULL, '0'),
('573285', '18585', '15415', '37527', '2017-05-12 15:24:30', NULL, '0'),
('573286', '18585', '15416', '37530', '2017-05-12 15:24:30', NULL, '0'),
('573287', '18585', '15420', '37535', '2017-05-12 15:24:30', NULL, '0'),
('573288', '18585', '15418', '37534', '2017-05-12 15:24:30', NULL, '0'),
('573289', '18585', '15419', '37537', '2017-05-12 15:24:30', NULL, '0'),
('573290', '18585', '15432', '37669', '2017-05-12 15:24:49', NULL, '0'),
('573455', '18585', '15351', '37664', '2017-05-14 19:32:53', NULL, '0'),
('573465', '18585', '15436', '37680', '2017-05-14 20:12:47', NULL, '0'),
('573457', '18585', '15298', '37356', '2017-05-14 20:12:39', NULL, '0'),
('573458', '18585', '15299', '37360', '2017-05-14 20:12:39', NULL, '0'),
('573459', '18585', '15300', '37362', '2017-05-14 20:12:39', NULL, '0'),
('573460', '18585', '15301', '37366', '2017-05-14 20:12:39', NULL, '0'),
('573461', '18585', '15433', '37670', '2017-05-14 20:12:39', NULL, '0'),
('573462', '18585', '15434', '37677', '2017-05-14 20:12:39', NULL, '0'),
('573463', '18585', '15302', '37369', '2017-05-14 20:12:39', NULL, '0'),
('573464', '18585', '15435', '37678', '2017-05-14 20:12:39', NULL, '0'),
('573466', '18585', '15303', '37371', '2017-05-14 20:12:59', NULL, '0'),
('573467', '18585', '15304', '37375', '2017-05-14 20:12:59', NULL, '0'),
('573468', '18585', '15458', '37727', '2017-05-14 20:13:07', NULL, '0'),
('573469', '18585', '15294', '37344', '2017-05-14 20:13:20', NULL, '0'),
('573470', '18585', '15295', '37348', '2017-05-14 20:13:20', NULL, '0'),
('573471', '18585', '15296', '37351', '2017-05-14 20:13:20', NULL, '0'),
('573472', '18585', '15297', '37354', '2017-05-14 20:13:20', NULL, '0'),
('573473', '18585', '15437', '37682', '2017-05-14 20:13:28', NULL, '0'),
('573474', '18585', '15291', '37335', '2017-05-14 20:13:39', NULL, '0'),
('573475', '18585', '15292', '37339', '2017-05-14 20:13:39', NULL, '0'),
('573476', '18585', '15293', '37341', '2017-05-14 20:13:39', NULL, '0'),
('573477', '18585', '15438', '37683', '2017-05-14 20:13:46', NULL, '0'),
('573478', '18585', '15425', '37636', '2017-05-14 20:13:58', NULL, '0'),
('573479', '18585', '15426', '37640', '2017-05-14 20:13:58', NULL, '0'),
('573480', '18585', '15423', '37630', '2017-05-14 20:13:58', NULL, '0'),
('573481', '18585', '15424', '37633', '2017-05-14 20:13:58', NULL, '0'),
('573482', '18585', '15453', '37714', '2017-05-14 20:14:06', NULL, '0'),
('573483', '18585', '15427', '37642', '2017-05-14 20:14:23', NULL, '0'),
('573484', '18585', '15428', '37646', '2017-05-14 20:14:23', NULL, '0'),
('573485', '18585', '15429', '37649', '2017-05-14 20:14:23', NULL, '0'),
('573486', '18585', '15430', '37651', '2017-05-14 20:14:23', NULL, '0'),
('573487', '18585', '15454', '37716', '2017-05-14 20:14:23', NULL, '0'),
('573488', '18585', '15431', '37655', '2017-05-14 20:14:23', NULL, '0'),
('573489', '18585', '15455', '37720', '2017-05-14 20:14:31', NULL, '0'),
('573490', '18585', '15305', '37378', '2017-05-14 20:14:50', NULL, '0'),
('573491', '18585', '15306', '37381', '2017-05-14 20:14:50', NULL, '0'),
('573492', '18585', '15307', '37384', '2017-05-14 20:14:50', NULL, '0'),
('573493', '18585', '15308', '37387', '2017-05-14 20:14:50', NULL, '0'),
('573494', '18585', '15456', '37723', '2017-05-14 20:14:50', NULL, '0'),
('573495', '18585', '15309', '37390', '2017-05-14 20:14:50', NULL, '0'),
('573496', '18585', '15457', '37725', '2017-05-14 20:14:59', NULL, '0'),
('573497', '18585', '15310', '37393', '2017-05-14 20:15:15', NULL, '0'),
('573498', '18585', '15311', '37395', '2017-05-14 20:15:15', NULL, '0'),
('573499', '18585', '15312', '37399', '2017-05-14 20:15:15', NULL, '0'),
('573500', '18585', '15313', '37401', '2017-05-14 20:15:15', NULL, '0'),
('573501', '18585', '15314', '37405', '2017-05-14 20:15:15', NULL, '0'),
('573502', '18585', '15422', '37628', '2017-05-14 20:15:15', NULL, '0');


/*
###### Finish Data Reset ######
*/