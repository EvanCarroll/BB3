package Bot::BB3::Plugin::Geoip;
use strict;
use warnings;

use Geo::IP;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command {
	my( $self, $said, $pm ) = @_;
	my $gi = Geo::IP->new(GEOIP_STANDARD);

	print "Record for $said->{body}: ";

	if( $said->{body} =~ /[a-zA-Z]/ ) {
		print $gi->country_code_by_name( $said->{body} );
	}
	else {
		print $gi->country_code_by_addr( $said->{body} );
	}
}

__DATA__
geoip 192.168.32.45 or geoip example.com; returns the country associated with the resolved IP address.
