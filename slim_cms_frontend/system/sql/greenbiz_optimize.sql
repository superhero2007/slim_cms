#greenbiz database optimize

#Search for content and navigation with no domain and delete
#Delete from greenbiz_core.content
DELETE FROM greenbiz_core.content
WHERE content.navigation_id IN(
	SELECT 
	navigation.navigation_id
	FROM greenbiz_core.navigation
	LEFT JOIN greenbiz_core.domain ON navigation.domain_id = domain.domain_id
	WHERE domain.domain_id IS NULL
);

OPTIMIZE TABLE greenbiz_core.content;

#Delete from greenbiz_core.navigation
DELETE FROM greenbiz_core.navigation
WHERE navigation.domain_id NOT IN(
	SELECT domain.domain_id
	FROM greenbiz_core.domain
);

OPTIMIZE TABLE greenbiz_core.navigation;

#Remove API V1 Stored Queries greater than 7 days
DELETE FROM greenbiz_api.stored_query
WHERE timestamp < (NOW() - INTERVAL 7 DAY);

OPTIMIZE TABLE greenbiz_api.stored_query;

#Remove API V1 user_log  > 1 year
DELETE FROM greenbiz_api.user_log
WHERE timestamp < (NOW() - INTERVAL 1 YEAR);

OPTIMIZE TABLE greenbiz_api.user_log;