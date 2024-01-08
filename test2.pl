#!/usr/bin/env perl
use strict;
use warnings;

use Net::Async::Redis;
use IO::Async::Loop;
use Future::AsyncAwait;
use Future::Utils qw(fmap_concat);
use Time::HiRes qw(gettimeofday tv_interval);

my $loop = IO::Async::Loop->new;

$loop->add(
    my $redis = Net::Async::Redis->new(
        host => 'redis',
        port => 6379)
);

async sub test_multi {
    my $key = shift;

    return await $redis->multi(sub {
        my $tx = shift;
        $tx->set("test::$key" => "key value")->on_done(sub {
            # print "Set $key - @_\n";
        });
        $tx->publish("test::$key", $key)->on_done(sub {
            # print "Pub $key - @_\n";
        });
    });
}

STDOUT->autoflush(1);
my $simple_hash = {};
for my $i (1..500) {
    my $key = "key$i";
    $simple_hash->{$key} = $i;
}

my @keys = keys %$simple_hash;

print "Before calling 'fmap_concat'\n";
my $start_time = [gettimeofday];
my @results = await fmap_concat {
        test_multi($_);
    }
    concurrent => 10,
    foreach => \@keys;
my $end_time = [gettimeofday];

my $elapsed = tv_interval($start_time, $end_time);
print "Time taken for computation: $elapsed seconds\n";

print "After calling 'fmap_concat'\n";

$loop->run;
