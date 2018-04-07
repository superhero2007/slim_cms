#Completed Suppliers Profile
SELECT
cc.client_id,
cc.name,
a.answer_type,
ans.string,
q.question,
cc.progress,
cc.completed
FROM greenbiz_checklist.client_result cr
LEFT JOIN greenbiz_checklist.client_checklist cc ON cr.client_checklist_id = cc.client_checklist_id
LEFT JOIN greenbiz_checklist.answer a ON a.answer_id = cr.answer_id
LEFT JOIN greenbiz_checklist.answer_string ans ON ans.answer_string_id = a.answer_string_id
LEFT JOIN greenbiz_checklist.question q ON q.question_id = cr.question_id;


#Total number of suppliers
SELECT
cc.client_id,
cc.name,
a.answer_type,
ans.string,
q.question
FROM greenbiz_checklist.client_result cr
LEFT JOIN greenbiz_checklist.client_checklist cc ON cr.client_checklist_id = cc.client_checklist_id
LEFT JOIN greenbiz_checklist.answer a ON a.answer_id = cr.answer_id
LEFT JOIN greenbiz_checklist.answer_string ans ON ans.answer_string_id = a.answer_string_id
LEFT JOIN greenbiz_checklist.question q ON q.question_id = cr.question_id;

#Supplier code of conduct
SELECT
cc.client_id,
cc.name,
a.answer_type,
ans.string,
q.question,
cc.status
FROM greenbiz_checklist.client_result cr
LEFT JOIN greenbiz_checklist.client_checklist cc ON cr.client_checklist_id = cc.client_checklist_id
LEFT JOIN greenbiz_checklist.answer a ON a.answer_id = cr.answer_id
LEFT JOIN greenbiz_checklist.answer_string ans ON ans.answer_string_id = a.answer_string_id
LEFT JOIN greenbiz_checklist.question q ON q.question_id = cr.question_id;


#Approved factory program
SELECT
cc.name,
a.answer_type,
ans.string,
q.question,
cc.progress,
cc.completed
FROM greenbiz_checklist.client_result cr
LEFT JOIN greenbiz_checklist.client_checklist cc ON cr.client_checklist_id = cc.client_checklist_id
LEFT JOIN greenbiz_checklist.answer a ON a.answer_id = cr.answer_id
LEFT JOIN greenbiz_checklist.answer_string ans ON ans.answer_string_id = a.answer_string_id
LEFT JOIN greenbiz_checklist.question q ON q.question_id = cr.question_id
WHERE a.answer_type = 'label';

#Food program
SELECT
cc.client_id,
cc.name,
q.question,
cc.progress,
cc.completed
FROM greenbiz_checklist.client_result cr
LEFT JOIN greenbiz_checklist.client_checklist cc ON cr.client_checklist_id = cc.client_checklist_id
LEFT JOIN greenbiz_checklist.answer a ON a.answer_id = cr.answer_id
LEFT JOIN greenbiz_checklist.answer_string ans ON ans.answer_string_id = a.answer_string_id
LEFT JOIN greenbiz_checklist.question q ON q.question_id = cr.question_id
WHERE a.answer_type = 'label'
WHERE ans.string = 'Food';
