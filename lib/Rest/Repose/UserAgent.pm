use Rest::Repose::Standard;

# PODCLASSNAME

class Rest::Repose::UserAgent using Moose {

    # VERSION:
    # ABSTRACT: User agent for Rest::Repose

    use LWP::UserAgent;

    has base_url => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has useragent => (
        is => 'ro',
        isa => InstanceOf['LWP::UserAgent'],
        default => sub { LWP::UserAgent->new },
    );
}
