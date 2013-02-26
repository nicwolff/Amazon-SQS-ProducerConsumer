#!/usr/bin/perl -s

use warnings;
use strict;

use Test::More tests => 5;
use Test::Warn;
use Data::Dumper;


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
