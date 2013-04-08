#!/usr/bin/perl -s
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
	plan tests => 11;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::ProducerConsumer::Base' );
my $sqs = new Amazon::SQS::ProducerConsumer::Base (
        AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
        SecretAccessKey => $ENV{AWS_SECRET_KEY},
);

my $queue_name = 'TestQueueForCycleTestScript';
my $queueURL = $sqs->create_queue( QueueName => $queue_name );
ok ($queueURL, "Queue URL created or already existing.");



use_ok( 'Amazon::SQS::Producer' );
use_ok( 'Amazon::SQS::Consumer' );



my $in_queue = new Amazon::SQS::Consumer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => $queueURL,
	wait_seconds => 120;

if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

my $out_queue = new Amazon::SQS::Producer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => $queueURL;

my $n = 0;

$out_queue->publish( { test => 'this is a test' } );


ITEM: while ( my $item = $in_queue->next ) {

        ok( $item, "received item $n" ) || warn 'Out of messages' && last;

	$out_queue->publish( $item );
	last if ++$n == 5;
	sleep 1;

}

is( $n, 5, 'publish and consume 5 items');


$sqs->delete_queue (Queue => $queueURL);
diag "wait 60 seconds. delete_queue will take up to 60 seconds to delete queue\n";
sleep (60);
diag "wait 30 more seconds. paranoid of race conditions\n";
sleep (30);

my @queue_items = $sqs->list_queues();
ok ((grep {$_ eq $queue_name} @queue_items) == 0,
    "Delete queue $queue_name as last step in test script");
