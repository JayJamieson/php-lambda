<?php

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

use Bref\Context\Context;
use Bref\Event\S3\S3Event;
use Bref\Event\S3\S3Handler;
use Psr\Log\LoggerInterface;
use Psr\Log\LogLevel;

class Handler extends S3Handler
{
    public LoggerInterface $log;

    public function __construct()
    {
        $this->log = new \Bref\Logger\StderrLogger(LogLevel::INFO);
    }

    public function handleS3(S3Event $event, Context $context): void
    {
        $bucketName = $event->getRecords()[0]->getBucket()->getName();
        $fileName = $event->getRecords()[0]->getObject()->getKey();
        $this->log->info($bucketName);
        $this->log->warning($fileName);
    }
}

return new Handler();
