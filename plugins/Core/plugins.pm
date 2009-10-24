package Bot::BB3::Plugin::Core::Plugins;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

has '+name' => ( default => 'plugins' );

sub command {
	my ($self, $said, $manager) = @_;
	my $output = join(" ", sort map { $_->name } @{$manager->get_plugins});
	
	#return( "handled", $output );
	return( "handled", $output );
}

1;

__DATA__
Returns a list of all of the loaded plugins for this bot. Syntax, plugins
