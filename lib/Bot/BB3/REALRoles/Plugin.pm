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

1;
