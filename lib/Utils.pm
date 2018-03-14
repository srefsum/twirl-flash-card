package Utils;

use Data::Dumper;
use warnings;
use strict;
use utf8;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Languages qw( DTxt getPreferedLanguage);

sub SetGlobals {
  my $self = shift;

  my $config = $MyApp::config;   
  my $me     = $self->session()->{auth_data};
  my $user   = $self->current_user();
  my $userid = $user->{$me}->userid();	
  my $id   	 = $user->{$me}->id();
  my $name 	 = $user->{$me}->name();
  
  $config->{RequestedLanguage} = $self->{'tx'}{'req'}{'content'}{'headers'}{'headers'}{'accept-language'};
  if (defined($config->{RequestedLanguage}[0])) {
	 	my @langs = split /,/ , $config->{RequestedLanguage}[0];  
		$config->{language} = getPreferedLanguage(\@langs);
  } else {
		$config->{language} = 'en';
		$config->{language} = $config->{language};
  }

  return($config,$user,$me);
}

1;


