<?php 
class ControllerExtensionPaymentSecuresubmit extends Controller {
	private $error = array();

	public function index() {
		$this->load->language('extension/payment/securesubmit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('setting/setting');
		
		if(version_compare(VERSION, '3.0.0', '>=')) {
			$token = 'user_token=' . $this->session->data['user_token'];
			$path = 'marketplace/extension';
			$prefix = 'payment_';
		} else {
			$token = 'token=' . $this->session->data['token'];
			$path = 'extension/extension';
			$prefix = '';
		}
		

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$this->model_setting_setting->editSetting($prefix . 'securesubmit', $this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$this->response->redirect($this->url->link($path, $token . '&type=payment', 'SSL'));
		}

		$data['heading_title'] = $this->language->get('heading_title');

		$data['text_edit'] = $this->language->get('text_edit');
		$data['text_enabled'] = $this->language->get('text_enabled');
		$data['text_disabled'] = $this->language->get('text_disabled');
		$data['text_all_zones'] = $this->language->get('text_all_zones');
		$data['text_test'] = $this->language->get('text_test');
		$data['text_live'] = $this->language->get('text_live');
		$data['text_authorization'] = $this->language->get('text_authorization');
		$data['text_capture'] = $this->language->get('text_capture');
		$data['text_checkout_settings'] = $this->language->get('text_checkout_settings');
		$data['text_velocity_settings'] = $this->language->get('text_velocity_settings');
		$data['text_total_helper'] = $this->language->get('text_total_helper');

		$data['entry_test_private_key'] = $this->language->get('entry_test_private_key');
		$data['entry_test_public_key'] = $this->language->get('entry_test_public_key');
		$data['entry_live_private_key'] = $this->language->get('entry_live_private_key');
		$data['entry_live_public_key'] = $this->language->get('entry_live_public_key');
		$data['entry_mode'] = $this->language->get('entry_mode');
		$data['entry_method'] = $this->language->get('entry_method');
		$data['entry_total'] = $this->language->get('entry_total');
		$data['entry_order_status'] = $this->language->get('entry_order_status');
		$data['entry_geo_zone'] = $this->language->get('entry_geo_zone');
		$data['entry_status'] = $this->language->get('entry_status');
		$data['entry_sort_order'] = $this->language->get('entry_sort_order');
		$data['entry_fraud_enable'] = $this->language->get('entry_fraud_enable');
		$data['entry_fraud_message'] = $this->language->get('entry_fraud_message');
		$data['entry_fraud_fail'] = $this->language->get('entry_fraud_fail');
		$data['entry_fraud_time'] = $this->language->get('entry_fraud_time');
		$data['entry_use_iframes'] = $this->language->get('entry_use_iframes');

		$data['button_save'] = $this->language->get('button_save');
		$data['button_cancel'] = $this->language->get('button_cancel');

		if (isset($this->error['warning'])) {
			$data['error_warning'] = $this->error['warning'];
		} else {
			$data['error_warning'] = '';
		}

		if (isset($this->error['test_private_key'])) {
			$data['error_test_private_key'] = $this->error['test_private_key'];
		} else {
			$data['error_test_private_key'] = '';
		}

		if (isset($this->error['test_public_key'])) {
			$data['error_test_public_key'] = $this->error['test_public_key'];
		} else {
			$data['error_test_public_key'] = '';
		}

		if (isset($this->error['live_private_key'])) {
			$data['error_live_private_key'] = $this->error['live_private_key'];
		} else {
			$data['error_live_private_key'] = '';
		}

		if (isset($this->error['live_public_key'])) {
			$data['error_live_public_key'] = $this->error['live_public_key'];
		} else {
			$data['error_live_public_key'] = '';
		}

		$data['breadcrumbs'] = array();

		$data['breadcrumbs'][] = array(
			'text'      => $this->language->get('text_home'),
			'href'      => $this->url->link('common/home', $token, 'SSL'),
			'separator' => false
		);

		$data['breadcrumbs'][] = array(
			'text'      => $this->language->get('text_payment'),
			'href' 		=> $this->url->link($path, $token . '&type=payment', true),
			'separator' => ' :: '
		);

		$data['breadcrumbs'][] = array(
			'text'      => $this->language->get('heading_title'),
			'href'      => $this->url->link('extension/payment/securesubmit', $token, 'SSL'),
		);

		$data['action'] = $this->url->link('extension/payment/securesubmit', $token, 'SSL');
		$data['cancel'] = $this->url->link($path, $token . '&type=payment', true);

		if (isset($this->request->post[$prefix . 'securesubmit_test_public_key'])) {
			$data[$prefix . 'securesubmit_test_public_key'] = $this->request->post[$prefix . 'securesubmit_test_public_key'];
		} else {
			$data[$prefix . 'securesubmit_test_public_key'] = $this->config->get($prefix . 'securesubmit_test_public_key');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_test_private_key'])) {
			$data[$prefix . 'securesubmit_test_private_key'] = $this->request->post[$prefix . 'securesubmit_test_private_key'];
		} else {
			$data[$prefix . 'securesubmit_test_private_key'] = $this->config->get($prefix . 'securesubmit_test_private_key');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_live_public_key'])) {
			$data[$prefix . 'securesubmit_live_public_key'] = $this->request->post[$prefix . 'securesubmit_live_public_key'];
		} else {
			$data[$prefix . 'securesubmit_live_public_key'] = $this->config->get($prefix . 'securesubmit_live_public_key');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_live_private_key'])) {
			$data[$prefix . 'securesubmit_live_private_key'] = $this->request->post[$prefix . 'securesubmit_live_private_key'];
		} else {
			$data[$prefix . 'securesubmit_live_private_key'] = $this->config->get($prefix . 'securesubmit_live_private_key');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_mode'])) {
			$data[$prefix . 'securesubmit_mode'] = $this->request->post[$prefix . 'securesubmit_mode'];
		} else {
			$data[$prefix . 'securesubmit_mode'] = $this->config->get($prefix . 'securesubmit_mode');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_method'])) {
			$data[$prefix . 'securesubmit_method'] = $this->request->post[$prefix . 'securesubmit_method'];
		} else {
			$data[$prefix . 'securesubmit_method'] = $this->config->get($prefix . 'securesubmit_method');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_total'])) {
			$data[$prefix . 'securesubmit_total'] = $this->request->post[$prefix . 'securesubmit_total'];
		} else {
			$data[$prefix . 'securesubmit_total'] = $this->config->get($prefix . 'securesubmit_total');
		}
		
		if (isset($this->request->post[$prefix . 'securesubmit_use_iframes'])) {
			$data[$prefix . 'securesubmit_use_iframes'] = $this->request->post[$prefix . 'securesubmit_use_iframes'];
		} else {
			$data[$prefix . 'securesubmit_use_iframes'] = $this->config->get($prefix . 'securesubmit_use_iframes');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_order_status_id'])) {
			$data[$prefix . 'securesubmit_order_status_id'] = $this->request->post[$prefix . 'securesubmit_order_status_id'];
		} else {
			$data[$prefix . 'securesubmit_order_status_id'] = $this->config->get($prefix . 'securesubmit_order_status_id');
		}

		$this->load->model('localisation/order_status');

		$data['order_statuses'] = $this->model_localisation_order_status->getOrderStatuses();

		if (isset($this->request->post[$prefix . 'securesubmit_geo_zone_id'])) {
			$data[$prefix . 'securesubmit_geo_zone_id'] = $this->request->post[$prefix . 'securesubmit_geo_zone_id'];
		} else {
			$data[$prefix . 'securesubmit_geo_zone_id'] = $this->config->get($prefix . 'securesubmit_geo_zone_id');
		}

		$this->load->model('localisation/geo_zone');

		$data['geo_zones'] = $this->model_localisation_geo_zone->getGeoZones();

		if (isset($this->request->post[$prefix . 'securesubmit_status'])) {
			$data[$prefix . 'securesubmit_status'] = $this->request->post[$prefix . 'securesubmit_status'];
		} else {
			$data[$prefix . 'securesubmit_status'] = $this->config->get($prefix . 'securesubmit_status');
		}

		if (isset($this->request->post[$prefix . 'securesubmit_sort_order'])) {
			$data[$prefix . 'securesubmit_sort_order'] = $this->request->post[$prefix . 'securesubmit_sort_order'];
		} else {
			$data[$prefix . 'securesubmit_sort_order'] = $this->config->get($prefix . 'securesubmit_sort_order') ;
		}
// fraud


		if (isset($this->request->post['securesubmit_fraud_enable'])) {
			$data['securesubmit_fraud_enable'] = $this->request->post['securesubmit_fraud_enable'];
		} else {
			$data['securesubmit_fraud_enable'] = $this->config->get('securesubmit_fraud_enable') ? 'checked ' : '';
		}

		if (isset($this->request->post['securesubmit_fraud_message'])) {
			$data['securesubmit_fraud_message'] = $this->request->post['securesubmit_fraud_message'];
		} else {
			$data['securesubmit_fraud_message'] = $this->config->get('securesubmit_fraud_message') ? $this->config->get('securesubmit_fraud_message') :  'Please contact us to complete the transaction.';
		}
		if (isset($this->request->post['securesubmit_fraud_fail'])) {
			$data['securesubmit_fraud_fail'] = $this->request->post['securesubmit_fraud_fail'];
		} else {
			$data['securesubmit_fraud_fail'] = $this->config->get('securesubmit_fraud_fail') ? $this->config->get('securesubmit_fraud_fail') : 3;
		}
		if (isset($this->request->post['securesubmit_fraud_time'])) {
			$data['securesubmit_fraud_time'] = $this->request->post['securesubmit_fraud_time'];
		} else {
			$data['securesubmit_fraud_time'] = $this->config->get('securesubmit_fraud_time') ? $this->config->get('securesubmit_fraud_time') : 10;
		}

// fraud
		$data['header'] = $this->load->controller('common/header');
		$data['column_left'] = $this->load->controller('common/column_left');
		$data['footer'] = $this->load->controller('common/footer');

		$this->response->setOutput($this->load->view('extension/payment/securesubmit', $data));
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', 'extension/payment/securesubmit')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

// 		if (!$this->request->post['securesubmit_login']) {
// 			$this->error['login'] = $this->language->get('error_login');
// 		}

// 		if (!$this->request->post['securesubmit_key']) {
// 			$this->error['key'] = $this->language->get('error_key');
// 		}

		return !$this->error;
	}
}
?>
