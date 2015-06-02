use 5.14.0;
use strict;
use warnings;

package Rest::Repose;

# VERSION
# ABSTRACT: Short intro

use base 'MoopsX::UsingMoose';

use Types::Standard();
use Rest::Repose::Mopes::Moose();
use MooseX::AttributeShortcuts();

sub import {
	my $class = shift;
	my %opts = @_;

	push @{ $opts{'imports'} ||= [] } => (
		'Types::Standard' => ['-types'],
		'Rest::Repose::Mopes::Moose' => [],
		'MooseX::AttributeShortcuts' => [],
	);

	push @{ $opts{'traits'} ||= [] } => (
		'Rest::Repose::Mopes::RequestResponseKeywords',
	);

	$class->SUPER::import(%opts);
}

1;


__END__

=pod

=head1 SYNOPSIS

    use Rest::Repose;

=head1 DESCRIPTION

Rest::Repose is ...

=head1 SEE ALSO

=cut
