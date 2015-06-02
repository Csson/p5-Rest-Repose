use MoopsX::UsingMoose;
use strict;
use warnings;

# PODCLASSNAME

 role TestFor::Role::Domain::CompleteDomainProperties
 with TestFor::Role::Domain::DomainProperties {

    # VERSION:
    # ABSTRACT: All domain properties
    has receiving_dns_records => (
        is => 'ro',
        isa => ArrayRef,
        traits => [qw/Array/],
        default => sub { [] },
        predicate => 1,
        handles => {
            all_receiving_dns_records => 'elements',
        }
    );
    has sending_dns_records => (
        is => 'ro',
        isa => ArrayRef,
        traits => [qw/Array/],
        default => sub { [] },
        predicate => 1,
        handles => {
            all_sending_dns_records => 'elements',
        }
    );
}

1;
