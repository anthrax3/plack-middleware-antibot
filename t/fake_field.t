use strict;
use warnings;

use Test::More;

use HTTP::Request::Common;
use HTTP::Message::PSGI qw(req_to_psgi);
use Plack::Middleware::Antibot::FakeField;

subtest 'returns true when not POST' => sub {
    my $filter = _build_filter();

    my $env = req_to_psgi GET '/';
    ok $filter->check($env);
};

subtest 'returns true when field not present' => sub {
    my $filter = _build_filter();

    my $env = req_to_psgi POST '/', {foo => 'bar'};
    ok $filter->check($env);
};

subtest 'returns false when field present' => sub {
    my $filter = _build_filter();

    my $env = req_to_psgi POST '/', {antibot_fake_field => 'bar'};
    ok !$filter->check($env);
};

sub _build_filter {
    Plack::Middleware::Antibot::FakeField->new(@_);
}

done_testing;
