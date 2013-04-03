#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
use Test::Deep;

use Data::Dumper;
use Amazon::SQS::ProducerConsumer::Base;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY}) {
        plan tests => 7;
} else {
        plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::ProducerConsumer::Base' );
my $sqs = new Amazon::SQS::ProducerConsumer::Base (
        AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
        SecretAccessKey => $ENV{AWS_SECRET_KEY},
);

ok (defined ($sqs), "Amazon::SQS::ProducerConsumer::Base");


SKIP: {
  my @queue_items = $sqs->list_queues();
  skip ("due to lack of pre-existing sqs queues",5) if !@queue_items;

  ok ( @queue_items > 0, "pre-existing queues");
  my $queue_name = $queue_items[0];   # arbitarrily choose one queue
  my $queueURL = $sqs->get_queue_url ("QueueName" => $queue_name);
  ok (defined ($queueURL), "get_queue_url()");
  my $queue_attributes = $sqs->get_all_queue_attributes(Queue => $queueURL);
  ok (defined ($queue_attributes),
     "get_all_queue_attributes (Queue => $queueURL)");
  ok (defined ($queue_attributes->{CreatedTimestamp}), "CreatedTimestamp");
  ok (defined ($queue_attributes->{MaximumMessageSize}), "MaximumMessageSize");
}
