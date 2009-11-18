package Bot::BB3::Plugin::Show_Paste;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use Bot::BB3::Roles::PasteBot;

sub command {
	my( $self, $said, $pm ) = @_;

	$said->{body} =~ /(\d+)\D*$/
		or do { print "Failed to find a paste id."; return };

	my $paste_id = $1;

	my $paste_record = Bot::BB3::Roles::PasteBot->get_paste( $paste_id );

	print $paste_record->{paste};
}

1;

__DATA__
show_paste <paste_id>. Displays the contents of the paste_id. Try it in different contexts such as dcc or private message!
