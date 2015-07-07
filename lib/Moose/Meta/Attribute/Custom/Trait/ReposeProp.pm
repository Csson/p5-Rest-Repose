use 5.14.0;
use strict;
use warnings;

package Moose::Meta::Attribute::Custom::Trait::ReposeProp {

    # VERSION:
    # ABSTRACT: Special attributes for Rest::Repose

    sub register_implementation {
        return 'Rest::Repose::Mopes::ReposePropAttributeTrait';
    }

}

1;
