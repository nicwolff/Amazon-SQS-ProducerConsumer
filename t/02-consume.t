#!/usr/bin/perl -s
use strict;

use Test::More tests => 3;

BEGIN {
	use_ok( 'Amazon::SQS::Consumer', 'use Amazon::SQS::Consumer' );
}

if ( ! $ENV{AWS_PUBLIC_KEY} ) { diag( 'Did you set the env var AWS_PUBLIC_KEY?' ) && die }
if ( ! $ENV{AWS_SECRET_KEY} ) { diag( 'Did you set the env var AWS_SECRET_KEY?' ) && die }

my $in_queue = Amazon::SQS::Consumer->new(
	AWSAccessKeyId => $ENV{AWS_PUBLIC_KEY},
	SecretAccessKey => $ENV{AWS_SECRET_KEY},
	queue => 'TestQueue',
	wait_seconds => 120
);

if ( ! $in_queue ) { diag( 'Did you create the SQS queue TestQueue?' ) && die }

ok( $in_queue->next, 'get message' );

ok( $in_queue->delete_previous, 'delete message' );