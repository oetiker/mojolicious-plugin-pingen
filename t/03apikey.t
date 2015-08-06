#!/usr/bin/env perl
use FindBin;
use lib $FindBin::Bin.'/../thirdparty/lib/perl5';
use lib $FindBin::Bin.'/../lib';

use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
{
    use Mojolicious::Lite;
    plugin 'Pingen' => {mocked => 1, exceptions => 1,apikey=>'wrong'};
    post '/upload' => sub {
        my $c = shift;
        eval {
           my $docId = $c->pingen->document->upload($c->req->upload('file'))->{id};
           $c->render(text=>$docId);
        };
        if ($@){
           $c->render(text=>$@);
        }
    };
    post '/send/:docid' => sub {
        my $c = shift;
        eval {
            my $sendId = $c->pingen->document->send($c->stash('docid'),{speed=>1})->{id};
            $c->render(text=>$sendId);
        };
        if ($@){
           $c->render(text=>$@);
        }
    };
    post '/cancel/:sendid' => sub {
        my $c = shift;
        eval {
           $c->pingen->send->cancel($c->stash('sendid'));
           $c->render(text=>'done');
        };
        if ($@){
           $c->render(text=>$@);
        }
    };
    post '/delete/:docid' => sub {
        my $c = shift;
        eval {
            $c->pingen->document->delete($c->stash('docid'));
            $c->render(text=>'done');
        };
        if ($@){
           $c->render(text=>$@);
        }
    };
}

my $t = Test::Mojo->new;
my %form;

$t->post_ok('/upload', form => { file => { content => '%!pdf', filename=>'hellovelo'} })->status_is(200)->content_is('Your token is invalid or expired');
$t->post_ok('/send/1', form => { file => { content => '%!pdf', filename=>'hellovelo'} })->status_is(200)->content_is('Your token is invalid or expired');
$t->post_ok('/cancel/2', form => { file => { content => '%!pdf', filename=>'hellovelo'} })->status_is(200)->content_is('Your token is invalid or expired');
$t->post_ok('/delete/1', form => { file => { content => '%!pdf', filename=>'hellovelo'} })->status_is(200)->content_is('Your token is invalid or expired');

done_testing;
