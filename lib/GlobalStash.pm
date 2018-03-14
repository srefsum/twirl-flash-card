package GlobalStash;

use strict;
use warnings;
use Data::Dumper;
use Languages qw( DTxt getPreferedLanguage);
use utf8;

sub SetGlobaleStashVariables {
   my $self    = shift;
   
   my $user = $self->current_user();
   my $me = $self->session()->{auth_data};  

   if (defined($user) and defined($me)) {

	$self->stash( JudgeName                => $user->{$me}->name());
    $self->stash( JudgeId                  => $user->{$me}->userid());
   } else {
	$self->stash( JudgeName               => "");
    $self->stash( JudgeId                 => "");
   }
   $self->stash( ClassTitle               =>  "");
   $self->stash( ClassName                =>  "");

   $self->stash( topPage                  => 0);
   $self->stash( version                  => '0.01');
   $self->stash( prefix                   => 0);
   $self->stash( circuitidno              => 1);
   $self->stash( StatusType               => 'Running');
   $self->stash( logout                   => 1);
   $self->stash( tilbake                  => 1);
   $self->stash( hjem                     => 0);
   $self->stash( user                     => 0);
   $self->stash( StatusMessage            => 'Test av flash card');

   $self->stash( LogoutLabel              => DTxt('LABL_LOGOUT'));
   $self->stash( UserPageLabel            => DTxt('LABL_USERPG'));
   $self->stash( HomeLabel                => DTxt('LABL_HOME'));
   $self->stash( VersionLabel             => DTxt('LABL_VERSION'));
   
}

sub SetFrontPageStashVariables {
   my $self    = shift;
   $self->stash( WelcomeStr             => DTxt('STR_WELCOME'));
   $self->stash( PasswdChgStr           => DTxt('STR_PASSCHG'));
   $self->stash( UserLabel              => DTxt('LABL_USER'));
   $self->stash( PasswordLabel          => DTxt('LABL_PASSWD'));
   $self->stash( LoginLabel             => DTxt('LABL_LOGIN'));
   $self->stash( PwChgLabel             => DTxt('LABL_PWCHG'));
   $self->stash( NewPw1Label            => DTxt('LABL_NEWPW1'));
   $self->stash( NewPw2Label            => DTxt('LABL_NEWPW2'));
}

1;
