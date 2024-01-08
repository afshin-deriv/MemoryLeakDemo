#!/usr/bin/env perl
use strict;
use warnings;

use Net::Async::Redis;
use IO::Async::Loop;
use Future::AsyncAwait;
use Future::Utils qw(fmap_concat);

my $loop = IO::Async::Loop->new;

$loop->add(
    my $redis = Net::Async::Redis->new(
        host => 'localhost',
        port => 6379)
);

async sub test_multi {
    my $key = shift;

    return await $redis->multi(sub {
        my $tx = shift;
        $tx->incr("test::$key")->on_done(sub {
            print "Incr - @_\n";
        });
        $tx->set("test::$key" => "key value")->on_done(sub {
            print "Set - @_\n";
        });
        $tx->del("test::$key")->on_done(sub {
            print "Del - @_\n";
        });
    });
}


my @keys = ("key1", "key2", "key3", "key4");

print "Before calling 'fmap_concat'\n";
my @results = await fmap_concat {
        test_multi($_);
    }
    concurrent => 4,
    foreach => \@keys;

print "After calling 'fmap_concat'\n"; ## It never happens inside Docker container!!!


$loop->run;
