package Bot::BB3::Plugin::Bels;
use strict;

# bels plugin for bb3
use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;
	my($arg) = @{$said->{"recommended_args"}};
	
	my $quotedir = $pm->main_conf->{be}->{quotes_dir} || "/dev/null";
	-d $quotedir or 
		die "error: quote directory does not exist, check etc/bb3.conf";

	opendir my $dh, $quotedir or die "Error opening quote directory\n";
	my @ent = sort grep { !/\./ } readdir $dh;
	closedir $dh;
	
	print "@ent";
	
}
__DATA__
get list of local quote files; usage: bels 
