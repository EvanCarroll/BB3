package Bot::BB3::Plugin::IMDB;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

BEGIN { delete $INC{"IMDB.pm"}; } # Force a reload, sigh.
use IMDB;
use Storable qw/freeze thaw/;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

has '+name' => ( default => 'imdb' );
	
	my %commands = (
		quote => sub {
			my $obj = shift;
			my $i = 0;

			return "No quotes for $obj->{data}->{title}"
				unless ref $obj->{data}->{quotes} eq 'ARRAY';

			# Why am I using goto..
			START:

			my $num_quotes = @{ $obj->{data}->{quotes} };
			my $quote = $obj->{data}->{quotes}->[rand $num_quotes];
			return if $i++ > 5;

			goto START if @$quote > 4;

			return join "\n", @$quote;
		},
		trivia => sub {
			my $obj = shift;

			return "No trivia for $obj->{data}->{title}"
				unless ref $obj->{data}->{trivia} eq 'ARRAY';

			my $num_trivias = @{ $obj->{data}->{trivia} };
			return $obj->{data}->{trivia}->[rand $num_trivias];
		},
	);

	for my $type ( qw/genre title summary uri url/ )
	{
		$commands{$type}=sub{
			my$obj=shift;
			return $obj->{data}{$type}
		};
	}

sub initialize {
	my( $self, $pm, $cache ) = @_;

	$self->{cache} = $cache;
}

# RETURNED CODE ROUTINE
sub command {
	my( $self, $said, $pm ) = @_;
	my $cache = $self->{cache};

	my $body = $said->{body};
	$body =~ s/^\s*(\w+)\s*//
		or return "Failed to match a command, try help imdb";
	my $command = $1;

	my $title = IMDB->normalize_title($body);

	my $obj;
	if( $cache->get($title) )
	{
		$obj = thaw($cache->get($title));
	}
	else
	{
		$obj = IMDB->new( $title );
		
		if( not $obj ) {
			return( 'handled', "Failed to match title $body" );
		}

		$cache->set( $title, freeze($obj) );
	}

	if( exists $commands{$command} )
	{
		return( 'handled', $commands{$command}->($obj) );
	}
	else
	{
		return( 'handled', "Sorry, $command is not valid. Try help imdb" );
	}
}

"Bot::BB3::Plugin::IMDB";

__DATA__
imdb SUBCOMMAND Movie Name. Supported subcommands are: quote summary genre trivia title uri 
