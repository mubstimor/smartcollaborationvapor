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
    $token = $_REQUEST['Token'];

if(isset($_REQUEST['Token'])){

    // $response['starting-params'] = $token .'-'. $currency. '-'. $description. '- amt - '. $amount;

\Stripe\Stripe::setApiKey($my_stripe_key);

try {
    $blogname = "Smart collaboration";
    $headers = "From: noreply@smartcollaboration.com\r\n";
    $headers .= "Reply-To: noreply@smartcollaboration.com\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";

    $customer = \Stripe\Customer::create(array('email' => $email, 'card' => $token ));

  // Check that it was paid:
    if ($customer->id != '') {
        $response['status'] = "Success";
        $response['message'] = "customer has been created!!";
        $response['customer_id'] = $customer->id;
        $response['email'] = $customer->email; 

// set users to yearly plan
         $subscription = \Stripe\Subscription::create(array('customer' => $customer->id, 'plan' => 'annual-plan' ));
         $response['subscription_id'] = $subscription->id;
         $response['subscription_start'] = $subscription->current_period_start;
         $response['subscription_end'] = $subscription->current_period_end;

         $hookresponse = postToDataServer($subscription->id, $subscription->current_period_start, $subscription->current_period_end, $customer->id, $subscription->status, $club);
         $response['hookresponse'] = $hookresponse;

         // send email to client
         $message = buildEmail();
         mail($email, "Payment received - PhysioAid", "Payment received", $headers);

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
}else{
     echo "Missing token in request";
}

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
    'amount_paid' => '99.99',
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

function buildEmail(){
    $message = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><!--[if IE]><html xmlns="http://www.w3.org/1999/xhtml" class="ie-browser" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><![endif]--><!--[if !IE]><!--><html style="margin: 0;padding: 0;" xmlns="http://www.w3.org/1999/xhtml"><!--<![endif]--><head>
    <!--[if gte mso 9]><xml>
     <o:OfficeDocumentSettings>
      <o:AllowPNG/>
      <o:PixelsPerInch>96</o:PixelsPerInch>
     </o:OfficeDocumentSettings>
    </xml><![endif]-->
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width">
    <!--[if !mso]><!--><meta http-equiv="X-UA-Compatible" content="IE=edge"><!--<![endif]-->
    <title>Template Base</title>
    
    
    <style type="text/css" id="media-query">
      body {
  margin: 0;
  padding: 0; }

table {
  border-collapse: collapse;
  table-layout: fixed; }

* {
  line-height: inherit; }

a[x-apple-data-detectors=true] {
  color: inherit !important;
  text-decoration: none !important; }

[owa] .img-container div, [owa] .img-container button {
  display: block !important; }

[owa] .fullwidth button {
  width: 100% !important; }

.ie-browser .col, [owa] .block-grid .col {
  display: table-cell;
  float: none !important;
  vertical-align: top; }

.ie-browser .num12, .ie-browser .block-grid, [owa] .num12, [owa] .block-grid {
  width: 500px !important; }

.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {
  line-height: 100%; }

.ie-browser .mixed-two-up .num4, [owa] .mixed-two-up .num4 {
  width: 164px !important; }

.ie-browser .mixed-two-up .num8, [owa] .mixed-two-up .num8 {
  width: 328px !important; }

.ie-browser .block-grid.two-up .col, [owa] .block-grid.two-up .col {
  width: 250px !important; }

.ie-browser .block-grid.three-up .col, [owa] .block-grid.three-up .col {
  width: 166px !important; }

.ie-browser .block-grid.four-up .col, [owa] .block-grid.four-up .col {
  width: 125px !important; }

.ie-browser .block-grid.five-up .col, [owa] .block-grid.five-up .col {
  width: 100px !important; }

.ie-browser .block-grid.six-up .col, [owa] .block-grid.six-up .col {
  width: 83px !important; }

.ie-browser .block-grid.seven-up .col, [owa] .block-grid.seven-up .col {
  width: 71px !important; }

.ie-browser .block-grid.eight-up .col, [owa] .block-grid.eight-up .col {
  width: 62px !important; }

.ie-browser .block-grid.nine-up .col, [owa] .block-grid.nine-up .col {
  width: 55px !important; }

.ie-browser .block-grid.ten-up .col, [owa] .block-grid.ten-up .col {
  width: 50px !important; }

.ie-browser .block-grid.eleven-up .col, [owa] .block-grid.eleven-up .col {
  width: 45px !important; }

.ie-browser .block-grid.twelve-up .col, [owa] .block-grid.twelve-up .col {
  width: 41px !important; }

@media only screen and (min-width: 520px) {
  .block-grid {
    width: 500px !important; }
  .block-grid .col {
    display: table-cell;
    Float: none !important;
    vertical-align: top; }
    .block-grid .col.num12 {
      width: 500px !important; }
  .block-grid.mixed-two-up .col.num4 {
    width: 164px !important; }
  .block-grid.mixed-two-up .col.num8 {
    width: 328px !important; }
  .block-grid.two-up .col {
    width: 250px !important; }
  .block-grid.three-up .col {
    width: 166px !important; }
  .block-grid.four-up .col {
    width: 125px !important; }
  .block-grid.five-up .col {
    width: 100px !important; }
  .block-grid.six-up .col {
    width: 83px !important; }
  .block-grid.seven-up .col {
    width: 71px !important; }
  .block-grid.eight-up .col {
    width: 62px !important; }
  .block-grid.nine-up .col {
    width: 55px !important; }
  .block-grid.ten-up .col {
    width: 50px !important; }
  .block-grid.eleven-up .col {
    width: 45px !important; }
  .block-grid.twelve-up .col {
    width: 41px !important; } }

@media (max-width: 520px) {
  .block-grid, .col {
    min-width: 320px !important;
    max-width: 100% !important; }
  .block-grid {
    width: calc(100% - 40px) !important; }
  .col {
    width: 100% !important; }
    .col > div {
      margin: 0 auto; }
  img.fullwidth {
    max-width: 100% !important; } }

    </style>
</head>
<!--[if mso]>
<body class="mso-container" style="background-color:#FFFFFF;">
<![endif]-->
<!--[if !mso]><!-->
<body class="clean-body" style="margin: 0;padding: 0;-webkit-text-size-adjust: 100%;background-color: #FFFFFF">
<!--<![endif]-->
  <div class="nl-container" style="min-width: 320px;Margin: 0 auto;background-color: #FFFFFF">
    <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color: #FFFFFF;"><![endif]-->

    <div style="background-color:#2C2D37;">
      <div style="Margin: 0 auto;min-width: 320px;max-width: 500px;width: 500px;width: calc(19000% - 98300px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;" class="block-grid two-up">
        <div style="border-collapse: collapse;display: table;width: 100%;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="background-color:#2C2D37;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width: 500px;"><tr class="layout-full-width" style="background-color:transparent;"><![endif]-->

              <!--[if (mso)|(IE)]><td align="center" width="250" style=" width:250px; padding-right: 0px; padding-left: 0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><![endif]-->
            <div class="col num6" style="Float: left;max-width: 320px;min-width: 250px;width: 250px;width: calc(35250px - 7000%);background-color: transparent;">
              <!--[if (!mso)&(!IE)]><!--><div style="border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;"><!--<![endif]-->
                <div style="background-color: transparent; display: inline-block!important; width: 100% !important;">
                  <div style="Margin-top:20px; Margin-bottom:5px;">

                  
<!--[if !mso]><!--><div style="Margin-right: 10px; Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 10px; font-size: 1px">&nbsp;</div>
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px;"><![endif]-->

	<div style="font-size:12px;line-height:14px;color:#555555;font-family:Arial, Helvetica, sans-serif;text-align:left;"><p style="margin: 0;font-size: 12px;line-height: 14px;text-align: center"><span style="color: rgb(255, 255, 255); font-size: 12px; line-height: 14px;"><strong><span style="font-size: 16px; line-height: 19px;">PhysioAid</span></strong></span></p></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 10px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  </div>
                </div>
              <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
            </div>
              <!--[if (mso)|(IE)]></td><td align="center" width="250" style=" width:250px; padding-right: 0px; padding-left: 0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><![endif]-->
            <div class="col num6" style="Float: left;max-width: 320px;min-width: 250px;width: 250px;width: calc(35250px - 7000%);background-color: transparent;">
              <!--[if (!mso)&(!IE)]><!--><div style="border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;"><!--<![endif]-->
                <div style="background-color: transparent; display: inline-block!important; width: 100% !important;">
                  <div style="Margin-top:20px; Margin-bottom:20px;">

                  
<!--[if !mso]><!--><div style="Margin-right: 10px; Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 20px; font-size: 1px">&nbsp;</div>
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px;"><![endif]-->

	<div style="font-size:12px;line-height:18px;color:#6E6F7A;font-family:Arial,  Helvetica, sans-serif;text-align:left;"><div style="text-align: right; line-height:18px; font-size:12px;"><span style="font-size: 16px; line-height: 24px;"><strong><span style="line-height: 24px; font-size: 16px;">Collaboration for Specialists.</span></strong></span></div></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 20px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  </div>
                </div>
              <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
            </div>
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>    <div style="background-color:#323341;">
      <div style="Margin: 0 auto;min-width: 320px;max-width: 500px;width: 500px;width: calc(19000% - 98300px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;" class="block-grid ">
        <div style="border-collapse: collapse;display: table;width: 100%;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="background-color:#323341;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width: 500px;"><tr class="layout-full-width" style="background-color:transparent;"><![endif]-->

              <!--[if (mso)|(IE)]><td align="center" width="500" style=" width:500px; padding-right: 0px; padding-left: 0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><![endif]-->
            <div class="col num12" style="min-width: 320px;max-width: 500px;width: 500px;width: calc(18000% - 89500px);background-color: transparent;">
              <!--[if (!mso)&(!IE)]><!--><div style="border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;"><!--<![endif]-->
                <div style="background-color: transparent; display: inline-block!important; width: 100% !important;">
                  <div style="Margin-top:0px; Margin-bottom:0px;">

                  
<!--[if !mso]><!--><div align="center" style="Margin-right: 10px;Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 10px; font-size:1px">&nbsp;</div>
  <!--[if (mso)|(IE)]><table width="100%" align="center" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px;padding-left: 10px;"><![endif]-->
  <div style="border-top: 10px solid transparent; width:100%; font-size:1px;">&nbsp;</div>
  <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
  <div style="line-height:10px; font-size:1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  
<!--[if !mso]><!--><div style="Margin-right: 0px; Margin-left: 0px;"><!--<![endif]-->
  <div style="line-height: 30px; font-size: 1px">&nbsp;</div>
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px;"><![endif]-->

	<div style="line-height:14px;font-size:12px;color:#ffffff;font-family:Arial, Helvetica, sans-serif;text-align:left;"><p style="margin: 0;line-height: 14px;text-align: center;font-size: 12px"><strong><span style="line-height: 14px; font-size: 12px;"><span style="font-size: 28px; line-height: 33px;">Smart&nbsp;Collaboration - PhysioAid</span></span></strong></p></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 30px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  
<!--[if !mso]><!--><div align="center" style="Margin-right: 10px;Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 10px; font-size:1px">&nbsp;</div>
  <!--[if (mso)|(IE)]><table width="100%" align="center" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px;padding-left: 10px;"><![endif]-->
  <div style="border-top: 10px solid transparent; width:100%; font-size:1px;">&nbsp;</div>
  <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
  <div style="line-height:10px; font-size:1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  
<div align="center" class="img-container center">
<!--[if !mso]><!--><div style="Margin-right: 0px;Margin-left: 0px;"><!--<![endif]-->
  <!--[if mso]><table width="402" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right:  0px; padding-left: 0px;" align="center"><![endif]-->
  <a href="https://beefree.io" target="_blank">
    <img class="center" align="center" border="0" src="images/bee_rocket.png" alt="Image" title="Image" style="outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block;border: none;height: auto;float: none;width: 100%;max-width: 402px" width="402">
  </a>


  <!--[if mso]></td></tr></table><![endif]-->
<!--[if !mso]><!--></div><!--<![endif]-->
</div>
                  
                  </div>
                </div>
              <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
            </div>
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>    <div style="background-color:#61626F;">
      <div style="Margin: 0 auto;min-width: 320px;max-width: 500px;width: 500px;width: calc(19000% - 98300px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;" class="block-grid ">
        <div style="border-collapse: collapse;display: table;width: 100%;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="background-color:#61626F;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width: 500px;"><tr class="layout-full-width" style="background-color:transparent;"><![endif]-->

              <!--[if (mso)|(IE)]><td align="center" width="500" style=" width:500px; padding-right: 0px; padding-left: 0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><![endif]-->
            <div class="col num12" style="min-width: 320px;max-width: 500px;width: 500px;width: calc(18000% - 89500px);background-color: transparent;">
              <!--[if (!mso)&(!IE)]><!--><div style="border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;"><!--<![endif]-->
                <div style="background-color: transparent; display: inline-block!important; width: 100% !important;">
                  <div style="Margin-top:30px; Margin-bottom:30px;">

                  
<!--[if !mso]><!--><div style="Margin-right: 10px; Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 25px; font-size: 1px">&nbsp;</div>
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px;"><![endif]-->

	<div style="font-size:12px;line-height:14px;color:#ffffff;font-family:Arial,  Helvetica, sans-serif;text-align:left;"><p style="margin: 0;font-size: 18px;line-height: 22px;text-align: center"><span style="font-size: 24px; line-height: 28px;"><strong>Payment Received.</strong></span></p></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 10px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  
<!--[if !mso]><!--><div style="Margin-right: 10px; Margin-left: 10px;"><!--<![endif]-->
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px;"><![endif]-->

	<div style="font-size:12px;line-height:18px;color:#B8B8C0;font-family:Arial, Helvetica, sans-serif;text-align:left;"><p style="margin: 0;font-size: 12px;line-height: 18px">Your payment has been received. Thank you</p></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 10px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  
<!--[if !mso]><!--><div align="center" style="Margin-right: 10px;Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 10px; font-size:1px">&nbsp;</div>
  <!--[if (mso)|(IE)]><table width="100%" align="center" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px;padding-left: 10px;"><![endif]-->
  <div style="border-top: 0px solid transparent; width:100%; font-size:1px;">&nbsp;</div>
  <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
  <div style="line-height:10px; font-size:1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  </div>
                </div>
              <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
            </div>
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>    <div style="background-color:#ffffff;">
      <div style="Margin: 0 auto;min-width: 320px;max-width: 500px;width: 500px;width: calc(19000% - 98300px);overflow-wrap: break-word;word-wrap: break-word;word-break: break-word;background-color: transparent;" class="block-grid ">
        <div style="border-collapse: collapse;display: table;width: 100%;">
          <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="background-color:#ffffff;" align="center"><table cellpadding="0" cellspacing="0" border="0" style="width: 500px;"><tr class="layout-full-width" style="background-color:transparent;"><![endif]-->

              <!--[if (mso)|(IE)]><td align="center" width="500" style=" width:500px; padding-right: 0px; padding-left: 0px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><![endif]-->
            <div class="col num12" style="min-width: 320px;max-width: 500px;width: 500px;width: calc(18000% - 89500px);background-color: transparent;">
              <!--[if (!mso)&(!IE)]><!--><div style="border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;"><!--<![endif]-->
                <div style="background-color: transparent; display: inline-block!important; width: 100% !important;">
                  <div style="Margin-top:30px; Margin-bottom:30px;">

                  

<div align="center" style="Margin-right: 10px; Margin-left: 10px; Margin-bottom: 10px;">
  <div style="line-height:10px;font-size:1px">&nbsp;</div>
  <div style="display: table; max-width:131px;">
  <!--[if (mso)|(IE)]><table width="131" align="center" cellpadding="0" cellspacing="0" border="0" style="border-collapse:collapse; mso-table-lspace: 0pt;mso-table-rspace: 0pt; width:131px;"><tr><td width="37" style="width:37px;" valign="top"><![endif]-->
    <table align="left" border="0" cellspacing="0" cellpadding="0" width="32" height="32" style="border-spacing: 0;border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px">
      <tbody><tr style="vertical-align: top"><td align="left" valign="middle" style="word-break: break-word;border-collapse: collapse !important;vertical-align: top">
        <a href="https://www.facebook.com/" title="Facebook" target="_blank">
          <img src="images/facebook.png" alt="Facebook" title="Facebook" width="32" style="outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block;border: none;height: auto;float: none;max-width: 32px !important">
        </a>
      <div style="line-height:5px;font-size:1px">&nbsp;</div>
      </td></tr>
    </tbody></table>
      <!--[if (mso)|(IE)]></td><td width="37" style="width:37px;" valign="top"><![endif]-->
    <table align="left" border="0" cellspacing="0" cellpadding="0" width="32" height="32" style="border-spacing: 0;border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 5px">
      <tbody><tr style="vertical-align: top"><td align="left" valign="middle" style="word-break: break-word;border-collapse: collapse !important;vertical-align: top">
        <a href="http://twitter.com/" title="Twitter" target="_blank">
          <img src="images/twitter.png" alt="Twitter" title="Twitter" width="32" style="outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block;border: none;height: auto;float: none;max-width: 32px !important">
        </a>
      <div style="line-height:5px;font-size:1px">&nbsp;</div>
      </td></tr>
    </tbody></table>
      <!--[if (mso)|(IE)]></td><td width="37" style="width:37px;" valign="top"><![endif]-->
    <table align="left" border="0" cellspacing="0" cellpadding="0" width="32" height="32" style="border-spacing: 0;border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;vertical-align: top;Margin-right: 0">
      <tbody><tr style="vertical-align: top"><td align="left" valign="middle" style="word-break: break-word;border-collapse: collapse !important;vertical-align: top">
        <a href="http://plus.google.com/" title="Google+" target="_blank">
          <img src="images/googleplus.png" alt="Google+" title="Google+" width="32" style="outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;clear: both;display: block;border: none;height: auto;float: none;max-width: 32px !important">
        </a>
      <div style="line-height:5px;font-size:1px">&nbsp;</div>
      </td></tr>
    </tbody></table>
    <!--[if (mso)|(IE)]></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td>&nbsp;</td></tr></table><![endif]-->
  </div>
</div>
                  
                  
<!--[if !mso]><!--><div style="Margin-right: 10px; Margin-left: 10px;"><!--<![endif]-->
  <div style="line-height: 15px; font-size: 1px">&nbsp;</div>
  <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px;"><![endif]-->

	<div style="font-size:12px;line-height:18px;color:#959595;font-family:Arial, Helvetica, sans-serif;text-align:left;"><p style="margin: 0;font-size: 14px;line-height: 21px;text-align: center">Invoice to client&nbsp;<span style="text-decoration: underline; font-size: 14px; line-height: 21px;"><a style="color:#C7702E;text-decoration: underline;" title="PhysioAid" href="https://smartcollaborationvapor.herokuapp.com" target="_blank" rel="noopener noreferrer">smart-collaboration</a></span></p></div>

  <!--[if mso]></td></tr></table><![endif]-->

  <div style="line-height: 10px; font-size: 1px">&nbsp;</div>
<!--[if !mso]><!--></div><!--<![endif]-->
                  
                  </div>
                </div>
              <!--[if (!mso)&(!IE)]><!--></div><!--<![endif]-->
            </div>
          <!--[if (mso)|(IE)]></tr></table></td></tr></table><![endif]-->
        </div>
      </div>
    </div>   <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
  </div>


</body></html>';

return $message;
}
?>