<?php

class HpsTokenData
{
    public $tokenValue      = null;
    public $expMonth        = null;
    public $expYear         = null;
    public $cvv             = null;
    public $responseCode    = null;
    public $responseMessage = null;

    public function __construct($responseMessage = null)
    {
        $this->responseMessage = $responseMessage;
    }
}
