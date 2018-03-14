package MyApp::Controller::Presenter;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Log;
use Mojo::Headers;

use Data::Dumper;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Languages qw( DTxt getPreferedLanguage);
use StoreMysql;
use GlobalStash;
use Utils;
use utf8;

sub Select {
  my $self = shift;
  if (defined($self->param('flash_cards')))     	{$self->FlashPrepare();    }
  if (defined($self->param('active_on_floor')))     {$self->Active_On_Floor();  }
}


sub FlashPrepare {
	my $self = shift;

	my %ReplyEn;
	$self->stash( tilbake                  => 1);
	$self->stash( EnCount                  => 1);
	$self->stash( Activate                 => 1);
	$self->stash( user                     => 1);
	GlobalStash::SetGlobaleStashVariables($self);
	
	my $AthleteActive = StoreMysql::LookupAtletesToFlash();

	$self->stash( AthleteActive     =>   \@$AthleteActive);
	$self->stash( EnContent   =>  encode_json \%ReplyEn );	
	$self->stash( VenueId   =>  $AthleteActive->[0]{VenueId} );	  

  $self->render( template => 'presenter/prepare_flash' );
}

sub Flash {
	my $self = shift;

	my $Athlete 	   = StoreMysql::LookupAthleteByExtId($self->param('AthletesId'));
	my $AthleteOrigin  = StoreMysql::LookupOriginById($Athlete->[0]{OriginId});
	my $Event    	   = StoreMysql::LookupEventOnId($self->param('VenueId'),$self->param('EventsId'));
	my $AthleteScores  = StoreMysql::LookupScoresToFlash($self->param('StartNo'));
	
	for (my $i = 0;$i < scalar @$AthleteScores; $i++ ) {
		$AthleteScores->[$i]{Score} = $AthleteScores->[$i]{Section_1} + $AthleteScores->[$i]{Section_2} +
		$AthleteScores->[$i]{Section_3} + $AthleteScores->[$i]{Section_4} + $AthleteScores->[$i]{Section_5} -
		$AthleteScores->[$i]{Deduction};
		
		$AthleteScores->[$i]{JudgesFlag} = $AthleteScores->[$i]{iso} . '.png';
	}
	
	$self->stash( AthletesName                     => $Athlete->[0]{AthletesName});
	$self->stash( Category                         => $Event->[0]{Category} . " " . $Event->[0]{Division}
													. " " . $Event->[0]{Level} . " " . $Event->[0]{EvHeat});
	$self->stash( StartNo                          => $self->param('StartNo'));
	$self->stash( Origin                           => $AthleteOrigin->[0]{OriginName});
	$self->stash( OriginFlag                       => $AthleteOrigin->[0]{iso} . '.png');
	$self->stash( AthleteScores                    => \@$AthleteScores);
	
	print Dumper $Athlete;
	print Dumper $Event;
	print Dumper $AthleteScores;
	$self->render( template => 'flash_card/flash' );
}

sub Active_On_Floor {
	my $self = shift;
  $self->render( template => 'presenter/active_on_floor' );
}

1;
