# Select page_section, page, form_group, quesiton, question_id
# 20171018

SELECT
page_section.title AS 'section',
#page_section.page_section_id,
page.title AS 'page',
form_group.name AS 'repeatable_group',
#page.page_id,
#page.sequence,
question.question,
question.question_id
#question.sequence
FROM greenbiz_checklist.question
LEFT JOIN greenbiz_checklist.page ON question.page_id = page.page_id
LEFT JOIN greenbiz_checklist.checklist ON page.checklist_id = checklist.checklist_id
LEFT JOIN greenbiz_checklist.page_section_2_page ON page.page_id = page_section_2_page.page_id
LEFT JOIN greenbiz_checklist.page_section ON page_section_2_page.page_section_id = page_section.page_section_id
LEFT JOIN greenbiz_checklist.form_group ON question.form_group_id = form_group.form_group_id

WHERE checklist.checklist_id = 144
AND question.content_block = 0

ORDER BY page.sequence, question.sequence