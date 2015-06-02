use 5.14.0;
use strict;
use warnings;

package Mail::Mailgun::Role::Call;

use List::UtilsBy 'extract_by';
use MooseX::Role::Parameterized;
use PerlX::Maybe 'maybe';
use Types::TypeTiny qw/TypeTiny/;
use Types::Standard -types;
use Types::RestRepose -types;
use HTTP::Request::Common;
use Data::Dump::Streamer;

parameter create_class => (
    isa => Str,
    required => 1,
);
parameter modify_args => (
    isa => Bool,
    default => 0,
);

role Rest::Repose::Role::Call using Moose {

    with 'Rest::Repose::Role::Printable';

    requires qw/repose_endpoint/;

    has ua => (
        is => 'ro',
        isa => ReposeUserAgent,
        required => 1,
    );
    has url => (
        is => 'ro',
        isa => Any,
        builder => 1,
    );

    method _build_url {

        my $url = $self->ua->base_url;

        $url .= $url !~ m{/$} ? '/' : '';
        $url .= join '/' => $self->endpoint_url;

        my $qs = $self->qs;

        if(defined $qs && scalar keys %$qs) {
            my $qs_string = join '&' => map { "$_=$qs->{ $_ }" } keys %$qs;
            $url .= '?' . $qs_string if defined $qs_string;
        }

        return $url;
    }

    method make_call => sub {
        my $self = shift;

        my $full_response = $self->do;
        my $new_args = $self->transform_response_to_args($full_response);

        if($p->modify_args) {
            $new_args = $self->args_modifier($new_args);
        }

        my $create_class = $p->create_class;
        return $create_class->new(%$new_args);

    };

    sub transform_response_to_args {
        my $self = shift;
        my $args = shift;

        my $new_args = delete $args->{'content'};

        # I don't think the response needs this?
        #$new_args->{'mailgun'} = $self->mailgun;

        $new_args->{'response'} = $args->{'response'};
        $new_args->{'call'} = $self;

        return $new_args;
    }

    sub do {
        my $self = shift;

        my $method = $self->method;

        my $response = $method eq 'get'    ? $self->uaget($self->url)
                     : $method eq 'post'   ? $self->uapost($self->url, $self->to_hash)
                     : $method eq 'delete' ? $self->uadelete($self->url)
                     : $method eq 'put'    ? $self->uaput($self->url, $self->to_hash)
                     :                       undef
                     ;

        return { content => decode_json($response->decoded_content ),
                 response => $response,
        };

    }

    sub uaget {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};
        my $options = { content => $contents };

        my $result = $self->mailgun->ua->get($url, $options);
        return $result;
    }

    sub uadelete {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};
        my $options = { content => $contents };

        my $result = $self->mailgun->ua->delete($url, $options);
        return $result;
    }

    sub uapost {
        my $self = shift;
        my $url = shift;
        my $contents = shift;

        my $request = POST($url, Content_Type => 'form-data', Content => $contents);
        my $result = $self->mailgun->ua->request($request);

        return $result;
    }
    sub uaput {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};

        # A song and dance to PUT content...
        my $request = POST($url, Content => $contents);
        $request->method('PUT');
        my $result = $self->mailgun->ua->request($request);

        return $result;
    }

};

1;
