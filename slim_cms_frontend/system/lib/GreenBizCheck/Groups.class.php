<?php
namespace GreenBizCheck;

class Groups extends Core {

    /**
     * Get Groups
     * Returns user defined groups, group concat concatenates heirachy name
     *
     * @param array $id 
     * @return void
     */
    public function getGroups($id) {
        $id = is_array($id) ? array_values($id) : explode(',', $id);
        
        $groups = $this->db->where('udg.user_defined_group_id', $id, 'IN')
            ->get(DB_PREFIX.'dashboard.user_defined_group udg');

        $groups = $this->groupConcatArray($groups, 'user_defined_group_id', 'parent_group_id', 'name');

        return $groups;
    }

    /**
     * Set Group
     * Creates user defined groups
     *
     * @param array $data
     * @return void
     */
    public function setGroup($data) {
        $result = $this->db->insert(DB_PREFIX.'dashboard.user_defined_group', $data);
        return $result;
    }

    /**
     * Update Group
     * Creates/Updates user defined groups
     *
     * @param array $data
     * @param  $id
     * @return void
     */
    public function updateGroup($data, $id) {
        $result = $this->db->where('user_defined_group_id', $id)
            ->update(DB_PREFIX.'dashboard.user_defined_group' , $data);

        return $result;
    }

    /**
     * Delete Group
     *
     * @param int $id Group Id
     * @return void
     */
    public function deleteGroup($id) {
        $this->deleteGroupMembers($id);
        $result = $this->db->where('user_defined_group_id', $id)
            ->delete(DB_PREFIX.'dashboard.user_defined_group');

        return $result;
    }

    /**
     * Delete Group Members
     *
     * @param [type] $id Group Id
     * @return void
     */
    public function deleteGroupMembers($id) {
        $result = $this->db->where('user_defined_group_id', $id)
            ->delete(DB_PREFIX.'dashboard.client_2_user_defined_group');

        return $result;
    }

    /**
     * Set Group Members
     *
     * @param array $data
     * @param int $id
     * @return void
     */
    public function setGroupMembers($data) {
        $result = $this->db->insertMulti(DB_PREFIX.'dashboard.client_2_user_defined_group', $data);
        return $result;
    }

	/**
	 * Get User Defined Group Membership
	 *
	 * @param int $id Client Id
	 * @return void
	 */
	public function getGroupMembership($id) {
		$result = $this->db->where('c2udg.client_id', $id)
			->where('udg.user_defined_group_id', NULL, 'IS NOT')
			->join(DB_PREFIX.'dashboard.user_defined_group udg', 'c2udg.user_defined_group_id=udg.user_defined_group_id', 'LEFT')
			->get(DB_PREFIX.'dashboard.client_2_user_defined_group c2udg', NULL, 'udg.*');
        return $result;
    }
    
    /**
     * Get User Defined Group Members
     *
     * @param int $id
     * @return void
     */
    public function getGroupMembers($id) {
        $result = $this->db->where('user_defined_group_id', $id)
        ->get(DB_PREFIX.'dashboard.client_2_user_defined_group', NULL, 'client_id');
        return $result;
    }
}
?>