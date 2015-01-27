use strict;
use warnings;

use Test::More;

use HTTP::Request::Common;
use Plack::Builder;
use Plack::Test;

subtest 'init filters' => sub {
    my $app = sub { [200, [], ['Hello']] };

    $app = builder {
        enable 'Antibot', filters => ['FakeField'];
        $app
    };

    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(GET '/');
        is $res->content, 'Hello';

        $res = $cb->(POST '/', {antibot_fake_field => 'bar'});
        is $res->code, 400;
    };
};

subtest 'init filters with params' => sub {
    my $app = sub { [200, [], ['Hello']] };

    $app = builder {
        enable 'Antibot', filters => [['FakeField', field_name => 'foo']];
        $app
    };

    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(GET '/');
        is $res->content, 'Hello';

        $res = $cb->(POST '/', {foo => 'bar'});
        is $res->code, 400;
    };
};

subtest 'returns 200 and set env on fall through' => sub {
    my $app = sub { [200, [], [$_[0]->{'antibot.detected'}]] };

    $app = builder {
        enable 'Antibot',
          filters      => ['FakeField'],
          fall_through => 1;
        $app
    };

    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(POST '/', {antibot_fake_field => 'bar'});
        is $res->code, 200;
        is $res->content, 'FakeField';
    };
};

done_testing;
