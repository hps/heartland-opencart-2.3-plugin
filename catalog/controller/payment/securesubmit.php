<?php

class ControllerPaymentSecureSubmit extends Controller {
	public function index() {

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
				'text'  => strftime('%B', mktime(0, 0, 0, $i, 1, 2000)),
				'value' => sprintf('%02d', $i)
			);
		}

		$today = getdate();

		$data['year_expire'] = array();

		for ($i = $today['year']; $i < $today['year'] + 11; $i++) {
			$data['year_expire'][] = array(
				'text'  => strftime('%Y', mktime(0, 0, 0, 1, 1, $i)),
				'value' => strftime('%Y', mktime(0, 0, 0, 1, 1, $i))
			);
		}

		if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/securesubmit.tpl')) {
			return $this->load->view($this->config->get('config_template') . '/template/payment/securesubmit.tpl', $data);
		} else {
			return $this->load->view('default/template/payment/securesubmit.tpl', $data);
		}

		$this->render();
	}

	public function send() {
		$this->load->model('checkout/order');

		$order_info = $this->model_checkout_order->getOrder($this->session->data['order_id']);

		require_once(DIR_APPLICATION . 'controller/payment/securesubmitfiles/Hps.php');

        $json = array();

        $config = new HpsConfiguration();
        $config->secretApiKey = $this->config->get('securesubmit_mode') == 'test' ? $this->config->get('securesubmit_test_private_key') : $this->config->get('securesubmit_live_private_key');
        $config->versionNumber = '1550';
        $config->developerId = '002914';

        $chargeService = new HpsChargeService($config);

        $address = new HpsAddress();
        $address->address = html_entity_decode($order_info['payment_address_1'], ENT_QUOTES, 'UTF-8');
        $address->city = html_entity_decode($order_info['payment_city'], ENT_QUOTES, 'UTF-8');
        $address->state = html_entity_decode($order_info['payment_zone'], ENT_QUOTES, 'UTF-8');
        $address->zip = preg_replace('/[^0-9]/', '', html_entity_decode($order_info['payment_postcode'], ENT_QUOTES, 'UTF-8'));
        $address->country = html_entity_decode($order_info['payment_country'], ENT_QUOTES, 'UTF-8');

        $cardHolder = new HpsCardHolder();
        $cardHolder->firstName = html_entity_decode($order_info['payment_firstname'], ENT_QUOTES, 'UTF-8');
        $cardHolder->lastName = html_entity_decode($order_info['payment_lastname'], ENT_QUOTES, 'UTF-8');
        $cardHolder->phone = preg_replace('/[^0-9]/', '', $order_info['telephone']);
        $cardHolder->email = $order_info['email'];
        $cardHolder->address = $address;

        $token = new HpsTokenData();
        $token->tokenValue = $_POST['securesubmitToken'];

		try {
			if ($this->config->get('securesubmit_method') == 'authorization')
			{
                $response = $chargeService->authorize(
                    $this->currency->format($order_info['total'], $order_info['currency_code'], 1.00000, false),
                    $this->currency->getCode(),
                    $token,
                    $cardHolder,
                    false,
                    null);
			}
			else
			{
                $response = $chargeService->charge(
                    $this->currency->format($order_info['total'], $order_info['currency_code'], 1.00000, false),
                    $this->currency->getCode(),
                    $token,
                    $cardHolder,
                    false,
                    null);
			}

            $this->model_checkout_order->confirm($this->session->data['order_id'], $this->config->get('config_order_status_id'));

            $message = '';
            if (isset($response->transactionId))
                $message .='Transaction ID:'.' '.$response->transactionId."\n";

            if (isset($response->cardType))
                $message .='Card Type:'.' '.$response->cardType."\n";


            $this->model_checkout_order->update($this->session->data['order_id'], $this->config->get('securesubmit_order_status_id'), $message, false);

            $json['success'] = $this->url->link('checkout/success', '', 'SSL');
		}
		catch (Exception $e) {
			$json['error'] = $e->getMessage();
		}

 		$this->response->setOutput(json_encode($json));
 	}
}