<?php
/*
 * 2016-06-15 Updated function for velocity checks
 * Prevent bot based attacks to identify valid card numbers by trial and error
 * OpenCart already supports captcha
 * google recaptcha is available as an extension.
 * http://code.tutsplus.com/tutorials/set-up-google-recaptcha-in-opencart--cms-25518
 * This plugin is maintained in github at https://github.com/hps/heartland-opencart-plugin
 *
 *
 * Heartland recommends all merchants enable these settings which will be the default if not changed in the extension settings.
 * Heartland also recommends using reCaptcha from google. Your situation may differ. In an ever changing evolving world of cyber-threats
 * you should regularly check for updates to this an any other plugin in an e-commerce site.
 *
 *
 * Updated code to use the latest php-SDK https://github.com/hps/heartland-php 2.8.9
 * This update was tested on 2.2.0.0 open cart http://www.opencart.com/index.php?route=download/download/success&download_id=44
 * Please ensure your installation complies with OpenCart Server requirements
 * http://docs.opencart.com/requirements/
 *
 *
 */
// include HPS library
require_once('securesubmitfiles/Hps.php');

/**
 * Class ControllerPaymentSecureSubmit
 * consumable functions
 * \ControllerPaymentSecureSubmit::index
 * \ControllerPaymentSecureSubmit::send
 * Class ControllerPaymentSecureSubmit
 */
class ControllerPaymentSecureSubmit extends Controller
{

    const VERSION_NUMBER = '1550';

    const DEVELOPER_ID = '002914';

    const MINUTE_IN_SECONDS = 60;

    const VELOCITY_WAIT = 2;

    const SECURESUBMIT_FRAUD_ENABLE_DEFAULT = 'on';

    const SECURESUBMIT_FRAUD_MESSAGE_DEFAULT = 'Please contact us to complete the transaction.';

    const SECURESUBMIT_FRAUD_FAIL_DEFAULT = 3;

    const SECURESUBMIT_FRAUD_TIME_DEFAULT = 10;

    /**
     * @var null|HpsServicesConfig
     */
    private $HpsServicesConfig = null;

    /**
     * @var \HpsCreditService|null
     */
    private $HpsCreditService = null;

    /**
     * @var null|string
     */
    private $secure_submit_private_key = null;

    /**
     * @var null
     */
    private $securesubmit_fraud_enable = null;

    /**
     * @var null
     */
    private $securesubmit_fraud_message = null;

    /**
     * @var null
     */
    private $securesubmit_fraud_fail = null;

    /**
     * @var null
     */
    private $securesubmit_fraud_time = null;

    /**
     * @var null
     */
    private $securesubmit_fraud_fail_var = null;

    /**
     * ControllerPaymentSecureSubmit constructor.
     *
     */
    public function __construct($registry)
    {
        parent::__construct($registry);
        $this->HpsCreditService = $this->getHpsCreditService();
        // \ControllerPaymentSecureSubmit::get_secure_submit_private_key
        $this->get_secure_submit_private_key();
        // \ControllerPaymentSecureSubmit::getSecureSubmitVelocity
        // check if velocity settings are enabled and set defaults if necesary or read values from db
        $this->getSecureSubmitVelocity();
    }

    /**
     * @return mixed
     */
    public function index()
    {

        $this->document->addScript('catalog/view/javascript/secure.submit-1.0.2.js');

        $this->load->language('payment/securesubmit');

        $data['text_credit_card'] = $this->language->get('text_credit_card');
        $data['text_wait'] = $this->language->get('text_wait');

        $data['entry_cc_owner'] = $this->language->get('entry_cc_owner');
        $data['entry_cc_number'] = $this->language->get('entry_cc_number');
        $data['entry_cc_expire_date'] = $this->language->get('entry_cc_expire_date');
        $data['entry_cc_cvv2'] = $this->language->get('entry_cc_cvv2');

        $data['button_confirm'] = $this->language->get('button_confirm');

        $data['months'] = array();

        for ($i = 1; $i <= 12; $i++) {
            $data['months'][] = array(
                'text' => strftime('%B', mktime(0, 0, 0, $i, 1, 2000)),
                'value' => sprintf('%02d', $i)
            );
        }

        $today = getdate();

        $data['year_expire'] = array();

        for ($i = $today['year']; $i < $today['year'] + 11; $i++) {
            $data['year_expire'][] = array(
                'text' => strftime('%Y', mktime(0, 0, 0, 1, 1, $i)),
                'value' => strftime('%Y', mktime(0, 0, 0, 1, 1, $i))
            );
        }

        if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/securesubmit.tpl')) {
            return $this->load->view($this->config->get('config_template') . '/template/payment/securesubmit.tpl', $data);
        } else {
            return $this->load->view('payment/securesubmit.tpl', $data);
        }
    }

    /**
     *Process payment
     */
    public function send()
    {
        $this->load->model('checkout/order');
        $orderID = $this->session->data['order_id'];
        // \ModelCheckoutOrder::getOrder
        $order_info = $this->model_checkout_order->getOrder($orderID);
        $curCode = $order_info['currency_code'];
        $amt = $order_info['total'];
        $json = array();

        // \ControllerPaymentSecureSubmit::getHpsCardHolder
        // builds the \HpsAddress as well
        // do this here since it is not specific only to credit card transactions
        $cardHolder = $this->getHpsCardHolder($order_info);

        try {
            /*
             * get \HpsAuthorization
             * in order to facilitate this we will retrieve the setting determining which call to make
             */
            $response = $this->chargeCreditCard($amt, $curCode, $cardHolder);
            $json['redirect'] = $this->buildCreditSuccessMessage($orderID, $response);
        } catch (HpsException $e) {
            $maxFail = $this->securesubmit_fraud_fail;

            if ($this->velocityIncrement() < $maxFail) {
                $this->sessionVar('previous', $e->getMessage());
            }
            $json['error'] = $e->getMessage();
        } catch (Exception $e) {
            $json['error'] = $e->getMessage();
        }

        // \Response::addHeader
        $this->response->addHeader('Content-Type: application/json');
        // \Response::setOutput
        $this->response->setOutput(json_encode($json));
    }

    /**
     * All the magic happens here. This function processes the credit card transaction according to your configuration
     *
     * @param float $amt amount to be billed
     * @param string $curCode currently should always be USD
     * @param \HpsCardHolder $cardHolder object with card holder specifics. used in AVS verification and other data records
     *
     * @return \HpsAuthorization        Basically any time the transaction processes successfully
     *
     * @throws \HpsCreditException      Pretty much any kind of issuer based declines.
     *                                  These response come from the card holders issuing bank
     * @throws \HpsException            If this occurs check the ip of your server is not outside of US and contact
     *                                  Heartland for additional information.
     *                                  Also this exception will catch  our velocity exceptions
     * @throws \HpsGatewayException     These exceptions indicate that the transaction was not sent to the issuer.
     *                                  The transaction was rejected by the gateway for the listed reason
     */
    private function chargeCreditCard($amt, $curCode, $cardHolder)
    {

        if ($this->sessionVar('count') > $this->securesubmit_fraud_fail) {
            // spoof processing time to not alert the bot that something unexpected is happening
            // but each failure will get slower and slower
            sleep(self::VELOCITY_WAIT * $this->sessionVar('count'));
            throw new HpsException(sprintf('%s %s', $this->securesubmit_fraud_message, $this->sessionVar('previous')));
        }
        switch ($this->config->get('securesubmit_method')) {
            case 'authorization':
                // process as authorization only. this will not be settled as a batch without further administrative action
                // \HpsCreditService::authorize
                $chargeMethod = 'authorize';
                break;
            default:
                // this authorizes and captures to batch the credit card transaction
                // \HpsCreditService::charge
                $chargeMethod = 'charge';
        }
        // \ControllerPaymentSecureSubmit::getHpsCreditService
        // \ControllerPaymentSecureSubmit::get_supt
        return $this->getHpsCreditService()->{$chargeMethod}($amt, $curCode, $this->get_supt(), $cardHolder);
    }

    /**
     * @param int $orderID
     * @param \HpsAuthorization $response
     *
     * @return string           the URL to Navigate on success
     */
    private function buildCreditSuccessMessage($orderID, $response)
    {
        // there is always a transaction id unless there is a comm error which throws an error prior to this line
        $message = 'Transaction ID:' . ' ' . $response->transactionId . "\n";

        // current code has the card number posting to the script so we can parse it here if it is not identified in the response;
        $message .= 'Card Type:' . ' ' . $this->getCcType($response) . "\n";

        // \ModelCheckoutOrder::addOrderHistory
        $this->model_checkout_order->addOrderHistory($orderID, $this->config->get('securesubmit_order_status_id'), $message, false);
        return $this->url->link('checkout/success');
    }

    /**
     * @return \HpsServicesConfig
     */
    private function getHpsServicesConfig()
    {
        // never need to create this more than once
        if (!($this->HpsServicesConfig instanceof HpsServicesConfig)) {
            // \HpsServicesConfig
            $this->HpsServicesConfig = new HpsServicesConfig();
            $this->HpsServicesConfig->versionNumber = self::VERSION_NUMBER;
            $this->HpsServicesConfig->developerId = self::DEVELOPER_ID;
        }
        return $this->HpsServicesConfig;
    }

    /** used for ALL CREDIT CARD transactions
     * @return \HpsCreditService
     */
    private function getHpsCreditService()
    {
        // never need to create this more than once
        return $this->HpsCreditService instanceof HpsCreditService ?
            $this->HpsCreditService :
            new HpsCreditService($this->getHpsServicesConfig());
    }

    /**
     * @param $order_info
     *
     * @return \HpsAddress
     */
    private function getHpsAddress($order_info)
    {
        $address = new HpsAddress();
        $address->address = html_entity_decode($order_info['payment_address_1'], ENT_QUOTES, 'UTF-8');
        $address->city = html_entity_decode($order_info['payment_city'], ENT_QUOTES, 'UTF-8');
        $address->state = html_entity_decode($order_info['payment_zone'], ENT_QUOTES, 'UTF-8');
        $address->zip = preg_replace('/[^0-9]/', '', html_entity_decode($order_info['payment_postcode'], ENT_QUOTES, 'UTF-8'));
        $address->country = html_entity_decode($order_info['payment_country'], ENT_QUOTES, 'UTF-8');
        return $address;
    }

    /**
     * @param $order_info
     *HpsAddress
     * @return \HpsCardHolder
     */
    private function getHpsCardHolder($order_info)
    {
        $cardHolder = new HpsCardHolder();
        $cardHolder->firstName = html_entity_decode($order_info['payment_firstname'], ENT_QUOTES, 'UTF-8');
        $cardHolder->lastName = html_entity_decode($order_info['payment_lastname'], ENT_QUOTES, 'UTF-8');
        $cardHolder->phone = preg_replace('/[^0-9]/', '', $order_info['telephone']);
        $cardHolder->email = $order_info['email'];
        $cardHolder->address = $this->getHpsAddress($order_info);
        return $cardHolder;
    }

    /**
     * @return \HpsTokenData
     */
    private function get_supt()
    {
        $token = new HpsTokenData();
        $token->tokenValue = filter_var(trim($_POST['securesubmitToken']), FILTER_SANITIZE_STRING);;
        return $token;
    }

    /**
     * @return null|string
     * @throws \HpsAuthenticationException
     */
    private function get_secure_submit_private_key()
    {
        if ($this->HpsServicesConfig->secretApiKey === null) {
            $mode = trim($this->config->get('securesubmit_mode'));
            $this->HpsServicesConfig->secretApiKey =
                filter_var(trim($this->config->get('securesubmit_' . $mode . '_private_key')), FILTER_SANITIZE_STRING);
        }
        if (!$this->HpsServicesConfig->validate(HpsConfigInterface::KEY_TYPE_SECRET)) {
            throw new HpsAuthenticationException(HpsExceptionCodes::AUTHENTICATION_ERROR, 'Incorrectly configured PrivateKey');
        };
        return $this->secure_submit_private_key;
    }

    /**
     * @param null $response
     *
     * @return int|string
     *
     * @TODO Send the card type from the token response and stop sending the card number
     */
    private function getCcType($response = null)
    {

        if (isset($response->cardType)) {
            $ret = $response->cardType;
        } else {
            $cc = new HpsCreditCard;
            $cc->number = filter_var(trim($_POST['cc_number']), FILTER_SANITIZE_NUMBER_INT);
            $ret = $cc->cardType();
        }
        return $ret;
    }

    /**
     * the intent of these settings is to offer a way to slow down bots
     * that attempt to try random invalid cards in an attempt ti identify valid cards
     */
    private function getSecureSubmitVelocity()
    {
        // system/library/config.php
        // \Config::get returns null if not found

        // get these values from the DB
        $securesubmit_fraud_enable = $this->config->get('securesubmit_fraud_enable');
        $securesubmit_fraud_message = $this->config->get('securesubmit_fraud_message');
        $securesubmit_fraud_fail = $this->config->get('securesubmit_fraud_fail');
        $securesubmit_fraud_time = $this->config->get('securesubmit_fraud_time');

        // if invalid or null set defaults for each
        if ($securesubmit_fraud_enable === null) { // set default
            $securesubmit_fraud_enable = self::SECURESUBMIT_FRAUD_ENABLE_DEFAULT;
        }
        if ($securesubmit_fraud_message === null) { // set default
            $securesubmit_fraud_message = self::SECURESUBMIT_FRAUD_MESSAGE_DEFAULT;
        }
        if ((int)$securesubmit_fraud_fail < 1) { // set default
            $securesubmit_fraud_fail = self::SECURESUBMIT_FRAUD_FAIL_DEFAULT;
        }
        if ((int)$securesubmit_fraud_time < 1) { // set default
            $securesubmit_fraud_time = self::SECURESUBMIT_FRAUD_TIME_DEFAULT;
        }

        // validation done lets set our properties
        $this->securesubmit_fraud_enable = (bool)$securesubmit_fraud_enable === 'on';
        $this->securesubmit_fraud_message = filter_var(trim($securesubmit_fraud_message), FILTER_SANITIZE_STRING);
        $this->securesubmit_fraud_fail = (int)$securesubmit_fraud_fail;
        $this->securesubmit_fraud_time = (int)$securesubmit_fraud_time * self::MINUTE_IN_SECONDS;

        // set a session var based on the users IP and if not set instantiate the count to 0
        $this->securesubmit_fraud_fail_var = "HeartlandHPS_FailCount_" . $this->getIP();
        $this->sessionVar('count');
    }

    /**
     * @return string
     */
    private function getIP()
    {

        if (array_key_exists("HTTP_X_FORWARDED_FOR", $_SERVER) && $_SERVER["HTTP_X_FORWARDED_FOR"] != "") {
            $IParray = array_values(array_filter(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])));
            $IP = end($IParray);
        } else {
            $IP = $_SERVER["REMOTE_ADDR"];
        }
        return md5($IP);
    }

    /**
     * Open cart sets session variables to never timeout while the browser is open
     * Heartland needs these values to die at a time defined in settings
     * this function works by checking the last time a var was set and  resetting if they have timed out
     * @param null|string $key
     * @param null|string $val
     *
     * @return mixed
     */
    private function sessionVar($key = null, $val = null)
    {
        /*
         * I need to set a timebomb on the following variables
         * $this->session->data[$this->securesubmit_fraud_fail_var]['count']
         * $this->session->data[$this->securesubmit_fraud_fail_var]['previous']
         * $this->session->data[$this->securesubmit_fraud_fail_var]['lastErrorTime']
         */
        $HPS_KEY = $this->securesubmit_fraud_fail_var;
        //unset($this->session->data[$HPS_KEY]);
        $timeOut = (int)$this->session->data[$HPS_KEY]['lastErrorTime'] + $this->securesubmit_fraud_time;

        if ($timeOut < time()) { // expired
            $this->session->data[$HPS_KEY] = array('count' => (int)1
            , 'previous' => (string)''
            , 'lastErrorTime' => (int)time());
        }
        if ($key !== null) {
            if ($val !== null) {
                $this->session->data[$HPS_KEY][$key] = $val;
                $this->session->data[$HPS_KEY]['lastErrorTime'] = time();
            }
            return $this->session->data[$HPS_KEY][$key];
        }
    }

    /**
     * Calling this function increments  a current valid velocity error counter.
     * the intent is to prevent excessive failed transactions and reduce risk of bot based attacks to validate cards.
     * a normal user is unlikely to ever see this many failures in a short defined period of time
     * @return mixed
     */
    private function velocityIncrement()
    {
        return $this->sessionVar('count', $this->sessionVar('count') + 1);
    }
}