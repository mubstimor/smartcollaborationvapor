<?php 
/*
* based on https://medium.com/@zachcoss/create-an-iphone-app-with-swift-that-charges-a-credit-card-using-stripe-and-heroku-d9020a4962a6
*/
require_once('vendor/stripe/stripe-php/init.php');
$my_stripe_key = getenv('STRIPE_KEY');
\Stripe\Stripe::setApiKey($my_stripe_key);

   $subscription_id = $_REQUEST['subscription'];
   if (isset($subscription_id)){
   echo getSubscriptionDetails($subscription_id);
   } else{
       echo "subscription should be provided.";
   }

function getSubscriptionDetails($subscription_id){
    // array for JSON response
$response = array();

try {

    $subscription = \Stripe\Subscription::retrieve($subscription_id);

  // Check that it was paid:
    if ($subscription->id != '') {
        $response['status'] = "Success";
        $response['subscription_id'] = $subscription->id;
        $response['customer_id'] = $subscription->customer;
        $response['subscription_status'] = $subscription->status;
        $response['subscription_end'] = $subscription->current_period_end;
        $response['plan'] = $subscription->plan->id;
        $response['plan_name'] = $subscription->plan->name;
        $response['plan_interval'] = $subscription->plan->interval;
        $response['plan_amount'] = $subscription->plan->amount;

     } else { // Charge was not paid!
        $response['Failure'] = "Failure";
        $response['message'] = "Failed to obtain subscription details.";
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
return json_encode($response);

}

?>