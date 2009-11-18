package Bot::BB3::Plugin::Shorten;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use WWW::Shorten 'Metamark';

sub command {
	my( $self, $said, $pm ) = @_;
	print "New link: ", makeashorterlink($said->{body});
}


__DATA__
shorten <url> returns the "short form" of a url. Defaults to using xrl.us.
