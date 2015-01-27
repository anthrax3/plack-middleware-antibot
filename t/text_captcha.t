use strict;
use warnings;

use Test::More;

use HTTP::Request::Common;
use HTTP::Message::PSGI qw(req_to_psgi);
use Plack::Middleware::Antibot::TextCaptcha;

subtest 'returns true when GET' => sub {
    my $filter = _build_filter();

    my $env = _build_env(GET '/');

    ok $filter->check($env);
};

subtest 'sets session when GET' => sub {
    my $filter = _build_filter();

    my $env = _build_env(GET '/');

    $filter->check($env);

    is $env->{'psgix.session'}->{antibot_textcaptcha}, 4;
};

subtest 'sets env when GET' => sub {
    my $filter = _build_filter();

    my $env = _build_env(GET '/');

    $filter->check($env);

    is $env->{'antibot.text_captcha'}, '2 + 2';
};

subtest 'returns false when no session when POST' => sub {
    my $filter = _build_filter();

    my $env = _build_env(POST '/');

    ok !$filter->check($env);
};

subtest 'returns false when no field when POST' => sub {
    my $filter = _build_filter();

    my $env = _build_env(POST '/', {});

    ok !$filter->check($env);
};

subtest 'returns false when wrong answer when POST' => sub {
    my $filter = _build_filter();

    my $env = _build_env(POST '/', {antibot_textcaptcha => 'abc'});

    ok !$filter->check($env);
};

subtest 'returns true when POST' => sub {
    my $filter = _build_filter();

    my $env = _build_env(
        POST('/', {antibot_textcaptcha => '123'}),
        'psgix.session' => {antibot_textcaptcha => '123'}
    );

    ok $filter->check($env);
};

sub _build_env {
    my $env = req_to_psgi @_;

    $env->{'psgix.session'}         ||= {};
    $env->{'psgix.session.options'} ||= {};

    $env;
}

sub _build_filter {
    Plack::Middleware::Antibot::TextCaptcha->new(@_);
}

done_testing;
