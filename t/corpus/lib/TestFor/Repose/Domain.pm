package TestFor::Repose;

use 5.14.0;
use strict;
use warnings;

use Rest::Repose;

resource Domain {

    purpose Add {

        request {

            post 'domains';

            param name => (
                isa => Str,
            );
            param smtp_password => (
                isa => Str,
            );
            param spam_action => (
                isa => Enum[qw/tag enabled/],
                optional => 1,
            );
            param wildcard => (
                isa => Bool,
                optional => 1,
            );
        }
        response {

            with 'TestFor::Role::Domain::CompleteDomainProperties';

            param thing => (
                isa => Bool,
                optional => 1,
            );
        }
    }
}

1;
