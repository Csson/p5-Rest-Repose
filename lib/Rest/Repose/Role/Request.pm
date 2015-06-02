use 5.14.0;
use MoopsX::UsingMoose;
use strict;
use warnings;

role Rest::Repose::Role::Request
with Rest::Repose::Role::Printable {

    use LWP::UserAgent;

    has base_url => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has ua => (
        is => 'ro',
        isa => InstanceOf['LWP::UserAgent'],
        default => sub { LWP::UserAgent->new },
    );

    method make_request {
        my $response_class = $self->get_response_class_name;
        my $response = $response_class->new(smtp_password => 'yes its done');

        return $response;
    }

    method get_response_class_name {
        my $class = $self->meta->name;
        $class =~ s{::(?:[^:]+)$}{};
        $class .= '::Response';
        return $class;
    }
}

1;
