<?php 

error_reporting(1);

 if(mail("mubstimor@gmail.com", "Stripe Hook", "hook called ")){
     echo "mail sent";
 }else{
     echo "mail not sent";
 }

?>