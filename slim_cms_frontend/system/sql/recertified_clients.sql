
    SELECT
    `client`.`company_name`,
    `invoice`.*,
    COUNT(`invoice`.`client_id`) AS `invoice_count`,
    `trans`.`trans_count`
    FROM `greenbiz_pos`.`invoice`
    LEFT JOIN `greenbiz_core`.`client` ON `invoice`.`client_id` = `client`.`client_id`
    LEFT JOIN (
        SELECT
        `transaction`.`client_id`,
        COUNT(*) AS `trans_count`
        FROM `greenbiz_pos`.`transaction`
        GROUP BY `transaction`.`client_id`
    ) AS `trans` ON `trans`.`client_id` = `client`.`client_id`
    WHERE `invoice`.`client_id` != 0
    AND `invoice`.`client_id` != 785
    AND `client`.`company_name` IS NOT NULL
    AND `trans_count` > 1
    GROUP BY `invoice`.`client_id`
    ORDER BY `invoice_count` DESC;