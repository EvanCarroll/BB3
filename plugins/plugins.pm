package Bot::BB3::Plugin::Plugins;
use strict;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

has '+name' => ( default => 'plugins' );

sub command {
	my($self, $said, $manager) = @_;
	my $output = join(" ", sort map { $_->{name} } @{$manager->get_plugins});
	
	#return( "handled", $output );
	return( "handled", $output );
}

"Bot::BB3::Plugin::Plugins";

__DATA__
Returns a list of all of the loaded plugins for this bot. Syntax, plugins
