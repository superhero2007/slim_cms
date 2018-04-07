<?php
namespace GreenBizCheck;

use \MysqliDb;

class Core {
    public $db;

    public function __construct() {
        $this->setDatabase();
    }

    /**
     * Set the database connection
     *
     * @return void
     */
    private function setDatabase() {
        $this->db = new MysqliDb(DB_HOST,DB_USER,DB_PASS);
        return;
    }

    /**
     * Group Concat
     * Takes an array with primary and foreign keys to return a concatenated string
     *
     * @param array $groups
     * @param string $primaryKey
     * @param string $foreignKey
     * @param string $valKey
     * @param integer $id
     * @param string $separator
     * @return void
     */
    public function groupConcat($groups, $primaryKey, $foreignKey, $valKey, $id = 0, $separator = " / ") {
        $result = null;
        foreach($groups as $key=>$val) {
            if($groups[$key][$primaryKey] === $id) {
                $result = empty($groups[$key][$foreignKey]) ? $groups[$key][$valKey] : $this->groupConcat($groups, $primaryKey, $foreignKey, $valKey, $groups[$key][$foreignKey]) . $separator . $groups[$key][$valKey];
                break;
            }
        }

        return $result;
    }

    /**
     * Group Concat Array
     * Traverses an array and implements the groupConcat function
     *
     * @param array $groups
     * @param string $primaryKey
     * @param string $foreignKey
     * @param string $valKey
     * @param string $separator
     * @return void
     */
    public function groupConcatArray($groups, $primaryKey, $foreignKey, $valKey, $separator = " / ") {
        foreach($groups as $key=>$val) {
            $groups[$key]['group'] = $this->groupConcat($groups, $primaryKey, $foreignKey, $valKey, $groups[$key][$primaryKey], $separator);
        }
        return $groups;
    }
}
?>