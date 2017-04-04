<?php
require_once('vendor/stripe/stripe-php/init.php');

$my_stripe_key = getenv('STRIPE_KEY');

\Stripe\Stripe::setApiKey($my_stripe_key);

try {
$invoice = \Stripe\Invoice::create(array("customer" => "cus_APkuS4jmLtnQaT"));

if ($invoice->id != "") {
        //$response['status'] = "Success";
        // $response['message'] = "Payment has been charged!!";
        echo "amount due ".$invoice->amount_due;
     }else{
        echo "invoice not created";
     }
}
catch(\Stripe\Error\Card $e) {
 $body = $e->getJsonBody();
    $err  = $body['error'];
    echo $err['message'];
}
catch(\Stripe\Error\Authentication $e){
    $body = $e->getJsonBody();
    $err  = $body['error'];
    echo $err['message'];
}
catch(\Stripe\Error\InvalidRequest $e){
    $body = $e->getJsonBody();
    $err  = $body['error'];
    echo $err['message'];
}
catch(\Stripe\Error\Base $e){
    echo "unable to process payment";
}

 ?>