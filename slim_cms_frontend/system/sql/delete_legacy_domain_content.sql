#Delete Legacy Domain Content and Navigation

#Delete from greenbiz_core.content
DELETE FROM greenbiz_core.content
WHERE content.navigation_id IN(
	SELECT 
	navigation.navigation_id
	FROM greenbiz_core.navigation
	LEFT JOIN greenbiz_core.domain ON navigation.domain_id = domain.domain_id
	WHERE domain.domain_id IS NULL
);

#Delete from greenbiz_core.navigation
DELETE FROM greenbiz_core.navigation
WHERE navigation.domain_id NOT IN(
	SELECT domain.domain_id
	FROM greenbiz_core.domain
);