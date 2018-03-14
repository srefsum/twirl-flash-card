package cryptSupport;

use strict;
use warnings;
use Data::Dumper;
use Crypt::PBKDF2;

 
my $pbkdf2;
sub rndStr{ join'', @_[ map{ rand @_ } 1 .. shift ]}
 
sub init {
 $pbkdf2 = Crypt::PBKDF2->new(
		hash_class => 'HMACSHA1', # this is the default
		iterations => 1000,       # so is this
		output_len => 32,         # and this
		salt_len   => 6,          # and this.
	);
} 


sub enCryptPassword {
	my $password = shift; 
	my $hash = $pbkdf2->generate($password);
	return $hash;
}

sub validatePassword {
	my $hash     = shift;
	my $password = shift;
	
	if ($pbkdf2->validate($hash, $password)) {
		return 1;
    }
	return 0;
}


sub generatePassword {
	my $pwd3 = rndStr (10, 'a'..'z', 0..9,'A'..'Z','!','#','<','>');
	return $pwd3;
}
1;