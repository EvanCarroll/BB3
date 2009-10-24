package Bot::BB3::Plugin::Core::Topic;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	push @{ $said->{special_commands} }, [
		pci_topic => $said->{channel} => $said->{body}
	];

	print "Changing the topic to $said->{body} in $said->{channel}";
}

1;

__DATA__
Attempts to change the topic in the current channel. Typically requires op/superuser permissions for the user as well as operator permissions for the bot.
