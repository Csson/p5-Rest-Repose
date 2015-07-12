package Rest::Repose::Mopes::RequestResponseKeywords;

use strict;
use warnings;

use Moo::Role;
use Module::Runtime qw/$module_name_rx/;

around _eat_package => sub {
    my $next = shift;
    my $self = shift;
    my ($rel) = shift;

    my $pkg = $self->keyword eq 'request'  ? 'Request'
            : $self->keyword eq 'response' ? 'Response'
            :                                $self->_eat(qr{(?:::)?$module_name_rx});
            ;

    return $self->qualify_module_name($pkg, $rel);
};

after parse => sub {
    my $self = shift;

    if($self->keyword eq 'request') {
        push @{ $self->relations->{'with'} ||= [] } => (
            'Rest::Repose::Role::Request',
        );
    }
    elsif($self->keyword eq 'response') {
        push @{ $self->relations->{'with'} ||= [] } => (
            'Rest::Repose::Role::Response',
        );
    }
};

around keywords => sub {
    my $next = shift;
    my $self = shift;

    return ($self->$next(@_), qw/resource purpose request response/);
};

around class_for_keyword => sub {
    my $next = shift;
    my $self = shift;

    if($self->keyword eq 'resource'
        || $self->keyword eq 'purpose'
        || $self->keyword eq 'request'
        || $self->keyword eq 'response')
    {
        require Moops::Keyword::Class;
        return 'Moops::Keyword::Class';
    }
    return $self->$next(@_);
};

1;
