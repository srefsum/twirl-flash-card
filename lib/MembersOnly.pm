package MembersOnly;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use Mojo::Util qw(secure_compare);
use MembersOnly::Controller::Members;


my %user_password = (
  rob    => 'red',
  dean   => 'ninja',
  brenda => 'secret',
  rita   => 'banana',
);

sub load_user {
  my ($app, $uid) = @_;

  exists $user_password{$uid} ? $uid : undef;
}

sub validate_user {
  my ($app, $username, $password, $extradata) = @_;
  if (exists($user_password{$username}) && secure_compare($password, $user_password{$username})) {
    return $username;
  }
  return;
}

1;
