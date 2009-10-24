package Bot::BB3::Plugin::Core::Part;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	push @{$said->{special_commands}},
		map { [ pci_part => $_ ] } @{$said->{recommended_args}}
	;

	print "Attempting to leave: @{$said->{recommended_args}} ";
}

1;

__DATA__
Attempts to leave a list of channels. Syntax, part #foo #bar #baz. Note, does no sanity checking. Typically requires op or superuser.
