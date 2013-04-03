#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
use Test::Deep;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY}) {
	plan tests => 13;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}


use_ok( 'Amazon::SQS::ProducerConsumer::Base' );
use_ok( 'Amazon::SQS::Producer' );
use_ok( 'Amazon::SQS::Consumer' );

sub test_producer_consumer {
  my $sqs = new Amazon::SQS::ProducerConsumer::Base (
        AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
        SecretAccessKey => $ENV{AWS_SECRET_KEY},
        @_,
  );

  my $queue_name = 'TestQueueForPublishTestScript';
  my $queueURL = $sqs->create_queue( QueueName => $queue_name );
  ok ($queueURL, "Create $queue_name");

  my $out_queue = new Amazon::SQS::Producer(
          AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
          SecretAccessKey => $ENV{AWS_SECRET_KEY},
          queue => $queueURL,
  );

  if ( ! $out_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

  ok( $out_queue->publish( { test => 'item' } ), "send data" );



  my $in_queue = Amazon::SQS::Consumer->new(
          AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
          SecretAccessKey => $ENV{AWS_SECRET_KEY},
          queue => $queueURL,
          wait_seconds => 120,
  );

  if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }


  my $received = $in_queue->next;
  cmp_deeply ($received, {test => 'item'}, "received data");

  ok( $in_queue->delete_previous, 'delete message' );

  $sqs->delete_queue (Queue => $queueURL);
  diag "wait 60 seconds. delete_queue will take up to 60 seconds to delete queue\n";
  sleep (60);

  my @queue_items = $sqs->list_queues();
  ok ((grep {$_ eq $queue_name} @queue_items) == 0,
      "Delete queue $queue_name; cleaning up.");
}

test_producer_consumer();
test_producer_consumer(host => 'sqs.us-east-1.amazonaws.com');