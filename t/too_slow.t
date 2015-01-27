use strict;
use warnings;

use Test::More;

use Plack::Middleware::Antibot::TooSlow;

subtest 'returns true when GET' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'GET',
        'psgix.session'         => {},
        'psgix.session.options' => {}
    };
    ok $filter->check($env);
};

subtest 'sets session time when GET' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'GET',
        'psgix.session'         => {},
        'psgix.session.options' => {}
    };

    $filter->check($env);

    ok $env->{'psgix.session'}->{antibot_tooslow};
};

subtest 'returns false when no session when POST' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'POST',
        'psgix.session'         => {},
        'psgix.session.options' => {}
    };

    ok !$filter->check($env);
};

subtest 'returns false when too slow when POST' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'POST',
        'psgix.session'         => {antibot_tooslow => 123},
        'psgix.session.options' => {}
    };

    ok !$filter->check($env);
};

subtest 'returns true when not slow when POST' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'POST',
        'psgix.session'         => {antibot_tooslow => time},
        'psgix.session.options' => {}
    };

    ok $filter->check($env);
};

sub _build_filter {
    Plack::Middleware::Antibot::TooSlow->new(@_);
}

done_testing;
