<?php
namespace GreenBizCheck;

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class Export extends Core {

    /**
     * Export Excel
     *
     * @param array $client_id
     * @param array $client_checklist_id
     * @return void
     */
    public function excel($clients, $checklists) {
        //Set default value id array is empty
        !empty($clients) ?: $clients[] = null;
        !empty($checklists) ?: $checklists[] = null;

        //Set the memory limit
        ini_set('memory_limit', '-1');
        $limit = 10000;
        $spreadsheet = new Spreadsheet();
        $spreadsheet->removeSheetByIndex(0);

        //Client Sheet
        $clientSheet = new Worksheet($spreadsheet, 'Clients');
        $spreadsheet->addSheet($clientSheet, 0);
        $clientSheet->fromArray(['Client ID', 'Company Name', 'Address Line 1', 'Address Line 2', 'Suburb', 'State', 'Postcode', 'Country'], NULL, 'A1');

        $results = $this->db->where('c.client_id', $clients, 'IN')
            ->get(DB_PREFIX.'core.client c', NULL, 'c.client_id, c.company_name, c.address_line_1, c.address_line_2, c.suburb, c.state, c.postcode, c.country');
        $clientSheet->fromArray($results, NULL, 'A2');

        // User Sheet
        $usersSheet = new Worksheet($spreadsheet, 'Users');
        $spreadsheet->addSheet($usersSheet, 1);
        $usersSheet->fromArray(['Client Contract ID', 'Client ID', 'Company Name', 'FirstName', 'LastName', 'Email', 'Phone'], NULL, 'A1');

        $results = $this->db->where('cc.client_id', $clients, 'IN')
            ->join(DB_PREFIX.'core.client c', 'c.client_id = cc.client_id', 'LEFT')
            ->orderby('cc.client_contact_id', 'asc')
            ->get(DB_PREFIX.'core.client_contact cc', NULL, 'cc.client_contact_id, cc.client_id, c.company_name, cc.firstname, cc.lastname, cc.email, cc.phone');
        $usersSheet->fromArray($results, NULL, 'A2');

        //Checklists
        $results = $this->db->where('cc.checklist_id', NULL, 'IS NOT')
            ->where('cc.checklist_id', $checklists, 'IN')
            ->where('cc.client_id', $clients, 'IN')
            ->join(DB_PREFIX.'checklist.client_checklist cc', 'cc.client_checklist_id=cr.client_checklist_id', 'LEFT')
            ->join(DB_PREFIX.'core.client c', 'c.client_id=cc.client_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.checklist ch', 'ch.checklist_id=cc.checklist_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.answer a', 'cr.answer_id=a.answer_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.answer_string ans', 'a.answer_string_id=ans.answer_string_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.question q', 'cr.question_id=q.question_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.page p', 'q.page_id=p.page_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.page_section_2_page ps2p', 'p.page_id=ps2p.page_id', 'LEFT')
            ->join(DB_PREFIX.'checklist.page_section ps', 'ps2p.page_section_id=ps.page_section_id', 'LEFT')
            ->orderBy('cc.checklist_id', 'ASC')
            ->orderBy('cc.client_checklist_id', 'ASC')
            ->orderBy('p.sequence', 'ASC')
            ->orderBy('q.sequence', 'ASC')
            ->orderBy('a.sequence', 'ASC')
            ->orderBy('cr.index', 'ASC')
            ->get(DB_PREFIX.'checklist.client_result cr', $limit, 'cc.checklist_id, ch.name, cc.client_checklist_id, c.company_name, ps.title as section, p.title, q.question_id, q.question, a.answer_id, ans.string, cr.arbitrary_value, cr.index');

        $resultLength = count($results);
        $startIndex = 0;
        for($i = 0; $i < $resultLength; $i++) {
            if($i === $resultLength-1 || $results[$i+1]['checklist_id'] != $results[$i]['checklist_id']) {
                $checklistSheet = new Worksheet($spreadsheet, substr($results[$i]['name'], 0, 30));
                $spreadsheet->addSheet($checklistSheet);
                $checklistSheet->fromArray(['CheckList ID', 'Name', 'Client CheckList ID', 'Company Name', 'Section', 'Page', 'Question ID', 'Question', 'Answer ID', 'String', 'Arbitrary Value', 'Index'], NULL, 'A1');
                $checklistSheet->fromArray(array_slice($results, $startIndex, $i), NULL, 'A2');
                $startIndex = $i+1;
            }
        }

        $writer = new Xlsx($spreadsheet);
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment; filename="export.xlsx"');
        $writer->save('php://output');
        die();
    }
}