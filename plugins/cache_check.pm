package Bot::BB3::Plugin::CacheCheck;
use strict;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

has '+name' => ( default => 'cache_check' );

sub initialize {
	my( $self, $pm, $cache ) = @_;

	die "Failed to receive a cache during initialization: $cache"
		unless $cache;

	$self->{cache} = $cache;
}

sub command {
	my( $self, $said, $pm ) = @_;
	my $cache = $self->{cache};

	my $key = "cache_check_counter";

	$cache->set( $key => ( $cache->get( $key ) + 1 ) );

	return( 'handled', "Counter: " . $cache->get( $key ) );

}

"Bot::BB3::Plugin::CacheCheck";
