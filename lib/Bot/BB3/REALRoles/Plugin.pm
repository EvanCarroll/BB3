package Bot::BB3::REALRoles::Plugin;
use Moose::Role;

has 'name' => ( isa => 'Str', is => 'ro', required => 1 );
has 'aliases' => ( isa => 'ArrayRef', is => 'ro' );
has 'opts' => (
	isa  => 'HashRef'
	, is => 'ro'
	, default => sub {
		my $self = shift;
		my @methods = $self->meta->get_method_list;
		my %hash;
		$hash{ command } = 1 if grep /command/, @methods;
		$hash{ handler } = 1 if grep /handle/, @methods;
		$hash{ post_process } = 1 if grep /post_process/, @methods;
		\%hash;
	}
);

sub create_table {
	my( $self, $dbh, $table_name, $create_table_sql ) = @_;

	local $@;
	eval {
		$dbh->do("SELECT * FROM $table_name LIMIT 1");
	};

	if( $@ =~ /no such table/ ) {
		# Race Conditions could cause two threads to create this table.
		local $@;
		eval {
			$dbh->do( $create_table_sql );
		};

		# Stupid threading issues.
		# All of the children try to do this at the same time.
		# Suppress most warnings.
		if( $@ and $@ !~ /already exists/ and $@ !~ /database schema has changed/ ) {
			die "Failed to create table: $@\n";
		}

		#Success!
	}
	elsif( $@ ) {
		die "Failed to access dbh to test table: $@";
		warn "Caller: ", join " ", map "[$_]", caller;
	}
}

1;
