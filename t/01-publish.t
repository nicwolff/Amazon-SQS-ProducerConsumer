#!/usr/bin/perl
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
	plan tests => 2;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::Producer' );

my $out_queue = new Amazon::SQS::Producer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue';

if ( ! $out_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

ok( $out_queue->publish( { test => 'item' } ) );