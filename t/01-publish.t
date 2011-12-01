#!/usr/bin/perl
use strict;

use Test::More tests => 2;

BEGIN {
	use_ok( 'Amazon::SQS::Producer', 'use Amazon::SQS::Producer' );
}

if ( ! $ENV{AWS_PUBLIC_KEY} ) { diag( 'Did you set the env var AWS_PUBLIC_KEY?' ) && die }
if ( ! $ENV{AWS_SECRET_KEY} ) { diag( 'Did you set the env var AWS_SECRET_KEY?' ) && die }

my $out_queue = new Amazon::SQS::Producer
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue';

if ( ! $out_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

ok( $out_queue->publish( { test => 'item' } ) );