<?php 
/*
* based on https://medium.com/@zachcoss/create-an-iphone-app-with-swift-that-charges-a-credit-card-using-stripe-and-heroku-d9020a4962a6
*/
require_once('vendor/stripe/stripe-php/init.php');
$my_stripe_key = getenv('STRIPE_KEY');
// array for JSON response
$response = array();

if(isset($_REQUEST['Token'])){
    $token = $_REQUEST['Token'];
    $amount = $_REQUEST['Amount'];
    $currency = $_REQUEST['currency'];
    $description = $_REQUEST['description'];

    // $response['starting-params'] = $token .'-'. $currency. '-'. $description. '- amt - '. $amount;

\Stripe\Stripe::setApiKey($my_stripe_key);

try {

    $charge = \Stripe\Charge::create(array('amount' => $amount*100, 'currency' => $currency, 'source' => $token, 'description' => $description ));

  // Check that it was paid:
    if ($charge->paid == true) {
        $response['status'] = "Success";
        $response['message'] = "Payment has been charged!!";
     } else { // Charge was not paid!
        $response['Failure'] = "Failure";
        $response['message'] = "Your payment could NOT be processed because the payment system rejected the transaction. You can try again or use another card.";
    }

}
catch(\Stripe\Error\Card $e) {
 $body = $e->getJsonBody();
    $err  = $body['error'];
    $response["error"] = $err['message'];
}
catch(\Stripe\Error\Authentication $e){
    $body = $e->getJsonBody();
    $err  = $body['error'];
    $response["error"] = $err['message'];
}
catch(\Stripe\Error\InvalidRequest $e){
    $body = $e->getJsonBody();
    $err  = $body['error'];
    $response["error"] = $err['message'];
}
catch(\Stripe\Error\Base $e){
    $response["error"] = "unable to process payment";
}


header('Content-Type: application/json');
echo json_encode($response);
//echo $charge;

}else{
    echo "Missing information in request";
}
?>