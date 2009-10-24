package Bot::BB3::Plugin::Core::Join;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	my @channels = grep /^#/, @{ $said->{recommended_args} };

	push @{ $said->{special_commands} },   
		[ 'pci_join', @channels ];

	print "Joining @{ $said->{recommended_args} }";
}

1;

__DATA__
Attempts to join a list of channels. Syntax join #foo #bar #baz. Typically requires op or superuser.
