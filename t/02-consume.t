#!/usr/bin/perl -s
use strict;

use Test::More;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
	plan tests => 1;
} else {
	plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::Consumer' );

diag ("This test script's functionality has been folded into 01-publish.t");