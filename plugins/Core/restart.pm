package Bot::BB3::Plugin::Core::Restart;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	push @{$said->{special_commands}}, [ bb3_restart=> 1 ];

	print "Attempting to restart..";
}

1;

__DATA__
restart. Attempts to rexecute the bot in the exact manner it was first execute. This has the effect of reloading all config files and associated plugins. Typically root only.
