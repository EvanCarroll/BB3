package Bot::BB3::Plugin::Nick_Lookup;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use DBI;

sub command {
	my( $self, $said, $pm ) = @_;

	my $dbh = DBI->connect("dbi:SQLite:dbname=var/hosts.db");

	my $recs = $dbh->selectall_arrayref( "SELECT * FROM hosts where nick = ?", {Slice=>{}}, $said->{body} );

	print "$said->{body}: ", join ", ", map $_->{host}, @$recs;
}

__DATA__
nick_lookup <nickname>; returns all of the hostnames this bot has seen a particular nick name use.
