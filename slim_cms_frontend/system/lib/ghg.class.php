<?php
/** 
*   Calculate Greenhouse Gas (GHG) Emissions
**/

class ghg {

    private $db;
    private $value;
    private $unit;
    private $type;
    private $region;
    private $country;
    private $state;
    private $date;
    private $scope;
    private $filters;
    private $ghgKeys;

	public function __construct($db) {
		$this->db = $db;
        $this->db->setDb(DB_PREFIX.'ghg');
        $this->filters = ['scope','country','state'];
        $this->ghgKeys = ['GHG_UNIT','GHG_COUNTRY','GHG_STATE','GHG_DATE'];
	}

    /**
    * Set the database method
    * @param object $db The database object
    * @return void
    **/
    public static function db($db) {
        return new ghg($db);
    }

    /**
    * Set the emission value
    * @param object $value The emission value
    * @return void
    **/
    public function value($value) {
        $this->value = $value;
        return $this;
    }

    /**
    * Set the emission unit
    * @param object $unit The emission unit
    * @return void
    **/
    public function unit($unit) {
        $this->unit = $unit;
        return $this;
    }

    /**
    * Set the emission type
    * @param object $type The emission type
    * @return void
    **/
    public function type($type) {
        $this->type = $type;
        return $this;
    }

    /**
    * Set the emission country
    * @param object $country The emission country
    * @return void
    **/
    public function country($country) {
        $this->country = $country;
        $this->setRegion($this->country);
        return $this;
    }

    /**
    * Set the emission state
    * @param object $state The emission state
    * @return void
    **/
    public function state($state) {
        $this->state = $state;
        return $this;
    }

    /**
    * Set the emission date
    * @param object $state The emission date
    * @return void
    **/
    public function date($date) {
        $this->date = $date;
        return $this;
    }

    /**
    * Set the emission scope
    * @param object $state The emission scope
    * @return void
    **/
    public function scope($scope) {
        $this->scope = $scope;
        return $this;
    }

    /**
    * A method to get the emission factors
    * @return array
    **/
    public function getEmissionFactors() {
        return $this->emissionFactors();
    }

    /**
    * A method to get a single emission factor
    * @return array
    **/
    public function getOneEmissionFactor() {
        $emissionFactors = $this->emissionFactors();
        return isset($emissionFactors[0]) ? $emissionFactors[0] : null;
    }

    /**
    * A method to set the ghg reporting region
    * @param string $country The name of a country
    * @return void
    **/
    private function setRegion($country) {
        $region_map = $this->db->where('LOWER(country)',strtolower($this->country))->getOne(DB_PREFIX.'ghg.region_map');
        $this->region = isset($region_map['region']) ? $region_map['region'] : null;

        return;
    }

    /**
    * A method to get the appropriate emission factor from the database
    * @param string $type The emission factor name
    **/
    private function emissionFactors() {
        isset($this->region) ? $this->db->where('region', $this->region) : null;
        isset($this->type) ? $this->db->where('type', $this->type): null;
        isset($this->date) ? $this->db->where('effective <= ?', Array($this->date)) : null;
        isset($this->scope) && in_array('scope',$this->filters) ? $this->db->where('scope', $this->scope) : null;
        isset($this->country) && in_array('country',$this->filters) ? $this->db->where('(LOWER(country) = ? OR country IS NULL)', Array(strtolower($this->country))) : null;
        isset($this->state) && in_array('state',$this->filters) ? $this->db->where('(LOWER(state) = ? OR state IS NULL)', Array(strtolower($this->state))) : null;
        $emissionFactors = $this->db->orderBy('state','DESC')->orderBy('country','DESC')->orderBy('effective','DESC')->get(DB_PREFIX.'ghg.emission_factor');

        if(empty($emissionFactors) && !empty($this->filters)) {
            array_pop($this->filters);
            return $this->emissionFactors();
        }

        return $emissionFactors;
    }

    /**
    * A method to save an emission to the database
    * @param array $data The data to insert
    **/
    public function saveEmission($data) {
        if(isset($data['client_checklist_id']) && isset($data['type']) && isset($data['type_id'])) {
            $this->deleteEmission($data['client_checklist_id'], $data['type'], $data['type_id'], isset($data['index']) ? $data['index'] : null);
        }

        return $this->db->insert(DB_PREFIX.'ghg.emission', $data);
    }

    /**
    * A method to delete an emission to the database
    * @param string $identifier The identifier of the emission
    * @param string $identifier_type The type of identifier
    * @param int $index The index of the emission
    **/
    public function deleteEmission($client_checklist_id, $type, $type_id, $index = 0) {
        $this->db->where('client_checklist_id',$client_checklist_id)
            ->where('type',$type)
            ->where('type_id',$type_id)
            ->where('`index`',$index);

        return $this->db->delete(DB_PREFIX.'ghg.emission');
    }

    /**
    * A method to loop through and calculate emissions
    **/
    public function processTriggers($client_checklist_id = null) {
        $triggers = $this->db->get(DB_PREFIX.'ghg.`trigger`');
        foreach($triggers as $trigger) {
            $trigger['client_checklist_id'] = $client_checklist_id;
            switch($trigger['source']) {
                case 'metric':   $this->calculateMetric($trigger);
                    break;

                case 'question':   $this->calculateQuestion($trigger);
                    break;
            }
        }
    }

    /**
    * A method to get emissions from the database
    **/
    public function getEmissions($client_checklist_id = array(), $output = null) {

        if(!empty($client_checklist_id)) {
            $client_checklist_id = is_array($client_checklist_id) ? array_values($client_checklist_id) : Array($client_checklist_id);
            $this->db->where('e.client_checklist_id',$client_checklist_id, 'IN');
        }

        $this->db->join(DB_PREFIX.'ghg.emission_factor ef', 'e.emission_factor_id=ef.emission_factor_id','LEFT');
        $this->db->join(DB_PREFIX.'checklist.client_checklist cc', 'cc.client_checklist_id=e.client_checklist_id', 'LEFT');
        $this->db->join(DB_PREFIX.'core.client c', 'c.client_id=cc.client_id', 'LEFT');
        $columns = 'c.client_id, c.company_name, e.emission_id, e.type, e.type_id, e.index, e.value, e.timestamp, ef.*';
        $emissions = $output == 'object' ? $this->db->ObjectBuilder()->get(DB_PREFIX.'ghg.emission e', NULL, $columns) : $this->db->get(DB_PREFIX.'ghg.emission e');

        return $emissions;
    }

    /**
    * Get client metric emission list
    **/
    public function getClientMetricQueue($metric_id, $client_checklist_id = null) {
        $this->db->join(DB_PREFIX.'checklist.metric_unit_type_2_metric mut2m', '(cm.metric_id=mut2m.metric_id AND cm.metric_unit_type_id=mut2m.metric_unit_type_id)', 'LEFT');
        $this->db->join(DB_PREFIX.'checklist.metric_unit_type_2_metric dmut2m', '(cm.metric_id = dmut2m.metric_id AND dmut2m.default = 1)', 'LEFT');
        $this->db->join(DB_PREFIX.'checklist.metric_unit_type dmut', 'dmut2m.metric_unit_type_id = dmut.metric_unit_type_id', 'LEFT');
        $this->db->join(DB_PREFIX.'checklist.client_checklist cc', 'cm.client_checklist_id = cc.client_checklist_id', 'LEFT');
        $this->db->join(DB_PREFIX.'core.client_address ca', 'ca.client_id = cc.client_id', 'LEFT');

        if(!is_null($client_checklist_id)) {
            $this->db->where('cm.client_checklist_id',$client_checklist_id);
        }
        $this->db->where('cm.metric_id',$metric_id);
        $this->db->where('cm.value > 0');
        $this->db->where('ca.country', NULL, 'IS NOT');

        $columns = 'cm.client_checklist_id,cm.metric_id,cm.timestamp,IF(mut2m.conversion > 0, cm.value*mut2m.conversion, cm.value) AS value,dmut.key,cc.date_range_finish,ca.administrative_area_level_1 AS state,ca.country';

        return $this->db->get(DB_PREFIX.'checklist.client_metric cm', NULL, $columns);
    }

    private function calculateMetric($trigger) {
        $clientMetrics = $this->getClientMetricQueue($trigger['key'], $trigger['client_checklist_id']);

        foreach($clientMetrics as $clientMetric) {
            $emissionFactor = ghg::db($this->db)->country($clientMetric['country'])->state($clientMetric['state'])->date($clientMetric['date_range_finish'])->type($trigger['type'])->scope($trigger['scope'])->getOneEmissionFactor(DB_PREFIX.'ghg.emission_factor');

            if(!empty($emissionFactor)){
                try {
                    $value = conversion::convert($clientMetric['value'], $clientMetric['key'])->to($emissionFactor['unit_key'])->format(3,'.','');
                    $emission = [
                        'client_checklist_id' => $clientMetric['client_checklist_id'],
                        'type' => 'metric',
                        'type_id' => $clientMetric['metric_id'],
                        'index' => 0,
                        'emission_factor_id' => $emissionFactor['emission_factor_id'],
                        'value' => (float)($value * $emissionFactor['factor'])
                    ];

                    $this->saveEmission($emission);
                } catch(Exception $e) {
                    error_log($e);
                }
            }
        }

        return;
    }


    /**
    * Get client result emission list
    **/
    public function getClientResultQueue($question_id, $client_checklist_id = null) {
        $this->db->join(DB_PREFIX.'checklist.client_checklist cc', 'cr.client_checklist_id = cc.client_checklist_id', 'LEFT');
        $this->db->join(DB_PREFIX.'core.client_address ca', 'ca.client_id = cc.client_id', 'LEFT');
        $this->db->join(DB_PREFIX.'checklist.answer a', 'cr.answer_id = a.answer_id', 'LEFT');
        $this->db->join(DB_PREFIX.'checklist.question q', 'cr.question_id = q.question_id', 'LEFT');

        if(!is_null($client_checklist_id)) {
            $this->db->where('cr.client_checklist_id',$client_checklist_id);
        }
        $this->db->where('cr.question_id',$question_id);
        $this->db->where('cr.arbitrary_value > 0');

        $columns = 'cr.client_checklist_id, cr.question_id, cr.answer_id, cr.arbitrary_value, ca.administrative_area_level_1 AS state,ca.country, a.*, q.*, cc.date_range_finish';

        return $this->db->get(DB_PREFIX.'checklist.client_result cr', NULL, $columns);
    }

    private function calculateQuestion($trigger) {
        $clientResults = $this->getClientResultQueue($trigger['key'], $trigger['client_checklist_id']);

        foreach($clientResults as $clientResult) {
            $ghgValues = $this->getGHGValues($clientResult['question_id'], $clientResult['client_checklist_id']);
            $ghgValues['GHG_COUNTRY'] = isset($ghgValues['GHG_COUNTRY']) ? $ghgValues['GHG_COUNTRY'] : $clientResult['country'];
            $ghgValues['GHG_STATE'] = isset($ghgValues['GHG_STATE']) ? $ghgValues['GHG_STATE'] : $clientResult['state'];
            $ghgValues['GHG_DATE'] = isset($ghgValues['GHG_DATE']) ? $ghgValues['GHG_DATE'] : $clientResult['date_range_finish'];

            if(!is_null($ghgValues['GHG_COUNTRY'])) {
                $emissionFactor = ghg::db($this->db)->country($ghgValues['GHG_COUNTRY'])->state($ghgValues['GHG_STATE'])->date($ghgValues['GHG_DATE'])->type($trigger['type'])->scope($trigger['scope'])->getOneEmissionFactor('emission_factor');
                try {
                    $value = conversion::convert($clientResult['arbitrary_value'], $ghgValues['GHG_UNIT'])->to($emissionFactor['unit_key'])->format(3,'.','');
                    $emission = [
                        'client_checklist_id' => $clientResult['client_checklist_id'],
                        'type' => 'question',
                        'type_id' => $clientResult['question_id'],
                        'index' => 0,
                        'emission_factor_id' => $emissionFactor['emission_factor_id'],
                        'value' => (float)($value * $emissionFactor['factor'])
                    ];

                    $this->saveEmission($emission);
                } catch(Exception $e) {
                    error_log($e);
                }
            }
        }

        return;
    }

    private function getGHGValues($question_id, $client_checklist_id = null) {
        $ghgValues = array();
        $clientChecklist = new clientChecklist($this->db);
        $rqs = $clientChecklist->getRelatedClientResults($question_id, $client_checklist_id);
        foreach($rqs as $rq) {
            foreach($this->ghgKeys as $ghgKey) {
                $value = is_null($rq['arbitrary_value']) ? $rq['alt_value'] : $rq['arbitrary_value'];
                $ghgValues[$ghgKey] = isset($ghgValues[$ghgKey]) ? $ghgValues[$ghgKey] : ($ghgValues[$ghgKey] = $rq['alt_key'] === $ghgKey ? $value : null);
            }
        }

        return $ghgValues;
    }

}