package MyApp::Controller::Authn;
use Mojo::Base 'Mojolicious::Controller';
use  Abstract::Profile;
# This action will render a template
use Data::Dumper;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Languages qw( DTxt getPreferedLanguage);
use GlobalStash;
use StoreMysql;
use cryptSupport;
use utf8;

our %LOGGED_IN = ();
  



sub form {
  my $self = shift;
  print "Hei\n";
  
}

sub login_post {
  my $self = shift;
  
  if (!defined($self->param('id'))) {$self->render('authn/form');return;}
  
  if ($self->authenticate($self->param('id'), $self->param('pw')
                         ,{brain_slug=>$self->param('slug')})) {
                           
    my $profile = Abstract::Profile->new({id=>$self->param('id')});
    $LOGGED_IN{$profile->id()} = $profile;

	
    $self->redirect_to('WelcomeIn');
	return;
  }
  GlobalStash::SetGlobaleStashVariables($self);   
  GlobalStash::SetFrontPageStashVariables($self);   
  $self->stash( logout                   => 0);
  $self->stash( tilbake                  => 0);
  $self->stash( hjem                     => 0);	  
  $self->stash( NewPassword              => 0);	  
  $self->render('authn/form');return;
}

sub login_get {
	my $self = shift;
	
	GlobalStash::SetGlobaleStashVariables($self);   
	GlobalStash::SetFrontPageStashVariables($self);   
    $self->stash( logout                   => 0);
    $self->stash( tilbake                  => 0);
    $self->stash( hjem                     => 0);	
    $self->stash( NewPassword              => 0);	
	$self->stash( topPage                  => 1);	
	
    $self->render('authn/form');
}

sub newpassword_get {
	my $self = shift;
	
	GlobalStash::SetGlobaleStashVariables($self);   
	GlobalStash::SetFrontPageStashVariables($self);   
    $self->stash( logout                   => 1);
    $self->stash( tilbake                  => 1);
    $self->stash( hjem                     => 0);	
    $self->stash( NewPassword              => 1);	  
	
    $self->render('authn/form');
}

sub newpassword_set {
	my $self = shift;
	
	
	if ($self->authenticate($self->param('id'), $self->param('pw')
                         ,{brain_slug=>$self->param('slug')})) {
						 
		if ( $self->param('pw_new_1') eq $self->param('pw_new_2')) {
			StoreMysql::UpdateUserPw($self->param('id'),
				cryptSupport::enCryptPassword($self->param('pw_new_1')));
		}
	}
	
	GlobalStash::SetGlobaleStashVariables($self);   
    $self->stash( logout                   => 1);
    $self->stash( tilbake                  => 1);
    $self->stash( hjem                     => 0);	
    $self->stash( NewPassword              => 1);	  
	
    $self->render('authn/form');
}


sub check {
  my $self = shift;
  if ($self->is_user_authenticated() and $LOGGED_IN{ $self->session('auth_data')}){
    return 1;
  }
  $self->logout();
  GlobalStash::SetGlobaleStashVariables($self);   
  GlobalStash::SetFrontPageStashVariables($self);     
  
  $self->redirect_to('authn/form');

  return 0;
}

sub delete {
  my $self = shift;

  my $user = $self->current_user();
  $LOGGED_IN{ $self->session('auth_data')} = undef;
  $self->logout();
  GlobalStash::SetGlobaleStashVariables($self);  
  GlobalStash::SetFrontPageStashVariables($self);     
  $self->stash( logout                   => 0);
  $self->stash( tilbake                  => 0);
  $self->stash( hjem                     => 0);	
  $self->stash( NewPassword              => 0);	  
  $self->render('authn/form');
  
}
 
1;
