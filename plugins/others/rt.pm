package Bot::BB3::Plugin::Rt;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use WWW::RottenTomatoes;

# Construct it outside the sub so it can at least pretend to do some caching.
my $rt = WWW::RottenTomatoes->new;

sub command {
	my( $self, $said, $pm ) = @_;

	local $@;
	my $movie_info = eval { $rt->movie_info( $said->{body} ) };

	if( $@ ) { 
		print "Error fetching movie info: $@";
		return;
	}

	if( $movie_info ) {
		print "$movie_info->{title}: $movie_info->{rating} - ", @{ $movie_info->{bubbles} }[ rand @{ $movie_info->{bubbles} } ];
	}

	else {
		print "Sorry failed to find a movie titled [$said->{body}]";
	}
}

__DATA__
RottenTomatoes plugin. Syntax, rt Movie Title.
