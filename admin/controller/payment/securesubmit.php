<?php
class ControllerPaymentSecureSubmit extends Controller {
	private $error = array();

	public function index() {
		$this->language->load('payment/securesubmit');

		$this->document->setTitle($this->language->get('heading_title'));

		$this->load->model('setting/setting');

		if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {
			$this->model_setting_setting->editSetting('securesubmit', $this->request->post);

			$this->session->data['success'] = $this->language->get('text_success');

			$this->redirect($this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL'));
		}

		$this->data['heading_title'] = $this->language->get('heading_title');

		$this->data['text_enabled'] = $this->language->get('text_enabled');
		$this->data['text_disabled'] = $this->language->get('text_disabled');
		$this->data['text_all_zones'] = $this->language->get('text_all_zones');
		$this->data['text_test'] = $this->language->get('text_test');
		$this->data['text_live'] = $this->language->get('text_live');
		$this->data['text_authorization'] = $this->language->get('text_authorization');
		$this->data['text_capture'] = $this->language->get('text_capture');

		$this->data['entry_test_private_key'] = $this->language->get('entry_test_private_key');
		$this->data['entry_test_public_key'] = $this->language->get('entry_test_public_key');
		$this->data['entry_live_private_key'] = $this->language->get('entry_live_private_key');
		$this->data['entry_live_public_key'] = $this->language->get('entry_live_public_key');
		$this->data['entry_mode'] = $this->language->get('entry_mode');
		$this->data['entry_method'] = $this->language->get('entry_method');
		$this->data['entry_total'] = $this->language->get('entry_total');
		$this->data['entry_order_status'] = $this->language->get('entry_order_status');
		$this->data['entry_geo_zone'] = $this->language->get('entry_geo_zone');
		$this->data['entry_status'] = $this->language->get('entry_status');
		$this->data['entry_sort_order'] = $this->language->get('entry_sort_order');

		$this->data['button_save'] = $this->language->get('button_save');
		$this->data['button_cancel'] = $this->language->get('button_cancel');

 		if (isset($this->error['warning'])) {
			$this->data['error_warning'] = $this->error['warning'];
		} else {
			$this->data['error_warning'] = '';
		}

 		if (isset($this->error['test_private_key'])) {
			$this->data['error_test_private_key'] = $this->error['test_private_key'];
		} else {
			$this->data['error_test_private_key'] = '';
		}

 		if (isset($this->error['test_public_key'])) {
			$this->data['error_test_public_key'] = $this->error['test_public_key'];
		} else {
			$this->data['error_test_public_key'] = '';
		}

	 	if (isset($this->error['live_private_key'])) {
			$this->data['error_live_private_key'] = $this->error['live_private_key'];
		} else {
			$this->data['error_live_private_key'] = '';
		}

 		if (isset($this->error['live_public_key'])) {
			$this->data['error_live_public_key'] = $this->error['live_public_key'];
		} else {
			$this->data['error_live_public_key'] = '';
		}

		$this->data['breadcrumbs'] = array();

   		$this->data['breadcrumbs'][] = array(
       		'text'      => $this->language->get('text_home'),
			'href'      => $this->url->link('common/home', 'token=' . $this->session->data['token'], 'SSL'),
      		'separator' => false
   		);

   		$this->data['breadcrumbs'][] = array(
       		'text'      => $this->language->get('text_payment'),
			'href'      => $this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL'),
      		'separator' => ' :: '
   		);

   		$this->data['breadcrumbs'][] = array(
       		'text'      => $this->language->get('heading_title'),
			'href'      => $this->url->link('payment/securesubmit', 'token=' . $this->session->data['token'], 'SSL'),
      		'separator' => ' :: '
   		);

		$this->data['action'] = $this->url->link('payment/securesubmit', 'token=' . $this->session->data['token'], 'SSL');

		$this->data['cancel'] = $this->url->link('extension/payment', 'token=' . $this->session->data['token'], 'SSL');

		if (isset($this->request->post['securesubmit_test_public_key'])) {
			$this->data['securesubmit_test_public_key'] = $this->request->post['securesubmit_test_public_key'];
		} else {
			$this->data['securesubmit_test_public_key'] = $this->config->get('securesubmit_test_public_key');
		}

		if (isset($this->request->post['securesubmit_test_private_key'])) {
			$this->data['securesubmit_test_private_key'] = $this->request->post['securesubmit_test_private_key'];
		} else {
			$this->data['securesubmit_test_private_key'] = $this->config->get('securesubmit_test_private_key');
		}

		if (isset($this->request->post['securesubmit_live_public_key'])) {
			$this->data['securesubmit_live_public_key'] = $this->request->post['securesubmit_live_public_key'];
		} else {
			$this->data['securesubmit_live_public_key'] = $this->config->get('securesubmit_live_public_key');
		}

		if (isset($this->request->post['securesubmit_live_private_key'])) {
			$this->data['securesubmit_live_private_key'] = $this->request->post['securesubmit_live_private_key'];
		} else {
			$this->data['securesubmit_live_private_key'] = $this->config->get('securesubmit_live_private_key');
		}

		if (isset($this->request->post['securesubmit_mode'])) {
			$this->data['securesubmit_mode'] = $this->request->post['securesubmit_mode'];
		} else {
			$this->data['securesubmit_mode'] = $this->config->get('securesubmit_mode');
		}

		if (isset($this->request->post['securesubmit_method'])) {
			$this->data['securesubmit_method'] = $this->request->post['securesubmit_method'];
		} else {
			$this->data['securesubmit_method'] = $this->config->get('securesubmit_method');
		}

		if (isset($this->request->post['securesubmit_total'])) {
			$this->data['securesubmit_total'] = $this->request->post['securesubmit_total'];
		} else {
			$this->data['securesubmit_total'] = $this->config->get('securesubmit_total');
		}

		if (isset($this->request->post['securesubmit_order_status_id'])) {
			$this->data['securesubmit_order_status_id'] = $this->request->post['securesubmit_order_status_id'];
		} else {
			$this->data['securesubmit_order_status_id'] = $this->config->get('securesubmit_order_status_id');
		}

		$this->load->model('localisation/order_status');

		$this->data['order_statuses'] = $this->model_localisation_order_status->getOrderStatuses();

		if (isset($this->request->post['securesubmit_geo_zone_id'])) {
			$this->data['securesubmit_geo_zone_id'] = $this->request->post['securesubmit_geo_zone_id'];
		} else {
			$this->data['securesubmit_geo_zone_id'] = $this->config->get('securesubmit_geo_zone_id');
		}

		$this->load->model('localisation/geo_zone');

		$this->data['geo_zones'] = $this->model_localisation_geo_zone->getGeoZones();

		if (isset($this->request->post['securesubmit_status'])) {
			$this->data['securesubmit_status'] = $this->request->post['securesubmit_status'];
		} else {
			$this->data['securesubmit_status'] = $this->config->get('securesubmit_status');
		}

		if (isset($this->request->post['securesubmit_sort_order'])) {
			$this->data['securesubmit_sort_order'] = $this->request->post['securesubmit_sort_order'];
		} else {
			$this->data['securesubmit_sort_order'] = $this->config->get('securesubmit_sort_order');
		}

		$this->template = 'payment/securesubmit.tpl';
		$this->children = array(
			'common/header',
			'common/footer'
		);

		$this->response->setOutput($this->render());
	}

	protected function validate() {
		if (!$this->user->hasPermission('modify', 'payment/securesubmit')) {
			$this->error['warning'] = $this->language->get('error_permission');
		}

// 		if (!$this->request->post['securesubmit_login']) {
// 			$this->error['login'] = $this->language->get('error_login');
// 		}

// 		if (!$this->request->post['securesubmit_key']) {
// 			$this->error['key'] = $this->language->get('error_key');
// 		}

		if (!$this->error) {
			return true;
		} else {
			return false;
		}
	}
}
?>