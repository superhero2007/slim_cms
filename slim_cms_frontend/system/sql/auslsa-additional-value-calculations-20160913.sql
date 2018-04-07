SET @client_checklist_id = (SELECT GROUP_CONCAT(client_checklist.client_checklist_id) FROM greenbiz_checklist.client_checklist WHERE checklist_id = 121);

DELETE FROM greenbiz_checklist.additional_value WHERE `group` = "Emission Calcluation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
DELETE FROM greenbiz_checklist.additional_value WHERE `group` = "Paper Calcluation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Emissions" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Emissions",
SUM(value),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Emissions Per Head" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Emissions Per Head",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33160"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Emissions Per m2" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Emissions Per m2",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33161"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Net Total Emissions" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Net Total Emissions",
IFNULL(SUM(value) - (
SELECT
	SUM(av.value) +  cr.arbitrary_value
	FROM greenbiz_checklist.additional_value av
	LEFT JOIN greenbiz_checklist.client_result cr ON av.client_checklist_id = cr.client_checklist_id
	WHERE av.client_checklist_id = additional_value.client_checklist_id
	AND av.key = "Green Tariff Electricity"
	AND av.group = "Emmission"
	AND cr.answer_id = 33162
),SUM(value)),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Net Total Emissions Per Head" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Net Total Emissions Per Head",
IFNULL(SUM(value) - (
SELECT
	SUM(av.value) +  cr.arbitrary_value
	FROM greenbiz_checklist.additional_value av
	LEFT JOIN greenbiz_checklist.client_result cr ON av.client_checklist_id = cr.client_checklist_id
	WHERE av.client_checklist_id = additional_value.client_checklist_id
	AND av.key = "Green Tariff Electricity"
	AND av.group = "Emmission"
	AND cr.answer_id = 33162
),SUM(value)) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33160"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Net Total Emissions Per m2" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Net Total Emissions Per m2",
IFNULL(SUM(value) - (
SELECT
	SUM(av.value) +  cr.arbitrary_value
	FROM greenbiz_checklist.additional_value av
	LEFT JOIN greenbiz_checklist.client_result cr ON av.client_checklist_id = cr.client_checklist_id
	WHERE av.client_checklist_id = additional_value.client_checklist_id
	AND av.key = "Green Tariff Electricity"
	AND av.group = "Emmission"
	AND cr.answer_id = 33162
),SUM(value)) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33161"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Paper Weight" AND `group` = "Paper Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Paper Weight",
SUM(value),
1,
"Paper Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Paper"
AND additional_value.key = "GrossWeight"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Paper Weight Per Head" AND `group` = "Paper Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Paper Weight Per Head",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33160"),
1,
"Paper Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Paper"
AND additional_value.key = "GrossWeight"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Gross Total Paper Weight Per m2" AND `group` = "Paper Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Gross Total Paper Weight Per m2",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33161"),
1,
"Paper Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Paper"
AND additional_value.key = "GrossWeight"
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Total Flight Emissions" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);

INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Total Flight Emissions",
SUM(value),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND additional_value.key IN("Flights - Short Haul", "Flights - International")
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Total Flight Emissions Per Head" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Total Flight Emissions Per Head",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33160"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND additional_value.key IN("Flights - Short Haul", "Flights - International")
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;

DELETE FROM greenbiz_checklist.additional_value WHERE `key` = "Total Flight Emissions Per m2" AND `group` = "Emission Calculation" AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id);
INSERT INTO greenbiz_checklist.additional_value (client_checklist_id, `key`, `value`, `index`, `group`)
SELECT
additional_value.client_checklist_id,
"Total Flight Emissions Per m2",
SUM(value) / (SELECT IFNULL(arbitrary_value,1)  FROM greenbiz_checklist.client_result WHERE client_result.client_checklist_id = additional_value.client_checklist_id AND client_result.answer_id = "33161"),
1,
"Emission Calculation"
FROM greenbiz_checklist.additional_value
WHERE additional_value.group = "Emmission"
AND additional_value.key IN("Flights - Short Haul", "Flights - International")
AND FIND_IN_SET(additional_value.client_checklist_id, @client_checklist_id)
GROUP BY additional_value.client_checklist_id;