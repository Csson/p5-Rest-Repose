use Moops;
use strict;
use warnings;

# PODCLASSNAME
# VERSION
# ABSTRACT

library Types::RestRepose

declares
    ReposeRoleNames,
    ReposeUserAgent,

    HttpResponse,
    ActualHttpResponse
{

    use Types::Standard qw/HashRef RoleName/;

    class_type ReposeUserAgent => { class => 'Rest::Repose::UserAgent' };
    class_type ActualHttpResponse => { class => 'HTTP::Response' };
    class_type HttpResponse => { class => 'Rest::Repose::HttpResponse' };


    coerce HttpResponse,
    from ActualHttpResponse,
    via {
        my $actual = $_;

        'Rest::Repose::HttpResponse'->new(
            reason => $actual->message,
            status => $actual->code,
            success => $actual->is_success,
            headers => { map { lc $_ => $actual->header($_) } $actual->header_field_names },
        );
    };

    declare ReposeRoleNames,
    as ArrayRef[RoleName],
    message { sprintf "Those are not RoleName's." };

    coerce ReposeRoleNames,
    from ArrayRef[Str],
    via { [ @$_ ] };

}

1;
