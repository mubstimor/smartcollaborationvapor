<?php 

require_once('vendor/stripe/stripe-php/init.php');
// $my_stripe_key = getenv('STRIPE_KEY');
$my_stripe_key = "sk_test_sJofmAULIyYNFHMKsopEclQG";

// rerieve the request's body and parse it as JSON
$input = @file_get_contents("php://input");
$event_json = json_decode($input);

\Stripe\Stripe::setApiKey($my_stripe_key);

try {

// Verify the event by fetching it from Stripe
$event = \Stripe\Event::retrieve($event_json->id);

// Do something with $event
 if ($event->id == true) {
    $event_type = $event->type;
    $customer = \Stripe\Customer::retrieve($event->data->object->customer);
    $email = $customer->email;

    if($event_type == "customer.subscription.created"){
         mail($email, "Stripe Hook", "subscription for client created");
    }
    else if($event_type == "invoice.payment_failed"){
        // convert amount to pounds
         $amount = sprintf('%0.2f', $event->data->object->amount_due / 100.0);
        notifyAppOnTransaction($customer->id, $amount, 'pending');
        mail($email, "Payment for subscription unsuccessful", "Transaction for ".$amount."failed");
    }
    else if($event_type == "invoice.payment_succeeded"){
        $amount = sprintf('%0.2f', $event->data->object->amount_due / 100.0);
        notifyAppOnTransaction($customer->id, $amount, 'active');
        mail($email, "Payment Received", "Transaction for ".$amount."successful");
    }
    else if($event_type == "customer.subscription.updated"){
        // billing period updated

    }
    else if($event_type == "customer.subscription.deleted"){
        $amount = sprintf('%0.2f', $event->data->object->amount_due / 100.0);
        notifyAppOnTransaction($customer->id, $amount, 'deactivated');
        mail($email, "Subscription ended", "Subscription for account has been deactivated.");
    }

 }

http_response_code(200); 

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

function notifyAppOnTransaction($customer, $amount, $status){
// Your ID and token
// $blogID = '8070105920543249955';
// $authToken = 'xzcdsfrfawskfesd';
$api_key_id = getenv('API_KEY_ID');
$api_key_secret = getenv('API_KEY_SECRET');
$api_string = $api_key_id.':'.$api_key_secret;
// $auth_key = getenv('SV_KEY');
$auth_key = base64_encode($api_string);
$authToken = 'Basic '.$auth_key;

// The data to send to the API
$postData = array(
    'customer_id' => $customer,
    'amount' => $amount,
    'status' => $status
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
$response = file_get_contents('https://smartcollaborationvapor.herokuapp.com/api/paymentupdates', FALSE, $context);

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