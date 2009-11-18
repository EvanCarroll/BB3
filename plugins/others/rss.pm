package Bot::BB3::Plugin::Rss;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use POE::Filter::Reference;
use IO::Socket::INET;
use Data::Dumper;

use XML::RSS::Parser;

sub command {
	my( $self, $said, $pm ) = @_;
	my $feed_uri = $said->{recommended_args}->[0];

	print "Couldn't find a url to fetch!" and return
		unless $feed_uri;
	
	my $parser = XML::RSS::Parser->new;
	my $feed = $parser->parse_uri( $feed_uri ) #TODO check for http:// schema
		or ( print "Couldn't parse $feed_uri because", $parser->errstr and return );
	
	for( $feed->query("//item/title") ) {
		print $_->text_content;
	}

}

__DATA__
Returns small list of headlines from an RSS feed. Syntax, fetch_rss http://example/rss