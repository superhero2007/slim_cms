<?php
$assessmentTools = new assessmentTools($this->db);

//All of the insert/edit/delete actions from the Assessment Maintenance setion of the Admin system
if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'checklist_dump') {
	set_time_limit(0);
}

if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'checklist_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`checklist` SET
					`checklist_id` = %2$d,
					`name` = "%3$s",
					`report_name` = "%4$s",
					`description` = "%5$s",
					`logo` = "%6$s",
					`company_logo` = "%7$s",
					`report_type` = "%8$s",
					`audit` = %9$d,
					`send_trigger_emails` = %10$d,
					`assessment_certificate` = %11$d,
					`scorable_assessment` = %12$d,
					`downloadable_reports` = %13$d,
					`report_template` = "%14$s",
					`exportable_actions` = %15$d,
					`email_report` = %16$d,
					`email_report_address` = "%17$s",
					`md5` = "%18$s",
					`archived` = %19$d,
					`help_content` = "%20$s",
					`submitable` = %21$d,
					`show_previous_results` = %22$d,
					`followup_call` = IF("%23$s" != "","%23$s",NULL),
					`progress_report` = %24$d,
					`last_page_submit` = %25$d,
					`report_cover_color` = IF("%26$s" != "","%26$s",NULL),
					`followup_sql` = IF("%27$s" != "","%27$s",NULL),
					`report_primary_color` = IF("%28$s" != "","%28$s",NULL),
					`report_secondary_color` = IF("%29$s" != "","%29$s",NULL),
					`require_page_complete` = %30$d
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['report_name']),
				$this->db->escape_string($_POST['description']),
				$this->db->escape_string($_POST['logo']),
				$this->db->escape_string($_POST['company_logo']),
				$this->db->escape_string($_POST['report_type']),
				$this->db->escape_string($_POST['audit']),
				$this->db->escape_string($_POST['send_trigger_emails']),
				$this->db->escape_string($_POST['assessment_certificate']),
				$this->db->escape_string($_POST['scorable_assessment']),
				$this->db->escape_string($_POST['downloadable_reports']),
				$this->db->escape_string($_POST['report_template']),
				$this->db->escape_string($_POST['exportable_actions']),
				$this->db->escape_string($_POST['email_report']),
				$this->db->escape_string($_POST['email_report_address']),
				$this->db->escape_string((strlen($_POST['md5']) > 0 ? $_POST['md5'] : $assessmentTools->generateRandomKey())),
				$this->db->escape_string($_POST['archived']),
				$this->db->escape_string($_POST['help_content']),
				$this->db->escape_string($_POST['submitable']),
				$this->db->escape_string($_POST['show_previous_results']),
				$this->db->escape_string($_POST['followup_call']),
				$this->db->escape_string($_POST['progress_report']),
				$this->db->escape_string($_POST['last_page_submit']),
				$this->db->escape_string($_POST['report_cover_color']),
				$this->db->escape_string($_POST['followup_sql']),
				$this->db->escape_string($_POST['report_primary_color']),
				$this->db->escape_string($_POST['report_secondary_color']),
				$this->db->escape_string($_POST['require_page_complete'])
			));
			header('location: ?page=checklists&mode=checklist_edit&checklist_id='.$this->db->insert_id);
			die();
		}
		case 'checklist_copy': {
			$new_checklist_id = $assessmentTools->duplicateAssessment($_POST['checklist_id'],$_POST['name'], $_POST['new-checklist-db']);
			header('location: ?page=checklists&mode=checklist_edit&checklist_id='.$new_checklist_id);
			die();
		}
		case 'checklist_delete': {
			$assessmentTools->deleteAssessment($_REQUEST['checklist_id']);
			header('location: ?page=checklists');
			break;
		}
		case 'checklist_variation_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`checklist_variation` SET
					`checklist_variation_id` = %2$d,
					`name` = "%3$s",
					`description` = "%4$s",
					`logo` = "%5$s",
					`company_logo` = "%6$s"
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['checklist_variation_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['description']),
				$this->db->escape_string($_POST['logo']),
				$this->db->escape_string($_POST['company_logo'])
			));
			header('location: ?page=checklists&mode=variation_edit&checklist_variation_id='.$this->db->insert_id);
			die();
		}
		case 'checklist_variation_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`checklist_variation`
				WHERE `checklist_variation_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['checklist_variation_id'])
			));
			header('location: ?page=checklists&mode=variation_list');
			die();
		}
		case 'certification_level_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`certification_level` SET
					`certification_level_id` = %2$d,
					`checklist_id` = %3$d,
					`name` = "%4$s",
					`target` = %5$d,
					`progress_bar_color` = "%6$s",
					`audit_required` = %7$d,
					`audit_item_count` = "%8$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['certification_level_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['target']),
				$this->db->escape_string($_POST['progress_bar_color']),
				$this->db->escape_string($_POST['audit_required']),
				$this->db->escape_string($_POST['audit_item_count'])
			));
			print $this->db->error;
			header('location: ?page=checklists&mode=certification_level_edit&checklist_id='.$_POST['checklist_id'].'&certification_level_id='.$this->db->insert_id);
			die();
		}
		case 'certification_level_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`certification_level`
				WHERE `certification_level_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['certification_level_id'])
			));
			header('location: ?page=checklists&mode=checklist_edit&amp;checklist_id='.$_REQUEST['checklist_id']);
			die();
		}
		case 'page_save': {

			//Save the page
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`page` SET
					`page_id` = %2$d,
					`checklist_id` = %3$d,
					`sequence` = %4$d,
					`enable_skipping` = %5$d,
					`title` = "%6$s",
					`content` = "%7$s",
					`show_notes_field` = %8$d,
					`display_in_table` = %9$d,
					`table_columns` = "%10$s",
					`page_layout` = "%11$s",
					`notes_field_title` = "%12$s",
					`notes_field_placeholder` = "%13$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['page_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['enable_skipping']),
				$this->db->escape_string($_POST['title']),
				$this->db->escape_string($_POST['content']),
				$this->db->escape_string($_POST['show_notes_field']),
				$this->db->escape_string($_POST['display_in_table']),
				$this->db->escape_string($_POST['table_columns']),
				isset($_POST['page_layout']) && $_POST['page_layout'] != '' ? $this->db->escape_string($_POST['page_layout']) : null,
				isset($_POST['notes_field_title']) && $_POST['notes_field_title'] != '' ? $this->db->escape_string($_POST['notes_field_title']) : null,
				isset($_POST['notes_field_placeholder']) && $_POST['notes_field_placeholder'] != '' ? $this->db->escape_string($_POST['notes_field_placeholder']) : null
			));

			$page_id = $this->db->insert_id;

			//If the page_section_id is set and is not zero, replace
			if(isset($_REQUEST['page_section_id'])) {

				if($_REQUEST['page_section_id'] > 0) {

					if(isset($_REQUEST['page_section_2_page_id']) && $_REQUEST['page_section_2_page_id'] > 0) {
						$this->db->query(sprintf('
							UPDATE `%1$s`.`page_section_2_page`	SET
								`page_section_id` = %2$d
							WHERE `page_section_2_page_id` = %3$d
						',
							DB_PREFIX.'checklist',
							$this->db->escape_string($_REQUEST['page_section_id']),
							$this->db->escape_string($_REQUEST['page_section_2_page_id'])
						));
					} else {
						$this->db->query(sprintf('
							INSERT INTO `%1$s`.`page_section_2_page`
								(page_section_id, page_id)
							VALUES (%2$d, %3$d);
						',
							DB_PREFIX.'checklist',
							$this->db->escape_string($_REQUEST['page_section_id']),
							$this->db->escape_string($page_id)
						));
					}

				} else {
					$this->db->query(sprintf('
						DELETE FROM `%1$s`.`page_section_2_page`
						WHERE `page_id` = %2$d;
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($page_id)
					));
				}
			}

			header('location: ?page=checklists&mode=page_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$page_id);
			die();
		}
		case 'page_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`action_2_answer`
				WHERE `answer_id` IN (
					SELECT `answer_id`
					FROM `%1$s`.`answer`
					WHERE `question_id` IN (
						SELECT `question_id`
						FROM `%1$s`.`question`
						WHERE `page_id` = %2$d
					)
				);
				
				DELETE FROM `%1$s`.`answer_2_question`
				WHERE `answer_id` IN (
					SELECT `answer_id`
					FROM `%1$s`.`answer`
					WHERE `question_id` IN (
						SELECT `question_id`
						FROM `%1$s`.`question`
						WHERE `page_id` = %2$d
					)
				)
				OR `question_id` IN (
					SELECT `question_id`
					FROM `%1$s`.`question`
					WHERE `page_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`answer`
				WHERE `question_id` IN (
					SELECT `question_id`
					FROM `%1$s`.`question`
					WHERE `page_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`metric_unit_type_2_metric`
				WHERE `metric_id` IN (
					SELECT `metric_id`
					FROM `%1$s`.`metric`
					WHERE `metric_group_id` IN (
						SELECT `metric_group_id`
						FROM `%1$s`.`metric_group`
						WHERE `page_id` = %2$d
					)
				);
				
				DELETE FROM `%1$s`.`metric`
				WHERE `metric_group_id` IN (
					SELECT `metric_group_id`
					FROM `%1$s`.`metric_group`
					WHERE `page_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`metric_group`
				WHERE `page_id` = %2$d;
				
				DELETE FROM `%1$s`.`question`
				WHERE `page_id` = %2$d;
				
				DELETE FROM `%1$s`.`page`
				WHERE `page_id` = %2$d;

				DELETE FROM `%1$s`.`page_section_2_page`
				WHERE `page_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['page_id'])
			));
			header('location: ?page=checklists&mode=page_list&checklist_id='.$_REQUEST['checklist_id']);
			die();
		}
		case 'page_reorder': {
			for($i=1;$i<count($_REQUEST['table-page-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`page` SET
						`sequence` = %2$d
					WHERE `page_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-page-list'][$i])
				));
			}
			die();
		}
		case 'question_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`question` SET
					`question_id` = %2$d,
					`checklist_id` = %3$d,
					`page_id` = %4$d,
					`sequence` = %5$d,
					`question` = "%6$s",
					`tip` = "%7$s",
					`multiple_answer` = %8$d,
					`required` = %9$d,
					`multi_site` = %10$d,
					`content_block` = %11$d,
					`display_in_table` = %12$d,
					`grid_layout_id` = %13$d,
					`index` = %14$d,
					`hidden` = %15$d,
					`import_key` = "%16$s",
					`export_key` = "%17$s",
					`alt_key` = "%18$s",
					`show_in_analytics` = %19$d,
					`repeatable` = %20$d,
					`validate` = %21$d,
					`form_group_id` = %22$d,
					`css_class` = "%23$s",
					`field_permission_id` = %24$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['question_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['page_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['question']),
				$this->db->escape_string($_POST['tip']),
				$this->db->escape_string($_POST['multiple_answer']),
				$this->db->escape_string($_POST['required']),
				$this->db->escape_string($_POST['multi_site']),
				$this->db->escape_string($_POST['content_block']),
				$this->db->escape_string($_POST['display_in_table']),
				$this->db->escape_string($_POST['grid_layout_id']),
				$this->db->escape_string($_POST['index']),
				$this->db->escape_string($_POST['hidden']),
				isset($_POST['import_key']) && $_POST['import_key'] != '' ? $this->db->escape_string($_POST['import_key']) : null,
				isset($_POST['export_key']) && $_POST['export_key'] != '' ? $this->db->escape_string($_POST['export_key']) : null,
				isset($_POST['alt_key']) && $_POST['alt_key'] != '' ? $this->db->escape_string($_POST['alt_key']) : null,
				$this->db->escape_string($_POST['show_in_analytics']),
				$this->db->escape_string($_POST['repeatable']),
				$this->db->escape_string($_POST['validate']),
				$this->db->escape_string(isset($_POST['form_group_id']) && $_POST['form_group_id'] > 0 ? $_POST['form_group_id'] : null),
				$this->db->escape_string(isset($_POST['css_class']) && $_POST['css_class'] != '' ? $_POST['css_class'] : null),
				$this->db->escape_string(isset($_POST['field_permission_id']) && $_POST['field_permission_id'] > 0 ? $_POST['field_permission_id'] : 3)
			));
			
			if(isset($_POST['step'])) {
				header('location: ?page=checklists&mode=wizard&step='.$_POST['step'].'&checklist_id='.$_POST['checklist_id'].'&question_id='.$this->db->insert_id);
			} else {
				header('location: ?page=checklists&mode=question_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&question_id='.$this->db->insert_id);
			}
			die();
		}
		case 'question_delete': {

			if(isset($_REQUEST['question_id'])) {
				$this->db->multi_query(sprintf('
					DELETE FROM `%1$s`.`action_2_answer`
					WHERE `answer_id` IN (
						SELECT `answer_id`
						FROM `%1$s`.`answer`
						WHERE `question_id` IN (%2$s)
					);
				
					DELETE FROM `%1$s`.`answer_2_question`
					WHERE `answer_id` IN (
						SELECT `answer_id`
						FROM `%1$s`.`answer`
						WHERE `question_id` IN (%2$s)
					)
					OR `question_id` IN (%2$s);
				
					DELETE FROM `%1$s`.`answer`
					WHERE `question_id` IN (%2$s);
				
					DELETE FROM `%1$s`.`question`
					WHERE `question_id` IN (%2$s);
				
					OPTIMIZE TABLE
						`%1$s`.`action_2_answer`,
						`%1$s`.`answer_2_question`,
						`%1$s`.`answer`,
						`%1$s`.`question`;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string(implode(',',$_REQUEST['question_id']))
				));
			}
			header('location: ?page=checklists&mode=page_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id']);
			die();
		}
		case 'question_reorder': {
			for($i=1;$i<count($_REQUEST['table-question-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`question` SET
						`sequence` = %2$d
					WHERE `question_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-question-list'][$i])
				));
			}
			die();
		}
		case 'metric_reorder': {
			for($i=1;$i<count($_REQUEST['table-metric-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`metric_group` SET
						`sequence` = %2$d
					WHERE `metric_group_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-metric-list'][$i])
				));
			}
			die();
		}
		case 'single_metric_reorder': {
			for($i=1;$i<count($_REQUEST['table-single-metric-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`metric` SET
						`sequence` = %2$d
					WHERE `metric_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-single-metric-list'][$i])
				));
			}
			die();
		}
		case 'question_copy': {
			$checklist_id = $_REQUEST['checklist_id'];
			$import_checklist_id = $_REQUEST['import_checklist_id'];
			$page_id = $_REQUEST['page_id'];
			
			foreach($_POST['import_question'] as $question_id => $value) {
				$questions	= array();
				$answers	= array();
				$actions	= array();

				//Get the database connection
				$this->db->setDb(DB_PREFIX.'checklist');

				//Get the question
				$this->db->where('question_id',$question_id);
				$question = $this->db->getOne('question');

				//Modify the identiiers
				unset($question['question_id']);
				$question['page_id'] = $page_id;

				//Insert the new question
				$questions[$question_id] = $this->db->insert('question', $question);

				//Get the answers
				$this->db->where('question_id',$question_id);
				$copyAnswers = $this->db->get('answer');

				//Modify the identiiers
				foreach($copyAnswers as $copyAnswer) {
					$data = $copyAnswer;
					unset($data['answer_id']);
					$data['question_id'] = $questions[$question_id];

					//Insert the new answers
					$answers[$copyAnswer['answer_id']] = $this->db->insert('answer', $data);
				}

				if($result = $this->db->query(sprintf('
					SELECT `report_section_id`
					FROM `%1$s`.`report_section`
					WHERE `checklist_id` = %2$d
					AND `title` = "Imported Actions";
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($checklist_id)
				))) {
					if($row = $result->fetch_object()) {
						$report_section_id = $row->report_section_id;
					}
				}
				if(!isset($report_section_id)) {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`report_section` SET
							`checklist_id` = %2$d,
							`title` = "Imported Actions";
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($checklist_id)
					));
					$report_section_id = $this->db->insert_id;
				}
				if($result = $this->db->query(sprintf('
					SELECT
						`action`.`action_id`,
						`action`.`demerits`,
						`action`.`title`,
						`action`.`summary`,
						`action`.`proposed_measure`,
						`action`.`comments`,
						`action`.`fail_factor`,
						`action`.`insta_fail`,
						`action`.`fail_point`
					FROM `%1$s`.`action_2_answer`
					LEFT JOIN `%1$s`.`action` USING(`action_id`)
					WHERE `action_2_answer`.`answer_id` IN (%2$s)
					GROUP BY `action`.`action_id`
					ORDER BY `action`.`sequence` ASC;
				',
					DB_PREFIX.'checklist',
					implode(',',array_keys($answers))
				))) {
					$sequence = 1;
					while($row = $result->fetch_object()) {
						$this->db->query(sprintf('
							INSERT INTO `%1$s`.`action` SET
								`checklist_id` = %2$d,
								`report_section_id` = %3$d,
								`sequence` = %4$d,
								`demerits` = %5$d,
								`title` = "%6$s",
								`summary` = "%7$s",
								`proposed_measure` = "%8$s",
								`comments` = "%9$s",
								`action`.`fail_factor` = %10$d,
								`action`.`insta_fail` = %11$d,
								`action`.`fail_point` = %12$d;
						',
							DB_PREFIX.'checklist',
							$checklist_id,
							$report_section_id,
							$sequence,
							$row->demerits,
							$this->db->escape_string($row->title),
							$this->db->escape_string($row->summary),
							$this->db->escape_string($row->proposed_measure),
							$this->db->escape_string($row->comments),
							$this->db->escape_string($row->fail_factor),
							$this->db->escape_string($row->insta_fail),
							$this->db->escape_string($row->fail_point)
						));
						$actions[$row->action_id] = $this->db->insert_id;
					}
					$result->close();
				}
				if($result = $this->db->query(sprintf('
					SELECT
						`commitment`.`action_id`,
						`commitment`.`merits`,
						`commitment`.`commitment`,
						`commitment`.`sequence`
					FROM `%1$s`.`commitment`
					WHERE `commitment`.`action_id` IN (%2$s)
					ORDER BY `commitment`.`sequence` ASC;
				',
					DB_PREFIX.'checklist',
					implode(',',array_keys($actions))
				))) {
					while($row = $result->fetch_object()) {
						$this->db->query(sprintf('
							INSERT INTO `%1$s`.`commitment` SET
								`action_id` = %2$d,
								`merits` = %3$d,
								`sequence` = %4$d,
								`commitment` = "%5$s";
						',
							DB_PREFIX.'checklist',
							$actions[$row->action_id],
							$row->merits,
							$row->sequence,
							$this->db->escape_string($row->commitment)
						));
					}
					$result->close();
				}
				if($result = $this->db->query(sprintf('
					SELECT
						`action_2_answer`.`action_2_answer_id`,
						`action_2_answer`.`action_id`,
						`action_2_answer`.`answer_id`,
						`action_2_answer`.`range_min`,
						`action_2_answer`.`range_max`
					FROM `%1$s`.`action_2_answer`
					WHERE `answer_id` IN (%2$s);
				',
					DB_PREFIX.'checklist',
					implode(',',array_keys($answers))
				))) {
					while($row = $result->fetch_object()) {
						$this->db->query(sprintf('
							INSERT INTO `%1$s`.`action_2_answer` SET
								`action_id` = %2$d,
								`answer_id` = %3$d,
								`range_min` = %4$d,
								`range_max` = %5$d
						',
							DB_PREFIX.'checklist',
							$actions[$row->action_id],
							$answers[$row->answer_id],
							$row->range_min,
							$row->range_max
						));
					}
					$result->close();
				}
				
				//Now insert the confirmations
				if($result = $this->db->query(sprintf('
					SELECT
						`confirmation`.`confirmation_id`,
						`confirmation`.`answer_id`,
						`confirmation`.`report_section_id`,
						`confirmation`.`arbitrary_value`,
						`confirmation`.`confirmation`
					FROM `%1$s`.`confirmation`
					WHERE `answer_id` IN (%2$s);
				',
					DB_PREFIX.'checklist',
					implode(',',array_keys($answers))
				))) {
					while($row = $result->fetch_object()) {
						$this->db->query(sprintf('
							INSERT INTO `%1$s`.`confirmation` SET
								`answer_id` = %2$d,
								`report_section_id` = %3$d,
								`arbitrary_value` = "%4$s",
								`confirmation` = "%5$s"
						',
							DB_PREFIX.'checklist',
							$answers[$row->answer_id],
							$report_section_id,
							$row->arbitrary_value,
							$row->confirmation
						));
					}
					$result->close();
				}
			}
			header('location: ?page=checklists&mode=page_edit&checklist_id='.$checklist_id.'&page_id='.$page_id);
			die();
		}
		case 'answer_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`answer` SET
					`answer_id` = %2$d,
					`question_id` = %3$d,
					`answer_string_id` = IF(%4$d != 0,%4$d,NULL),
					`sequence` = %5$d,
					`answer_type` = "%6$s",
					`range_min` = IF("%7$s" != "","%7$s",NULL),
					`range_max` = IF("%8$s" != "","%8$s",NULL),
					`range_step` = IF("%9$s" != "","%9$s",NULL),
					`range_unit` = IF("%10$s" != "","%10$s",NULL),
					`number_of_rows` = IF("%11$s" != "","%11$s",NULL),
					`default_value` = IF("%12$s" != "","%12$s",NULL),
					`function` = IF("%13$s" != "","%13$s",NULL),
					`prepend_content` = IF("%14$s" != "","%14$s",NULL),
					`append_content` = IF("%15$s" != "","%15$s",NULL),
					`calculation` = IF("%16$s" != "","%16$s",NULL),
					`function_description` = IF("%17$s" != "","%17$s",NULL),
					`alt_value` = IF("%18$s" != "","%18$s",NULL);
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['answer_id']),
				$this->db->escape_string($_POST['question_id']),
				$this->db->escape_string($_POST['answer_string_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['answer_type']),
				$this->db->escape_string($_POST['range_min']),
				$this->db->escape_string($_POST['range_max']),
				$this->db->escape_string($_POST['range_step']),
				$this->db->escape_string($_POST['range_unit']),
				$this->db->escape_string($_POST['number_of_rows']),
				$this->db->escape_string($_POST['default_value']),
				$this->db->escape_string($_POST['function']),
				$this->db->escape_string($_POST['prepend_content']),
				$this->db->escape_string($_POST['append_content']),
				$this->db->escape_string($_POST['calculation']),
				$this->db->escape_string($_POST['function_description']),
				$this->db->escape_string($_POST['alt_value'])
			));
			header('location: ?page=checklists&mode=answer_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&question_id='.$_POST['question_id'].'&answer_id='.$this->db->insert_id);
			die();
		}
		case 'answer_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`action_2_answer`
				WHERE `answer_id` = %2$d;
				
				DELETE FROM `%1$s`.`answer_2_question`
				WHERE `answer_id` = %2$d;
			
				DELETE FROM `%1$s`.`answer`
				WHERE `answer_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`action_2_answer`,
					`%1$s`.`answer_2_question`,
					`%1$s`.`answer`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['answer_id'])
			));
			header('location: ?page=checklists&mode=question_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id'].'&question_id='.$_REQUEST['question_id']);
			die();
		}
		case 'answer_string_save': {
			foreach($_POST['string'] as $string) {
				if($string != '') {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`answer_string` SET
							`string` = "%2$s";
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($string)
					));
				}
			}
			header('location: ?page=checklists&mode=answer_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&question_id='.$_POST['question_id'].'&answer_id='.$_POST['answer_id']);
			die();
		}
		case 'answer_reorder': {
			for($i=1;$i<count($_REQUEST['table-answer-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`answer` SET
						`sequence` = %2$d
					WHERE `answer_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-answer-list'][$i])
				));
			}
			die();
		}
		case 'answer_yes_no_combo': {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`answer` (`question_id`,`answer_string_id`,`sequence`,`answer_type`) VALUES
					(%2$d,1,1,"checkbox"),
					(%2$d,2,2,"checkbox");
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['question_id'])
			));
			header('location: ?page=checklists&mode=question_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id'].'&question_id='.$_REQUEST['question_id']);
			die();
		}
		case 'answer_2_question_save': {
			$index = 0;
			foreach($_POST["answer_id"] as $answer_id) {
				$this->db->query(sprintf('
					REPLACE INTO `%1$s`.`answer_2_question` SET
						`answer_2_question_id` = %2$d,
						`answer_id` = %3$d,
						`question_id` = %4$d,
						`range_min` = %5$d,
						`range_max` = %6$d,
						`comparator` = "%7$s";
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string(isset($_POST['answer_2_question_id'][$index])?$_POST['answer_2_question_id'][$index]:null),
					$this->db->escape_string($_POST['answer_id'][$index]),
					$this->db->escape_string($_POST['question_id']),
					$this->db->escape_string($_POST['range_min'][$index]),
					$this->db->escape_string($_POST['range_max'][$index]),
					$this->db->escape_string($_POST['comparator'][$index])
				));
				$index++;
			}
			header('location: ?page=checklists&mode=answer_2_question_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&question_id='.$_POST['question_id'].'&master_question_id='.$_POST['master_question_id']);
			die();
		}
		case 'answer_2_question_delete': {

			if(isset($_REQUEST['answer_2_question_id'])) {
				$this->db->multi_query(sprintf('
					DELETE FROM `%1$s`.`answer_2_question`
					WHERE `answer_2_question_id` IN (%2$s);
				
					OPTIMIZE TABLE
						`%1$s`.`answer_2_question`;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string(implode(',',$_REQUEST['answer_2_question_id']))
				));
			}
			header('location: ?page=checklists&mode=question_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id'].'&question_id='.$_REQUEST['question_id']);
			die();
		}
		case 'action_2_answer_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`action_2_answer` SET
					`action_2_answer_id` = %2$d,
					`action_id` = %3$d,
					`answer_id` = "%4$s",
					`question_id` = %7$d,
					`range_min` = %5$d,
					`range_max` = %6$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['action_2_answer_id']),
				$this->db->escape_string($_POST['action_id']),
				$this->db->escape_string($_POST['answer_id']),
				$this->db->escape_string($_POST['range_min']),
				$this->db->escape_string($_POST['range_max']),
				($_POST['answer_id'] == '-1') ? $this->db->escape_string($_POST['question_id']) : 0
			));
			if(isset($_POST['page_id']) && isset($_POST['question_id'])) {
				header('location: ?page=checklists&mode=answer_2_action_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&question_id='.$_POST['question_id'].'&answer_id='.$_POST['answer_id'].'&action_2_answer_id='.$this->db->insert_id);
			} else {
				header('location: ?page=checklists&mode=action_2_answer_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$_POST['action_id'].'&action_2_answer_id='.$this->db->insert_id);
			}
			die();
		}
		case 'action_2_answer_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`action_2_answer`
				WHERE `action_2_answer_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`action_2_answer;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['action_2_answer_id'])
			));
			if(isset($_REQUEST['page_id']) && isset($_REQUEST['question_id'])) {
				header('location: ?page=checklists&mode=question_edit&chcklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id'].'&question_id='.$_REQUEST['question_id']);
			} else {
				header('location: ?page=checklists&mode=action_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id'].'&action_id='.$_REQUEST['action_id']);
			}
			die();
		}
		// -- Start of international report section --
		/*case 'international_report_section_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`international_report_section` SET
					`international_report_section_id` = %2$d,
					`report_section_id` = %3$d,
					`country_id` = %4$d,
					`content` = "%5$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['international_report_section_id']),
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['country_id']),
				$this->db->escape_string($_POST['content'])
			));
			header('location: ?page=checklists&mode=international_report_section_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&international_report_section_id='.$this->db->insert_id);
			die();
		}
		case 'international_report_section_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`international_report_section`
				WHERE `international_report_section_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['international_report_section_id'])
			));
			header('location: ?page=checklists&mode=report_section_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id']);
			die();
		}*/
		
		// -- Start of international action section --
		case 'international_action_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`international_action` SET
					`international_action_id` = %2$d,
					`report_section_id` = %3$d,
					`action_id` = %4$d,
					`country_id` = %5$d,
					`proposed_measure` = "%6$s",
					`comments` = "%7$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['international_action_id']),
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['action_id']),
				$this->db->escape_string($_POST['country_id']),
				$this->db->escape_string($_POST['proposed_measure']),
				$this->db->escape_string($_POST['comments'])
			));
			header('location: ?page=checklists&mode=international_action_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$_POST['action_id'].'&international_action_id='.$this->db->insert_id);
			die();
		}
		case 'international_action_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`international_action`
				WHERE `international_action_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['international_action_id'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id'].'&action_id='.$_REQUEST['action_id']);
			die();
		}
		
		// -- Start of international confirmation section --
		/*case 'international_confirmation_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`international_confirmation` SET
					`international_confirmation_id` = %2$d,
					`report_section_id` = %3$d,
					`confirmation_id` = %4$d,
					`country_id` = %5$d,
					`confirmation` = "%6$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['international_confirmation_id']),
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['confirmation_id']),
				$this->db->escape_string($_POST['country_id']),
				$this->db->escape_string($_POST['confirmation'])
			));
			header('location: ?page=checklists&mode=international_confirmation_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&confirmation_id='.$_POST['confirmation_id'].'&international_confirmation_id='.$this->db->insert_id);
			die();
		}
		case 'international_confirmation_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`international_confirmation`
				WHERE `international_confirmation_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['international_confirmation_id'])
			));
			header('location: ?page=checklists&mode=confirmation_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id'].'&confirmation_id='.$_REQUEST['confirmation_id']);
			die();
		}*/
		
		case 'report_section_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`report_section` SET
					`report_section_id` = %2$d,
					`checklist_id` = %3$d,
					`sequence` = %4$d,
					`title` = "%5$s",
					`content` = "%6$s",
					`display_in_pdf` = %7$d,
					`display_in_html` = %8$d,
					`multi_site` = %9$d,
					`output` = IF("%10$s" != "","%10$s",NULL);
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['title']),
				$this->db->escape_string($_POST['content']),
				$this->db->escape_string($_POST['display_in_pdf']),
				$this->db->escape_string($_POST['display_in_html']),
				$this->db->escape_string($_POST['multi_site']),
				$this->db->escape_string(isset($_POST['output']) ? $_POST['output'] : NULL)
			));
			header('location: ?page=checklists&mode=report_section_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$this->db->insert_id);
			die();
		}
		case 'report_section_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`action_2_answer`
				WHERE `action_id` IN (
					SELECT `action_id`
					FROM `%1$s`.`action`
					WHERE `report_section_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`commitment`
				WHERE `action_id` IN (
					SELECT `action_id`
					FROM `%1$s`.`action`
					WHERE `report_section_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`action`
				WHERE `report_section_id` = %2$d;
			
				DELETE FROM `%1$s`.`report_section`
				WHERE `report_section_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`action_2_answer`,
					`%1$s`.`commitment`,
					`%1$s`.`action`,
					`%1$s`.`report_section;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['report_section_id'])
			));
			header('location: ?page=checklists&mode=report_section_list&checklist_id='.$_REQUEST['checklist_id']);
			die();
		}
		case 'report_section_reorder': {
			for($i=1;$i<count($_REQUEST['table-report-section-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`report_section` SET
						`sequence` = %2$d
					WHERE `report_section_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-report-section-list'][$i])
				));
			}
			die();
		}
		case 'action_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`action` SET
					`action_id` = %2$d,
					`checklist_id` = %3$d,
					`report_section_id` = %4$d,
					`sequence` = %5$d,
					`demerits` = %6$d,
					`title` = "%7$s",
					`summary` = "%8$s",
					`proposed_measure` = "%9$s",
					`comments` = "%10$s",
					`fail_factor` = %11$d,
					`insta_fail` = %12$d,
					`fail_point` = %13$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['action_id']),
				$this->db->escape_string($_POST['checklist_id']),
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['demerits']),
				$this->db->escape_string($_POST['title']),
				$this->db->escape_string($_POST['summary']),
				$this->db->escape_string($_POST['proposed_measure']),
				$this->db->escape_string($_POST['comments']),
				$this->db->escape_string($_POST['fail_factor']),
				$this->db->escape_string($_POST['insta_fail']),
				$this->db->escape_string($_POST['fail_point'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$this->db->insert_id);
			die();
		}
		case 'resource_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`resource` SET
					`resource_id` = %2$d,
					`action_id` = %3$d,
					`resource_type_id` = %4$d,
					`sequence` = %5$d,
					`url` = "%6$s",
					`description` = "%7$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['resource_id']),
				$this->db->escape_string($_POST['action_id']),
				$this->db->escape_string($_POST['resource_type_id']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['url']),
				$this->db->escape_string($_POST['description'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$_POST['action_id']);
			die();
		}
		case 'resource_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`resource`
				WHERE `resource_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['resource_id'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id'].'&action_id='.$_REQUEST['action_id']);
			die();
		}
		case 'action_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`action_2_answer`
				WHERE `action_id` = %2$d;
				
				DELETE FROM `%1$s`.`commitment`
				WHERE `action_id` = %2$d;
			
				DELETE FROM `%1$s`.`action`
				WHERE `action_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`action_2_answer`,
					`%1$s`.`commitment`,
					`%1$s`.`action`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['action_id'])
			));
			header('location: ?page=checklists&mode=report_section_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id']);
			die();
		}
		case 'action_duplicate': {
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`action` (`checklist_id`,`report_section_id`,`sequence`,`demerits`,`title`,`summary`,`proposed_measure`,`comments`,`fail_factor`,`insta_fail`,`fail_point`)
				SELECT
					`action`.`checklist_id`,
					`action`.`report_section_id`,
					`action`.`sequence`,
					`action`.`demerits`,
					`action`.`title`,
					`action`.`summary`,
					`action`.`proposed_measure`,
					`action`.`comments`,
					`action`.`fail_factor`,
					`action`.`insta_fail`,
					`action`.`fail_point`
				FROM `%1$s`.`action`
				WHERE `action`.`action_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['action_id'])
			));
			$new_action_id = $this->db->insert_id;
			$this->db->multi_query(sprintf('
				INSERT INTO `%1$s`.`action_2_answer` (`action_id`,`answer_id`,`range_min`,`range_max`)
				SELECT
					%2$d,
					`action_2_answer`.`answer_id`,
					`action_2_answer`.`range_min`,
					`action_2_answer`.`range_max`
				FROM `%1$s`.`action_2_answer`
				WHERE `action_2_answer`.`action_id` = %3$d;
				INSERT INTO `%1$s`.`commitment` (`action_id`,`merits`,`sequence`,`commitment`)
				SELECT
					%2$d,
					`commitment`.`merits`,
					`commitment`.`sequence`,
					`commitment`.`commitment`
				FROM `%1$s`.`commitment`
				WHERE `commitment`.`action_id` = %3$d;
			',
				DB_PREFIX.'checklist',
				$new_action_id,
				$this->db->escape_string($_POST['action_id'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$new_action_id);
			die();
		}
		case 'action_reorder': {
			for($i=1;$i<count($_REQUEST['table-action-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`action` SET
						`sequence` = %2$d
					WHERE `action_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-action-list'][$i])
				));
			}
			die();
		}
		case 'commitment_save': {
			/*$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`commitment` SET
					`commitment_id` = %2$d,
					`action_id` = %3$d,
					`commitment_fieldset_id` = %4$d,
					`merits` = %5$d,
					`sequence` = %6$d,
					`commitment` = "%7$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['commitment_id']),
				$this->db->escape_string($_POST['action_id']),
				$this->db->escape_string($_POST['commitment_fieldset_id']),
				$this->db->escape_string($_POST['merits']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['commitment'])
			));*/
            $this->db->query(sprintf('
				REPLACE INTO `%1$s`.`commitment` SET
					`commitment_id` = %2$d,
					`action_id` = %3$d,
					`merits` = %4$d,
					`sequence` = %5$d,
					`commitment` = "%6$s";
			',
                DB_PREFIX.'checklist',
                $this->db->escape_string($_POST['commitment_id']),
                $this->db->escape_string($_POST['action_id']),
                $this->db->escape_string($_POST['merits']),
                $this->db->escape_string($_POST['sequence']),
                $this->db->escape_string($_POST['commitment'])
            ));
			header('location: ?page=checklists&mode=commitment_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&action_id='.$_POST['action_id'].'&commitment_id='.$this->db->insert_id);
			die();
		}
		case 'commitment_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`commitment`
				WHERE `commitment_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`commitment`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['commitment_id'])
			));
			header('location: ?page=checklists&mode=action_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id'].'&action_id='.$_REQUEST['action_id']);
			die();
		}
		case 'commitment_reorder': {
			for($i=1;$i<count($_REQUEST['table-commitment-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`commitment` SET
						`sequence` = %2$d
					WHERE `commitment_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-commitment-list'][$i])
				));
			}
			die();
		}
		case 'resource_reorder': {
			for($i=1;$i<count($_REQUEST['table-resource-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`resource` SET
						`sequence` = %2$d
					WHERE `resource_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-resource-list'][$i])
				));
			}
			die();
		}
		case 'metric_group_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`metric_group` SET
					`metric_group_id` = %2$d,
					`page_id` = %3$d,
					`name` = "%4$s",
					`description` = "%5$s",
					`metric_group_type_id` = %6$d,
					`sequence` = %7$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['metric_group_id']),
				$this->db->escape_string($_POST['page_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['description']),
				$this->db->escape_string($_POST['metric_group_type_id']),
				$this->db->escape_string($_POST['sequence'])
			));
			header('location: ?page=checklists&mode=metric_group_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&metric_group_id='.$this->db->insert_id);
			die();
		}
		case 'form_group_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`form_group` SET
					`form_group_id` = %2$d,
					`page_id` = %3$d,
					`name` = "%4$s",
					`description` = "%5$s",
					`repeatable` = %6$d,
					`min_rows` = %7$d,
					`max_rows` = %8$d,
					`repeat_question` = %9$d,
					`css_class` = "%10$s",
					`sortable` = %11$d,
					`show_order` = %12$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['form_group_id']),
				$this->db->escape_string($_POST['page_id']),
				$this->db->escape_string($_POST['name']),
				$this->db->escape_string($_POST['description']),
				$this->db->escape_string($_POST['repeatable']),
				$this->db->escape_string($_POST['min_rows']),
				$this->db->escape_string($_POST['max_rows']),
				$this->db->escape_string($_POST['repeat_question']),
				$this->db->escape_string($_POST['css_class']),
				$this->db->escape_string($_POST['sortable']),
				$this->db->escape_string($_POST['show_order'])
			));
			header('location: ?page=checklists&mode=form_group_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&form_group_id='.$this->db->insert_id);
			die();
		}

		case 'form_group_delete': {
			$this->db->multi_query(sprintf('
				UPDATE `%1$s`.`question` SET
					`form_group_id` = NULL
				WHERE form_group_id = %2$d;

				DELETE FROM `%1$s`.`form_group`
				WHERE `form_group_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['form_group_id'])
			));
			header('location: ?page=checklists&mode=page_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id']);
			die();
		}
		case 'metric_group_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`metric_unit_type_2_metric`
				WHERE `metric_id` IN (
					SELECT `metric_id`
					FROM `%1$s`.`metric`
					WHERE `metric_group_id` = %2$d
				);
				
				DELETE FROM `%1$s`.`metric`
				WHERE `metric_group_id` = %2$d;
			
				DELETE FROM `%1$s`.`metric_group`
				WHERE `metric_group_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`metric_unit_type_2_metric`,
					`%1$s`.`metric`,
					`%1$s`.`metric_group`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['metric_group_id'])
			));
			header('location: ?page=checklists&mode=page_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id']);
			die();
		}
		case 'confirmation_save': {
			
				$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`confirmation` SET
					`confirmation_id` = %2$d,
					`answer_id` = %3$d,
					`report_section_id` = %4$d,
					`arbitrary_value` = %5$d,
					`confirmation` = "%6$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['confirmation_id']),
				$this->db->escape_string($_POST['answer-id']),
				$this->db->escape_string($_POST['report_section_id']),
				$this->db->escape_string($_POST['arbitrary-value']),
				$this->db->escape_string($_POST['confirmation'])
			));
			header('location: ?page=checklists&mode=confirmation_edit&checklist_id='.$_POST['checklist_id'].'&report_section_id='.$_POST['report_section_id'].'&confirmation_id='.$this->db->insert_id);
			die();
		}
		case 'confirmation_delete': {
				$this->db->query(sprintf('
				DELETE FROM `%1$s`.`confirmation`
				WHERE `confirmation_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['confirmation_id'])
			));
			header('location: ?page=checklists&mode=report_section_edit&checklist_id='.$_REQUEST['checklist_id'].'&report_section_id='.$_REQUEST['report_section_id']);
			die();
		}
		case 'metric_save': {

			//Set the metric values
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`metric` SET
					`metric_id` = %2$d,
					`metric_group_id` = %3$d,
					`metric` = "%4$s",
					`sequence` = %5$d,
					`max_duration` = %6$d,
					`help` = "%7$s",
					`required` = %8$d,
					`max_variation` = %9$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['metric_id']),
				$this->db->escape_string($_POST['metric_group_id']),
				$this->db->escape_string($_POST['metric']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['max_duration']),
				$this->db->escape_string($_POST['help']),
				$this->db->escape_string($_POST['required']),
				$this->db->escape_string($_POST['max_variation'])
			));
			$metric_id = $this->db->insert_id;

			//Delete all metric_unit_type_2_metric settings
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`metric_unit_type_2_metric` WHERE `metric_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$metric_id
			));

			if(is_array($_POST['metric_unit_type'])) {
				foreach($_POST['metric_unit_type'] as $metric_unit_type_id) {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`metric_unit_type_2_metric` SET
							`metric_unit_type_id` = %2$d,
							`metric_id` = %3$d,
							`conversion` = "%4$s",
							`default` = %5$d;
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($metric_unit_type_id),
						$this->db->escape_string($metric_id),
						isset($_POST['metric_unit_conversion'][$metric_unit_type_id]) ? $_POST['metric_unit_conversion'][$metric_unit_type_id] : null,
						isset($_POST['default_metric_unit_type']) && $_POST['default_metric_unit_type'] == $metric_unit_type_id ? 1 : 0
					));
				}
			}
			$this->db->query(sprintf('
				OPTIMIZE TABLE `%1$s`.`metric_unit_type_2_metric`;
			',
				DB_PREFIX.'checklist'
			));
			header('location: ?page=checklists&mode=metric_edit&checklist_id='.$_POST['checklist_id'].'&page_id='.$_POST['page_id'].'&metric_group_id='.$_POST['metric_group_id'].'&metric_id='.$metric_id);
			die();
		}
		case 'metric_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`metric_unit_type_2_metric`
				WHERE `metric_id` = %2$d;
				
				DELETE FROM `%1$s`.`metric`
				WHERE `metric_id` = %2$d;
				
				OPTIMIZE TABLE
					`%1$s`.`metric_unit_type_2_metric`,
					`%1$s`.`metric_id`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['metric_id'])
			));
			header('location: ?page=checklists&mode=metric_group_edit&checklist_id='.$_REQUEST['checklist_id'].'&page_id='.$_REQUEST['page_id'].'&metric_group_id='.$_REQUEST['metric_group_id']);
			die();
		}
		case 'audit_save': {
				$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`audit` SET
					`audit_id` = %2$d,
					`answer_id` = %3$d,
					`arbitrary_value` = %4$d,
					`audit_type` = "%5$s";
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['audit_id']),
				$this->db->escape_string($_POST['answer-id']),
				$this->db->escape_string($_POST['arbitrary-value']),
				$this->db->escape_string($_POST['audit_type'])
			));
			header('location: ?page=checklists&mode=audit_edit&checklist_id='.$_POST['checklist_id'].'&audit_id='.$this->db->insert_id);
			die();
		}
		case 'audit_delete': {
				$this->db->query(sprintf('
				DELETE FROM `%1$s`.`audit`
				WHERE `audit_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['audit_id'])
			));
			header('location: ?page=checklists&mode=audit_list&checklist_id='.$_REQUEST['checklist_id']);
			die();
		}
		case 'page_section_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`page_section`
				WHERE `page_section_id` = %2$d;
				
				DELETE FROM `%1$s`.`page_section_2_page`
				WHERE `page_section_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['page_section_id'])
			));
			header('location: ?page=checklists&mode=page_section_list&checklist_id='.$_REQUEST['checklist_id']);
			die();
		}
		case 'page_section_reorder': {
			for($i=1;$i<count($_REQUEST['table-page-section-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`page_section` SET
						`sequence` = %2$d
					WHERE `page_section_id` = %3$d;
				',
					DB_PREFIX.'checklist',
					$i,
					$this->db->escape_string($_REQUEST['table-page-section-list'][$i])
				));
			}
			die();
		}
		
		case 'page_section_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`page_section` SET
					`page_section_id` = %2$d,
					`title` = "%3$s",
					`sequence` = %4$d,
					`checklist_id` = %5$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_POST['page_section_id']),
				$this->db->escape_string($_POST['title']),
				$this->db->escape_string($_POST['sequence']),
				$this->db->escape_string($_POST['checklist_id'])
			));
			header('location: ?page=checklists&mode=page_section_list&checklist_id='.$_POST['checklist_id']);
			die();
		}
		
		case 'page_section_unlink_page': {
			if(isset($_REQUEST['page_section_2_page'])) {
				foreach($_REQUEST['page_section_2_page'] as $page_section_2_page) {
					$this->db->query(sprintf('
						DELETE FROM `%1$s`.`page_section_2_page`
						WHERE `page_section_2_page_id` = %2$d;
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($page_section_2_page)
					));
				}
			}
			
			header('Location: ?page=checklists&mode=page_section_edit&page_section_id='.$_REQUEST['page_section_id']."&checklist_id=".$_REQUEST['checklist_id']);
			die();
		}
		
		case 'page_section_link_page': {
			if(isset($_REQUEST['page_id'])) {
				foreach($_REQUEST['page_id'] as $page_id) {
					$this->db->query(sprintf('
						INSERT INTO `%1$s`.`page_section_2_page`
							(page_section_id, page_id)
						VALUES (%2$d, %3$d);
					',
						DB_PREFIX.'checklist',
						$this->db->escape_string($_REQUEST['page_section_id']),
						$this->db->escape_string($page_id)
					));
				}
			}
			header('Location: ?page=checklists&mode=page_section_edit&page_section_id='.$_REQUEST['page_section_id']."&checklist_id=".$_REQUEST['checklist_id']);
			die();
		}

		case 'import_content':
			if(isset($_FILES['import_content_file']) && isset($_POST['checklist_id'])) {
				ini_set('auto_detect_line_endings',TRUE);
				$handle = fopen($_FILES['import_content_file']['tmp_name'],'r');
				$header = array();
				$content = array();
				$index = 0;
				while ( ($row = fgetcsv($handle) ) !== FALSE ) {
					if($index === 0) {
						$header = $row;
					} else {
						$data = array();
						foreach($row as $key=>$val) {
							$data[$header[$key]] = $val;
						}
						$content[] = $data;
					}
					$index++;
				}

				$checklist_id = $_POST['checklist_id'];
				$this->db->setDb(DB_PREFIX.'checklist');

				foreach($content as $row) {
					$row['checklist_id'] = $checklist_id;
					foreach($header as $field) {
						switch($field) {
							case 'page_section_title':
									$this->db->where('checklist_id',$row['checklist_id']);
									$this->db->where('title', $row['page_section_title']);
									$result = $this->db->get('page_section',1);

									if($this->db->count > 0) {
										$row['page_section_id'] = $result[0]['page_section_id'];
									} else {
										$row['page_section_id'] = $this->db->insert('page_section',['checklist_id' => $row['checklist_id'], 'title' => $row[$field]]);
									}

								break;

							case 'page_title':
									$this->db->join('page_section_2_page', 'page_section_2_page.page_id=page.page_id', 'LEFT');
									$this->db->where('checklist_id',$row['checklist_id']);
									$this->db->where('title', $row['page_title']);
									$this->db->where('page_section_id', $row['page_section_id']);
									$result = $this->db->get('page', 1);

									if($this->db->count > 0) {
										$row['page_id'] = $result[0]['page_id'];
									} else {
										$row['page_id'] = $this->db->insert('page',['checklist_id' => $row['checklist_id'], 'title' => $row[$field]]);
									}

									//Set page_section_2_page link
									if(isset($row['page_section_id']) && isset($row['page_id'])) {
										$this->db->where('page_section_id',$row['page_section_id']);
										$this->db->where('page_id', $row['page_id']);
										$result = $this->db->get('page_section_2_page',1);

										if($this->db->count > 0) {
											$row['page_section_2_page_id'] = $result[0]['page_section_2_page_id'];
											$this->db->where('page_section_2_page_id', $result[0]['page_section_2_page_id']);
											$this->db->update('page_section_2_page',['page_section_id' => $row['page_section_id'], 'page_id' => $row['page_id']]);
										} else {
											$row['page_section_2_page_id'] = $this->db->insert('page_section_2_page',['page_section_id' => $row['page_section_id'], 'page_id' => $row['page_id']]);
										}
									}
								break;

								case 'question':

										$question = array();
										$question['question'] = $row['question'];
										$question['multiple_answer'] = isset($row['multiple_answer']) ? $row['multiple_answer'] : 0;
										$question['required'] = isset($row['required']) ? $row['required'] : 0;
										$question['checklist_id'] = isset($row['checklist_id']) ? $row['checklist_id'] : null;
										$question['page_id'] = isset($row['page_id']) ? $row['page_id'] : null;
										$question['sequence'] = isset($row['question_sequence']) && is_numeric($row['question_sequence']) ? $row['question_sequence'] : null;

										$this->db->where('checklist_id',$row['checklist_id']);
										$this->db->where('page_id',$row['page_id']);
										$this->db->where('question', $row['question']);
										$result = $this->db->get('question',1);

										if(!is_null($question['checklist_id']) && !is_null($question['page_id'])) {
											if($this->db->count > 0) {
												$row['question_id'] = $result[0]['question_id'];
												$this->db->where('question_id', $result[0]['question_id']);
												$this->db->update('question', $question);
											} else {
												$row['question_id'] = $this->db->insert('question', $question);
											}
										}
									break;

								case 'answer':

										if(isset($row['question_id'])) {
											if(isset($row['answer']) && $row['answer'] != '') {
												$this->db->where('string', $row['answer']);
												$result = $this->db->get('answer_string',1);
												$row['answer_string_id'] = $this->db->count > 0 ? $result[0]['answer_string_id'] : $this->db->insert('answer_string', ['string' => $row['answer']]);
											}

											$this->db->where('question_id', $row['question_id']);
											if(isset($row['answer_string_id'])) {
												$this->db->where('answer_string_id', $row['answer_string_id']);
											}
											$result = $this->db->get('answer',1);

											$answer = array();
											$answer['question_id'] = $row['question_id'];
											$answer['answer_string_id'] = isset($row['answer_string_id']) ? $row['answer_string_id'] : null;
											$answer['answer_type'] = isset($row['answer_type']) ? $row['answer_type'] : null;
											$answer['sequence'] = isset($row['answer_sequence']) && is_numeric($row['answer_sequence']) ? $row['answer_sequence'] : null;

											if($this->db->count > 0) {
												$row['answer_id'] = $result[0]['answer_id'];
												$this->db->where('answer_id', $row['answer_id']);
												$this->db->update('answer',$answer);
											} else {
												$row['answer_id'] = $this->db->insert('answer',$answer);
											}
										}
									break;
						}
					}
				}
			}

		break;
	}
}

//Get all of the data from the database for rendering content/information to the admin pages
if($result = $this->db->query(sprintf('
	SELECT
		`checklist`.*,
		COUNT(`client_checklist`.`client_checklist_id`) AS `num_clients`
	FROM `%1$s`.`checklist`
	LEFT JOIN `%1$s`.`client_checklist` USING(`checklist_id`)
	GROUP BY `checklist`.`checklist_id`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist');
	}
	$result->close();
}

//Get the country list
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`country`;
',
	DB_PREFIX.'resources'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'country');
	}
	$result->close();
}

//Get the grid_layout
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`grid_layout`
	ORDER BY `col` DESC;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'grid_layout');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT
		`checklist_variation`.*,
		COUNT(`client_checklist`.`client_checklist_id`) AS `num_clients`
	FROM `%1$s`.`checklist_variation`
	LEFT JOIN `%1$s`.`client_checklist` USING(`checklist_variation_id`)
	GROUP BY `checklist_variation`.`checklist_variation_id`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'checklist_variation');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`certification_level`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'certification_level');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`confirmation`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'confirmation');
	}
	$result->close();
}

//Get the audit details
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`audit`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'audit');
	}
	$result->close();
}

//Get a separate all_pages node for question, answer, action dupliation script
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`page`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'all_pages');
	}
	$result->close();
}

//Get all of thr resource types
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`resource_type`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'resource_type');
	}
	$result->close();
}

//Limit by checklist id for speed improvement
//Only return if the checklist_id request variable is set
if(isset($_REQUEST['checklist_id'])){
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`page`
		WHERE `checklist_id` = "%2$d"
		ORDER BY `page`.`sequence`;
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'page');
		}
		$result->close();
	}
	
	//Limit by checklist id for speed imrpovement
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`question`
		WHERE `checklist_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'question');
		}
		$result->close();
	}

	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`field_permission`;
	',
		DB_PREFIX.'checklist'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'field_permission');
		}
		$result->close();
	}
	
	//Limit by question id for speed improvement
	if($result = $this->db->query(sprintf('
		SELECT `answer`.*
			FROM `%1$s`.`question`
			LEFT JOIN `%1$s`.`answer` ON `answer`.`question_id` = `question`.`question_id`
			WHERE `question`.`checklist_id` = "%2$d"
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'answer');
		}
		$result->close();
	}
	
	//Limit by checklist id for speed improvement
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`report_section`
		WHERE `checklist_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'report_section');
		}
		$result->close();
	}
	
	//Limit by checklist id for speed improvement
	//Get the possible scoring issues
	if($result = $this->db->query(sprintf('
		SELECT
			`action`.`action_id`,
			`action`.`checklist_id`,
			`action`.`report_section_id`,
			`action`.`demerits`,
			`action`.`fail_factor`,
			`action`.`insta_fail`,
			`action`.`fail_point`
		FROM `%1$s`.`action`
		WHERE `action`.`action_id` NOT IN (
			SELECT
			`action`.`action_id`
			FROM `%1$s`.`commitment`
			LEFT JOIN `%1$s`.`action` ON `commitment`.`action_id` = `action`.`action_id`
			WHERE `commitment`.`merits` = `action`.`demerits`
		)
		AND `action`.`checklist_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'problem_action');
		}
		$result->close();
	}
	
	//Limit by checklist_id for performance
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`action`
		WHERE `checklist_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$tmpDoc = new DOMDocument('1.0','UTF-8');
			$row->proposed_measure_wellformed = @$tmpDoc->loadXML('<body>'.$row->proposed_measure.'</body>') ? ($row->proposed_measure != strlen(strip_tags($row->proposed_measure)) ? '1' : '0') : '0';
			$row->comments_wellformed = @$tmpDoc->loadXML('<body>'.$row->comments.'</body>') ? ($row->comments != strlen(strip_tags($row->comments)) ? '1' : '0') : '0';
			$this->row2config($row,'action');
		}
		$result->close();
	}

	//Get the resource_2_action
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`resource`
		WHERE `action_id` IN(
			SELECT
			`action`.`action_id`
			FROM `%1$s`.`action`
			WHERE `action`.`checklist_id` = "%2$d"
		);
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'resource');
		}
		$result->close();
	}
}

//Form Group
if(isset($_REQUEST['page_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`form_group`
		WHERE `page_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['page_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'form_group');
		}
		$result->close();
	}
}


if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`answer_string`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'answer_string');
	}
	$result->close();
}

//Get the international report section list
//Only return if the report_section_id request variable is set
/*if(isset($_REQUEST['report_setion_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`international_report_section`
		WHERE `report_section_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['report_section_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'international_report_section');
		}
		$result->close();
	}
}*/

//Get the international action list
//Limit by action_id for speed improvement
if(isset($_REQUEST['action_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`international_action`
		WHERE `action_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['action_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'international_action');
		}
		$result->close();
	}
}

//Get the international confirmation list
//Limit by confirmation_id for speed improvement
/*
if(isset($_REQUEST['confirmation_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`international_confirmation`
		WHERE `confirmation_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['confirmation_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'international_confirmation');
		}
		$result->close();
	}
}*/

if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`commitment`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'commitment');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`action_2_answer`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'action_2_answer');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`answer_2_question`;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'answer_2_question');
	}
	$result->close();
}
/*if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`commitment_fieldset`
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'commitment_fieldset');
	}
	$result->close();
}*/
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`metric`
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'metric');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`metric_unit_type`
	ORDER BY `metric_unit_type` ASC;
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'metric_unit_type');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`metric_unit_type_2_metric`
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'metric_unit_type_2_metric');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`metric_group`
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'metric_group');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`metric_group_type`
',
	DB_PREFIX.'checklist'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'metric_group_type');
	}
	$result->close();
}

//Used for importing checklist quetions from another assessment
//Limit by checklist id for speed improvement
//Only return if the import_checklist_id request variable is set
if(isset($_REQUEST['import_checklist_id'])){
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`page`
		WHERE `checklist_id` = "%2$d";
	',
		DB_PREFIX.'checklist',
		$_REQUEST['import_checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'import_checklist_page');
		}
		$result->close();
	}
	
	//Limit by checklist id for speed imrpovement
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`question`
		WHERE `checklist_id` = "%2$d"
		ORDER BY `question`.`sequence`;
	',
		DB_PREFIX.'checklist',
		$_REQUEST['import_checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'import_checklist_question');
		}
		$result->close();
	}
}

if(isset($_REQUEST['checklist_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`page_section`
		WHERE `checklist_id` = %2$d
		ORDER BY `page_section`.`sequence`;
	',
		DB_PREFIX.'checklist',
		$_REQUEST['checklist_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'page_section');
		}
		$result->close();
	}
	if($result = $this->db->query(sprintf('
		SELECT 
		page_section_2_page.page_section_2_page_id,
		page_section_2_page.page_section_id,
		page_section_2_page.page_id,
		page.sequence
		FROM `%1$s`.`page_section_2_page`
		LEFT JOIN %1$s.page ON page_section_2_page.page_id = page.page_id
		ORDER BY `page`.`sequence`;
	',
		DB_PREFIX.'checklist'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'page_section_2_page');
		}
		$result->close();
	}
}
?>