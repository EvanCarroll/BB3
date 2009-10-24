package Bot::BB3::Plugin::Core::Reload_Plugins;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	push @{ $said->{special_commands} },
		[ pm_reload_plugins => 1 ]
	;

	print "Attempting to reload plugins...";
}

1;

__DATA__

Attempts to reload all of the plugins in the plugin directory. Has the effect of reloading any changed plugins or adding any new ones that have been added. Typically root only.
