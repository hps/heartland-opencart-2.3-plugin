<link rel="stylesheet" type="text/css" href="catalog/view/stylesheet/securesubmit.css">

<!-- make iframes styled like other form -->
<style type="text/css">
    #iframes iframe{
        float:left;
        width:100%;
    }
    .iframeholder:after,
    .iframeholder::after{
        content:'';
        display:block;
        width:100%;
        height:0px;
        clear:both;
        position:relative;
    }
</style>


<!-- The Payment Form -->
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
<form id="iframes" action="" method="GET">
    <div class="form-group">
        <label for="iframesCardNumber">Card Number:</label>
        <div class="iframeholder" id="iframesCardNumber"></div>
    </div>
    <div class="form-group">
        <label for="iframesCardExpiration">Card Expiration:</label>
        <div class="iframeholder" id="iframesCardExpiration"></div>
    </div>
    <div class="form-group">
        <label for="iframesCardCvv">Card CVV:</label>
        <div class="iframeholder" id="iframesCardCvv"></div>
    </div>


</form>

<div class="buttons">
    <div class="pull-right">
        <input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="btn btn-primary" />
    </div>
</div>

<!-- The SecureSubmit Javascript Library -->
<script type="text/javascript" src="https://api2.heartlandportico.com/SecureSubmit.v1/token/2.1/securesubmit.js"></script>
<!-- The Integration Code -->
<script type="text/javascript">
    var secureSubmitKey = '<?php echo $publicKey ?>';

    //call method untill Heartland loaded
    var interval = setInterval(loadIframeTokenization, 100);
    var attempts = 0;

    //method to load iframe
    function loadIframeTokenization() {
        'use strict';
        //check whether Heartland is loaded
        if (typeof Heartland == 'object') {
            clearInterval(interval);
        } else {
            attempts ++;
            if(attempts > 20){
                alert('Problem loading payment Method! Try again later.');
                clearInterval(interval);
            }
            return;
        }
        // Create a new `HPS` object with the necessary configuration
        var hps = new Heartland.HPS({
            publicKey: secureSubmitKey,
            type: 'iframe',
            // Configure the iframe fields to tell the library where
            // the iframe should be inserted into the DOM and some
            // basic options
            fields: {
                cardNumber: {
                    target: 'iframesCardNumber',
                    placeholder: '•••• •••• •••• ••••'
                },
                cardExpiration: {
                    target: 'iframesCardExpiration',
                    placeholder: 'MM / YYYY'
                },
                cardCvv: {
                    target: 'iframesCardCvv',
                    placeholder: 'CVV'
                }
            },
            // Collection of CSS to inject into the iframes.
            // These properties can match the site's styles
            // to create a seamless experience.
            style: {
                'input[type=text],input[type=tel]': {
                    'box-sizing': 'border-box',
                    'display': 'block',
                    'width': '100%',
                    'height': '45px',
                    'padding': '6px 12px',
                    'font-size': '14px',
                    'line-height': '1.42857143',
                    'color': '#555',
                    'background-color': '#fff',
                    'background-image': 'none',
                    'border': '1px solid #ccc',
                    'border-radius': '0px',
                    '-webkit-box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075)',
                    'box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075)',
                    '-webkit-transition': 'border-color ease-in-out .15s,-webkit-box-shadow ease-in-out .15s',
                    '-o-transition': 'border-color ease-in-out .15s,box-shadow ease-in-out .15s',
                    'transition': 'border-color ease-in-out .15s,box-shadow ease-in-out .15s'
                },
                'input[type=text]:focus,input[type=tel]:focus': {
                    'border-color': '#66afe9',
                    'outline': '0',
                    '-webkit-box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6)',
                    'box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6)'
                },
                'input[type=submit]': {
                    'box-sizing': 'border-box',
                    'display': 'inline-block',
                    'padding': '6px 12px',
                    'margin-bottom': '0',
                    'font-size': '14px',
                    'font-weight': '400',
                    'line-height': '1.42857143',
                    'text-align': 'center',
                    'white-space': 'nowrap',
                    'vertical-align': 'middle',
                    '-ms-touch-action': 'manipulation',
                    'touch-action': 'manipulation',
                    'cursor': 'pointer',
                    '-webkit-user-select': 'none',
                    '-moz-user-select': 'none',
                    '-ms-user-select': 'none',
                    'user-select': 'none',
                    'background-image': 'none',
                    'border': '1px solid transparent',
                    'border-radius': '4px',
                    'color': '#fff',
                    'background-color': '#337ab7',
                    'border-color': '#2e6da4'
                },
                'input[type=submit]:hover': {
                    'color': '#fff',
                    'background-color': '#286090',
                    'border-color': '#204d74'
                },
                'input[type=submit]:focus, input[type=submit].focus': {
                    'color': '#fff',
                    'background-color': '#286090',
                    'border-color': '#122b40',
                    'text-decoration': 'none',
                    'outline': '5px auto -webkit-focus-ring-color',
                    'outline-offset': '-2px'
                },
                'input[name=cardNumber]': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-inputcard-blank@2x.png")',
                  'background-position':'right',
                  'background-size':'56px 33px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat'
                },
                'input[name=cardCvv]': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/cvv1.png")',
                  'background-position':'right',
                  'background-size':'56px 33px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat'
                },
                '.invalid.card-type-visa': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'86px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-47px'
                },
                '.valid.card-type-visa': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-1px'
                },
                '.invalid.card-type-discover': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-422px'
                },
                '.valid.card-type-discover': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-372px'
                },
                '.invalid.card-type-jcb': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-325px'
                },
                '.valid.card-type-jcb': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-281px'
                },
                '.invalid.card-type-amex': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-237px'
                },
                '.valid.card-type-amex': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-189px'
                },
                '.invalid.card-type-mastercard': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-142px'
                },
                '.valid.card-type-mastercard': {
                  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
                  'background-position':'right',
                  'background-size':'85px 463px',
                  'display':'-webkit-inline-box',
                  'background-repeat':'no-repeat',
                  'background-position-y':'-98px'
                },
            },
            // Callback when a token is received from the service
            onTokenSuccess: secureSubmitResponseHandler,
            // Callback when an error is received from the service
            onTokenError: secureSubmitResponseHandler
        });

        // Attach a handler to interrupt the form submission
        $("#button-confirm").click(function (e) {
            // Prevent the form from continuing to the `action` address
            e.preventDefault();
            $(this).button('loading');
            // Tell the iframes to tokenize the data
            hps.Messages.post(
                    {
                        accumulateData: true,
                        action: 'tokenize',
                        message: secureSubmitKey
                    },
                    'cardNumber'
                    );
        });

        function secureSubmitResponseHandler(response) {
            var bodyTag = $('body').first();
            if (response.error !== undefined && response.error.message !== undefined) {
                alert(response.error.message);
                $('#button-confirm').button('reset');
                return false;
            } else {
                bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.token_value + "'/>");
                form_submit(response);
            }
        }

        function form_submit(response) {
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
                    $('#button-confirm').button('loading');
                },
                complete: function () {
                    $('#button-confirm').button('reset');
                },
                success: function (json) {
                    if (json['error']) {
                        alert(json['error']);
                    }
                    if (json['redirect']) {
                        window.location = json['redirect'];
                    }
                }
            });
        }

    }
    ;
</script>
