#Update greenbiz_checklist.client_result with corrected character encoding
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€œ', '“');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€', '”');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€™', '’');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€˜', '‘');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€”', '–');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€“', '—');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€¢', '-');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€¦', '…');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â„¢', '&trade;');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â€', '-');
UPDATE greenbiz_checklist.client_result SET arbitrary_value = REPLACE(arbitrary_value, 'â—', '-');