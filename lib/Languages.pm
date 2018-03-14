package Languages;

#
# TODO: implement 
#

use strict;
use warnings;
use Data::Dumper;
use Switch;
use URI::Escape;
use utf8;

use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION     = 1.00;  
@ISA         = qw(Exporter);
@EXPORT      = qw( &DTxt &Found &Expected &getPreferedLanguage);  # symbols to export on request 
 

sub noTxt {
    my $val = shift;
    switch ($val) {
        case "STR_WELCOME"  { return 'Velkommen til Flash Card Autorisering'}
        case "STR_PASSCHG"  { return 'Velkommen til Passord endrings siden'}
        case "LABL_USER"    { return 'Bruker'}
        case "LABL_PASSWD"  { return 'Passord'}
        case "LABL_LOGIN"   { return 'Logg inn'}
        case "LABL_PWCHG"   { return 'Endre passord'}
        case "LABL_NEWPW1"  { return 'Nytt passord'}
        case "LABL_NEWPW2"  { return 'Nytt passord igjen'}


		case "LABL_ESCORES" { return 'Gi poeng'}
		case "LABL_MYSCORES"{ return 'Mine poeng'}
		case "LABL_EVACT"   { return 'Aktivere Gruppe'}
		case "LABL_EVDACT"  { return 'Deaktivere Gruppe'}
		case "LABL_ATHACT"  { return 'Aktivere Utøver'}
		case "LABL_ATHDACT" { return 'Deaktivere Utøver'}
		case "LABL_PRESENT" { return 'Presenter'}
		case "LABL_FLASH"   { return 'Flash Card'}
		case "LABL_ADMIN"   { return 'Vedlikehold'}
		
        case "LABL_LOGOUT"  { return 'Logg ut'}
        case "LABL_USERPG"  { return 'Bruker'}
        case "LABL_HOME"    { return 'Hjem'}
        case "LABL_VERSION" { return 'Versjon'}
		
        case "LABL_TBLNO"   { return 'Nummer'}
        case "LABL_TBLDEC"  { return 'Seksjon'}
	    case "LABL_TBLSC"   { return 'Poeng'}

		
        case "LABL_CAT"     { return 'Kategori'}
        case "LABL_DIV"     { return 'Divisjon'}
        case "LABL_CLASS"   { return 'Klasse'}
        case "LABL_LANE"    { return 'Bane'}
        case "LABL_STNO"    { return 'Start nummer'}
        case "LABL_ATHNAME" { return 'Utøver'}
        case "LABL_ATHNO"   { return 'Utøver nummer'}
		
        case "LABL_SECT1"   { return 'Variasjon'}
        case "LABL_SECT2"   { return 'Vanskelighetsgrad'}
        case "LABL_SECT3"   { return 'Tempo og kontroll'}
        case "LABL_SECT4"   { return 'Flyt og eleganse'}
        case "LABL_SECT5"   { return 'Fremførelse og presentasjon'}
        case "LABL_PBD"     { return 'Poeng før trekk'}
        case "LABL_DP"      { return 'Poengtrekk'}
        case "LABL_PAD"     { return 'Poeng etter trekk'}
        case "LABL_SUBMB"   { return 'Send inn Skjema'}
        case "LABL_RESETB"  { return 'Slett Skjema'}

        else                { return "NOTRANS: $val ::" . enTxt($val, @_)}
    }
}


sub enTxt {
    my $val = shift;
    switch ($val) {
	
        case "STR_WELCOME"  { return 'Welcome to Flash Card Authorization'}
        case "STR_PASSCHG"  { return 'Welcome to Password Change page'}
        case "LABL_USER"    { return 'User'}
        case "LABL_PASSWD"  { return 'Password'}
        case "LABL_LOGIN"   { return 'Login'}
        case "LABL_PWCHG"   { return 'Change password'}
        case "LABL_NEWPW1"  { return 'New password'}
        case "LABL_NEWPW2"  { return 'New password again'}

        case "LABL_LOGOUT"  { return 'Logout'}
        case "LABL_USERPG"  { return 'User'}
        case "LABL_HOME"    { return 'Home'}
        case "LABL_VERSION" { return 'Version'}

		case "LABL_ESCORES" { return 'Score'}
		case "LABL_MYSCORES"{ return 'My Scores'}
		case "LABL_EVACT"   { return 'Activate Event'}
		case "LABL_EVDACT"  { return 'Deactivate Event'}
		case "LABL_ATHACT"  { return 'Activate Athlete'}
		case "LABL_ATHDACT" { return 'Deactivate Athlete'}
		case "LABL_PRESENT" { return 'Present'}
		case "LABL_FLASH"   { return 'Flash Card'}
		case "LABL_ADMIN"   { return 'Admin'}

        case "LABL_TBLNO"   { return 'No.'}
        case "LABL_TBLDEC"  { return 'Section'}
        case "LABL_TBLSC"   { return 'Score'}
		
        case "LABL_CAT"     { return 'Category'}
        case "LABL_DIV"     { return 'Division'}
        case "LABL_CLASS"   { return 'Class'}
        case "LABL_LANE"    { return 'Lane'}
        case "LABL_STNO"    { return 'Start number'}
        case "LABL_ATHNAME" { return 'Athlete'}
        case "LABL_ATHNO"   { return 'Athlete number'}
		
        case "LABL_SECT1"   { return 'Variation'}
        case "LABL_SECT2"   { return 'Dificulty'}
        case "LABL_SECT3"   { return 'Tempo and control'}
        case "LABL_SECT4"   { return 'Flow and elegancee'}
        case "LABL_SECT5"   { return 'Fremførelse og presentasjon'}
        case "LABL_PBD"     { return 'Points before deduction'}
        case "LABL_DP"      { return 'Deductions'}
        case "LABL_PAD"     { return 'Points after deduction'}
        case "LABL_SUBMB"   { return 'Submit Form'}
        case "LABL_RESETB"  { return 'Reset Form'}
		
		
        else                { return "$val : Missing text value"}
    }
}

sub DTxt {
    my $config         = $MyApp::config;   
    if ($config->{language} eq 'en') {return(enTxt(@_));}
    if ($config->{language} eq 'nb') {return(noTxt(@_));}
    if ($config->{language} eq 'it') {return(enTxt(@_));}
    if ($config->{language} eq 'es') {return(enTxt(@_));}
    if ($config->{language} eq 'fr') {return(enTxt(@_));}
    if ($config->{language} eq 'ge') {return(enTxt(@_));}
}

sub Found {
    my $config         = $MyApp::config;   
	if ($config->{language} eq 'en') {return('Found');}
    if ($config->{language} eq 'nb') {return('Funnet');}
}

sub Expected {
    my $config         = $MyApp::config;   
	if ($config->{language} eq 'en') {return('Expected');}
    if ($config->{language} eq 'nb') {return('Forventet');}
}

sub getPreferedLanguage {
    my $langArr = shift;

    for (my $i = 0; $i < scalar @$langArr; $i++) {
        if (($langArr->[$i] eq 'nb') or
            ($langArr->[$i] eq 'fr') or		
            ($langArr->[$i] eq 'es') or		
            ($langArr->[$i] eq 'nl') or		
            ($langArr->[$i] eq 'it') or		
            ($langArr->[$i] eq 'ge') or		
            ($langArr->[$i] eq 'en')) {
            return($langArr->[$i]);
        } else {
            if ($langArr->[$i] =~ /nn/i)    { return('nb');}
            if ($langArr->[$i] =~ /nb-NO/i) { return('nb');}
            if ($langArr->[$i] =~ /en-US/i) { return('en');}
            if ($langArr->[$i] =~ /en/i)    { return('en');}
            if ($langArr->[$i] =~ /fr/i)    { return('fr');}
            if ($langArr->[$i] =~ /es/i)    { return('es');}
            if ($langArr->[$i] =~ /nl/i)    { return('nl');}
            if ($langArr->[$i] =~ /it/i)    { return('it');}
            if ($langArr->[$i] =~ /ge/i)    { return('ge');}
        }
    }
    
    return('en');
}


1;
        