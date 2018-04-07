<?php
class db extends MysqliDb {

	public $insert_id;
	public $affected_rows;

    /**
     * Escape harmful characters which might affect a query.
     *
     * @param string $str The string to escape.
     *
     * @return string The escaped string.
     */
    public function escape_string($str)
    {
        return $this->escape($str);
    }

    /**
     * Execute raw SQL query.
     *
     * @param string $query      User-provided query to execute.
     * @param array  $bindParams Variables array to bind to the SQL statement.
     *
     * @return array Contains the returned rows from the query.
     */
    public function query($query, $numRows = NULL, $legacy = true)
    {
		$result = $legacy ? $this->mysqli()->query($query) : $this->query($query, $numRows);
		$this->setMysqliProperties();
		return $result;
	}

    /**
     * A method to disconnect from the database
     *
     * @throws Exception
     * @return void
     */
    public function close()
    {
		return $this->disconnect();
    }

    /**
     * A method to set the database
     *
     * @param $database 	The name of the database
     * @return void
     */
    public function setDb($database)
    {
		$this->db = $database;
		$this->mysqli()->select_db($this->db);
		return;
    }

    /**
     * A method to set the last insert id
     *
     * @param $id	The id of the last insert
     */
    public function setMysqliProperties()
    {
		$this->insert_id = $this->mysqli()->insert_id;
		$this->affected_rows = $this->mysqli()->affected_rows;
		return;
    }

    /**
     * A method to query the database multiple times
     *
     * @param $query 	The query
     * @return void
     */
    public function multi_query($query)
    {
		$result = $this->mysqli()->multi_query($query);
		$this->setMysqliProperties();
		return $result;
    }

    /** Legacy use next result
     *
     * @param $query 	The query
     * @return void
     */
    public function use_result()
    {
		$result = $this->mysqli()->use_result();
		$this->setMysqliProperties();
		return $result;
    }

    /**
     * A method to check for more results
     *
     * @param $query 	The query
     * @return void
     */
    public function more_results()
    {
		$result = $this->mysqli()->more_results();
		$this->setMysqliProperties();
		return $result;
    }

    /**
     * A method to check the next result
     *
     * @param $query 	The query
     * @return void
     */
    public function next_result()
    {
		$result = $this->mysqli()->next_result();
		$this->setMysqliProperties();
		return $result;
    }

    /**
     * A method to create a query and store it for use at a later date
     *
     * @param $storedQuery 	The query
     * @return int
     */
	public function insertStoredQuery($storedQuery) {
		$query = sprintf('
			INSERT INTO `%1$s`.`stored_query` 
			SET `query` = "%2$s"
		',
			DB_PREFIX.'api',
			$storedQuery
		);

		$this->query($query);
		$this->setMysqliProperties();

		return $this->insert_id;
	}

    /**
     * A method to prepare content in UTF8 format before working with the database
     *
     * @param $content 		The content to be converted
     * @return string
     */
	public function prepareUTF8Content($content) {
		$search = [     
			// www.fileformat.info/info/unicode/<NUM>/ <NUM> = 2018
            "\xC2\xAB",     // « (U+00AB) in UTF-8
            "\xC2\xBB",     // » (U+00BB) in UTF-8
            "\xE2\x80\x98", // ‘ (U+2018) in UTF-8
            "\xE2\x80\x99", // ’ (U+2019) in UTF-8
            "\xE2\x80\x9A", // ‚ (U+201A) in UTF-8
            "\xE2\x80\x9B", // ‛ (U+201B) in UTF-8
            "\xE2\x80\x9C", // “ (U+201C) in UTF-8
            "\xE2\x80\x9D", // ” (U+201D) in UTF-8
            "\xE2\x80\x9E", // „ (U+201E) in UTF-8
            "\xE2\x80\x9F", // ‟ (U+201F) in UTF-8
            "\xE2\x80\xB9", // ‹ (U+2039) in UTF-8
            "\xE2\x80\xBA", // › (U+203A) in UTF-8
            "\xE2\x80\x93", // – (U+2013) in UTF-8
            "\xE2\x80\x94", // — (U+2014) in UTF-8
            "\xE2\x80\xA6"  // … (U+2026) in UTF-8
		];

	    $replacements = [
            "<<", 
            ">>",
            "'",
            "'",
            "'",
            "'",
            '"',
            '"',
            '"',
            '"',
            "<",
            ">",
            "-",
            "-",
            "..."
	    ];

	    $content = str_replace($search, $replacements, $content);

		return $content;
	}
}

?>