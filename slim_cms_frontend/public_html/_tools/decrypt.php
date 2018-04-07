<?php
@include('../../config.php');
header("Content-type: text/plain");

$string = 'bszfHN1dvGS5rJFF2MLLbX4ze6Z/IfuRp6FXE7qBQRdsXAlvffz1PSh7QiqvNxA9O4i2jhzZysAkf75qu/kTx0ZOdQq4k+wu7VNNYrzCC36cTYXrwedbIt+g+JBAme71JZ6sxvM2oWLnMAE8p99FZ53hZfVA1NMvc+O3PI0YcfGUClkdJ+2wSg83hvS9IG+tIgqPI9bN0Rrhe6bxi59Sk6TPvhE3J/sqcKspe7+cNDt0T2fI1WEfjG0ASfqb0TZpRcwTfDcGoDD447kSKwsngw+wkn9Qor8laOhtMaDgNkk=';
$array = unserialize(crypt::decrypt($string));

$array['email']['subject'] = 'Welcome to EcoSmash';
$array['email']['stationery'] = 'EcoSmash_welcome';

//print_r($array);

print crypt::encrypt(serialize($array));
?>