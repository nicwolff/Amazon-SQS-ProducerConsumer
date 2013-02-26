#!/usr/bin/perl -s

use warnings;
use strict;

use Test::More;
use Data::Dumper;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
        plan tests => 2;
} else {
        plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::ProducerConsumer::Base' );

my $host = 'sqs.us-east-1.amazonaws.com';
if (!defined $ENV{AWS_SQS_ENDPOINT}) {
  diag "AWS_SQS_ENDPOINT not detected. Use default $host.";
}
else {
  $host = $ENV{AWS_SQS_ENDPOINT};
}

my $sqs = new Amazon::SQS::ProducerConsumer::Base (
        AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
        SecretAccessKey => $ENV{AWS_SECRET_KEY},
        host => $host,
);

my $queueURL = $sqs->create_queue( QueueName => 'TestQueue' );

my @queue_items = $sqs->list_queues();
ok (@queue_items > 0, "queue is present on $host");

