#!/usr/bin/perl -s
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
	plan tests => 3;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::Consumer' );

my $in_queue = Amazon::SQS::Consumer->new(
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue',
	wait_seconds => 120
);

if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

ok( $in_queue->next, 'get message' );

ok( $in_queue->delete_previous, 'delete message' );