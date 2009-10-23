package Bot::BB3::PluginWrapper;

	use strict;

	package PluginWrapper::WrapSTDOUT;
	
	sub TIEHANDLE {
		my( $class, $buffer_ref ) = @_;
		return bless { buffer => $buffer_ref }, $class;
	}

	sub PRINT {
		my( $self, @args ) = @_;
		${ $self->{buffer} } .= join $", @args;

		return 1;
	}

	sub PRINTF {
		my( $self, $format, @args ) = @_;
		${ $self->{buffer} } .= sprintf $format, @args;

		return 1;
	}

package Bot::BB3::PluginWrapper;
	use strict;
	use warnings;

	use Moose;

	## not sure if these should be ro yet
	has 'name' => ( isa => 'Str', is => 'rw' ); 
	has 'coderef' => ( isa => 'CodeRef', is => 'rw' );

	sub BUILDARGS {
		my( $class, $name, $coderef ) = @_;
		{ coderef => $coderef, name => $name };
	}

	has 'opts' => (
		isa => 'HashRef'
		, is => 'ro'
		, default => sub { +{ command=>1 } }
	);

	sub command {
		my( $self, $said, $pm ) = @_;
		my( $name ) = $self->name;

		my $output;
		local *STDOUT;
		tie *STDOUT, 'PluginWrapper::WrapSTDOUT', \$output;

		$self->coderef->($said,$pm);

		untie *STDOUT;

		return( 'handled', $output );
	}


1;
