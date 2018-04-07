<?php

use Slim\Http\Request;
use Slim\Http\Response;

/**
 * API Version 2
 */
$app->group('/v2', function() use ($app) {

    //Auth
    $app->group('/auth', function() use ($app) {
        $app->post('/login', 'Auth:login');
    });
    
    //Clients
    $app->group('/clients', function() use ($app) {

        $app->get('', 'Clients:getClients');
        $app->post('', 'Clients:setClient');

        //Client Roles
        $app->group('/roles', function() use ($app) {

            $app->get('', 'ClientRoles:getClientRoles');
            $app->post('', 'ClientRoles:setClientRole');

            $app->get('/members', 'ClientRoles:getClientToRoles');
            $app->post('/members', 'ClientRoles:setClientToRole');

        });

        $app->get('/types', 'Clients:getClientTypes');

        $app->get('/{client_id}', 'Clients:getClients');
        $app->delete('/{client_id}', 'Clients:deleteClient');

        //Client Contacts
        $app->group('/{client_id}/contacts', function() use ($app) {
            $app->get('', 'ClientContacts:getClientContacts');
            $app->get('/{client_contact_id}', 'ClientContacts:getClientContacts');

            $app->post('', 'ClientsContacts:setClientContact');
        });

        //Client Checklists
        $app->group('/{client_id}/checklists', function() use ($app) {
            $app->get('', 'ClientChecklists:getClientChecklists');
            $app->post('', 'ClientChecklists:setClientChecklist');

            $app->get('/{client_checklist_id}', 'ClientChecklists:getClientChecklists');

            $app->get('/{client_checklist_id}/results', 'ClientChecklists:getClientChecklistResults');
            $app->post('/{client_checklist_id}/results', 'ClientChecklists:setClientChecklistResult');
            $app->delete('/{client_checklist_id}/results', 'ClientChecklists:deleteClientChecklistResults');
        });   
    });

    //Checklists    
    $app->group('/checklists', function() use ($app) {

        $app->get('', 'Checklists:getChecklists');
        $app->get('/{checklist_id}', 'Checklists:getChecklists');
        $app->get('/{checklist_id}/questionAnswers', 'Checklists:getQuestionAnswers');

        //Pages
        $app->group('/{checklist_id}/pages', function() use ($app) {
            $app->get('', 'Checklists:getPages');
            $app->get('/{page_id}', 'Checklists:getPages');
            
            //Questions
            $app->group('/{page_id}/questions', function() use ($app) {
                $app->get('', 'Checklists:getQuestions');
                $app->get('/{question_id}', 'Checklists:getQuestions');
                
                //Answers
                $app->group('/{question_id}/answers', function() use ($app) {
                    $app->get('', 'Checklists:getAnswers');
                    $app->get('/{answer_id}', 'Checklists:getAnswers');                
                });
            });
        });
            
        //Questions
        $app->group('/{checklist_id}/questions', function() use ($app) {
            $app->get('', 'Checklists:getQuestions');
            $app->get('/{question_id}', 'Checklists:getQuestions');
            
            //Answers
            $app->group('/{question_id}/answers', function() use ($app) {
                $app->get('', 'Checklists:getAnswers');
                $app->get('/{answer_id}', 'Checklists:getAnswers');                
            });
        });
    
        //Client Checklists
        $app->group('/{checklist_id}/clientChecklists', function() use ($app) {
            $app->get('', 'Checklists:getClientChecklists');
            $app->delete('', 'Checklists:deleteClientChecklists');

            $app->get('/results', 'Checklists:getResults');
            $app->get('/{client_checklist_id}', 'ClientChecklists:getClientChecklists');
        });

        //Import Profile
        $app->group('/{checklist_id}/importProfiles', function() use ($app) {
            $app->get('', 'Checklists:getImportProfiles');
            $app->get('/{import_profile_id}', 'Checklists:getImportProfiles');
            $app->get('/{import_profile_id}/maps', 'Checklists:getImportProfileMaps');
        });   
    });
});