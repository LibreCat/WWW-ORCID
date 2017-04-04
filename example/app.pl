#!/usr/bin/perl

use strict;
use warnings;
use WWW::ORCID;
use WWW::ORCID::API::v2_0 ();
use Dancer;

my $get_methods = [map { s/get_//; $_ } values %WWW::ORCID::API::v2_0::GET];
my $get_put_code_methods = [map { s/get_//; $_ } values %WWW::ORCID::API::v2_0::GET_PUT_CODE];
my $add_methods = [map { s/add_//; $_ } values %WWW::ORCID::API::v2_0::ADD];
my $client;
my $read_public_token;

sub client {
    $client ||= WWW::ORCID->new(
        version => '2.0',
        sandbox => 1,
        client_id => $ENV{ORCID_CLIENT_ID},
        client_secret => $ENV{ORCID_CLIENT_SECRET},
    );
}

sub read_public_token {
    $read_public_token ||= client->access_token(grant_type => 'client_credentials', scope => '/read-public');
}

sub tokens {
    session('tokens') || {};
}

sub add_token {
    my ($token) = @_;
    my $tokens = session('tokens') || {};
    $tokens->{$token->{orcid}} = $token;
    session(tokens => $tokens);
    $tokens;
}

hook 'before' => sub {
    if (defined(my $orcid = param('orcid'))) {
        tokens->{$orcid} || return redirect('/authorize');
    }
};

get '/tokens' => sub {
    to_json(tokens);
};

get '/authorize' => sub {
    my $params = params;
    redirect client->authorize_url(
        %$params,
        show_login => 'true',
        scope => '/person/update /activities/update',
        response_type => 'code',
        redirect_uri => 'https://developers.google.com/oauthplayground',
    );
};

get '/authorized' => sub {
    my $code = param('code');
    my $token = client->access_token(
        grant_type => 'authorization_code',
        code => $code,
    );
    add_token($token);
    to_json($token);
};

get '/search' => sub {
    my $params = params;
    my $token = read_public_token;
    to_json($token) . to_json(client->search($token, $params));
};

get '/:orcid/add' => sub {
    content_type 'text/html';
    template 'add', {methods => $add_methods};
};

post '/:orcid/add' => sub {
    my $orcid  = param('orcid');
    my $method = param('method');
    $method = "add_$method";
    my $request_body = from_json(param('request_body'));
    my $response_body = client->$method(tokens->{$orcid}, $orcid, $request_body);
    content_type 'text/html';
    template 'add', {methods => $add_methods, response_body => to_json($response_body)};
};

for my $path (@$get_methods) {
    my $method = "get_$path";
    get "/:orcid/$path" => sub {
        my $orcid = param('orcid');
        to_json(client->$method(tokens->{$orcid}, $orcid));
    };
}

for my $path (@$get_put_code_methods) {
    my $method = "get_$path";
    get "/:orcid/$path/:put_code" => sub {
        my $orcid = param('orcid');
        my $put_code = param('put_code');
        to_json(client->$method(tokens->{$orcid}, $orcid, $put_code));
    };
}

for my $path (@$add_methods) {
    my $method = "add_$path";
    post "/:orcid/$path" => sub {
        my $orcid = param('orcid');
        my $request_body = from_json(param('request_body'));
        to_json(client->$method(tokens->{$orcid}, $orcid, $request_body));
    };
}

dance;
