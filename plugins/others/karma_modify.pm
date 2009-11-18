package Bot::BB3::Plugin::Karma_Modify;
use POE::Component::IRC::Common qw/l_irc/;
use DBI;
use DBD::SQLite;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

has '+name' => ( default => 'karma_modify' );

sub dbh { 
	my( $self ) = @_;
	
	if( $self->{dbh} and $self->{dbh}->ping ) {
		return $self->{dbh};
	}

	my $dbh = $self->{dbh} = DBI->connect(
		"dbi:SQLite:dbname=var/karma.db",
		"",
		"",
		{ RaiseError => 1, PrintError => 0 }
	);

	return $dbh;
}

sub BUILD {
	my $self = shift;

	my $sql = "CREATE TABLE karma (
		karma_id INTEGER PRIMARY KEY AUTOINCREMENT,
		subject VARCHAR(250),
		operation TINYINT,
		author VARCHAR(32),
		modified_time INTEGER
	)"; # Stupid lack of timestamp fields

	$self->create_table( $self->dbh, "karma", $sql );

	delete $self->{dbh}; # UGLY HAX GO.
	                     # Basically we delete the dbh we cached so we don't fork
											 # with one active

}

sub handle {
	my( $self, $said, $pm ) = @_;
	my $body = $said->{body};

	if( $body =~ /\(([^\)]+)\)(\+\+|--)/ or $body =~ /(\w+)(\+\+|--)/ ) {
		my( $subject, $op ) = ($1,$2);
		if( $op eq '--' ) { $op = -1 } elsif( $op eq '++' ) { $op = 1 }

		$self->dbh->do( "INSERT INTO karma (subject,operation,author,modified_time) VALUES (?,?,?,?)",
			undef,
			l_irc( $subject ),
			$op,
			$said->{name},
			scalar time,
		);
	}

	return;
}

"Bot::BB3::Plugin::Karma_Modify";
