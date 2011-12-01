#!/usr/bin/perl -s
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
	plan tests => 8;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::Producer' );
use_ok( 'Amazon::SQS::Consumer' );

my $in_queue = new Amazon::SQS::Consumer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue',
	wait_seconds => 120;

if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

my $out_queue = new Amazon::SQS::Producer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue';

my $n;

ITEM: while ( my $item = $in_queue->next ) {

	ok( $item ) || warn 'Out of messages' && last;

	$out_queue->publish( $item );
	last if ++$n == 5;
	sleep 1;

}

is( $n, 5, 'publish and consume 5 items');

done_testing();