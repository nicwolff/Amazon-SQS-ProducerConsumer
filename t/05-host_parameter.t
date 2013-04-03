#!/usr/bin/perl -s

use warnings;
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
        plan tests => 7;
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

my $queue_name = 'TestQueueForHostParameterTestScript';

my $queueURL = $sqs->create_queue( QueueName => $queue_name );
like ($queueURL, qr{^http://$host}p, "$host included in created queue's url");
like ($queueURL, qr{$queue_name$}p, "$queue_name included in create queue's url");
is ($queueURL, $sqs->get_queue_url( QueueName => $queue_name ),
  "get_queue_url() fetches same $queue_name");

diag "wait 60 seconds. create_queue may be slow\n";
sleep (60);
my @queue_items = $sqs->list_queues();
ok ( (grep {$_ eq $queue_name} @queue_items) > 0, "queue $queue_name is present on $host")
  or diag "current queues: " . (join ', ', @queue_items);

$sqs->delete_queue (Queue => $queueURL);
diag "wait 60 seconds. delete_queue will take up to 60 seconds to delete queue\n";
sleep (60); 

@queue_items = $sqs->list_queues();
ok ((grep {$_ eq $queue_name} @queue_items) == 0,
    "queue $queue_name should be absent on $host");

my $post_delete_url = $sqs->get_queue_url( QueueName => $queue_name );
ok (!defined($post_delete_url), "get_queue_url() gets undef after queue deleted");
