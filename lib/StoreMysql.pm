package StoreMysql;

use DBI;
use strict;
use Data::Dumper;
use utf8;

my %conf;
my $config;

sub createConf {
	# mysql -u drillApp -p drillApp
	$config   = \%conf;
	$config->{'DRILLAPPUSERNAME'}   = 'drillApp';
	$config->{'DRILLAPPUSERPASSWD'} = '#=drill';
	$config->{'DRILLAPPDB'}         = 'drillApp' ;
	$config->{'DRILLAPPSERVER'}     = 'localhost';
	$config->{'DRILLAPPPORT'}       = 3306;
	return $config;
}

sub __get_rancid_dbh {

    my $config   = createConf;;
    my $user     = $config->{'DRILLAPPUSERNAME'};
    my $password = $config->{'DRILLAPPUSERPASSWD'};
    my $database = $config->{'DRILLAPPDB'};
    my $hostname = $config->{'DRILLAPPSERVER'};
    my $port     = $config->{'DRILLAPPPORT'};
    
    my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";
    my $dbh = DBI->connect($dsn, $user, $password) or die("could not connect to the database: $!");
    return $dbh;
}

sub StoreNewVenue {
    
    my $VenueName  = shift;
    my $dbh = __get_rancid_dbh();
	
	my $rows = LookupVenue($VenueName);
	if (scalar @$rows > 0) {return($rows->[0]{VenueId});}	

    my $sth = $dbh->prepare("INSERT INTO Venues (Venue) VALUES (?)");
    my $rv = $sth->execute($VenueName);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'VenueId');
	#print "My new venue id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}


sub LookupVenue {
    
    my $VenueName  = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Venues WHERE Venue Like ?");
    my $rv   = $sth->execute($VenueName);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}


sub StoreNewEvents {
	my $VenueId    = shift;
	my $Category   = shift;
	my $Division   = shift;
	my $Level      = shift;
	my $EvHeat     = shift;
	my $Lane       = shift;

	my $rows = LookupEvent($VenueId,$Category,$Division,$Level,$EvHeat);
	if (scalar @$rows > 0) {return($rows->[0]{EventsId});}	
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO Events (VenueId,Category,Division,Level,EvHeat,Lane) VALUES (?,?,?,?,?,?)");
    my $rv = $sth->execute($VenueId,$Category,$Division,$Level,$EvHeat,$Lane);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'EventsId');
	#print "My new Event id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupEvent {
	my $VenueId    = shift;
	my $Category   = shift;
	my @rows;
	
    my $dbh = __get_rancid_dbh();

	my $sth  = $dbh->prepare("SELECT * FROM Events WHERE VenueId Like ? AND Category LIKE ? ");
    my $rv   = $sth->execute($VenueId,$Category);

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}

sub LookupEventOnId {
	my $VenueId    = shift;
	my $EventsId   = shift;
	my @rows;
	
    my $dbh = __get_rancid_dbh();

	my $sth  = $dbh->prepare("SELECT * FROM Events WHERE VenueId Like ? AND EventsId LIKE ? ");
    my $rv   = $sth->execute($VenueId,$EventsId);

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}


sub StoreNewOrigin {
    
    my $OriginName  = shift;
	
	my $rows = LookupOrigin($OriginName);
	if (scalar @$rows > 0) {return($rows->[0]{OriginId});}	
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO Origin (OriginName) VALUES (?)");
    my $rv = $sth->execute($OriginName);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'OriginId');
	#print "My new OriginId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupOrigin {
    
    my $OriginName  = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Origin WHERE OriginName = ?");
    my $rv   = $sth->execute($OriginName);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
	#print Dumper  \@rows;
    return \@rows;       
}

sub LookupOriginById {
    
    my $OriginId  = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Origin WHERE OriginId = ?");
    my $rv   = $sth->execute($OriginId);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
	#print Dumper  \@rows;
    return \@rows;       
}


sub StoreNewAthlete {
    
    my $AthletesName   = shift;
    my $AthletesExtId  = shift;
    my $OriginId         = shift;

    my $dbh = __get_rancid_dbh();
	
	my $rows = LookupAthleteByName($AthletesName);
	if (scalar @$rows > 0) {return($rows->[0]{AthletesId});}	

	my $rows = LookupAthleteByExtId($AthletesExtId);
	if (scalar @$rows > 0) {return($rows->[0]{AthletesId});}		

    my $sth = $dbh->prepare("INSERT INTO Athletes (AthletesName,AthletesExtId,OriginId) VALUES (?,?,?)");
    my $rv = $sth->execute($AthletesName,$AthletesExtId,$OriginId);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'AthletesId');
	#print "My new AthletesId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupAthleteByName {
    
    my $AthletesName  = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Athletes WHERE AthletesName = ?");
    my $rv   = $sth->execute($AthletesName);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}

sub LookupAthleteByExtId {
    
    my $AthletesExtId  = shift;
	#print "LookupAthleteByExtId : $AthletesExtId\n";
    my $dbh = __get_rancid_dbh();
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Athletes WHERE AthletesExtId like ?");
    my $rv   = $sth->execute($AthletesExtId);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}



sub StoreNewJudges {
    
    my $JudgesName  = shift;
    my $JudgesExtId = shift;
    my $OriginId    = shift;
	
	my $rows = LookupJudgesByName($JudgesName);
	if (scalar @$rows > 0) {return($rows->[0]{JudgesId});}	
	
	$rows = LookupJudgesByExtId($JudgesExtId);
	if (scalar @$rows > 0) {return($rows->[0]{JudgesId});}	
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO Judges (JudgesName,JudgeExtId,OriginId) VALUES (?,?,?)");
    my $rv = $sth->execute($JudgesName,$JudgesExtId,$OriginId);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'JudgesId');
	#print "My new JudgesId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupJudgesByName {
    
    my $JudgesName  = shift;
    my $dbh = __get_rancid_dbh();
	
	my @rows;
	
	my $sth  = $dbh->prepare("SELECT * FROM Judges WHERE JudgesName Like ?");
    my $rv   = $sth->execute($JudgesName);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}

sub LookupJudgesByExtId {
    
    my $JudgeExtId  = shift;
	my @rows;
	
    my $dbh = __get_rancid_dbh();
	
	my $sth  = $dbh->prepare("SELECT * FROM Judges WHERE JudgeExtId Like ?");
    my $rv   = $sth->execute($JudgeExtId);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}

sub StoreNewEventJudges {
    
    my $VenueId      = shift;
	my $EventsId     = shift;
	my $JudgesId     = shift;	
	my $JudgesExtId  = shift;	
	
	my $rows = LookupEventJudge($VenueId,$EventsId,$JudgesExtId);
	if (scalar @$rows > 0) { return($rows->[0]{EventJudgeId}); }

    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO EventsJudges (VenueId,EventsId,JudgesId,JudgesExtId) VALUES (?,?,?,?)");
    my $rv = $sth->execute($VenueId,$EventsId,$JudgesId,$JudgesExtId);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'EventJudgeId');
	#print "My new EventJudgeId id: $id \n";
	
    $dbh->disconnect();
	return ($id);    $dbh->disconnect();
}

sub LookupEventJudge {
    
    my $VenueId      = shift;
 	my $EventsId     = shift;
	my $JudgesExtId  = shift;	
	
	my @rows;
	
    my $dbh = __get_rancid_dbh();
	
	my $sth  = $dbh->prepare("SELECT * FROM EventsJudges WHERE EventsId Like ? AND  VenueId Like ? AND  JudgesExtId Like ?");
    my $rv   = $sth->execute($EventsId,$VenueId,$JudgesExtId);	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}

sub LookupEventJudges {
    
    my $VenueId      = shift;
 	my $EventsId     = shift;

	my @rows;
	
    my $dbh = __get_rancid_dbh();
	
	my $sth  = $dbh->prepare("SELECT * FROM EventsJudges WHERE EventsId Like ? AND  VenueId Like ?");
    my $rv   = $sth->execute($EventsId,$VenueId );	

    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}
   
sub LookupEventJudgesExtended {
    my $VenueId      = shift;
 	my $EventsId     = shift;

	my @rows;
    my $dbh = __get_rancid_dbh();
	my $sth  = $dbh->prepare("SELECT EJ.VenueId,EJ.EventsId,J.JudgesId,J.JudgesName,J.OriginId,U.UserStr FROM EventsJudges EJ "
					. "LEFT JOIN Judges J ON J.JudgesId = EJ.JudgesId "
					. "LEFT JOIN Users U ON U.UserName = J.JudgesName "
					. "where EJ.VenueId = ? AND EJ.EventsId = ? ");
    my $rv   = $sth->execute($VenueId,$EventsId );	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }
    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;       
}


sub StoreNewStartNo {
    my $VenueId = shift;
	my $EventsId = shift;
    my $StartNo = shift;
	my $AthletesId = shift;

	#print "$VenueId,$StartNo,$EventsId,$AthletesId\n";
	
	my $rows = LookupStartNo($VenueId,$StartNo);
	if (scalar @$rows > 0) { return($rows->[0]{StartNoId}); }
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO StartNo (VenueId,StartNo,EventsId,AthletesId) VALUES (?,?,?,?)");
    my $rv = $sth->execute($VenueId,$StartNo,$EventsId,$AthletesId);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'StartNoId');
	#print "My new StartNoId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupStartNo {
    my $VenueId = shift;
    my $StartNo = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;

 	my $sth  = $dbh->prepare("SELECT * FROM StartNo WHERE VenueId = ? AND StartNo = ?");
    my $rv = $sth->execute($VenueId,$StartNo);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupStartNoByEvent {
    my $VenueId = shift;
    my $Eventid = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;

 	my $sth  = $dbh->prepare("SELECT * FROM StartNo WHERE VenueId = ? AND EventsId = ? ORDER by StartNo ASC");
    my $rv = $sth->execute($VenueId,$Eventid);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub StoreNewScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	my $Section_1  = shift;
	my $Section_2  = shift;
	my $Section_3  = shift;
	my $Section_4  = shift;
	my $Section_5  = shift;
	my $Deduction  = shift;


	my $rows = LookupScore($StartNo  ,$JudgesId  ,$EventsId);
	if (scalar @$rows > 0) { 
		UpdateScore($StartNo, $JudgesId, $EventsId, $Section_1,
			$Section_2, $Section_3, $Section_4, $Section_5, $Deduction);
		return($rows->[0]{ScoreId});
	}
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO Scores (StartNo,JudgesId,EventsId,Section_1,Section_2,Section_3,Section_4,Section_5,Deduction) VALUES (?,?,?,?,?,?,?,?,?)");
    my $rv = $sth->execute($StartNo   ,$JudgesId  ,$EventsId  ,$Section_1 ,$Section_2 ,$Section_3 ,$Section_4 ,$Section_5 ,$Deduction);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'ScoreId');
	#print "My new ScoreId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM Scores WHERE StartNo Like ? AND JudgesId Like ? and EventsId LIKE ?");
    my $rv = $sth->execute($StartNo   ,$JudgesId  ,$EventsId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupScoresCompleted {
	my $JudgesId   = shift;
	my $EventsId   = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT ScoreId,JudgesId,EventsId,StartNo FROM Scores WHERE JudgesId = ? and EventsId = ? AND Completed = 1 ORDER BY StartNo ASC");
    my $rv = $sth->execute($JudgesId ,$EventsId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

# Must add VenueId to make unique
sub LookupEventScoresForAll {
	my $StartNo    = shift;
	my $EventsId   = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT ScoreId,JudgesId,EventsId,StartNo FROM Scores WHERE StartNo = ? and EventsId = ? ");
    my $rv = $sth->execute($StartNo ,$EventsId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}


sub UpdateScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	my $Section_1  = shift;
	my $Section_2  = shift;
	my $Section_3  = shift;
	my $Section_4  = shift;
	my $Section_5  = shift;
	my $Deduction  = shift;

    my $dbh = __get_rancid_dbh();
	
    my $sth = $dbh->prepare("UPDATE Scores SET Section_1 = ? ,Section_2 = ?,Section_3 = ?,Section_4 = ? ,Section_5 = ? ,Deduction = ? " . 
	                        "WHERE StartNo Like ? AND JudgesId LIKE ? AND EventsId LIKE ?");
    my $rv = $sth->execute($Section_1 ,$Section_2 ,$Section_3 ,$Section_4 ,$Section_5 ,$Deduction, $StartNo ,$JudgesId  ,$EventsId);
	
    $dbh->disconnect();
}

sub CompleteScores {
	my $VenueId    = shift;	
	my $EventsId   = shift;
	my $StartNo    = shift;
	
	my $rows = 	LookupEventScoresForAll( $StartNo, $EventsId);	

    my $dbh = __get_rancid_dbh();
	my $sth;
	for (my $i = 0; $i < scalar @$rows ;$i++) {
		$sth = $dbh->prepare("UPDATE Scores SET Completed = ? " . 
								"WHERE StartNo = ? AND JudgesId = ? AND EventsId = ?");
		my $rv = $sth->execute(1, $rows->[$i]{StartNo} ,$rows->[$i]{JudgesId}  ,$rows->[$i]{EventsId});
	}
	

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
}




sub StoreNewPreScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	my $Section_1  = shift;
	my $Section_2  = shift;
	my $Section_3  = shift;
	my $Section_4  = shift;
	my $Section_5  = shift;
	my $Deduction  = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
	
    my $sth = $dbh->prepare("INSERT INTO PreScores (StartNo,JudgesId,EventsId,Section_1,Section_2,Section_3,Section_4,Section_5,Deduction) VALUES (?,?,?, ?,?,?, ?,?,?)");
    my $rv = $sth->execute($StartNo   ,$JudgesId  ,$EventsId  ,$Section_1 ,$Section_2 ,$Section_3 ,$Section_4 ,$Section_5 ,$Deduction);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'ScoreId');
	#print "My new ScoreId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub DeletePreScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;

    my $dbh = __get_rancid_dbh();
	
    my $sth = $dbh->prepare("DELETE FROM PreScores WHERE StartNo = ? AND JudgesId = ? AND EventsId = ?");
    my $rv = $sth->execute($StartNo   ,$JudgesId  ,$EventsId);
	
    $dbh->disconnect();
	return;
}

sub UpdatePreScore {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	my $Section_1  = shift;
	my $Section_2  = shift;
	my $Section_3  = shift;
	my $Section_4  = shift;
	my $Section_5  = shift;
	my $Deduction  = shift;
	
	
    my $dbh = __get_rancid_dbh();
	
    my $sth = $dbh->prepare("UPDATE PreScores SET Section_1 = ? ,Section_2 = ?,Section_3 = ?,Section_4 = ? ,Section_5 = ? ,Deduction = ? " . 	                        "WHERE StartNo = ? AND JudgesId = ? AND EventsId = ?");
    my $rv = $sth->execute($Section_1 ,$Section_2 ,$Section_3 ,$Section_4 ,$Section_5 ,$Deduction, $StartNo ,$JudgesId  ,$EventsId);
	
    $dbh->disconnect();
}


sub LookupPreScoreUnique {
    my $StartNo    = shift;
	my $JudgesId   = shift;
	my $EventsId   = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM PreScores WHERE StartNo = ? AND JudgesId = ? AND EventsId = ?");
    my $rv = $sth->execute($StartNo   ,$JudgesId  ,$EventsId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupPreScore {
    my $StartNo    = shift;
	my $EventsId   = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM PreScores WHERE StartNo Like ? AND EventsId LIKE ?");
    my $rv = $sth->execute($StartNo  ,$EventsId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}


sub StoreNewUser {
	my $UserStr       = shift;
	my $UserName      = shift;
	my $UserPassword  = shift;
	my $OriginId      = shift;
	my $Roles         = shift;
	
	my @rows;

	my $rows = LookupUser($UserStr);
	if (scalar @$rows > 0) { return($rows->[0]{UserId}); }	

    my $dbh = __get_rancid_dbh();
	
	#INSERT INTO `Users` (`UserId`, `UserStr`, `UserName`, `UserPassword`, `OriginId`, `Roles`) 
    #		               VALUES (NULL, 'sir', 'Sigvald', 'pw1', '4', 'HeadJudge,Judge,Admin,Presenter');
	
    my $sth = $dbh->prepare("INSERT INTO Users (UserStr,UserName,UserPassword,OriginId,Roles) VALUES (?,?,?,?,?)");
    my $rv = $sth->execute($UserStr   ,$UserName  ,$UserPassword  ,$OriginId ,$Roles);
	
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'UserId');
	#print "My new ScoreId id: $id \n";
	
    $dbh->disconnect();
	return ($id);
}

sub LookupUser {
	my $UserStr        = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM Users WHERE UserStr = ?");
    my $rv = $sth->execute($UserStr);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub UpdateUserPw {
	my $UserStr        = shift;
	my $UserPw         = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
    my $sth = $dbh->prepare("UPDATE Users SET UserPassword = ? WHERE UserStr = ?");
    my $rv = $sth->execute($UserPw ,$UserStr);

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
}

sub StoreActiveListEntry {
    
    my $VenueId  = shift;
    my $EventId  = shift;
    my $State    = shift;
	
	my $rows = LookupActiveListEntry($VenueId,$EventId);
	if (scalar @$rows > 0) { return( $rows->[0]{ OriginId} ,0 );}	
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO ActiveList (ActiveVenueId,ActiveEventId,State) VALUES (?,?,?)");
    my $rv = $sth->execute($VenueId,$EventId,$State);
	
	my $id = $dbh->last_insert_id(undef, undef, undef, 'ActiveId');
	
    $dbh->disconnect();
	return ($id,1);
}

sub LookupActiveListEntry {
	my $VenueId        = shift;
	my $EventId        = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM ActiveList WHERE ActiveVenueId = ? AND ActiveEventId = ?");
    my $rv = $sth->execute($VenueId,$EventId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupActiveListList {
	my $VenueId        = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT * FROM ActiveList WHERE ActiveVenueId Like ?");
    my $rv = $sth->execute($VenueId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}


sub UpdateActiveListEntryState {
	my $VenueId        = shift;
	my $EventId        = shift;
    my $State          = shift;	
	
    my $dbh = __get_rancid_dbh();
    
 	my $sth  = $dbh->prepare("UPDATE ActiveList SET State = ? WHERE ActiveVenueId = ? AND ActiveEventId = ?");
    my $rv = $sth->execute($State,$VenueId,$EventId);
	

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
}

sub LookupMyActiveEvent {
	my $id          = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("select * from Venues v " .
         "left join Events e on v.VenueId = e.Venueid " .
		 "left join EventsJudges je on e.EventsId = je.EventsId " .
		 "left join Judges j on je.JudgesId = j.JudgesId " .
         "where je.JudgesId = ?");
    my $rv = $sth->execute($id);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupActiveEvents {
	my $id          = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("select * from Venues v " .
         "left join Events e on v.VenueId = e.Venueid " .
		 "left join EventsJudges je on e.EventsId = je.EventsId " .
		 "left join Judges j on je.JudgesId = j.JudgesId ");
    my $rv = $sth->execute();
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub LookupNotCompletedAtleteId {
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT DISTINCT(ST.AthletesId),SC.StartNo,SC.EventsId FROM Scores SC " . 
	                             "LEFT JOIN StartNo ST ON ST.StartNo = SC.StartNo " . 
	                             "WHERE SC.Completed = ? ");
    my $rv = $sth->execute('0');
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}	   


sub StoreNewActiveAthlete {
    my $VenueId    = shift;
	my $EventsId   = shift;
    my $StartNo    = shift;
	my $AthletesId = shift;
	my $Lane       = shift;

	#print "$VenueId,$StartNo,$EventsId,$AthletesId\n";
	
	my $rows = LookupStartNo($VenueId,$StartNo);
	if (scalar @$rows > 0) { return($rows->[0]{StartNoId}); }
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO StartNo (VenueId,EventsId,StartNo,AthletesId,Lane) VALUES (?,?,?,?,?)");
    my $rv = $sth->execute($VenueId,$EventsId,$StartNo,$AthletesId,$Lane);
	
    $dbh->disconnect();
}

sub StoreCompletedAthlete {
    my $VenueId    = shift;
	my $EventsId   = shift;
    my $StartNo    = shift;
	my $IntStartNo = shift;
	my $Status     = shift;
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO StartNoCompleted (VenueId,EventsId,StartNo,IntStartNo,Status) VALUES (?,?,?,?,?)");
    my $rv = $sth->execute($VenueId,$EventsId,$StartNo,$IntStartNo,$Status);
	
    $dbh->disconnect();
}

sub RemoveActiveOnFloor {
    my $VenueId    = shift;
	my $EventsId   = shift;
	my $StartNo    = shift;

	my $rows = LookupStartNo($VenueId,$StartNo);
	if (scalar @$rows > 0) { return($rows->[0]{StartNoId}); }
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("DELETE FROM StartNoCompleted WHERE VenueId = ? AND EventsId = ? AND StartNo = ?");
    my $rv = $sth->execute($VenueId,$EventsId,$StartNo);
	
    $dbh->disconnect();
}

sub GetAthletesCompleted {
    my $VenueId    = shift;

    my $dbh = __get_rancid_dbh();
	my @rows;
    my $sth = $dbh->prepare("SELECT * FROM StartNoCompleted WHERE VenueId = ?");
    my $rv = $sth->execute($VenueId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }
    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}

sub StoreNewActiveOnFloor {
    my $VenueId    = shift;
	my $EventsId   = shift;
    my $StartNo    = shift;
	my $AthletesId = shift;
	my $Lane       = shift;
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("INSERT INTO ActiveAthletes (VenueId,EventsId,StartNo,AthletesId,Lane) VALUES (?,?,?,?,?)");
    my $rv = $sth->execute($VenueId,$EventsId,$StartNo,$AthletesId,$Lane);
	
    $dbh->disconnect();
}

sub GetAthletesActiveOnFloor {
    my $VenueId    = shift;

    my $dbh = __get_rancid_dbh();
	my @rows;
    my $sth = $dbh->prepare("SELECT * FROM ActiveAthletes WHERE VenueId = ?");
    my $rv = $sth->execute($VenueId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }
    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}


sub RemoveActiveAthlete {
    my $VenueId    = shift;
	my $EventsId   = shift;
	my $StartNo   = shift;
	
    my $dbh = __get_rancid_dbh();

    my $sth = $dbh->prepare("DELETE FROM ActiveAthletes WHERE VenueId = ? AND EventsId = ? AND StartNo = ?");
    my $rv = $sth->execute($VenueId,$EventsId,$StartNo);
	
    $dbh->disconnect();
}

sub LookupAtletesToActivate {
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT ST.VenueId,ST.EventsId, ST.StartNo, ST.IntStartNo,ST.AthletesId," 
       . "EV.Lane, EV.Category, EV.Division, EV.Level,                  "
	   . "ATH.AthletesName,ATH.OriginId  FROM StartNo ST                "
	   . "LEFT JOIN Athletes ATH ON ATH.AthletesExtId = ST.AthletesId   "
	   . "LEFT JOIN ActiveList AL ON AL.ActiveEventId = ST.EventsId     "
	   . "LEFT JOIN Events EV ON EV.EventsId = ST.EventsId              "
	   . "ORDER BY  ST.IntStartNo, EV.Lane ASC                          ");
    my $rv = $sth->execute();
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}	   


sub LookupMyCompletedScores {
	my $EventsId   = shift;	
	my $JudgesId   = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT SC.*, ATH.AthletesName, ATH.OriginId FROM Scores SC "
							. "LEFT JOIN StartNo ST ON ST.StartNo = SC.StartNo "
							. "LEFT JOIN Athletes ATH ON ATH.AthletesExtId = ST.AthletesId "
							. "WHERE SC.EventsId = ? AND SC.JudgesId = ?");
    my $rv = $sth->execute($EventsId,$JudgesId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}	   


sub LookupActiveAtletesOnTheFloor {
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT AA.VenueId,AA.EventsId,ST.StartNo,ST.IntStartNo,ST.AthletesId,  "
			. "   EV.Lane, EV.Category, EV.Division, EV.Level,ATH.AthletesName, "
			. "   ATH.OriginId "
			. "FROM ActiveAthletes AA "
			. "LEFT JOIN Athletes ATH ON ATH.AthletesExtId = AA.AthletesId "
			. "LEFT JOIN Events EV ON EV.EventsId = AA.EventsId "
			. "LEFT JOIN StartNo ST ON ST.StartNo = AA.StartNo ");
    my $rv = $sth->execute();
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}
	   
sub LookupAtletesToFlash {
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT SNC.Status,SNC.StartNo,SN.AthletesId,ATH.AthletesName,ATH.AthletesName,ATH.OriginId,EV.* FROM StartNoCompleted SNC  "
	. "Left Join StartNo SN on SN.StartNo = SNC.StartNo "
    . "Left Join Athletes ATH on SN.AthletesId = ATH.AthletesExtId "
    . "Left join Events EV on SNC.EventsId = EV.EventsId " 
	. "WHERE SNC.Status = ? ");
    my $rv = $sth->execute('Scored');
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}
	   
sub LookupScoresToFlash {
	my $StartNo = shift;
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT SC.*, JD.JudgesName, JD.OriginId, O.OriginName, O.iso FROM Scores SC "
	. "left join Judges JD On SC.JudgesId = JD.JudgesId "
    . "left join Origin O ON JD.OriginId = O.OriginId "
    . "where SC.StartNo = ?");
    my $rv = $sth->execute($StartNo);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}	   

sub LookupAthletesInEvent {
	my $VenueId        = shift;
	my $EventId        = shift;
	
    my $dbh = __get_rancid_dbh();
	my @rows;
    
 	my $sth  = $dbh->prepare("SELECT ST.VenueId, ST.EventsId,ATH.AthletesName, ST.StartNo, ST.IntStartNo, "
	        . "O.OriginName, EV.Category, EV.Division, EV.Level, EV.EvHeat, EV.Lane FROM Athletes ATH "
			. "LEFT JOIN StartNo ST ON ATH.AthletesExtId = ST.AthletesId "
			. "LEFT JOIN Origin O ON ATH.OriginId = O.OriginId "
			. "LEFT JOIN Events EV ON ST.EventsId = EV.EventsId "
			. "WHERE ST.VenueId = ? AND ST.EventsId = ? "
			. "ORDER BY ST.IntStartNo ASC");
    my $rv = $sth->execute($VenueId,$EventId);
	
    if ($sth->rows() != 0 ) {
        while (my $row = $sth->fetchrow_hashref()) {
            push @rows, $row;
        }
    }

    $sth->finish(); 
    my $rc  = $dbh->disconnect;
    return \@rows;    
}




1;
