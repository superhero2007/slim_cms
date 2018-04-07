<?php

class currency extends dbModel {
	
	// STATIC METHODS
	// ------------------------------------------------------------------------------

	public static function stGetCurrencyById($db, $currency_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$currency = new self($db);
		return($currency->getCurrencyById($currency_id, $additionalWhere, $additionalVariables));
	}
	
	public static function toXml($currency, $doc) {
		$currencyNode = self::createElementWithAttributes($doc, 'currency', $currency);
		return($currencyNode);
	}
	
	// INSTANCE METHODS
	// ------------------------------------------------------------------------------

	public function getCurrencyById($currency_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$currency = NULL;
		
		if ($result = $this->query('
			SELECT *
			FROM `%1$s`.`currency`
			WHERE `currency`.`currency_id` = %2$d '.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'pos',
					$currency_id
				)
			)
		)) {
			$currency = $result->fetch_object();
			$result->close();
		}
		
		return($currency);
	}

}

?>