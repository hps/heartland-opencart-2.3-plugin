<h2><?php echo $text_credit_card; ?></h2>
<div class="content" id="payment">
  <table class="form">
    <tr>
      <td><?php echo $entry_cc_owner; ?></td>
      <td><input type="text" name="cc_owner" value="" /></td>
    </tr>
    <tr>
      <td><?php echo $entry_cc_number; ?></td>
      <td><input type="text" class="cc_number" value="" /></td>
    </tr>
    <tr>
      <td><?php echo $entry_cc_expire_date; ?></td>
      <td><select class="cc_expire_date_month">
          <?php foreach ($months as $month) { ?>
          <option value="<?php echo $month['value']; ?>"><?php echo $month['text']; ?></option>
          <?php } ?>
        </select>
        /
        <select class="cc_expire_date_year">
          <?php foreach ($year_expire as $year) { ?>
          <option value="<?php echo $year['value']; ?>"><?php echo $year['text']; ?></option>
          <?php } ?>
        </select></td>
    </tr>
    <tr>
      <td><?php echo $entry_cc_cvv2; ?></td>
      <td><input type="text" class="cc_cvv2" value="" size="3" /></td>
    </tr>
  </table>
</div>
<div class="buttons">
  <div class="right"><input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="button" /></div>
</div>
<script type="text/javascript"><!--
$('#button-confirm').bind('click', secureSubmitFormHandler);

    $(".cc_number").keydown(function (e) {
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
	
	var securesubmit_public_key = '<?php echo 
	($this->config->get('securesubmit_mode') == 'test') ? $this->config->get('securesubmit_test_public_key') : $this->config->get('securesubmit_live_public_key'); ?>';
	
		if ( jQuery( 'input.securesubmitToken' ).size() == 0 ) {
			var card 	= jQuery('.cc_number').val().replace(/\D/g, '');
			var cvc 	= jQuery('.cc_cvv2').val();
			var month	= jQuery('.cc_expire_date_month').val();
			var year	= jQuery('.cc_expire_date_year').val();
			hps.tokenize({
				data: {
					public_key: securesubmit_public_key,
					number: card,
					cvc: cvc,
					exp_month: month,
					exp_year: year
				},
				success: function(response) {
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
	var bodyTag = jQuery('body').first();
   
    if ( response.message ) {
        alert(response.message);
        $('#button-confirm').attr('disabled', false);
    } else {
        bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.token_value + "'/>");
        form_submit();
    }
}

function form_submit( ) {
    var ret = [];
    jQuery(':input').each(function(index) {
        ret.push( encodeURIComponent(this.name) + "=" + encodeURIComponent( $(this).val() ) );
    });
    
	$.ajax({
		url: 'index.php?route=payment/securesubmit/send',
		type: 'post',
		data: ret.join("&").replace(/%20/g, "+"),
		dataType: 'json',		
		beforeSend: function() {
		$('#button-confirm').attr('disabled', true);
		$('#payment').before('<div class="attention"><img src="catalog/view/theme/default/image/loading.gif" alt="" /> <?php echo $text_wait; ?></div>');
		},
		complete: function() {
			$('#button-confirm').attr('disabled', false);
			$('.attention').remove();
		},				
		success: function(json) {
			if (json['error']) {
				alert(json['error']);
			}
			
			if (json['success']) {
				location = json['success'];
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