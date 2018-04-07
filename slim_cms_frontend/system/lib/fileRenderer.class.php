<?php
//CSV Class

class fileRenderer {

	public function array2CSV($data, $filename) {

		// output headers so that the file is downloaded rather than displayed
		header('Content-Type: text/csv; charset=utf-8');
		header('Content-Disposition: attachment; filename=' . $filename . '.csv');

		// create a file pointer connected to the output stream
		$output = fopen('php://output', 'w');

		// output the column headings
		fputcsv($output, isset($data[0]) ? array_keys((array)$data[0]) : array('No data available.'));

		foreach($data as $row) {
			fputcsv($output, (array)$row);
		}

		die();
	}

}
?>