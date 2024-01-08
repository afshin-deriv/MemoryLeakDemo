#!/usr/bin/env perl
use strict;
use warnings;

use feature qw(say);
use Net::Async::Redis;
use IO::Async::Loop;
use Future::AsyncAwait;
use Future::Utils qw(fmap_concat);

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

my $simple_array = {};
for my $i (1..500) {
    my $key = "key$i";
    $simple_array->{$key} = $i;
}


my @result = await fmap_concat {
        test_multi($_);
    }
    concurrent  => 4,
    foreach => [keys %{$simple_array}];

say $_ // '<undef>' for @result;
