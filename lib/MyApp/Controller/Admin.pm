package MyApp::Controller::Admin;
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
#use JSON qw(decode_json encode_json);


sub Select {
  my $self = shift;
  if (defined($self->param('activate_events')))     {$self->Activate_Events();    }
  if (defined($self->param('deactivate_events')))   {$self->DeActivate_Events();  }
  if (defined($self->param('activate_athletes')))   {$self->Activate_Athletes();  }
  if (defined($self->param('deactivate_athletes'))) {$self->DeActivate_Athletes();} 
}


sub Activate_Events {
  my $self = shift;
  my $rows = StoreMysql::LookupEvent( '%' . '%', '%' . '%');
  
  my %Reply;
  my %ReplyEn;
  my $EnCount = 0;
  $Reply{Events} = $rows;
  for (my $i = 0; $i < scalar @$rows; $i++) {

	my $Activerow = StoreMysql::LookupActiveListEntry($rows->[$i]{VenueId}, $rows->[$i]{EventsId});
	
	
	if (defined($Activerow) and  scalar @$Activerow > 0) {
		$Reply{Events}[$EnCount]{State} = $Activerow->[0]{State};
	} else { 
		$Reply{Events}[$EnCount]{State} = 'NotStarted';
	}
	$Reply{Events}[$EnCount]{EventsId} = $rows->[$i]{EventsId};
	$Reply{Events}[$EnCount]{VenueId}  = $rows->[$i]{VenueId};
	$Reply{Events}[$EnCount]{Lane}     = $rows->[$i]{Lane};
	$EnCount++;
  }

  my $config         = $MyApp::config;   
   
  $config->{RequestedLanguage} = $self->{'tx'}{'req'}{'content'}{'headers'}{'headers'}{'accept-language'};
  if (defined($config->{RequestedLanguage}[0])) {
		my @langs = split /,/ , $config->{RequestedLanguage}[0];  
		$config->{language} = getPreferedLanguage(\@langs);
	} else {
		$config->{language} = 'en';
		$config->{language} = $config->{language};
	}
  
  #print Dumper $config;
  GlobalStash::SetGlobaleStashVariables($self);
   $self->stash( logout                   => 1);
   $self->stash( tilbake                  => 1);
   $self->stash( VenuesId                 => 21);
   $self->stash( Events                   => '');
   $self->stash( EventId                  => 1);
   
   
   $self->stash( Content     =>  \%Reply);
   $self->stash( EnContent   =>  encode_json \%ReplyEn );
   $self->stash( EnCount     =>  $EnCount );
   
  
  # Render template "example/welcome.html.ep" with message
  $self->render( template => 'admin/activatevenueevent' );
}

sub DeActivate_Events {
	my $self = shift;

	
	
	
    $self->render( template => 'admin/activatevenueevent' );
}


sub Activate_Athletes {
	my $self = shift;
	
	my %ReplyEn;
	my ($config,$user,$me) = Utils::SetGlobals($self);
	$self->stash( tilbake                  => 1);
	$self->stash( EnCount                  => 1);
	$self->stash( EventJudgesCnt           => 0);
	$self->stash( Activate                 => 1);
	$self->stash( EventJudgesUid           => 0);	
	$self->stash( EventJudgesId            => 0);		
	$self->stash( user                     => 1);
	$self->stash( SubmitButtLabl           => DTxt('LABL_SUBMB'));	
	GlobalStash::SetGlobaleStashVariables($self);
	
	my $AthleteActive = StoreMysql::LookupAtletesToActivate();

	my $ListToRemove = StoreMysql::GetAthletesCompleted($AthleteActive->[0]{VenueId});
	for (my $i = 0;$i < @$ListToRemove; $i++) {
		for (my $j = 0;$j < @$AthleteActive; $j++) {
			if ($ListToRemove->[$i]{StartNo} == $AthleteActive->[$j]{StartNo}) {
				$AthleteActive->[$j]{Deleted} = 1;
				last;
			}
		}	
	}
	
	my $AtletesOnFloor = StoreMysql::GetAthletesActiveOnFloor($AthleteActive->[0]{VenueId});
	for (my $i = 0;$i < @$AtletesOnFloor; $i++) {
		for (my $j = 0;$j < @$AthleteActive; $j++) {
			if ($AtletesOnFloor->[$i]{StartNo} == $AthleteActive->[$j]{StartNo}) {
				$AthleteActive->[$j]{Deleted} = 1;
				last;
			}
		}	
	}

	
	$self->stash( AthleteActive     =>   \@$AthleteActive);
	$self->stash( EnContent   =>  encode_json \%ReplyEn );	
	$self->stash( VenueId   =>  $AthleteActive->[0]{VenueId} );	
	
	$self->render( template => 'admin/deactivate' );
}


sub Reorder_Athletes {
	my $self = shift;
	
	 
	
	my %ReplyEn;
	my ($config,$user,$me) = Utils::SetGlobals($self);
	$self->stash( tilbake                  => 1);
	$self->stash( EnCount                  => 1);
	$self->stash( EventJudgesCnt           => 0);
	$self->stash( Activate                 => 2);
	$self->stash( EventJudgesUid           => 0);	
	$self->stash( EventJudgesId            => 0);		
	$self->stash( user                     => 1);
	$self->stash( SubmitButtLabl           => DTxt('LABL_SUBMB'));	
	GlobalStash::SetGlobaleStashVariables($self);
	
	my $AthleteActive = StoreMysql::LookupAthletesInEvent($self->param('VenueId'), $self->param('EventsId'));

	my $ListToRemove = StoreMysql::GetAthletesCompleted($self->param('VenueId'));
	for (my $i = 0;$i < @$ListToRemove; $i++) {
		for (my $j = 0;$j < @$AthleteActive; $j++) {
			if ($ListToRemove->[$i]{StartNo} == $AthleteActive->[$j]{StartNo}) {
				$AthleteActive->[$j]{Deleted} = 1;
				last;
			}
		}	
	}
	
	# my $AtletesOnFloor = StoreMysql::GetAthletesActiveOnFloor($AthleteActive->[0]{VenueId});
	# for (my $i = 0;$i < @$AtletesOnFloor; $i++) {
	# 	for (my $j = 0;$j < @$AthleteActive; $j++) {
	# 		if ($AtletesOnFloor->[$i]{StartNo} == $AthleteActive->[$j]{StartNo}) {
	# 			$AthleteActive->[$j]{Deleted} = 1;
	# 			last;
	# 		}
	# 	}	
	# }

	
	$self->stash( AthleteActive     =>   \@$AthleteActive);
	$self->stash( EnContent   =>  encode_json \%ReplyEn );	
	$self->stash( VenueId   =>  $AthleteActive->[0]{VenueId} );	
	
	$self->render( template => 'admin/deactivate' );
}


# TODO Fix IntStartNo --> Now set to Zero!
sub SetAthleteStateActive {
  my $self = shift;
  my $config         = $MyApp::config;   
  my $Activate = $self->param('Activate');
  my $Request  = decode_json $self->param('SetStateforEvents');
   
  print  Dumper $Request;
  if (defined($Request->{Events})) {

	for (my $i = 0; $i < scalar @{$Request->{Events}}; $i++) {
		if (defined($Request->{Events}[$i])) {
			if ($Request->{Events}[$i]{State} eq 'OnFloor') {
				StoreMysql::StoreNewActiveOnFloor(  $Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo},  $Request->{Events}[$i]{AthletesId},  $Request->{Events}[$i]{Lane});
			} elsif ($Request->{Events}[$i]{State} eq 'Withdrawn') {
				StoreMysql::StoreCompletedAthlete($Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo},  0, 'Withdrawn');
			} elsif ($Request->{Events}[$i]{State} eq 'NoShow') {
				StoreMysql::StoreCompletedAthlete($Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo},  0, 'NoShow');
			} elsif ($Request->{Events}[$i]{State} eq 'Locked') {
				StoreMysql::StoreCompletedAthlete($Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo},  0, 'Scored');	
				StoreMysql::CompleteScores($Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo}); 					
				StoreMysql::RemoveActiveAthlete($Request->{Events}[$i]{VenueId},  $Request->{Events}[$i]{EventsId},  
				$Request->{Events}[$i]{StartNo}); 					
			} elsif ($Request->{Events}[$i]{State} eq 'Unlocked') {
			}
		}
	}
  }
  $self->DeActivate_Athletes();
}


sub DeActivate_Athletes {
	my $self = shift;
	my %ReplyEn;
	my ($config,$user,$me) = Utils::SetGlobals($self);
	$self->stash( tilbake                  => 1);
	$self->stash( EnCount                  => 1);
	$self->stash( EventJudgesCnt           => 0);
	$self->stash( Activate                 => 0);
	$self->stash( user                     => 1);
	$self->stash( SubmitButtLabl           => DTxt('LABL_SUBMB'));	
	GlobalStash::SetGlobaleStashVariables($self);

	my $Str ='';
	my @StrJudges;
	my @IdJudges;
	my $AthleteActive = StoreMysql::LookupActiveAtletesOnTheFloor();
	
	for (my $i = 0;$i< scalar @$AthleteActive; $i++) {
		
		my @StrJudge;
		my @IdJudge;
		my $Origin = StoreMysql::LookupOriginById($AthleteActive->[$i]{OriginId});
		$AthleteActive->[$i]{Origin} = $Origin->[0]{OriginName};
		
		my $EventJudges      = StoreMysql::LookupEventJudgesExtended ($AthleteActive->[0]{VenueId},$AthleteActive->[$i]{EventsId});
		$AthleteActive->[$i]{EventJudgesCnt}         = scalar @$EventJudges;
		
		if ($Str eq '') {$Str = $AthleteActive->[$i]{EventJudgesCnt};} 
		else {$Str = $Str . ',' . $AthleteActive->[$i]{EventJudgesCnt};}

		for (my $j = 0; $j < scalar @$EventJudges; $j++) {
			push @StrJudge, $EventJudges->[$j]{UserStr};
			push @IdJudge,  { id =>  $EventJudges->[$j]{JudgesId}, uid =>$EventJudges->[$j]{UserStr}};
		}
		push @StrJudges, @StrJudge;
		push @IdJudges, {event => $AthleteActive->[$i]{EventsId},startno => ,$AthleteActive->[$i]{StartNo}, judges => \@IdJudge};
	}
	$Str 	   = '['. $Str . ']'; 
	

	$self->stash( AthleteActive             => \@$AthleteActive);
	$self->stash( EnCount                   => scalar @$AthleteActive);
	$self->stash( EnContent                 =>  encode_json \%ReplyEn );	
	$self->stash( VenueId                   =>  $AthleteActive->[0]{VenueId} );		
	$self->stash( EventJudgesCnt            => $Str);	
	$self->stash( EventJudgesUid            => encode_json \@StrJudges);	
	$self->stash( EventJudgesId             => encode_json \@IdJudges);	
	
	$self->render( template => 'admin/deactivate' );	
}



sub searchEvents {
  my $self = shift;
  
  my $rows = StoreMysql::LookupEvent($self->param('VenuesId'), '%' . $self->param('Events') . '%');


  
  my %Reply;
  my %ReplyEn;
  my $EnCount = 0;
  $Reply{Events} = $rows;
  for (my $i = 0; $i < scalar @$rows; $i++) {

	my $Activerow = StoreMysql::LookupActiveListEntry($self->param('VenuesId'), $rows->[$i]{EventsId});
	
	if (defined($Activerow) and  scalar @$Activerow > 0) {
		$Reply{Events}[$EnCount]{State} = $Activerow->[0]{State};
	} else { 
		$Reply{Events}[$EnCount]{State} = 'NotStarted';
	}
	$Reply{Events}[$EnCount]{EventsId} = $rows->[$i]{EventsId};
	$Reply{Events}[$EnCount]{VenueId}  = $rows->[$i]{VenueId};
	$Reply{Events}[$EnCount]{Lane}     = $rows->[$i]{Lane};
	$EnCount++;
  }
  
  print Dumper \%Reply;
  my $config         = $MyApp::config;   
   
   
  $config->{RequestedLanguage} = $self->{'tx'}{'req'}{'content'}{'headers'}{'headers'}{'accept-language'};
  if (defined($config->{RequestedLanguage}[0])) {
		my @langs = split /,/ , $config->{RequestedLanguage}[0];  
		$config->{language} = getPreferedLanguage(\@langs);
	} else {
		$config->{language} = 'en';
		$config->{language} = $config->{language};
	}
  
  #print Dumper $config;
  GlobalStash::SetGlobaleStashVariables($self);
   $self->stash( logout                   => 1);
   $self->stash( tilbake                  => 1);
   $self->stash( VenuesId                 => 21);
   $self->stash( Events                   => '');
   $self->stash( EventId                  => 1);
   
   $self->stash( Content     =>  \%Reply);
   $self->stash( EnContent   =>  encode_json \%ReplyEn );
   $self->stash( EnCount     =>  $EnCount );
   
   print $self->stash( 'EnContent' );
   
  
  # Render template "example/welcome.html.ep" with message
  $self->render( template => 'admin/activatevenueevent' );
}

sub SetStateforEvents {
  my $self = shift;
  
  my $config         = $MyApp::config;   
   
  my $Request = decode_json $self->param('SetStateforEvents');
   
  print  Dumper $Request;
 
  if (defined($Request->{Events})) {
     my $tmp = $Request->{Events};
	 for (my $i = 0; $i < scalar @{$Request->{Events}}; $i++) {
		if (defined($Request->{Events}[$i])) {
		   my ($id,$res) = StoreMysql::StoreActiveListEntry($Request->{Events}[$i]{VenueId},$Request->{Events}[$i]{EventsId},$Request->{Events}[$i]{State});
		     if ($res == 0) {
		    	StoreMysql::UpdateActiveListEntryState($Request->{Events}[$i]{VenueId},$Request->{Events}[$i]{EventsId},$Request->{Events}[$i]{State});
		     }
		}
		print $i . "\n";
	 }
	 
  }


 
  my $rows = StoreMysql::LookupEvent( '%' . '%', '%' . '%');
  
  my %Reply;
  my %ReplyEn;
  my $EnCount = 0;
  $Reply{Events} = $rows;
  for (my $i = 0; $i < scalar @$rows; $i++) {

	my $Activerow = StoreMysql::LookupActiveListEntry($rows->[$i]{VenueId}, $rows->[$i]{EventsId});
	
	if (defined($Activerow) and  scalar @$Activerow > 0) {
		$Reply{Events}[$EnCount]{State} = $Activerow->[0]{State};
	} else { 
		$Reply{Events}[$EnCount]{State} = 'NotStarted';
	}
	$Reply{Events}[$EnCount]{EventsId} = $rows->[$i]{EventsId};
	$Reply{Events}[$EnCount]{VenueId}  = $rows->[$i]{VenueId};
	$Reply{Events}[$EnCount]{Lane}     = $rows->[$i]{Lane};
	$EnCount++;
  }
  
  
  $config->{RequestedLanguage} = $self->{'tx'}{'req'}{'content'}{'headers'}{'headers'}{'accept-language'};
  if (defined($config->{RequestedLanguage}[0])) {
		my @langs = split /,/ , $config->{RequestedLanguage}[0];  
		$config->{language} = getPreferedLanguage(\@langs);
	} else {
		$config->{language} = 'en';
		$config->{language} = $config->{language};
	}
  
  #print Dumper $config;
  GlobalStash::SetGlobaleStashVariables($self);
   $self->stash( logout                   => 1);
   $self->stash( tilbake                  => 1);
   $self->stash( VenuesId                 => 21);
   $self->stash( Events                   => '');
   $self->stash( EventId                  => 1);
   
   
   $self->stash( Content    			  =>  \%Reply);
   $self->stash( EnContent   			  =>  encode_json \%ReplyEn );
   $self->stash( EnCount     			  =>  $EnCount );
   #$self->stash( Content     =>  \%Reply);
   
  
  # Render template "example/welcome.html.ep" with message
  $self->render( template => 'admin/activatevenueevent' );
}

sub WelcomeIn {
  my $self = shift;
  
  my ($config,$user,$me) = Utils::SetGlobals($self);

  GlobalStash::SetGlobaleStashVariables($self);
  $self->stash( tilbake                  => 0);
  $self->stash( user                     => 1);
  
  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework! at : ' );
}






sub DeActivate {
	my $self = shift;
	print "DeActivate\n";
    my $user  = $self->current_user();
    my $me    = $self->session()->{auth_data};  

    #if (defined($user) and defined($me)) {
		my $name 	 = $user->{$me}->name();
		my $id   	 = $user->{$me}->id();
		my $userid   = $user->{$me}->userid();	
	#}
	print "$name:$id:$userid\n";
	my ($config,$user,$me) = Utils::SetGlobals($self);
	print "SetGlobals:$user:$me\n";
	GlobalStash::SetGlobaleStashVariables($self);
	$self->stash( tilbake                  => 1);
	$self->stash( user                     => 1);
	$self->stash( SubmitButtLabl           => DTxt('LABL_SUBMB'));
	
	#Look up ActiveEvents
	my $ActiveList = StoreMysql::LookupActiveListList("%");
	my $EventList = StoreMysql::LookupActiveEvents();
	print "EventList:$userid" . Dumper $ActiveList;

	my $Str ='';
	my $AthleteActive = StoreMysql::LookupNotCompletedAtleteId();
	
	
	for (my $i = 0;$i< scalar @$AthleteActive; $i++) {
		my $Athlete = StoreMysql::LookupAthleteByExtId($AthleteActive->[$i]{AthletesId});
		$AthleteActive->[$i]{AthletesName} = $Athlete->[0]{AthletesName};
		$AthleteActive->[$i]{OriginId} = $Athlete->[0]{OriginId};
		
		my $Origin = StoreMysql::LookupOriginById($AthleteActive->[$i]{OriginId});
		$AthleteActive->[$i]{Origin} = $Origin->[0]{OriginName};
		
		my $EventJudges      = StoreMysql::LookupEventJudges ($ActiveList->[0]{VenueId},$AthleteActive->[$i]{EventsId});
		$AthleteActive->[$i]{EventJudgesCnt}         = scalar @$EventJudges;
		
		if ($Str eq '') {$Str = $AthleteActive->[$i]{EventJudgesCnt};} 
		else {$Str = $Str . ',' . $AthleteActive->[$i]{EventJudgesCnt};}
		print "Str $Str\n";
	}
	$Str = '['. $Str . ']'; 
	print "Str $Str\n";
	
	print Dumper $AthleteActive;
	$self->stash( AthleteActive              => \@$AthleteActive);
	$self->stash( EnCount                    => scalar @$AthleteActive);
	$self->stash( EventJudgesCnt            => $Str);
	
    $self->render( template => 'admin/deactivate' );
}

sub score_status  {
   my $self = shift;
   $self->app->log->debug('WebSocket opened.');
   SocketScores($self);
};

sub initReply {
   my $self  = shift;
   my $value = shift;
   my $reply = shift;
}

sub scoresProcesReply {
   my $self  = shift;
   my $value = shift;
 
	for (my $i = 0; $i < scalar @{$value->{Judges}};$i++) {
		my $MyScores  = StoreMysql::LookupEventScoresForAll($value->{Judges}[$i]{startno},$value->{Judges}[$i]{event});
		for (my $s = 0; $s < scalar @{$value->{Judges}[$i]{judges}}; $s++ ) {
			$value->{Judges}[$i]{judges}[$s]{scored} = 0;
		}
		for (my $j = 0; $j < scalar @$MyScores;$j++) {
			for (my $s = 0; $s < scalar @{$value->{Judges}[$i]{judges}}; $s++ ) {
				if ($value->{Judges}[$i]{judges}[$s]{id} eq $MyScores->[$j]{JudgesId}) {
					$value->{Judges}[$i]{judges}[$s]{scored} = 1;
				}
			}
		}
	}
 }



sub SocketScores {
   my $self = shift; 
   # Opened
   # Increase inactivity timeout for connection a bit
   Mojo::IOLoop->stream($self->tx->connection)->timeout(1000);

   # Incoming message
   $self->on( message => sub {
	   my ($self, $msg) = @_;
	   my $value = decode_json($msg);
	
	   print Dumper $value; 
	   
	   my %reply = ();
	  
	   if ( $value->{tweet_id} =~ /^#open/ ) {
		  $self->send(encode_json(\%reply));
	   }

	   if ( $value->{tweet_id} =~ /^#close/ ) {
		   $self->app->log->debug("close");
	   }
	   
	   if (!( $value->{tweet_id} =~ /^#keep/ )) {
		  #$self->initReply ($value, \%reply);
	   }
	   
       if ( $value->{tweet_id} =~ /^#keep/ ) {
		  #$self->initReply ($value, \%reply);
		 $self->scoresProcesReply ($value);
		  $self->send(encode_json($value));
	   }
	   #Debug print 
	   if (( $value->{tweet_id} =~ /^#open/ )) {
		  $self->send(encode_json(\%reply));
	   }
	}
  );

 # Closed
 $self->on(finish => sub {
   my ($self, $code, $reason) = @_;
   $self->app->log->debug("WebSocket closed with status $code.");
 });
};



1;
