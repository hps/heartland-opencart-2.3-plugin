<?php

class HpsChargeService extends HpsCreditService {
    function __construct(HpsConfiguration $config=null){
        $flag = defined('E_USER_DEPRECATED') ? E_USER_DEPRECATED : E_USER_NOTICE;
        error_log('HpsChargeService is Deprecated and will soon be removed.', $flag);
        parent::__construct($config);
    }
} 