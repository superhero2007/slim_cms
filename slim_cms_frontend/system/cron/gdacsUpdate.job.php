<?php
	//Cron to update GDACS events for greenbizcheck and ecobizcheck databases
	//Run every hour
	$gdacs = new gdacs($db);
	$gdacs->updateGdacsFeed('greenbiz_');
	$gdacs->updateGdacsFeed('ecobiz_');
?>