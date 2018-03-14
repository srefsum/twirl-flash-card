package MyApp::Controller::Scores;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Log;
use Mojo::Headers;

use Data::Dumper;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Languages qw( DTxt getPreferedLanguage);
use GlobalStash;
use StoreMysql;
use Utils;
use utf8;

sub Select {
  my $self = shift;
  if (defined($self->param('scores')))     {$self->LoadScoreSheet();    }
  if (defined($self->param('myscores')))   {$self->ShowEventScores();  }
}


sub Something {
   my $self  = shift;

   my $user  = $self->current_user();
   my $me    = $self->session()->{auth_data};  

   if (defined($user) and defined($me)) {
		my $name 	 = $user->{$me}->name();
		my $id   	 = $user->{$me}->id();
		my $userid   = $user->{$me}->userid();

		#Look up ActiveEvents
		my $EventList = StoreMysql::LookupMyActiveEvent($userid);

		$self->stash( EventsId                => $EventList->[0]{EventsId});		
		$self->stash( VenueId                 => $EventList->[0]{VenueId});		
		
		$self->stash( Venue                   => $EventList->[0]{Venue});
		$self->stash( ClassName               => $EventList->[0]{Category} . " " .
												 $EventList->[0]{Division} . " " . 
												 $EventList->[0]{Level}   );
		$self->stash( EvHeat                  => $EventList->[0]{EvHeat});
		$self->stash( Lane                    => $EventList->[0]{Lane});
		
		#lookup Startnumbers 
		my $StartNumbers = StoreMysql::LookupStartNoByEvent($EventList->[0]{VenueId},$EventList->[0]{EventsId});
		
		
		#lookup Scores Completed
		my $CompletedStartNumbers = StoreMysql::LookupScoresCompleted($EventList->[0]{JudgesId},$EventList->[0]{EventsId});

		#Select lowest startnumber
		my $offset = scalar @$CompletedStartNumbers;
		
		my $ActiveStartnumber = $StartNumbers->[$offset]{StartNo};
		my $AthleteExtId      = $StartNumbers->[$offset]{AthletesId};
		 
		my $EventJudges      = StoreMysql::LookupEventJudges ($EventList->[0]{VenueId},$EventList->[0]{EventsId});
		$self->stash( EventJudgesCnt           => scalar @$EventJudges);

		my $ActiveAthlete   = StoreMysql::LookupAthleteByExtId($AthleteExtId);

		$self->stash( AthleteName              => $ActiveAthlete->[0]{AthletesName});
		$self->stash( ValidAthID               => $ActiveAthlete->[0]{AthletesExtId});
		$self->stash( AthleteId                => $ActiveAthlete->[0]{AthletesId});
		$self->stash( OriginId                 => $ActiveAthlete->[0]{OriginId});
		$self->stash( StartNo                  => $ActiveStartnumber);

		
		
		my $MyPreScores  = StoreMysql::LookupPreScoreUnique($StartNumbers->[$offset]{StartNo},
		                                                    $EventList->[0]{JudgesId},
															$EventList->[0]{EventsId});	
		if (scalar @$MyPreScores > 0) {
			$self->stash( Section_1_val           => $MyPreScores->[0]{Section_1}); 
			$self->stash( Section_2_val           => $MyPreScores->[0]{Section_2}); 
			$self->stash( Section_3_val           => $MyPreScores->[0]{Section_3}); 
			$self->stash( Section_4_val           => $MyPreScores->[0]{Section_4}); 
			$self->stash( Section_5_val           => $MyPreScores->[0]{Section_5}); 
			$self->stash( Section_Deduction_val   => $MyPreScores->[0]{Deduction}); 
		} else {
			$self->stash( Section_1_val           => 0); 
			$self->stash( Section_2_val           => 0); 
			$self->stash( Section_3_val           => 0); 
			$self->stash( Section_4_val           => 0); 
			$self->stash( Section_5_val           => 0); 
			$self->stash( Section_Deduction_val   => 0); 		
		}
		
   } 
}

sub SetStatusVariables {
   my $self    = shift;
   
   GlobalStash::SetGlobaleStashVariables($self);   
   
   $self->stash( ValidAthID               => 1);
   $self->stash( AthleteId                => 1);
   $self->stash( StartNo                  => 558);
   $self->stash( Lane                     => 558);
   
   $self->stash( Venue                    => 558);
   $self->stash( Event                    => 558);
   
   $self->stash( ClassTitle               =>  DTxt('LABL_CAT'));
   
   $self->stash( StartNoLabel             => DTxt('LABL_STNO'));
   $self->stash( AthleteLabel             => DTxt('LABL_ATHNAME'));
   $self->stash( AthleteNumberLabel       => DTxt('LABL_ATHNO'));
   
   $self->stash( TableTitleNo             => DTxt('LABL_TBLNO'));
   $self->stash( TableTitleSection        => DTxt('LABL_TBLDEC'));
   $self->stash( TableTitlePoints         => DTxt('LABL_TBLSC'));
   
   $self->stash( Section_1                => DTxt('LABL_SECT1'));
   $self->stash( Section_2                => DTxt('LABL_SECT2'));
   $self->stash( Section_3                => DTxt('LABL_SECT3'));
   $self->stash( Section_4                => DTxt('LABL_SECT4'));
   $self->stash( Section_5                => DTxt('LABL_SECT5'));
   $self->stash( pad_calc                 => 0);
   $self->stash( pbd_calc                 => 0);
   
   $self->stash( Total_Score              => DTxt('LABL_PBD'));
   $self->stash( Section_Deduction        => DTxt('LABL_DP'));
   $self->stash( Total_After_Deduction    => DTxt('LABL_PAD'));
  
   $self->stash( SubmitButtLabl          => DTxt('LABL_SUBMB'));
   $self->stash( ResetButtLabl           => DTxt('LABL_RESETB'));
   
   
   $self->stash( ScoresTemplate           => 2);
   
   


   $self->Something();
}

sub date_time_mojo {
    my $self      = shift;
    my $dir       = $self->param('dir');
    my $today     = $self->param('today');
    my $thismonth = $self->param('thismonth');
    my $thisyear  = $self->param('thisyear');
    
    my $time = localtime();
    
    return ($time);
}


sub LoadScoreSheet {
  my $self = shift;

  my ($config,$user,$me) = Utils::SetGlobals($self);
  $self->SetStatusVariables();
  $self->render(template => 'scores/scoretop' );
}

# This action will render a template

sub ShowEventScores {
	my $self = shift;

    GlobalStash::SetGlobaleStashVariables($self);	
	my ($config,$user,$me) = Utils::SetGlobals($self);
	my $userid   = $user->{$me}->userid();
	
	my $EventList = StoreMysql::LookupMyActiveEvent($userid);
	$self->stash( EventsId                => $EventList->[0]{EventsId});		
	$self->stash( VenueId                 => $EventList->[0]{VenueId});		

	$self->stash( Venue                   => $EventList->[0]{Venue});
	$self->stash( ClassName               => $EventList->[0]{Category} . " " .
											 $EventList->[0]{Division} . " " . 
											 $EventList->[0]{Level}   );
	$self->stash( EvHeat                  => $EventList->[0]{EvHeat});
	$self->stash( Lane                    => $EventList->[0]{Lane});
	$self->stash( StartNoLabel            => "fffff");
    $self->stash( ScoresTemplate          => '3' );
   
   print "EventList" . Dumper $EventList;
	
	my $AthleteActive = StoreMysql::LookupMyCompletedScores($EventList->[0]{EventsId},$EventList->[0]{JudgesId});
	for (my $i = 0; $i < scalar @$AthleteActive; $i++) {
		$AthleteActive->[$i]{Total} = $AthleteActive->[$i]{Section_1} + $AthleteActive->[$i]{Section_2} +
								      $AthleteActive->[$i]{Section_3} + $AthleteActive->[$i]{Section_4} +
									  $AthleteActive->[$i]{Section_5} - $AthleteActive->[$i]{Deduction}; 
    }
    $self->stash( AthleteActive              => \@$AthleteActive);
	
	print "AthleteActive:" . Dumper $AthleteActive;
	
	$self->render(template => 'scores/scoretop' );
}

sub welcomehome {
  my $self = shift;
  $self->SetStatusVariables();

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub echo_prefix  {
   my $self = shift;
   $self->app->log->debug('WebSocket opened.');
   SocketPrefix($self);
};

sub initReply {
   my $self  = shift;
   my $value = shift;
   my $reply = shift;
   
   
   $reply->{Section_1} = ($value->{Section_1} > 20) ? 20 : $value->{Section_1};
   $reply->{Section_1} = ($reply->{Section_1} <  0) ?  0 : $reply->{Section_1};
   
   $reply->{Section_2} = ($value->{Section_2} > 20) ? 20 : $value->{Section_2};
   $reply->{Section_2} = ($reply->{Section_2} <  0) ?  0 : $reply->{Section_2};
   
   $reply->{Section_3} = ($value->{Section_3} > 20) ? 20 : $value->{Section_3};
   $reply->{Section_3} = ($reply->{Section_3} <  0) ?  0 : $reply->{Section_3};
   
   $reply->{Section_4} = ($value->{Section_4} > 20) ? 20 : $value->{Section_4};
   $reply->{Section_4} = ($reply->{Section_4} <  0) ?  0 : $reply->{Section_4};
   $reply->{Section_5} = ($value->{Section_5} > 20) ? 20 : $value->{Section_5};
   $reply->{Section_5} = ($reply->{Section_5} <  0) ?  0 : $reply->{Section_5};
   
   $reply->{Section_Deduction} = ($value->{Section_Deduction} <    0) ?    0 : $value->{Section_Deduction};
   $reply->{Section_Deduction} = ($reply->{Section_Deduction} >  100) ?  100 : $reply->{Section_Deduction};
   
   $reply->{Section_pbd} = $reply->{Section_1} + $reply->{Section_2} + $reply->{Section_3} +  $reply->{Section_4} + $reply->{Section_5};
   $reply->{Section_pad} = $reply->{Section_pbd} - $reply->{Section_Deduction};
   

}

sub scoresProcesReply {
   my $self  = shift;
   my $value = shift;
   my $reply = shift;

   my $StartNo    = $value->{StartNo};
   my $JudgesId   = $value->{JudgeId};
   my $EventsId   = $value->{EventsId};
   

   my $MyPreScores  = StoreMysql::LookupPreScoreUnique($StartNo,$JudgesId,$EventsId);
   if (scalar @$MyPreScores > 0) {
	  StoreMysql::UpdatePreScore($StartNo, $JudgesId, $EventsId, $reply->{Section_1}, $reply->{Section_2}, 
	          $reply->{Section_3},	$reply->{Section_4}, $reply->{Section_5},  	$reply->{Section_Deduction});
   } else {
	  StoreMysql::StoreNewPreScore($StartNo, $JudgesId, $EventsId, $reply->{Section_1}, $reply->{Section_2}, 
	          $reply->{Section_3},	$reply->{Section_4}, $reply->{Section_5},  	$reply->{Section_Deduction});
   }
   my $AllPreScores = StoreMysql::LookupPreScore($StartNo, $EventsId);
   
   my @AllScoresCounts;
   $reply->{PreScoresCount} = scalar @$AllPreScores;
   for (my $i = 0; $i < scalar @$AllPreScores; $i++) {
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Section_1} > 0);
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Section_2} > 0);
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Section_3} > 0);
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Section_4} > 0);
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Section_5} > 0);
	  $AllScoresCounts[$i]++ if ($AllPreScores->[$i]{Deduction} > 0);
   }
   $reply->{AllScoresCounts} = \@AllScoresCounts;
}

sub submitScores {
  my $self = shift;
	my $AthleteId             = $self->param('AthleteId');             
	my $AthleteName           = $self->param('AthleteName');           
	my $EventsId              = $self->param('EventsId');              
	my $JudgesId              = $self->param('JudgeId');               
	my $JudgeName             = $self->param('JudgeName');             
	my $Section_1_val         = $self->param('Section_1_val');         
	my $Section_2_val         = $self->param('Section_2_val');         
	my $Section_3_val         = $self->param('Section_3_val');         
	my $Section_4_val         = $self->param('Section_4_val');         
	my $Section_5_val         = $self->param('Section_5_val');         
	my $Section_Deduction_val =	$self->param('Section_Deduction_val'); 
	my $ValidAthID            = $self->param('ValidAthID');            
	my $VenueId               = $self->param('VenueId');               
	my $StartNo               = $self->param('StartNo');               
  
    my $MyPreScores  = StoreMysql::LookupPreScoreUnique($StartNo,$JudgesId,$EventsId);
    if (scalar @$MyPreScores > 0) {
	  StoreMysql::DeletePreScore($StartNo, $JudgesId, $EventsId);
    }
	StoreMysql::StoreNewScore($StartNo, $JudgesId, $EventsId, $Section_1_val,
	   $Section_2_val, $Section_3_val, $Section_4_val, $Section_5_val, $Section_Deduction_val);
   
    $self->SetStatusVariables();

    # Render template "example/welcome.html.ep" with message
	$self->ShowEventScores();
}

sub SocketPrefix {
   my $self = shift; 
   # Opened
   # Increase inactivity timeout for connection a bit
   Mojo::IOLoop->stream($self->tx->connection)->timeout(1000);

   # Incoming message
   $self->on( message => sub {
	   my ($self, $msg) = @_;
	   my $value = decode_json($msg);

	   my %reply = ();
	  
	   if ( $value->{tweet_id} =~ /^#open/ ) {
		   ; #$self->app->log->debug("open");
	   }

	   if ( $value->{tweet_id} =~ /^#close/ ) {
		   $self->app->log->debug("close");
	   }
	   
	   if (!( $value->{tweet_id} =~ /^#keep/ )) {
		
		  $self->initReply ($value, \%reply);

	   }

	   if ( $value->{tweet_id}    =~ /^#keys_sted/ ) {
		  $self->send(encode_json(\%reply));
	   }
	   elsif ( $value->{tweet_id} =~ /^#product/ ) {
		  $self->send(encode_json(\%reply));
	   }
	   elsif ( $value->{tweet_id} =~ /^#sjekk/ ) {
		  $self->send(encode_json(\%reply));
	   }
	   elsif ( $value->{tweet_id} =~ /^#keep/ ) {
		  print "Received msg:" . Dumper $value;
		  $self->initReply ($value, \%reply);
		  $self->scoresProcesReply ($value, \%reply);
		  print "Reply msg:" . Dumper \%reply;
		  $self->send(encode_json(\%reply));
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
