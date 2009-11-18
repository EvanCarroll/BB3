package Bot::BB3::Plugin::Conf_Dump;
use strict;
use warnings;
use Config::General;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;
	my $main_conf = $pm->main_conf;

	my $o = Config::General->new(
			-ConfigFile => $file,
			-LowerCaseNames => 1,
			-UseApacheInclude => 1,
			-AutoTrue => 1
		);

	print $o->save_string( $main_conf );
}

__DATA__

Dump the current configuration file
