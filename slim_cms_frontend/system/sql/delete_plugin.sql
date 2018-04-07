#Delete Plugin MySQL Query

#Delete from greenbiz_core.plugin_method_call_param
DELETE FROM greenbiz_core.plugin_method_call_param
WHERE plugin_method_call_id IN(
	SELECT plugin_method_call.plugin_method_call_id FROM greenbiz_core.plugin_method_call
	WHERE plugin_method_call.plugin_method_id IN(
		SELECT plugin_method.plugin_method_id FROM greenbiz_core.plugin_method
		WHERE plugin_method.plugin_id IN(
			SELECT plugin.plugin_id FROM greenbiz_core.plugin
			WHERE plugin.plugin_id IN(21,19,6,28,11,5,24,23,9,10,12,17,20,14,13,29,7)
		)
	)
);

#Delete from greenbiz_core.plugin_method_call
DELETE FROM greenbiz_core.plugin_method_call
WHERE plugin_method_call.plugin_method_id IN(
	SELECT plugin_method.plugin_method_id FROM greenbiz_core.plugin_method
	WHERE plugin_method.plugin_id IN(
		SELECT plugin.plugin_id FROM greenbiz_core.plugin
		WHERE plugin.plugin_id IN(21,19,6,28,11,5,24,23,9,10,12,17,20,14,13,29,7)
	)
);

#Delete from greenbiz_core.plugin_method
DELETE FROM greenbiz_core.plugin_method
WHERE plugin_method.plugin_id IN(
	SELECT plugin.plugin_id FROM greenbiz_core.plugin
	WHERE plugin.plugin_id IN(21,19,6,28,11,5,24,23,9,10,12,17,20,14,13,29,7)
);

#Delete from greenbiz_core.plugin
DELETE FROM greenbiz_core.plugin
WHERE plugin.plugin_id IN(21,19,6,28,11,5,24,23,9,10,12,17,20,14,13,29,7);