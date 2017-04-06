#!/usr/bin/perl

use strict;
use warnings;
use WWW::ORCID;
#use WWW::ORCID::API::v2_0 ();
use Dancer;

#my $get_methods = [map { s/get_//; $_ } values %WWW::ORCID::API::v2_0::GET];
#my $get_put_code_methods = [map { s/get_//; $_ } values %WWW::ORCID::API::v2_0::GET_PUT_CODE];
#my $add_methods = [map { s/add_//; $_ } values %WWW::ORCID::API::v2_0::ADD];
my $client = WWW::ORCID->new(
    version => '2.0',
    sandbox => 1,
    client_id => $ENV{ORCID_CLIENT_ID},
    client_secret => $ENV{ORCID_CLIENT_SECRET},
);

my $read_public_token;
my $read_limited_token;

sub read_public_token {
    $read_public_token ||= $client->access_token(grant_type => 'client_credentials', scope => '/read-public');
}

sub read_limited_token {
    $read_limited_token ||= $client->access_token(grant_type => 'client_credentials', scope => '/read-limited');
}

sub tokens {
    session('tokens') || {};
}

sub add_token {
    my ($token) = @_;
    my $tokens = tokens;
    $tokens->{$token->{orcid}} = $token;
    session(tokens => $tokens);
    $tokens;
}

hook 'before' => sub {
    if (defined(my $orcid = param('orcid'))) {
        tokens->{$orcid} || return redirect('/authorize');
    }
};

get '/read-public-token' => sub {
    content_type 'application/json';
    to_json(read_public_token);
};

get '/read-limited-token' => sub {
    content_type 'application/json';
    to_json(read_limited_token);
};

get '/tokens' => sub {
    content_type 'application/json';
    to_json(tokens);
};

get '/authorize' => sub {
    my $params = params;
    redirect $client->authorize_url(
        %$params,
        show_login => 'true',
        scope => '/person/update /activities/update',
        response_type => 'code',
        redirect_uri => 'https://developers.google.com/oauthplayground',
    );
};

get '/authorized' => sub {
    my $code = param('code');
    my $token = $client->access_token(
        grant_type => 'authorization_code',
        code => $code,
    );
    add_token($token);
    content_type 'application/json';
    to_json($token);
};

get '/search' => sub {
    my $params = params;
    content_type 'application/json';
    to_json($client->search(%$params, token => read_public_token));
};

#get '/:orcid/add' => sub {
    #template 'add', {methods => $add_methods};
#};

#post '/:orcid/add' => sub {
    #my $orcid  = param('orcid');
    #my $method = param('method');
    #$method = "add_$method";
    #my $request_body = from_json(param('request_body'));
    #my $response_body = client->$method(tokens->{$orcid}, $orcid, $request_body);
    #template 'add', {methods => $add_methods, response_body => to_json($response_body)};
#};

get '/:orcid/**' => sub {
    content_type 'application/json';
    my ($path) = splat;
    my $orcid  = param('orcid');
    to_json($client->get($path, token => tokens->{$orcid}, orcid => $orcid));
};

post '/:orcid/**' => sub {
    my ($path) = splat;
    my $orcid  = param('orcid');
    my $body = from_json(request->body);
    content_type 'application/json';
    to_json($client->add($path, $body, token => tokens->{$orcid}, orcid => $orcid));
};

put '/:orcid/**' => sub {
    my ($path) = splat;
    my $orcid  = param('orcid');
    my $body = from_json(request->body);
    content_type 'application/json';
    to_json($client->update($path, $body, token => tokens->{$orcid}, orcid => $orcid));
};

del '/:orcid/**' => sub {
    content_type 'application/json';
    my ($path) = splat;
    my $orcid  = param('orcid');
    to_json($client->delete($path, token => tokens->{$orcid}, orcid => $orcid));
};

#for my $path (@$get_methods) {
    #my $method = "get_$path";
    #get "/:orcid/$path" => sub {
        #my $orcid = param('orcid');
        #to_json(client->$method(tokens->{$orcid}, $orcid));
    #};
#}

#for my $path (@$get_put_code_methods) {
    #my $method = "get_$path";
    #get "/:orcid/$path/:put_code" => sub {
        #my $orcid = param('orcid');
        #my $put_code = param('put_code');
        #to_json(client->$method(tokens->{$orcid}, $orcid, $put_code));
    #};
#}

#for my $path (@$add_methods) {
    #my $method = "add_$path";
    #post "/:orcid/$path" => sub {
        #my $orcid = param('orcid');
        #my $request_body = from_json(param('request_body'));
        #to_json(client->$method(tokens->{$orcid}, $orcid, $request_body));
    #};
#}

dance;
