<?php echo $header; ?><?php echo $column_left; ?>
<div id="content">
    <div class="page-header">
        <div class="container-fluid">
            <div class="pull-right">
                <button type="submit" form="secure-submit-form" data-toggle="tooltip" title="<?php echo $button_save; ?>" class="btn btn-primary"><i class="fa fa-save"></i></button>
                <!-- <div class="buttons"><a onclick="$('#form').submit();" class="button"><?php echo $button_save; ?></a></div> -->
                <a href="<?php echo $cancel; ?>" data-toggle="tooltip" title="<?php echo $button_cancel; ?>" class="btn btn-default"><i class="fa fa-reply"></i></a>
            </div>
            <h1><!-- <img src="view/image/payment.png" alt="" /> --><?php echo $heading_title; ?></h1>
            <ul class="breadcrumb">
                <?php foreach ($breadcrumbs as $breadcrumb) { ?>
                <li><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a></li>
                <?php } ?>
            </ul>
        </div>
    </div>
    <div class="container-fluid">
        <?php if ($error_warning) { ?>
        <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo $error_warning; ?>
            <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
        <?php } ?>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h3 class="panel-title"><i class="fa fa-pencil"></i> <?php echo $text_edit; ?></h3>
        </div>
        <div class="panel-body">
            <form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="secure-submit-form" class="form-horizontal">
                <input type="hidden" name="securesubmit_module[1][position]" value="content_top" />
                <input type="hidden" name="securesubmit_module[1][layout_id]" value="7" />
                <input type="hidden" name="securesubmit_module[1][status]" value="1" />
                <input type="hidden" name="securesubmit_module[1][sort_order]" value="0" />

                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="input-test-public-key"><?php echo $entry_test_public_key; ?></label>
                    <div class="col-sm-10">
                        <input type="text" name="securesubmit_test_public_key" value="<?php echo $securesubmit_test_public_key; ?>" placeholder="<?php echo $entry_test_public_key; ?>" id="input-test-public-key" class="form-control"/>
                        <?php if ($error_test_public_key) { ?>
                        <span class="error"><?php echo $error_test_public_key; ?></span>
                        <?php } ?>
                    </div>
                </div>
                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="input-test-private-key"><?php echo $entry_test_private_key; ?></label>
                    <div class="col-sm-10">
                        <input type="text" name="securesubmit_test_private_key" value="<?php echo $securesubmit_test_private_key; ?>" placeholder="<?php echo $entry_test_private_key; ?>" id="input-test-private-key" class="form-control"/>
                        <?php if ($error_test_private_key) { ?>
                        <span class="error"><?php echo $error_test_private_key; ?></span>
                        <?php } ?>
                    </div>
                </div>
                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="input-live-public-key"><?php echo $entry_live_public_key; ?></label>
                    <div class="col-sm-10">
                        <input type="text" name="securesubmit_live_public_key" value="<?php echo $securesubmit_live_public_key; ?>" placeholder="<?php echo $entry_live_public_key; ?>" id="input-live-public-key" class="form-control"/>
                        <?php if ($error_live_public_key) { ?>
                        <span class="error"><?php echo $error_live_public_key; ?></span>
                        <?php } ?>
                    </div>
                </div>
                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="input-live-private-key"><?php echo $entry_live_private_key; ?></label>
                    <div class="col-sm-10">
                        <input type="text" name="securesubmit_live_private_key" value="<?php echo $securesubmit_live_private_key; ?>" placeholder="<?php echo $entry_live_private_key; ?>" id="input-live-private-key" class="form-control"/>
                        <?php if ($error_live_private_key) { ?>
                        <span class="error"><?php echo $error_live_private_key; ?></span>
                        <?php } ?>
                    </div>
                </div>
                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_mode; ?></label>
                    <div class="col-sm-10">
                        <select name="securesubmit_mode" id="input-mode" class="form-control">
                            <?php if ($securesubmit_mode == 'test') { ?>
                            <option value="test" selected="selected"><?php echo $text_test; ?></option>
                            <?php } else { ?>
                            <option value="test"><?php echo $text_test; ?></option>
                            <?php } ?>
                            <?php if ($securesubmit_mode == 'live') { ?>
                            <option value="live" selected="selected"><?php echo $text_live; ?></option>
                            <?php } else { ?>
                            <option value="live"><?php echo $text_live; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>
                <div class="form-group required">
                    <label class="col-sm-2 control-label" for="auth"><?php echo $entry_method; ?></label>
                    <div class="col-sm-10">
                        <select name="securesubmit_method" id="auth" class="form-control">
                            <?php if ($securesubmit_method == 'authorization') { ?>
                            <option value="authorization" selected="selected"><?php echo $text_authorization; ?></option>
                            <?php } else { ?>
                            <option value="authorization"><?php echo $text_authorization; ?></option>
                            <?php } ?>
                            <?php if ($securesubmit_method == 'capture') { ?>
                            <option value="capture" selected="selected"><?php echo $text_capture; ?></option>
                            <?php } else { ?>
                            <option value="capture"><?php echo $text_capture; ?></option>
                            <?php } ?>
                        </select>
                    </div>
                </div>
                <fieldset>
                    <legend><?php echo $text_checkout_settings; ?></legend>
                    <div class="form-group">
                        <label class="col-sm-12 control-label" style="text-align: left"><?php echo $text_total_helper; ?></label>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label" for="entry-total"><?php echo $entry_total; ?></label>
                        <div class="col-sm-10">
                            <input type="text" name="securesubmit_total" value="<?php echo $securesubmit_total; ?>" placeholder="<?php echo $entry_total; ?>" id="entry-total" class="form-control"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label" for="order-status"><?php echo $entry_order_status; ?></label>
                        <div class="col-sm-10">
                            <select name="securesubmit_order_status_id" id="order-status" class="form-control">
                                <?php foreach ($order_statuses as $order_status) { ?>
                                <?php if ($order_status['order_status_id'] == $securesubmit_order_status_id) { ?>
                                <option value="<?php echo $order_status['order_status_id']; ?>" selected="selected"><?php echo $order_status['name']; ?></option>
                                <?php } else { ?>
                                <option value="<?php echo $order_status['order_status_id']; ?>"><?php echo $order_status['name']; ?></option>
                                <?php } ?>
                                <?php } ?>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                      <label class="col-sm-2 control-label" for="geo-zone"><?php echo $entry_geo_zone; ?></label>
                      <div class="col-sm-10">
                        <select name="securesubmit_geo_zone_id" id="geo-zone" class="form-control">
                        <option value="0"><?php echo $text_all_zones; ?></option>
                        <?php foreach ($geo_zones as $geo_zone) { ?>
                        <?php if ($geo_zone['geo_zone_id'] == $securesubmit_geo_zone_id) { ?>
                        <option value="<?php echo $geo_zone['geo_zone_id']; ?>" selected="selected"><?php echo $geo_zone['name']; ?></option>
                        <?php } else { ?>
                        <option value="<?php echo $geo_zone['geo_zone_id']; ?>"><?php echo $geo_zone['name']; ?></option>
                        <?php } ?>
                        <?php } ?>
                    </select>
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-sm-2 control-label" for="status"><?php echo $entry_status; ?></label>
                      <div class="col-sm-10">
                        <select name="securesubmit_status" id="status" class="form-control">
                        <?php if ($securesubmit_status) { ?>
                        <option value="1" selected="selected"><?php echo $text_enabled; ?></option>
                        <option value="0"><?php echo $text_disabled; ?></option>
                        <?php } else { ?>
                        <option value="1"><?php echo $text_enabled; ?></option>
                        <option value="0" selected="selected"><?php echo $text_disabled; ?></option>
                        <?php } ?>
                    </select>
                      </div>
                    </div>
                    <div class="form-group">
                      <label class="col-sm-2 control-label" for="sort-order"><?php echo $entry_sort_order; ?></label>
                      <div class="col-sm-10">
                        <input type="text" name="securesubmit_sort_order" value="<?php echo $securesubmit_sort_order; ?>" placeholder="<?php echo $entry_sort_order; ?>" id="sort-order" class="form-control" />
                      </div>
                    </div>
                </fieldset>

            </form>
        </div>
    </div>
</div>
<?php echo $footer; ?>
