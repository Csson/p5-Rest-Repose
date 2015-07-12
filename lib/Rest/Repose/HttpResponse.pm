use Rest::Repose::Standard;
use strict;
use warnings;

# PODCLASSNAME

class Rest::Repose::HttpResponse using Moose {

    # VERSION:
    # ABSTRACT: .

    has headers => (
        is => 'ro',
        isa => HashRef,
        traits => [qw/Hash /],
        #printable_asis => 1,
    );
    has reason => (
        is => 'ro',
        isa => Str,
        required => 1,
       # traits => ['Repose'],
       # printable_asis => 1,
    );
    has status => (
        is => 'ro',
        isa => Int,
        required => 1,
       # traits => ['Repose'],
       # printable_asis => 1,
    );
    has success => (
        is => 'ro',
        isa => Bool,
        required => 1,
       # traits => ['Repose'],
       # printable_asis => 1,
    );
    has url => (
        is => 'ro',
        isa => Str,
       # traits => ['Repose'],
       # printable_asis => 1,
    );

}

1;
