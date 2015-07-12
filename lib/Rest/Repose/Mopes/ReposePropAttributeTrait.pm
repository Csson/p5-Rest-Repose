use 5.14.0;
use strict;
use warnings;

package Rest::Repose::Mopes::ReposePropAttributeTrait {

    # VERSION:
    # ABSTRACT: ...

    use Moose::Role;
    use Types::Standard qw/Bool Str Maybe CodeRef/;
    use namespace::clean -except => 'meta';
    use MooseX::AttributeShortcuts;

    has prop_name => (
        is => 'ro',
        isa => Str,
        required => 1,
    );

    no Moose::Role;

}

1;
