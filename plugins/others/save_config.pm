package Bot::BB3::Plugin::Save_Configuration;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;

	push @{$said->{special_commands}}, [ bb3_save_main_conf => 1 ];

	print "Attempting to save my config, note that it won't change anything until I restart.";
}

__DATA__
save_config. Attempts to write the current config structure back to the file it was originally read from. Hopefully you've modified it first. Note, may lose comments. Root only.
