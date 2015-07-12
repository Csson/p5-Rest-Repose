use 5.14.0;
use strict;
use warnings;

package Rest::Repose::Mopes::ReposeAttributeTrait {

    # VERSION:
    # ABSTRACT: ...

    use Moose::Role;
    use Types::Standard qw/Bool Str Maybe CodeRef/;
    use namespace::clean -except => 'meta';
    use MooseX::AttributeShortcuts;

    has optional => (
        is => 'rw',
        isa => Bool,
        default => 1,
    );
    has printable_asis => (
        is => 'rw',
        isa => Bool,
        default => 1,
    );
    has printable_method => (
        is => 'rw',
        isa => Bool,
        default => 0,
    );
    has real_name => (
        is => 'rw',
        isa => Str,
        predicate => 1,
    );
    has dpath => (
        is => 'ro',
        isa => Str,
    );
    has qs => (
        is => 'ro',
        isa => Bool,
        default => 0,
    );
    
    
    
    
    
#    has mailgun_hashable_method => (
#        is => 'ro',
#        isa => Bool,
#        predicate => 1,
#        default => 0,
#    );
#    has mailgun_hashable_string => (
#        is => 'ro',
#        isa => Bool,
#        predicate => 1,
#        default => 0,
#    );
#    has mailgun_hashable_with_prefix => (
#        is => 'ro',
#        isa => Str,
#        predicate => 1,
#    );
#
#    sub mailgun_hashable {
#        my $self = shift;
#        return $self->mailgun_hashable_method || $self->mailgun_hashable_string || 0;
#    }

    no Moose::Role;

}

1;
