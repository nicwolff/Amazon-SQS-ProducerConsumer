#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
use Test::Warn;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY}) {
        plan tests => 7;
} else {
        plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::ProducerConsumer::Base' );
use_ok( 'Amazon::SQS::Producer' );

my $sqs = new Amazon::SQS::ProducerConsumer::Base (
  AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
  SecretAccessKey => $ENV{AWS_SECRET_KEY},
);

my $queue_name = 'TestQueueForDeprecatedFeature';
my $queueURL = $sqs->create_queue( QueueName => $queue_name );
ok ($queueURL, "Create $queue_name");

# normal case
my $out_queue = new Amazon::SQS::Producer(
  AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
  SecretAccessKey => $ENV{AWS_SECRET_KEY},
  queue => $queueURL,
);

# deprecated case
my $out_queue2;
warning_like
  {
    $out_queue2 = new Amazon::SQS::Producer(
      AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
      SecretAccessKey => $ENV{AWS_SECRET_KEY},
      queue => $queue_name,
    )
  }
  [ qr/^Use of queue name for queue parameter is now deprecated./ ],
  "emit deprecation warning for using queue name as queue parameter";

is ($out_queue->{host}, $out_queue2->{host}, "consistent host");
is ($out_queue->{queue}, $out_queue2->{queue}, "consistent queue url");


$sqs->delete_queue (Queue => $queueURL);
diag "wait 60 seconds. delete_queue will take up to 60 seconds to delete queue\n";
sleep (60);
diag "wait 30 more seconds. paranoid of race conditions\n";
sleep (30);

my @queue_items = $sqs->list_queues();
ok ((grep {$_ eq $queue_name} @queue_items) == 0,
    "Delete queue $queue_name; cleaning up.");
