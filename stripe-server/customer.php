<?php 
/*
* based on https://medium.com/@zachcoss/create-an-iphone-app-with-swift-that-charges-a-credit-card-using-stripe-and-heroku-d9020a4962a6
*/
require_once('vendor/stripe/stripe-php/init.php');
$my_stripe_key = getenv('STRIPE_KEY');
// array for JSON response
$response = array();

    $email = $_REQUEST['email'];
    $club = $_REQUEST['club_id'];

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
         $response['subscription_start'] = $subscription->current_period_start;
         $response['subscription_end'] = $subscription->current_period_end;

         $hookresponse = postToDataServer($subscription->id, $subscription->current_period_start, $subscription->current_period_end, $customer->id, $subscription->status, $club);
         $response['hookresponse'] = $hookresponse;

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

/**
* Based on http://stackoverflow.com/questions/16920291/post-request-with-json-body
*/
function postToDataServer($package, $date_paid, $next_payment, $stripe_customer_id, $status, $club_id ){
// Your ID and token
$blogID = '8070105920543249955';
$authToken = 'xzcdsfrfawskfesd';

// The data to send to the API
$postData = array(
    'package' => $package,
    'date_paid' => $date_paid,
    'amount_paid' => '0.00',
    'date_of_next_payment' => $next_payment,
    'payment_id' => $stripe_customer_id,
    'status' => $status,
    'club_id' => $club_id
);

// Create the context for the request
$context = stream_context_create(array(
    'http' => array(
        // http://www.php.net/manual/en/context.http.php
        'method' => 'POST',
        'header' => "Authorization: {$authToken}\r\n".
            "Content-Type: application/json\r\n",
        'content' => json_encode($postData)
    )
));

// Send the request
$response = file_get_contents('http://smartcollaborationvapor.herokuapp.com/subscriptions', FALSE, $context);

// Check for errors
if($response === FALSE){
    die('Error');
}

// Decode the response
$responseData = json_decode($response, TRUE);

// Print the date from the response
return $responseData['recorded'];
}
?>