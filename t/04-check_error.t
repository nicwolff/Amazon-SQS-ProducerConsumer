#!/usr/bin/perl -s

use warnings;
use strict;

use Test::More tests => 4;
use Test::Warn;

use_ok( 'Amazon::SQS::ProducerConsumer::Base' );

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
