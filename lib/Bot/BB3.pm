package Bot::BB3;

use POE;
use POE::Session;
use POE::Wheel::Run;
use POE::Filter::Reference;

use Memoize qw/memoize/;

use Bot::BB3::ConfigParser;
use Bot::BB3::PluginManager;
use Bot::BB3::PluginConfigParser;
use Bot::BB3::Logger;

our $VERSION = '3.01';
use 5.008;

use Data::Dumper;
use strict;

sub new {
	my( $class, $args ) = @_;

	$args->{main_conf_file} ||= 'etc/bb3.conf';
	$args->{plugin_conf_file} ||= 'etc/plugins.conf';
	
	my $self = bless { args => $args }, $class;

	$self->parse_main_conf( $args->{main_conf_file} );
	$self->parse_plugin_conf( $args->{plugin_conf_file} );
	$self->_initialize();
	$self->_spawn_plugin_manager(); #Must be before spawn_pci, sigh
	$self->_spawn_roles( $args->{only_roles} );

	return $self;
}


#------------------------------------------------------------------------------
# Init methods
#------------------------------------------------------------------------------




sub _initialize {
	my( $self ) = @_;

	# WE create a session solely to register for 
	# a SIGINT handler, this is suboptimal
	# but I don't know if it's required.
	POE::Session->create( 
		object_states => [
			$self => [qw/_start SIGINT/]
		]
	);

	return 1;
}

sub _spawn_plugin_manager {
	my( $self ) = @_;

	$self->{ plugin_manager } = Bot::BB3::PluginManager->new( 
		$self->{ conf }, 
		$self->{ plugin_conf },  
		$self,
	);
}

sub _spawn_roles {
	my( $self, $role_list ) = @_;
	my $conf = $self->get_conf;

	if( $role_list ) {
		for( split /\s*,\s*/, $role_list ) {  #We should never have spaces anyway
			$self->_load_role( $_ ); # I hope they passed the correct module name..
		}
	}
	else { #Load every Role we can find

		for my $inc ( @INC ) {
			for( glob "$inc/Bot/BB3/Roles/*" ) {
				next unless s/\.pm$//;

				s/^\Q$inc\///;
				s{/}{::}g;

				my $role_name = $_;
				$role_name =~ s/^Bot::BB3::Roles:://;

				warn "Role Name: $role_name";
				warn "enabled: $conf->{roles}->{lc $role_name}->{enabled}\n";
				unless( 
					exists $conf->{roles}->{lc $role_name}->{enabled}
					and not $conf->{roles}->{lc $role_name}->{enabled} 
				) {
					$self->_load_role( $_ );
				}
			}
		}
	}
}

sub _load_role {
	my( $self, $role ) = @_;

	warn "Attempting to load $role\n";

	local $@;
	eval "require $role;"; # Avoid having to turn Foo::Bar back in to Foo/Bar.pm..

	if( $@ ) { warn "Failed to load $role: $@\n"; return; }

	warn "Spawning $role\n";

	$self->{$role} = $role->new( 
		$self->get_conf,
		$self->{plugin_manager}, #Hack, maybe.. plugin_manager needs to be loaded first.
	);
}

#------------------------------------------------------------------------------
# Public Methods
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Accessors
#------------------------------------------------------------------------------

sub get_conf {
	$_[0]->{conf};
}

sub restart {
	if( not -x $^X ) {
		error "Can't restart ourself because [$^X], our executable, is no longer executable!";
		return;
	}

	if( not -e $0 or not -r _ or -s _ < 100 ) {
		error "Can't restart ourself because our bot probram [$0] is no longer in a useful state!";
		return;
	}

	exec $^X, $0, @ARGV;
}

sub parse_main_conf {
	my( $self, $conf_file ) = @_;

	debug "Parsing config file [$conf_file]";

	if( not -e $conf_file or not -r _ ) {
		error "Failed to read conf_file [$conf_file]";
		exit 1;
	}


	my $conf = Bot::BB3::ConfigParser->parse_file( $conf_file )
		or die "Failed to parse a conf file! $BB3::Conf::PARSE_ERROR\n";
	
	unless( keys %$conf ) {
		error "Failed to successfully read [$conf_file]!";
		exit 1;
	}

	my %conf_defaults = (
		start_plugin_children => 4,
		max_plugin_children => 10,
		child_handle_count => 100,
		http_plugin_port => 10080,
		pastebot_plugin_port => 10081,
	);

	for( keys %conf_defaults ) {
		#Sigh, where is my //=
		$conf->{$_} = $conf_defaults{ $_ }
			unless defined( $conf->{$_} );
	}

	debug Dumper $conf;

	$self->{conf} = $conf;

	return 1;
}


sub parse_plugin_conf {
	my( $self, $conf_file ) = @_;

	my $conf = Bot::BB3::PluginConfigParser->parse_file( $conf_file )
		or die "Failed to parse Plugin Config File: $!\n";

	$self->{plugin_conf} = $conf;
}

sub save_main_conf {
	my( $self ) = @_;
	my $conf = $self->get_conf;
	my $conf_filename = $self->{args}->{main_conf_file};

	if( not $conf_filename or not -e $conf_filename or not -w _ ) {
		error "Couldn't find a valid file to write our conf to, tried [$conf_filename], " .
		 " either doesn't exist or not writable";
		return;
	}

	Bot::BB3::ConfigParser->save_file( $conf_filename, $conf );
}

sub change_conf {
	my( $self, $path, $value ) = @_;
	my $conf = $self->get_conf;

	if( $value =~ s/^\s*\[\s*// and $value =~ s/\s*\]\s*$// ) {
		$value = [ split /\s*,\s*/, $value ];
	}

	warn "Change_conf initiated";

	my $ref = $conf;
	my @parts = split /\./, $path;
	my $final_key = pop @parts;

	for( @parts ) {
		if( ref $ref eq 'HASH' ) {
			$ref = $ref->{$_};
		}
		elsif( ref $ref eq 'ARRAY' ) {
			$ref = $ref->[$_];
		}
		else {
			error "Passed a path that didn't lead us properly down the rabbit hole. $path";
			return;
		}
	}

	warn "change_conf $ref -> $final_key -> $value";

	return unless $ref and $final_key and length $value;

	warn "Set something: ", $ref->{$final_key} = $value;

	warn "New value: $ref->{$final_key}";
	
	use Data::Dumper;
	warn Dumper $ref;
	warn Dumper $conf;
}

#------------------------------------------------------------------------------
# POE Methods
#------------------------------------------------------------------------------

sub _start {
	my( $self, $kernel, $session ) = @_[OBJECT,KERNEL,SESSION];


	$kernel->sig( INT => 'SIGINT' ); 
}


# This is called by a sigints. We ask the plugin manager
# to kill its children. We have to yield a exit call
# otherwise the plugin_manager's yield won't get processed.
# The above issue should be fixed by switching to the 
# kernel->call interface. Delete this comment when verified.
sub SIGINT {
	my( $self, $kernel ) = @_[OBJECT,KERNEL];

	warn "Oh gads, SIGINT\n";

	$self->{plugin_manager}->call( 'please_die' );

	$kernel->stop;

	exit;
}

1;
__END__

=head1 NAME

Bot::BB3 - The Robert Grimes Buubot with less suck

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Bot::BB3;

    my $foo = Bot::BB3->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Robert Grimes, C<< <buu at erxz.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bot-bb3 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bot-BB3>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bot::BB3


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bot-BB3>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bot-BB3>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bot-BB3>

=item * Search CPAN

L<http://search.cpan.org/dist/Bot-BB3/>

=back

=head1 ACKNOWLEDGEMENTS

Evan Carroll, for removing some major suck


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Grimes.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
