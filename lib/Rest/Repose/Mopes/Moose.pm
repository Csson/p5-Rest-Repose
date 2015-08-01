use 5.14.0;
use strict;
use warnings;

package Rest::Repose::Mopes::Moose;

use Moose::Exporter;
use Types::Standard -types;
use PerlX::Maybe 'maybe';
use Data::Dump::Streamer;
use Data::DPath 'dpath';
use Moose::Meta::Role;
use Carp;

Moose::Exporter->setup_import_methods(
    with_meta => [qw/get put post http_delete param prop body/],
    class => {
        meta_roles => ['Rest::Repose::Mopes::ReposeAttributeTrait'],
    },
);

sub param {
    my $meta = shift;
    my $param_name = shift;
    my $settings = { @_ };
    my $isa = delete $settings->{'isa'};

    my $attr = {
        is => 'ro',
        maybe isa => $isa,
        maybe coerce => delete $settings->{'coerce'},
        maybe default => delete $settings->{'default'},
        maybe printable_prefix => delete $settings->{'printable_prefix'},
        maybe printable_asis => delete $settings->{'printable_asis'},
        maybe lazy => delete $settings->{'lazy'},
        maybe qs => delete $settings->{'qs'},
        required => delete $settings->{'optional'} ? 0 : 1,
        predicate => 1,
    };

    if(exists $settings->{'printable_method'}) {

        if(CodeRef->check($settings->{'printable_method'})) {
            $meta->add_method($param_name.'_printable' => $settings->{'printable_method'});
            $settings->{'printable_method'} = 1;
        }
        $attr->{'printable_method'} = delete $settings->{'printable_method'};
        $attr->{'printable_asis'} = !$attr->{'printable_method'};
    }
    elsif(exists $settings->{'printable_asis'}) {
        $attr->{'printable_method'} = 0;
        $attr->{'printable_asis'} = !$attr->{'printable_asis'};
    }
    else {
        $attr->{'printable_method'} = 0;
        $attr->{'printable_asis'} = 1;
    }

    ($attr, $settings) = set_attribute_traits($meta, $param_name, $isa, ['Repose'], $settings, $attr);

    if(scalar keys %$settings) {
        carp sprintf q{The following attributes (in %s, param '%s') has no meaning: %s}, $meta->name, $param_name, join ', ' => sort keys %$settings;
    }

    $meta->add_attribute($param_name, %$attr);
}

sub prop {
    my $meta = shift;
    my $prop_name = shift;
    my $settings = { @_ };
    my $raw_response = $meta->get_attribute('repose_raw_response');

    my $isa = delete $settings->{'isa'};

    my $attr = {
        is => 'ro',
        lazy => 1,
        isa => Str,
        required => delete $settings->{'optional'} ? 0 : 1,
        prop_name => $prop_name,
        predicate => 1,
    };

    $attr->{'default'} = delete $settings->{'dpath'} || "/$prop_name";

    ($attr, $settings) = set_attribute_traits($meta, $prop_name, Str, ['ReposeProp'], $settings, $attr);

    my $path_name = sprintf 'repose_dpath_%s' => $prop_name;
    my $prop_isa = delete $settings->{'isa'} || Str;
    $meta->add_attribute($path_name, %$attr);

    if($isa->is_subtype_of(ArrayRef)) {
        $meta->add_attribute(
            $prop_name => (
                is => 'rw',
                isa => $isa,
                coerce => 1,
                default => sub { [] },
                traits => ['Array'],
                handles => {
                    "all_$prop_name" => 'elements',
                    "get_$prop_name" => 'get',
                    "count_$prop_name" => 'count',
                    "filter_$prop_name" => 'grep',
                    "map_$prop_name" => 'map',
                    "find_$prop_name" => 'first',
                },
            )
        );
    }
    elsif($isa->is_subtype_of(HashRef)) {
         $meta->add_attribute(
            $prop_name => (
                is => 'rw',
                isa => $isa,
                coerce => 1,
                default => sub { {} },
                traits => ['Hash'],
                handles => {
                    "all_$prop_name" => 'elements',
                    "get_$prop_name" => 'get',
                    "count_$prop_name" => 'count',
                },
            )
        );
    }
    else {
        $meta->add_attribute(
            $prop_name => (
                is => 'ro',
                isa => $isa,
          maybe coerce => delete $settings->{'coerce'},
                predicate => 1,
                lazy => 1,
                default => sub {
                    my $self = shift;
                    my @result = dpath($self->$path_name)->match($self->repose_raw_response);
                    return shift @result;
                },
            )
        );
    }

    if(scalar keys %$settings) {
        carp sprintf q{The following attributes (in %s, prop '%s') has no meaning: %s}, $meta->name, $prop_name, join ', ' => sort keys %$settings;
    }
#    else {
#        $meta->add_method($prop_name => sub {
#            my $self = shift;
#
#            my @result = dpath($self->$path_name)->match($self->repose_raw_response);
#            return shift @result;
#        });
#    }

}

sub set_attribute_traits {
    my $meta = shift;
    my $param_name = shift;
    my $isa = shift;
    my $traits = shift;
    my $settings = shift;
    my $attr = shift;

    if(exists $settings->{'traits'}) {
        if(ArrayRef->check($settings->{'traits'})) {
            push @$traits => @{ delete $settings->{'traits'} };
        }
        else {
            confess sprintf q{param attribute 'trait' takes an ArrayRef, in %s, param '%s'}, $meta->name, $param_name;
        }
    }

    if($isa->is_subtype_of(ArrayRef) || $isa == ArrayRef) {
        push @$traits => 'Array';

        if(!exists $attr->{'default'}) {
            $attr->{'default'} = sub { [] };
        }

        $attr->{'handles'} = exists $settings->{'handles'} ? delete $settings->{'handles'} : make_array_handles($param_name);
    }
    elsif($isa->is_subtype_of(HashRef) || $isa == HashRef) {
        push @$traits => 'Hash';

        if(!exists $attr->{'default'}) {
            $attr->{'default'} = sub { { } };
        }

        $attr->{'handles'} = exists $settings->{'handles'} ? delete $settings->{'handles'} : make_hash_handles($param_name);
    }
    $attr->{'traits'} = $traits;

    return ($attr, $settings);
}

sub make_array_handles {
    my $param_name = shift;

    return {
        "all_$param_name" => 'elements',
        "join_$param_name" => 'join',
        "get_$param_name" => 'get',
        "count_$param_name" => 'count',
    }
}
sub make_hash_handles {
    my $param_name = shift;

    return {
        "kv_$param_name" => 'kv',
    };
}

sub modify_response {
    my $meta = shift;
    my $method = shift;

    $meta->add_method('modify_response', $method);
}

sub body {
    my $meta = shift;
    my $body_sub = shift;

    $meta->add_method(printable_body => $body_sub);
}

sub get {
    my $meta = shift;
    my $destination = shift;

    prepare_http_method($meta, 'get', $destination);
}
sub put {
    my $meta = shift;
    my $destination = shift;

    prepare_http_method($meta, 'put', $destination);
}
sub post {
    my $meta = shift;
    my $destination = shift;
    my $content_type = shift || 'form-data';

    $meta->add_attribute(repose_content_type => (
        is => 'ro',
        isa => 'Str',
        default => $content_type,
    ));

    prepare_http_method($meta, 'post', $destination);
}
sub http_delete {
    my $meta = shift;
    my $destination = shift;

    prepare_http_method($meta, 'delete', $destination);
}

sub prepare_http_method {
    my $meta = shift;
    my $method = shift;
    my $destination = shift;

    if($meta->get_attribute('repose_http_method')) {
        confess sprintf q{You are setting the http method more than once. Use only one of get, put, post and delete in %s}, $meta->name;
    }

    $meta->add_attribute(repose_http_method => (
        is => 'ro',
        isa => Str,
        required => 1,
        predicate => 1,
        default => $method,
    ));
    $meta->add_attribute(repose_destination => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        builder => 1,
    ));
    $meta->add_method(_build_repose_destination => sub {
        my $self = shift;
        my @destination_parts = split m{/} => $destination;

        my $destination = [];
        foreach my $part (@destination_parts) {
            if($part =~ m{^:(\w+)$}) {
                my $method = $1;
                push @$destination => $self->$method;
            }
            else {
                push @$destination => $part;
            }
        }
        return join '/' => ($self->base_url, @$destination);
        
    });
}

1;
