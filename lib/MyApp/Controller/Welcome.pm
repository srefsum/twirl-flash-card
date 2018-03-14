package MyApp::Controller::Welcome;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Log;
use Mojo::Headers;

use Data::Dumper;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Languages qw( DTxt getPreferedLanguage);
use GlobalStash;
use Utils;
use utf8;


sub welcome {
  my $self = shift;
  
  my ($config,$user,$me) = Utils::SetGlobals($self);
  
  #print Dumper $config;
  GlobalStash::SetGlobaleStashVariables($self);
   $self->stash( logout                   => 0);
   $self->stash( tilbake                  => 0);
   $self->stash( ScoreLbl                 => DTxt('LABL_ESCORES'));
   $self->stash( MyScoreLbl               => DTxt('LABL_MYSCORES'));   
   $self->stash( ActvLbl                  => DTxt('LABL_EVACT'));
   $self->stash( DeActvLbl                => DTxt('LABL_EVDACT'));
   $self->stash( ActvAthLbl               => DTxt('LABL_ATHACT'));
   $self->stash( DeActvAthLbl             => DTxt('LABL_ATHDACT'));
   $self->stash( PresntLbl                => DTxt('LABL_PRESENT'));
   $self->stash( FlashLbl                 => DTxt('LABL_FLASH'));
   $self->stash( AdminLbl                 => DTxt('LABL_ADMIN'));

  
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework! at : ' );
}

sub WelcomeIn {
  my $self = shift;
  my ($config,$user,$me) = Utils::SetGlobals($self);
  print "Me $me\n";
  $config->{RequestedLanguage} = $self->{'tx'}{'req'}{'content'}{'headers'}{'headers'}{'accept-language'};
  if (defined($config->{RequestedLanguage}[0])) {
	 	my @langs = split /,/ , $config->{RequestedLanguage}[0];  
		$config->{language} = getPreferedLanguage(\@langs);
	} else {
		$config->{language} = 'en';
		$config->{language} = $config->{language};
	}

  GlobalStash::SetGlobaleStashVariables($self);
  $self->stash( tilbake                  => 0);
  $self->stash( user                     => 1);

  $self->stash( ScoreLbl                 => DTxt('LABL_ESCORES'));
  $self->stash( MyScoreLbl               => DTxt('LABL_MYSCORES'));
  $self->stash( ActvLbl                  => DTxt('LABL_EVACT'));
  $self->stash( DeActvLbl                => DTxt('LABL_EVDACT'));
  $self->stash( ActvAthLbl               => DTxt('LABL_ATHACT'));
  $self->stash( DeActvAthLbl             => DTxt('LABL_ATHDACT'));
  $self->stash( PresntLbl                => DTxt('LABL_PRESENT'));
  $self->stash( FlashLbl                 => DTxt('LABL_FLASH'));
  $self->stash( AdminLbl                 => DTxt('LABL_ADMIN'));  
  
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework! at : ' );
}



1;
