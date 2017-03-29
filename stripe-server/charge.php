<?php 

require_once('vendor/autoload.php')

// set api keys
\Stripe\Stripe::setApiKey('sk_test_sJofmAULIyYNFHMKsopEclQG');

$token = $_POST['Token'];
$amount = $_POST['Amount'];
$currency = $_POST['currency'];
$description = $_POST['description'];

// charge stripe only once
try {
    $charge = \Stripe\Charge::create(array(
         "amount" => $amount*100, // Convert amount in cents to dollar
        "currency" => $currency,
        "source" => $token,
        "description" => $description)
     );

    // Check that it was paid:
    if ($charge->paid == true) {
        $response = array( 'status'=> 'Success', 'message'=>'Payment has been charged!!' );
     } else { // Charge was not paid!
        $response = array( 'status'=> 'Failure', 'message'=>'Your payment could NOT be processed because the payment system rejected the transaction. You can try again or use another card.' );
    }

 header('Content-Type: application/json');
 echo json_encode($response);
} catch(\Stripe\Error\Card $e) {
 // The card has been declined
header('Content-Type: application/json');
 echo json_encode($response);
}

?>