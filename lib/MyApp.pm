package MyApp;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;
use Mojolicious::Plugin::Authorization;

use Mojo::Headers;
use Data::Dumper;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use StoreMysql;
use cryptSupport;

our $config;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  $config = $self->plugin('Config');
  
  # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer') if $config->{perldoc};

  
    $self->secrets(['This secret is used for new sessionsLeYTmFPhw3q',
        'This secret is used _only_ for validation QrPTZhWJmqCjyGZmguK']);

    # The cookie name
    $self->app->sessions->cookie_name('FlashCard');

    # Expiration reduced to 10 Minutes
    $self->app->sessions->default_expiration('600');
  
 
	$self->plugin('authentication', {
      autoload_user => 1,
      load_user => sub {
        my $self = shift;
        my $uid  = shift;
		
		print "Load User $uid\n";
		#my ($package, $filename, $line, $subroutine) = caller(3);
		#print "$subroutine load_user:" . $uid . "\n";
		
        return {%MyApp::Controller::Authn::LOGGED_IN{$uid}};		
      },
      validate_user => sub {
        my $self  = shift;
        my $un    = shift || '';
        my $pw    = shift || '';
        my $extra = shift || {};
		
		#print "validate_user $un $pw " . Dumper $extra;
		if ($un eq '') {return undef;}
		my $rows = StoreMysql::LookupUser($un);
		for (my $i = 0; $i < scalar @$rows;$i++) {
			if ($un ne $rows->[$i]{UserStr}) {next;}
			cryptSupport::init();
			return $un if (cryptSupport::validatePassword($rows->[$i]{UserPassword},$pw));
		}
        return undef;
      },
    }
  );

    $self->plugin('authorization',{

    has_priv => sub {
       my $self = shift;
       my ($priv, $extradata) = @_;
       my $user = $self->current_user();
	   my $me = $self->session()->{auth_data};	
       return $user->{$me}->can_i($priv) if (defined($me));
	   return 0;
    },
    
    is_role => sub {
      my $self = shift;
      my ($role, $extradata) = @_;
      my $user = $self->current_user();
	  my $me = $self->session()->{auth_data};
      return 1 if ($user->{$me}->role() eq $role);
      return 0;
    },
    
    user_privs => sub {
      my $self = shift;
      my ($extradata) = @_;
      my $user = $self->current_user();
	  my $me = $self->session()->{auth_data};	
      return keys(%{$user->{$me}->can()});
    },

    user_role => sub {
      my $self = shift;
      my ($extradata) = @_;
	  my $me = $self->session()->{auth_data};	
      my $user = $self->{$me}->current_user();
      return $user->role();
    },
    user_logged_in => sub {
      my $self = shift;
      my ($extradata) = @_;
	  my $me = $self->session()->{auth_data};	
      my $user = $self->{$me}->current_user();
	  
	  return 1 if {%MyApp::Controller::Authn::LOGGED_IN{$user}};
      return 0;
    },
  });



  
  my $r = $self->routes;
  # Normal route to controller
  $r->route('/')->via('get')->to(controller => 'authn',  action => 'delete');
  $r->route('/welcome')->via('get')->to(controller => 'authn',  action => 'delete');
  
  $r->route('/login')  ->via('post')->to( controller => 'authn',  action => 'login_post');
  $r->route('/login')  ->via('get') ->to( controller => 'authn',  action => 'login_get');
  $r->route('/logout') ->to(controller => 'authn',  action => 'delete');
 
  my $rn = $self->routes;
  
  $rn->add_condition(logged_in => sub {
	my ($route, $c, $captures, $num) = @_;

    my $user = $self->current_user();
    my $me = $self->session()->{auth_data}; 

	# Loser
	if (!defined($me)) {
		$self->redirect_to('/logout');
		return undef 
	}
	# Winner
	return 1 if {%MyApp::Controller::Authn::LOGGED_IN{$me}};
	# Loser
	$self->redirect_to('/logout');
	return undef;
});

  #$rn->route('/WelcomeIn')->over(authenticated => 1)->via('get')->to(controller => 'welcome', action => 'WelcomeIn');
  $rn->route('/WelcomeIn')->to(controller => 'welcome', action => 'WelcomeIn');
 
  #$r->get('/Scores')->to(controller => 'Scores', action => 'welcome');
  #$r->get('/Scores')->over(has_priv => 'headjudge')->to(controller => 'Scores', action => 'welcome');

  $rn->get('/Scores') ->over(authenticated => 1)->over(has_priv => 'judge')->to(controller => 'Scores', action => 'Select');
  $rn->get('/Scores') ->over(authenticated => 1)->over(has_priv => 'judge')->to(controller => 'Scores', action => 'loadscore');
  $rn->post('/Scores')->over(authenticated => 1)->over(has_priv => 'judge')->to(controller => 'Scores', action => 'submitScores');
  $rn->websocket ('/ws/echo_prefix')->to(controller => 'Scores', action => 'echo_prefix'); 

  $rn->route('/newpassword')      ->over(authenticated => 1)->via('get') ->to( controller => 'authn',   action => 'newpassword_get');
  $rn->route('/newpassword')      ->via('get') ->to( controller => 'authn', action => 'login_get');
  $rn->route('/newpassword')      ->over(authenticated => 1)->via('post')  ->to( controller => 'authn',  action => 'newpassword_set');
  $rn->route('/admin')            ->over(authenticated => 1)->via('get')   ->to( controller => 'admin',  action => 'Select');
  $rn->route('/admin')            ->over(authenticated => 1)->via('post')  ->to( controller => 'admin',  action => 'SetAthleteStateActive');
  $rn->websocket ('/ws/admin_score_status')->to(controller => 'admin', action => 'score_status'); 
  $rn->route('/searchEvents')     ->over(authenticated => 1)->via('post')  ->to( controller => 'admin',  action => 'searchEvents');
  $rn->route('/SetStateforEvent') ->over(authenticated => 1)->via('post')  ->to( controller => 'admin',  action => 'SetStateforEvents');
  $rn->route('/ReOrderAthletes')  ->over(authenticated => 1)->via('post')  ->to( controller => 'admin',  action => 'Reorder_Athletes');
  
  $rn->route('/presenter')        ->over(authenticated => 1)->via('get')   ->to( controller => 'presenter',  action => 'Select');
  $rn->route('/flash')            ->over(authenticated => 1)->via('post')  ->to( controller => 'presenter',  action => 'Flash');
}


1;
