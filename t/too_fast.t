use strict;
use warnings;

use Test::More;

use Plack::Middleware::Antibot::TooFast;

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

    ok $env->{'psgix.session'}->{antibot_toofast};
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

subtest 'returns false when too fast when POST' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'POST',
        'psgix.session'         => {antibot_toofast => time},
        'psgix.session.options' => {}
    };

    ok !$filter->check($env);
};

subtest 'returns true when slow when POST' => sub {
    my $filter = _build_filter();

    my $env = {
        REQUEST_METHOD          => 'POST',
        'psgix.session'         => {antibot_toofast => 123},
        'psgix.session.options' => {}
    };

    ok $filter->check($env);
};

sub _build_filter {
    Plack::Middleware::Antibot::TooFast->new(@_);
}

done_testing;
