#!/usr/bin/perl -s

use warnings;
use strict;

use Test::More;
use Test::Warn;
use Data::Dumper;

if ( $ENV{AWS_PUBLIC_KEY} && $ENV{AWS_SECRET_KEY} ) {
        plan tests => 5;
} else {
        plan skip_all => 'AWS_PUBLIC_KEY and AWS_SECRET_KEY environment variables not set, skipping all tests.';
}

use_ok( 'Amazon::SQS::Producer' );
use_ok( 'Amazon::SQS::Consumer' );

my $sqs = new Amazon::SQS::ProducerConsumer::Base (
        AWSAccessKeyId => 'foobar',
        SecretAccessKey => 'foobar',
);

my $message;
warning_like
  { $message = $sqs->create_queue() }
  qr/^HTTP POST failed with error 403 Forbidden at /,
  "check_error emits warning";
is ($message, undef, "create_queue() returns undef on error");
is ($sqs->{error}, 'HTTP POST failed with error 403 Forbidden',
  '$sqs->{error} is filled with error');
