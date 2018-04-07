DELETE FROM greenbiz_api.stored_query
WHERE timestamp < (NOW() - INTERVAL 7 DAY);

OPTIMIZE TABLE greenbiz_api.stored_query;