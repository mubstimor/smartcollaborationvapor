<?php 
/*
* based on https://medium.com/@zachcoss/create-an-iphone-app-with-swift-that-charges-a-credit-card-using-stripe-and-heroku-d9020a4962a6
*/
require_once('vendor/stripe/stripe-php/init.php');
$my_stripe_key = getenv('STRIPE_KEY');
// array for JSON response
$response = array();

    $email = $_REQUEST['email'];

    // $response['starting-params'] = $token .'-'. $currency. '-'. $description. '- amt - '. $amount;

\Stripe\Stripe::setApiKey($my_stripe_key);

try {

    $customer = \Stripe\Customer::create(array('email' => $email ));

  // Check that it was paid:
    if ($customer->id != '') {
        $response['status'] = "Success";
        $response['message'] = "customer has been created!!";
        $response['customer_id'] = $customer->id;
        $response['email'] = $customer->email; 

         $subscription = \Stripe\Subscription::create(array('customer' => $customer->id, 'plan' => 'basic-monthly' ));
         $response['subscription_id'] = $subscription->id;


     } else { // Charge was not paid!
        $response['Failure'] = "Failure";
        $response['message'] = "Failed to create customer.";
    }

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
    $body = $e->getJsonBody();
    $err  = $body['error'];
    $response["error"] = $err['message'];
}


header('Content-Type: application/json');
echo json_encode($response);
//echo $charge;


?>