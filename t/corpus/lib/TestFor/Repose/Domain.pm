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

            prop thing => (
                isa => Bool,
                optional => 1,
            );
            prop receiving_dns_records => (
                isa => Bool,
                optional => 1,
            );
            prop sending_dns_records => (
                isa => Bool,
                optional => 1,
            );
        }
    }
}

1;
