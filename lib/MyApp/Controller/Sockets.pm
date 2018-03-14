package MyApp::Controller::Sockets;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::IOLoop;

use warnings;
use strict;

websocket '/ws/echo_prefix' => sub {
   my $self = shift;
   $self->app->log->debug('WebSocket opened.');
   #SocketPrefix($self);
};

1;