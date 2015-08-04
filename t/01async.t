#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin.'/../thirdparty/lib/perl5';
use lib $FindBin::Bin.'/../lib';

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
{
    use Mojolicious::Lite;
    plugin 'Pingen' => {mocked => 1};
    post '/send' => sub {
        my $c = shift;
        my $docId;
        $c->delay(
            sub { $c->pingen->document->upload(
                $c->req->upload('file'),
                shift->begin
            )},
            sub {
                my ($delay,$res)  = @_;
                if (not $res->{error}){
                    $docId = $res->{id};
                    $c->pingen->document->send($docId,{speed=>1},$delay->begin);
                }
                else {
                    return $c->render(json=>$res);
                }
            },
            sub {
                my ($delay,$res)  = @_;
                if (not $res->{error}){
                    $c->pingen->send->cancel($res->{id},$delay->begin);
                }
                else {
                    return $c->render(json=>$res);
                }
            },
            sub {
                my ($delay,$res)  = @_;
                if (not $res->{error}){
                    $c->pingen->document->delete($docId,$delay->begin);
                }
                else {
                    return $c->render(json=>$res);
                }
            },
            sub {
                my ($delay,$res)  = @_;
                return $c->render(json=>$res);
            },
        );
    };
}

my $t = Test::Mojo->new;
my %form;

$t->post_ok('/send', form => { file => { content => '%!pdf', filename=>'hellovelo'} })->status_is(200)->json_is('/error', 0);

done_testing;
