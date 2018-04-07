#Set Question Index
UPDATE greenbiz_checklist.question SET `index` = 100 WHERE question_id IN(24181, 24184, 24179, 24182, 24180, 24183, 24186, 24185);

#Reams Purchased
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33285
SET cr.question_id = 24181, cr.answer_id = 63343, cr.index = 100;

#% Double Sided Impressions
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33289
SET cr.question_id = 24184, cr.answer_id = 63360, cr.index = 100;

#Paper Size
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33280
SET cr.question_id = 24179, cr.answer_id = 63338, cr.index = 100;

#Certification
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33287
SET cr.question_id = 24182, cr.answer_id = 63345, cr.index = 100;

#Paper Weight
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33284
SET cr.question_id = 24180, cr.answer_id = 63342, cr.index = 100;

#Recycled Content
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33288
SET cr.question_id = 24183, cr.answer_id = 63359, cr.index = 100;

#Gross Paper (kg)
UPDATE greenbiz_checklist.client_result cr
INNER JOIN (SELECT cr2.* FROM greenbiz_checklist.client_result cr2 WHERE cr2.answer_id = 33291) AS os ON cr.client_checklist_id = os.client_checklist_id AND os.index = cr.index AND cr.answer_id = 33292
SET cr.question_id = 24186, cr.answer_id = 63363, cr.index = 100;

#Paper Type
UPDATE greenbiz_checklist.client_result cr
SET  cr.question_id =24185, cr.answer_id = 63362, cr.index = 100
WHERE cr.answer_id = 33291;

#FSC
INSERT INTO greenbiz_checklist.client_result (client_checklist_id, question_id, answer_id, arbitrary_value, `index`)
SELECT cr.client_checklist_id, cr.question_id, 33287, cr.arbitrary_value, cr.index 
FROM greenbiz_checklist.client_result cr
WHERE cr.answer_id IN(33286, 40390, 40391, 40392, 40393, 40394, 40395);

#AFS
INSERT INTO greenbiz_checklist.client_result (client_checklist_id, question_id, answer_id, arbitrary_value, `index`)
SELECT cr.client_checklist_id, cr.question_id, 40396, cr.arbitrary_value, cr.index 
FROM greenbiz_checklist.client_result cr
WHERE cr.answer_id IN(33286, 40390, 40391, 40392, 40393, 40394, 40395, 40396, 40397, 40398, 40399);

#NCOS
INSERT INTO greenbiz_checklist.client_result (client_checklist_id, question_id, answer_id, arbitrary_value, `index`)
SELECT cr.client_checklist_id, cr.question_id, 40400, cr.arbitrary_value, cr.index 
FROM greenbiz_checklist.client_result cr
WHERE cr.answer_id IN(40390,40391,40392,40393,40394,40395,40396,40397,40398);

#Other Certifications
INSERT INTO greenbiz_checklist.client_result (client_checklist_id, question_id, answer_id, arbitrary_value, `index`)
SELECT cr.client_checklist_id, cr.question_id, 40401, cr.arbitrary_value, cr.index 
FROM greenbiz_checklist.client_result cr
WHERE cr.answer_id IN(40391,40392,40393,40394,40395,40396,40397,40398, 40399);

#Delete OLD Client Result
DELETE FROM greenbiz_checklist.client_result WHERE answer_id IN(33286,40390,40391,40392,40393,40394,40395,40396,40397,40398,40399);

#Delete Old answers options
DELETE FROM greenbiz_checklist.answer WHERE answer_id in(33286,40390,40391,40392,40393,40394,40395,40396,40397,40398,40399);



