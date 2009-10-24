package Bot::BB3::Plugin::Core::Echo;
use strict;
use warnings;

use Moose;
with 'Bot::BB3::REALRoles::Plugin';

sub command { print $_[1]->{body} }

1;

__DATA__
Echo just prints its argument verbatim.
