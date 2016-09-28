<?php
  global $config;
  $securesubmit_public_key = $config->get('securesubmit_mode') == 'test'
? $config->get('securesubmit_test_public_key')
: $config->get('securesubmit_live_public_key');
$securesubmit_use_iframes = !!($config->get('securesubmit_use_iframes'));
?>
<link rel="stylesheet" type="text/css" href="catalog/view/stylesheet/securesubmit.css">

<?php if ($securesubmit_use_iframes): // help prevent flash of no fields ?>
<link rel="dns-prefetch" href="https://hps.github.io" />
<link rel="prefetch" href="https://hps.github.io" />
<link rel="dns-prefetch" href="https://api.heartlandportico.com" />
<link rel="prefetch" href="https://api.heartlandportico.com" />
<?php endif; ?>

<form class="form-horizontal">
  <fieldset id="payment">
    <legend><?php echo $text_credit_card; ?><br>

      <div class="ss-shield">  </div>
        <div class="visa-gray hidden-xs "></div>
        <div class="mc-gray hidden-xs"></div>
        <div class="amex-gray hidden-xs"></div>
        <div class="jcb-gray hidden-xs"></div>
        <div class="disc-gray hidden-xs"></div>

    </legend>

     <div class="form-group required col-md-10">

      <label class="control-label ss-label" for="input-cc-number"><?php echo $entry_cc_number; ?></label></br>


       <?php if ($securesubmit_use_iframes): ?>
       <div id="securesubmitIframeCardNumber" class="ss-frame-container"></div>
       <?php else: ?>
       <input type="tel" value="" placeholder="•••• •••• •••• ••••" id="input-cc-number" class="form-control ss-form-control card-type-icon" />
       <?php endif; ?>

    </div>

   <div class="form-group required col-md-5">
      <label class="control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>

     <?php if ($securesubmit_use_iframes): ?>
     <div id="securesubmitIframeCardExpiration" class="ss-frame-container"></div>
     <?php else: ?>
     <input type="tel" name="cc_expire_date" id="input-cc-expire-date" class="form-control ss-form-control" placeholder="MM / YYYY" />
     <?php endif; ?>

    </div>
    <div class="form-group required col-md-5 col-md-offset-7">
        <label class="control-label ss-label cvv-label" for="input-cc-cvv2"><?php echo $entry_cc_cvv2; ?></label></br>

      <?php if ($securesubmit_use_iframes): ?>
      <div id="securesubmitIframeCardCvv" class="ss-frame-container"></div>
      <?php else: ?>
      <input type="tel" value="" placeholder="<?php echo $entry_cc_cvv2; ?>" id="input-cc-cvv2" class="form-control ss-form-control cvv-icon"  />
      <?php endif; ?>

    </div>
  </fieldset>
</form>
<div class="buttons">
  <div class="pull-right">
    <input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="btn btn-primary" />
  </div>
</div>
<script type="text/javascript"><!--
          $(document).ready(function () {
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
              var securesubmit_public_key = '<?php echo $securesubmit_public_key;?>';
              if ($('input.securesubmitToken').size() === 0) {
                if (<?php echo ($securesubmit_use_iframes ? 'true' : 'false');?>) {
        window.hps.Messages.post(
          {
            accumulateData: true,
            action: 'tokenize',
            message: securesubmit_public_key
          },
          'cardNumber'
        );
      } else {
        var card  = $('#input-cc-number').val().replace(/\D/g, '');
        var cvc   = $('#input-cc-cvv2').val();
        var exp   = $('#input-cc-expire-date').val().split(' / ');
              var month = exp[0];
              var year  = exp[1];
              (new Heartland.HPS({
                publicKey: securesubmit_public_key,
                cardNumber: card,
                cardCvv: cvc,
                cardExpMonth: month,
                cardExpYear: year,
                success: secureSubmitResponseHandler,
                error: secureSubmitResponseHandler
              })).tokenize();
              return false;
              }
              }
              return true;
              }
              function secureSubmitResponseHandler(response) {
                var bodyTag = $('body').first();
                if (response.message) {
                alert(response.message);
                $('#button-confirm').button('reset');
              } else {
                bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.token_value + "'/>");
                form_submit();
              }
              }
              function form_submit() {
                var ret = [];
                $(':input').each(function (index) {
                ret.push(encodeURIComponent(this.name) + "=" + encodeURIComponent($(this).val()));
              });
                $.ajax({
                url: 'index.php?route=payment/securesubmit/send',
                type: 'post',
                data: ret.join("&").replace(/%20/g, "+"),
                dataType: 'json',
                cache: false,
                beforeSend: function () {
                $('#button-confirm').button('loading');
              },
                complete: function () {
                $('#button-confirm').button('reset');
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
              loadjsfile("https://api.heartlandportico.com/SecureSubmit.v1/token/2.1/securesubmit.js", "js", 'secureSubmitPrepareFields();');
  window.secureSubmitPrepareFields = function () {
    var securesubmit_public_key = '<?php echo $securesubmit_public_key;?>';
    var image_base = '<?php echo $base_url; ?>catalog/view/image';
    if (<?php echo ($securesubmit_use_iframes ? 'true' : 'false');?>) {
      // Create a new `HPS` object with the necessary configuration
      window.hps = new Heartland.HPS({
        publicKey: securesubmit_public_key,
        type:      'iframe',
        // Configure the iframe fields to tell the library where
        // the iframe should be inserted into the DOM and some
        // basic options
        fields: {
          cardNumber: {
            target:      'securesubmitIframeCardNumber',
            placeholder: '•••• •••• •••• ••••'
          },
          cardExpiration: {
            target:      'securesubmitIframeCardExpiration',
            placeholder: 'MM / YYYY'
          },
          cardCvv: {
            target:      'securesubmitIframeCardCvv',
            placeholder: 'CVV'
          }
        },
        // Collection of CSS to inject into the iframes.
        // These properties can match the site's styles
        // to create a seamless experience.
        style: {
          'input': {
            'font-size': '12px',
            'border': '1px solid #ababab',
            'border-radius': '0px',
            'display': '-webkit-inline-box',
            'height': '40px',
            'width': '95%',
            'padding': '6px 12px',
            'padding-right': '0',
            'line-height': '1.42857143',
            'color': '#555',
            'background-color': '#fff',
            'box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075)',
            'transition': 'border-color ease-in-out.15s,box-shadow ease-in-out .15s',
            'font-family': '"Helvetica Neue",Helvetica,Arial,sans-serif',
            'margin': '0'
          },
          '@media only screen and (max-width: 991px)': {
            'input[name="cardNumber"]': {
              'width': '95%'
            }
          },
          '@media only screen and (min-width: 992px) and (max-width: 1199px)': {
            'input[name="cardNumber"]': {
              'width': '93.5%'
            }
          },
          '@media only screen and (min-width: 1200px)': {
            'input[name="cardNumber"]': {
              'width': '93.5%'
            }
          },
          'input[name="cardNumber"]': {
            'background-image': 'url("' + image_base + '/ss-inputcard-blank@2x.png")',
            'background-repeat': 'no-repeat',
            'background-size': '56px 33px',
            'background-position': 'right'
          },
          'input[name="cardCvv"]': {
            'background-image': 'url("' + image_base + '/cvv1.png")',
            'background-repeat': 'no-repeat',
            'background-position': 'right',
            'background-size': '60px 36px'
          },
          // invalid
          'input[name="cardNumber"].card-type-visa.invalid': {
            'background-image': 'url("' + image_base + '/visa-gray.png")',
            'background-size': '50px 18px'
          },
          'input[name="cardNumber"].card-type-amex.invalid': {
            'background-image': 'url("' + image_base + '/amex-gray.png")',
            'background-size': '30px 30px'
          },
          'input[name="cardNumber"].card-type-jcb.invalid': {
            'background-image': 'url("' + image_base + '/jcb-gray.png")',
            'background-size': '40px 30px'
          },
          'input[name="cardNumber"].card-type-discover.invalid': {
            'background-image': 'url("' + image_base + '/disc-gray.png")',
            'background-size': '70px 50px'
          },
          'input[name="cardNumber"].card-type-mastercard.invalid': {
            'background-image': 'url("' + image_base + '/mc-gray.png")',
            'background-size': '50px 30px'
          },
          // valid
          'input[name="cardNumber"].card-type-visa.valid': {
            'background-image': 'url("' + image_base + '/ss-inputcard-visa@2x.png")',
            'background-size': '81px 48px'
          },
          'input[name="cardNumber"].card-type-mastercard.valid': {
            'background-image': 'url("' + image_base + '/ss-inputcard-mastercard@2x.png")',
            'background-size': '60px 39px'
          },
          'input[name="cardNumber"].card-type-discover.valid': {
            'background-image': 'url("' + image_base + '/ss-inputcard-discover@2x.png")',
            'background-size': '93px 44px'
          },
          'input[name="cardNumber"].card-type-jcb.valid': {
            'background-image': 'url("' + image_base + '/ss-inputcard-jcb@2x.png")',
            'background-size': '61px 37px'
          },
          'input[name="cardNumber"].card-type-amex.valid': {
            'background-image': 'url("' + image_base + '/ss-inputcard-amex@2x.png")',
            'background-size': '51px 34px'
          }
        },
        // Callback when a token is received from the service
        onTokenSuccess: secureSubmitResponseHandler,
        // Callback when an error is received from the service
        onTokenError: secureSubmitResponseHandler
      });
    } else {
      Heartland.Card.attachNumberEvents('#input-cc-number');
      Heartland.Card.attachExpirationEvents('#input-cc-expire-date');
      Heartland.Card.attachCvvEvents('#input-cc-cvv2');
    }
  }
});
</script>