<form class="form-horizontal">
  <fieldset id="payment">
    <legend><?php echo $text_credit_card; ?>
      <div class="ss-shield">
        <h6>We accept Visa, Mastercard, AMEX, Discover & JCB </h4>
      </div>
    </legend>

    <div class="form-group required col-md-10 ">

      <label class="control-label ss-label" for="input-cc-owner"><?php echo $entry_cc_owner; ?></label></br>
       
        <input type="text" name="cc_owner" value="" placeholder="<?php echo $entry_cc_owner; ?>" id="input-cc-owner" class="form-control ss-form-control" />
   
    </div>
     <div class="form-group required col-md-10">
  
      <label class="control-label ss-label" for="input-cc-number"><?php echo $entry_cc_number; ?></label></br>
     
        <input type="text" name="cc_number" value="" placeholder="<?php echo $entry_cc_number; ?>" id="input-cc-number" class="form-control ss-form-control card-type-icon" />
    
    </div>
</br>
   <div class="form-group required col-md-5">
      <label class="control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>
         
        <input type="text" name="cc_expire_date_month" id="input-cc-expire-date-month" class="form-control ss-form-control" placeholder="mm / yy" />
      
    </div>
    <div class="form-group required col-md-5 col-md-offset-7"> 
        <label class="control-label ss-label cvv-label" for="input-cc-cvv2"><?php echo $entry_cc_cvv2; ?></label></br>
      
        <input type="text" name="cc_cvv2" value="" placeholder="<?php echo $entry_cc_cvv2; ?>" id="input-cc-cvv2" class="form-control ss-form-control cvv-icon"  />
         
   
    </div>
<!--
    <div class="form-group required">
      <label class="col-md-5 control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>
          <div class="col-sm-10 col-md-5">
        <input type="text" name="cc_expire_date_month" id="input-cc-expire-date-month" class="form-control ss-form-control" placeholder="mm / yy"></input>
      </div>
    </div>
    <div class="form-group required"> 
        <label class="col-md-5 control-label ss-label" for="input-cc-cvv2"><?php echo $entry_cc_cvv2; ?></label></br>
      <div class="col-sm-10 col-md-5">
        <input type="text" name="cc_cvv2" value="" placeholder="<?php echo $entry_cc_cvv2; ?>" id="input-cc-cvv2" class="form-control ss-form-control cvv-icon"  />
         
       </div>  
    </div>
    -->

  </fieldset>
</form>
<div class="buttons">
  <div class="pull-right">
    <input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="btn btn-primary" />
  </div>
</div>
<script type="text/javascript"><!--
$('#button-confirm').bind('click', secureSubmitFormHandler);
    $("#input-cc-number").keydown(function (e) {
        // Allow: backspace, delete, tab, escape, enter and .
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
             // Allow: Ctrl+A
            (e.keyCode == 65 && e.ctrlKey === true) ||
             // Allow: home, end, left, right
            (e.keyCode >= 35 && e.keyCode <= 39)) {
                 // let it happen, don't do anything
                 return;
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    });

function secureSubmitFormHandler() {

	var securesubmit_public_key = "<?php global $config; echo
	($config->get('securesubmit_mode') == 'test') ? $config->get('securesubmit_test_public_key') : $config->get('securesubmit_live_public_key'); ?>";

		if ( $( 'input.securesubmitToken' ).size() == 0 ) {
			var card 	= $('#input-cc-number').val().replace(/\D/g, '');
			var cvc 	= $('#input-cc-cvv2').val();
			var month	= $('#input-cc-expire-date-month').val();
			var year	= $('#input-cc-expire-date-year').val();
			hps.tokenize({
				data: {
					public_key: securesubmit_public_key,
					number: card,
					cvc: cvc,
					exp_month: month,
					exp_year: year
				},
				success: function(response) {
          console.log('alright, we hit a success point');
					secureSubmitResponseHandler(response);
				},
				error: function(response) {
					secureSubmitResponseHandler(response);
				}
			});
			return false;
	}

	return true;
}

function secureSubmitResponseHandler( response ) {

	var bodyTag = $('body').first();
    if ( response.message ) {
        alert(response.message);
        $('#button-confirm').button('reset');
    } else {
        bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.token_value + "'/>");
        form_submit();
    }
}

function form_submit() {
    var ret = [];
    $(':input').each(function(index) {
        ret.push( encodeURIComponent(this.name) + "=" + encodeURIComponent( $(this).val() ) );
    });

	$.ajax({
		url: 'index.php?route=payment/securesubmit/send',
		type: 'post',
		data: ret.join("&").replace(/%20/g, "+"),
		dataType: 'json',
    cache: false,
		beforeSend: function() {
		$('#button-confirm').button('loading');
		},
		complete: function() {
			$('#button-confirm').button('reset');
		},
    success: function(json){
      if (json['error']) {
       alert(json['error']);
      }
      if (json['redirect']) {
        location = json['redirect'];
      }
    }
	});
}

function loadjsfile(filename, filetype){
 if (filetype=="js"){ //if filename is a external JavaScript file
  var fileref=document.createElement('script')
  fileref.setAttribute("type","text/javascript")
  fileref.setAttribute("src", filename)
 }
 if (typeof fileref!="undefined")
  document.getElementsByTagName("head")[0].appendChild(fileref)
}

loadjsfile("catalog/view/javascript/secure.submit-1.0.2.js", "js") //dynamically load and add this .js file
</script>
