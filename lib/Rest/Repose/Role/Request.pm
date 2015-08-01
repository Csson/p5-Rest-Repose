use 5.14.0;
use MoopsX::UsingMoose;
use strict;
use warnings;

# VERSION
# PODCLASSNAME
# ABSTRACT: ..

role Rest::Repose::Role::Request
with Rest::Repose::Role::Printable {

    use LWP::UserAgent;
    use HTTP::Request::Common;
    use JSON::MaybeXS 'decode_json';
    use List::UtilsBy 'extract_by';
    use Data::Dump::Streamer;
    use URL::Encode 'url_encode';

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

    has url => (
        is => 'ro',
        isa => Str,
        init_arg => undef,
        lazy => 1,
        default => sub { shift->repose_destination },
    );

    method make_request {
        my $response_class = ref $self;
        $response_class =~ s{Request$}{Response};

        my $done = $self->_do;

        my $response = $response_class->new(repose_raw_response => $done->{'content'},
                                            repose_request => $self,
                                            repose_response => $done->{'response'}
                                        );

        return $response;
    }

    sub _do {
        my $self = shift;

        my $method = $self->repose_http_method;
        my $url = $self->_repose_url;

        my $printable = $self->meta->has_method('printable_body') ? $self->printable_body : $self->_printable;

        my $response = $method eq 'get'    ? $self->_uaget($url)
                     : $method eq 'post'   ? $self->_uapost($url, $printable)
                     : $method eq 'delete' ? $self->_uadelete($url)
                     : $method eq 'put'    ? $self->_uaput($url, $printable)
                     :                       undef
                     ;

        my $decoded_json = {};
        try {
            $decoded_json = $self->_undash(decode_json $response->content);
        }
        catch {
            $decoded_json = {};
        };

        return {
            content => $decoded_json,
            response => $response,
        };

    }

    method _undash($struct, $level = 1) {

        if(ref $struct eq 'ARRAY') {
            my $newstruct = [];
            foreach my $value (@$struct) {
                push @$newstruct => $self->_undash($value);
            }
            $struct = $newstruct;
        }
        elsif(ref $struct eq 'HASH') {
            my @keys = keys %$struct;

            foreach my $key (@keys) {
                my $value = $struct->{ $key };
                my $newkey = $key;
                $newkey =~ s{-}{_}g;

                $struct->{ $newkey } = $self->_undash($value, $level + 1);

                if($newkey ne $key) {
                    delete $struct->{ $key };
                }
            }
        }

        return $struct;
    }

    method _repose_url {
        my $url = $self->url;

        my @all_attributes = map { $self->meta->get_attribute($_) } $self->meta->get_attribute_list;
        my @repose_attributes = extract_by { $_->does('Repose') } @all_attributes;
        my @qs_attributes = sort { $a->name cmp $b->name } grep { $_->qs } @repose_attributes;

        my $qs_string = join '&' => map {
                                        my $attr = $_;
                                        my $attr_name = $attr->name;
                                        my $method = $attr_name.'_printable';
                                        my $predicate = "has_$attr_name";

                                        if($attr->printable_asis && $self->$predicate) {
                                            List::AllUtils::pairmap { join '=' => $a, url_encode($b) } ($attr_name, $self->$attr_name);
                                        }
                                        elsif($attr->printable_method) {
                                            List::AllUtils::pairmap { join '=' => $a, url_encode($b) } $self->$method;
                                        }
                                        else {
                                            ();
                                        }
        } @qs_attributes;
        $url .= '?' . $qs_string if defined $qs_string;

        return $url;
    }

    sub _uaget {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};
        my $options = { content => $contents };

        my $result = $self->ua->get($url, $options);
        return $result;
    }

    sub _uadelete {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};
        my $options = { content => $contents };

        my $result = $self->ua->delete($url, $options);
        return $result;
    }

    sub _uapost {
        my $self = shift;
        my $url = shift;
        my $contents = shift;

#warn '>>' . $contents->[0] . '<<';
#$contents = $contents->[0];

        my $request = POST($url, Content_Type => $self->repose_content_type, Content => $contents);
        my $result = $self->ua->request($request);

        return $result;
    }
    sub _uaput {
        my $self = shift;
        my $url = shift;
        my $contents = shift || {};

        # A song and dance to PUT content...
        my $request = POST($url, Content => $contents);
        $request->method('PUT');
        my $result = $self->ua->request($request);

        return $result;
    }
}

1;

__END__




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

    #method transform_response_to_args($class: ConsumerOf['Mail::Mailgun::Role::Call'] $call, HashRef $args --> HashRef but assumed) {
    sub transform_response_to_args {
        my $self = shift;
        my $args = shift;

        my $new_args = delete $args->{'content'};
        $new_args->{'mailgun'} = $self->mailgun;
        $new_args->{'response'} = $args->{'response'};
        $new_args->{'call'} = $self;

        return $new_args;
    }
};

1;
