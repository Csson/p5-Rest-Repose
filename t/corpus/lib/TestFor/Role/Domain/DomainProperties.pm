use MoopsX::UsingMoose;
use strict;
use warnings;

# PODCLASSNAME

 role TestFor::Role::Domain::DomainProperties {

    # VERSION:
    # ABSTRACT: Role for basic domain properties

    has created_at => (
        is => 'ro',
        isa => Any,
        predicate => 1,
    );
    has smtp_login => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has name => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has smtp_password => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has wildcard => (
        is => 'ro',
        isa => Bool,
        predicate => 1,
    );
    has spam_action => (
        is => 'ro',
        isa => Enum[qw/disabled tag/],
        predicate => 1,
    );
    # Should probably be enum, but incomplete list of possible values.
    has state => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
}

1;