package Abstract::Profile;
use strict;
use warnings;
use Data::Dumper;
#use DBD::Oracle;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }


use StoreMysql;
use cryptSupport;

our $VERSION = '0.01';


   


sub new {
    my $class = shift;
    my $self = {};
    bless( $self, ( ref($class) || $class ) );
    $self->_initialize(@_);
    return $self;
}


sub _initialize {

  my $self = shift;
  
  my ($opt) = @_;

  my $rows = StoreMysql::LookupUser($opt->{id});
  #print "$opt->{id}:" . Dumper  $rows;
  
  for (my $i = 0; $i < scalar @$rows;$i++) {
	if ($opt->{id} ne $rows->[$i]{UserStr}) {next;}
	else {
		$self->id($opt->{id});
		$self->name($rows->[$i]{UserName});
		$self->password($rows->[$i]{UserPassword});
		$self->origin($rows->[$i]{OriginId});
		$self->role($rows->[$i]{Roles});
		$self->userid($rows->[$i]{UserId});

  
	  #$self->can($i_can); 
	  $self->{can}{admin}     =  ($rows->[$i]{Roles} =~ /admin/i)     ? 1 : 0;
	  $self->{can}{presenter} =  ($rows->[$i]{Roles} =~ /presenter/i) ? 1 : 0;
	  $self->{can}{judge}     =  ($rows->[$i]{Roles} =~ /judge/i)     ? 1 : 0;
	  $self->{can}{headjudge} =  ($rows->[$i]{Roles} =~ /headjudge/i) ? 1 : 0;
	}
  }
  
  return $self;
  
}

sub id {
  my $self = shift;

  if (@_) {
    $self->{id} = shift;
    return 1;
  }
  return $self->{id};

};

sub can {
  my $self = shift;

  if (@_) {
    $self->{can} = shift;
    return 1;
  }
  return $self->{can};

};

sub can_i {
  my $self   = shift;
  my ($action) = @_;
  return $self->{can}{$action};
}

sub role {
  my $self = shift;
  if (@_) {
    $self->{role} = shift;
    return 1;
  }
  return $self->{role};
};

sub origin {
  my $self = shift;
  if (@_) {
    $self->{origin} = shift;
    return 1;
  }
  return $self->{origin};
};

sub password {
  my $self = shift;
  if (@_) {
    $self->{password} = shift;
    return 1;
  }
  return $self->{password};
};

sub password_validate {
  my $self = shift;
  my $pw   = shift;
  $self->{password_validated} = cryptSupport::validatePassword($self->{password},$pw);
  return $self->{password_validated};
};


sub name {
  my $self = shift;
  if (@_) {
    $self->{name} = shift;
    return 1;
  }
  return $self->{name};
};

sub userid {
  my $self = shift;
  if (@_) {
    $self->{userid} = shift;
    return 1;
  }
  return $self->{userid};
};

1;
