#!/usr/bin/perl

use strict;
use warnings;
use WWW::ORCID;
use Dancer;

my $client;
my $read_public_token;
my $tokens = {};

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

get '/tokens' => sub {
    to_json($tokens);
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
    $tokens->{$token->{orcid}} = $token->{access_token};
    to_json($token);
};

get '/search' => sub {
    my $params = params;
    my $token = read_public_token;
    to_json($token) . to_json(client->search($token, $params));
};

use WWW::ORCID::API::v2_0 ();
for my $method (values %WWW::ORCID::API::v2_0::GET_RECORD_PARTS) {
    my $path = $method;
    $path =~ s/^get_//;
    get "/:orcid/$path" => sub {
        my $orcid = param('orcid');
        my $token = $tokens->{$orcid} || return redirect('/authorize');
        to_json(client->$method($token, $orcid));
    };
}

dance;
