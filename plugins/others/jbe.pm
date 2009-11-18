package Bot::BB3::Plugin::Jbe;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

use LWP::Simple;
use CGI;

sub command {
	my( $self, $said, $pm ) = @_;
	my $arg = $said->{body};
	
	my $suffix;
	if (!($arg =~ /(\S+)/)) {
		print "No fortune filename given.  Try the `jbels' command to list fortune files.\n";
		return;
	}
	my $nam = $1;
	$suffix = ($nam =~ /:/ ? "source=" : "file=") . CGI::escape($nam);

	my $uri = "http://jdporter.perlmonk.org/fortune.cgi?plain;" . $suffix;
	my $content = get($uri);
	if (!defined($content)) {

		print "error loading fortune feed\n";
	}
	
	$content =~ s/[\r\n]+\s*/ /g;
	
	print $content, "\n";
	
};

!%Bot:: && @ARGV and # standalone run hack
	&$main({"body", join(" ", @ARGV)});

1;

# jbels (jdporter's fortune feed list) plugin for buubot3
__DATA__
Get a fortune cookie from jdporter's fortune feed (http://jdporter.perlmonk.org/fortune.cgi); usage: jbe name; see also jbels
