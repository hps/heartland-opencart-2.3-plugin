<link rel="stylesheet" type="text/css" href="<?php echo $base;?>catalog/view/stylesheet/securesubmit.css">
<link rel="dns-prefetch" href="https://hps.github.io" />
<link rel="prefetch" href="https://hps.github.io" />
<link rel="dns-prefetch" href="https://api.heartlandportico.com" />
<link rel="prefetch" href="https://api.heartlandportico.com" />

<!-- The Payment Form -->
<div id="hpsPaymentForm">
	<fieldset id="payment">
		<legend><?php echo $text_credit_card; ?><br>
			<div class="ss-shield">  </div>
			<div class="visa-gray hidden-xs "></div>
			<div class="mc-gray hidden-xs"></div>
			<div class="amex-gray hidden-xs"></div>
			<div class="jcb-gray hidden-xs"></div>
			<div class="disc-gray hidden-xs"></div>
		</legend>
	</fieldset>
	<div class="form-group">
		<label class="control-label ss-label" for="input-cc-number"><?php echo $entry_cc_number; ?></label></br>

		<div class="form-group required col-md-10">
			<label class="control-label ss-label" for="input-cc-number"><?php echo $entry_cc_number; ?></label></br>
			<div id="securesubmitIframeCardNumber" class="ss-frame-container"></div>
			<p class="error-message" id="gps-card-error"></p>
	</div>
	<div class="form-group">
		<label class="control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>

		<div class="form-group required col-md-5">
			<label class="control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>
			<div id="securesubmitIframeCardExpiration" class="ss-frame-container"></div>
			<p class="error-message" id="gps-expiry-error"></p>
	</div>
	<div class="form-group">
		<label class="control-label ss-label cvv-label" for="input-cc-cvv2"><?php echo $entry_cc_cvv2; ?></label></br>

		<div id="securesubmitIframeCardCvv" class="ss-frame-container"></div>
		<p class="error-message" id="gps-cvv-error"></p>
	</div>
	<div class="form-group required ">
		<div id="submit_button" class="ss-frame-container"></div>
	</div>

<script type="text/javascript">
$(document).ready(function () {

  function secureSubmitResponseHandler(response) {
    var bodyTag = $('body').first();
    if (response.message) {
      alert(response.message);

    } else {
      bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.paymentReference + "'/>");
      form_submit();
    }
  }

  function form_submit() {
    var ret = [];
    $(':input').each(function (index) {
      ret.push(encodeURIComponent(this.name) + "=" + encodeURIComponent($(this).val()));
    });

    $.ajax({
      url: 'index.php?route=extension/payment/securesubmit/send',
      type: 'post',
      data: ret.join("&").replace(/%20/g, "+"),
      dataType: 'json',
      cache: false,
      beforeSend: function () {

      },
      complete: function () {
          var submit_button = document.getElementById('submit_button');
          submit_button.classList.remove("disable-button");
      },
      success: function (json){
        if (json['error']) {
          alert(json['error']);
        }
        if (json['redirect']) {
          window.location = json['redirect'];
        }
      }
    });
  }

  function loadjsfile(filename, filetype, callback) {
    if (filetype === "js") { //if filename is a external JavaScript file
      var fileref = document.createElement('script');
      fileref.setAttribute("type","text/javascript");
      fileref.setAttribute("src", filename);
    }
    if (typeof fileref !== "undefined" && typeof callback !== 'undefined') {
      fileref.setAttribute('onload', callback);
    }
    if (typeof fileref !== "undefined") {
      document.getElementsByTagName("head")[0].appendChild(fileref);
    }
  }

  //dynamically load and add this .js file
  loadjsfile("https://js.globalpay.com/v1/globalpayments.js", "js", "secureSubmitPrepareFields();");

  window.secureSubmitPrepareFields = function () {
    var publicKey = '<?php echo $publicKey;?>';

    GlobalPayments.configure({
        "publicApiKey": "<?php echo $publicKey;?>"
    });
      // Create a new `HPS` object with the necessary configuration
      window.hps = GlobalPayments.ui.form({
         fields: {
              "card-number": {
                  placeholder: "•••• •••• •••• ••••",
                  target: "#securesubmitIframeCardNumber"
              },
			 "card-expiration": {
				 placeholder: "MM / YYYY",
				 target: "#securesubmitIframeCardExpiration"
			 },
			 "card-cvv": {
				 placeholder: "•••",
				 target: "#securesubmitIframeCardCvv"
			 },
			 "submit": {
				 target: "#submit_button",
				 text: "Confirm Order"
			 }
		 },
        // Collection of CSS to inject into the iframes.
        // These properties can match the site's styles
        // to create a seamless experience.
		  styles:  {
			  'html' : {
				  "-webkit-text-size-adjust": "100%"
			  },
			  'body' : {
				  'width' : '100%'
			  },
			  '#secure-payment-field-wrapper' : {
				  'position' : 'relative',
				  'justify-content'  : 'flex-end',
				  'margin': '0 12px'
			  },
			  '#secure-payment-field' : {
				  'background-color' : '#fff',
				  'border'           : '1px solid #ccc',
				  'border-radius'    : '4px',
				  'display'          : 'block',
				  'font-size'        : '14px',
				  'height'           : '35px',
				  'padding'          : '6px 12px',
				  'width'            : '100%',
			  },
			  '#secure-payment-field:focus' : {
				  "border": "1px solid lightblue",
				  "box-shadow": "0 1px 3px 0 #cecece",
				  "outline": "none"
			  },
			  'button#secure-payment-field.submit' : {
				  'width': 'unset',
				  'flex': 'unset',
				  'float': 'right',
				  'color': '#fff',
				  'background': '#2e6da4',
				  'cursor': 'pointer'
			  },
			  '.card-number::-ms-clear' : {
				  'display' : 'none'
			  },
			  'input[placeholder]' : {
				  'letter-spacing' : '.5px',
			  },
		  }
	  });
	  window.hps.on('submit', 'click', function(){
		  var submit_button = document.getElementById('submit_button');
		  submit_button.classList.add("disable-button");
	  });
	  window.hps.on("token-success", function(resp) {
		  window.hps.errors();
		  if(resp.details.cardSecurityCode == false){
			  document.getElementById("gps-expiry-error").style.display = 'block';
			  document.getElementById("gps-expiry-error").innerText = 'Invalid Card Details';
			  var submit_button = document.getElementById('submit_button');
			  submit_button.classList.remove("disable-button");
		  }else{
			  secureSubmitResponseHandler(resp);
		  }
	  });
	  window.hps.on("token-error", function(resp) {
		  if(resp.error){
			  resp.reasons.forEach(function(v){
				  if(v.code == "INVALID_CARD_NUMBER"){
					  document.getElementById("gps-card-error").style.display = 'block';
					  document.getElementById("gps-card-error").innerText = v.message;
				  }else{
					  alert(v.message);
				  }
			  })
		  }
		  var submit_button = document.getElementById('submit_button');
		  submit_button.classList.remove("disable-button");
	  });
	  window.hps.errors = function(){
		  var errorsDiv = document.getElementsByClassName("error-message");
		  for(var i = 0; i < errorsDiv.length; i++){
			  errorsDiv[i].style.display = "none";
		  }
	  }
	  window.hps.stopConfirm = function(){
		  var errorsDiv = document.getElementsByClassName("error-message");
		  for(var i = 0; i < errorsDiv.length; i++){
			  errorsDiv[i].style.display = "none";
		  }
		}
  }
});
</script>
