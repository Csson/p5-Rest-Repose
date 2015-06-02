use Moops;
use strict;
use warnings;

# PODCLASSNAME
# VERSION
# ABSTRACT

library Types::RestRepose

declares
    ReposeRoleNames,
    ReposeUserAgent
{

    use Types::Standard qw/HashRef RoleName/;

    class_type ReposeUserAgent => { class => 'Rest::Repose::UserAgent' };

    declare ReposeRoleNames,
    as ArrayRef[RoleName],
    message { sprintf "Those are not RoleName's." };

    coerce ReposeRoleNames,
    from ArrayRef[Str],
    via { [ @$_ ] };

}

1;
