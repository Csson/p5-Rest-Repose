use 5.14.0;
use strict;
use warnings;

package Rest::Repose::Mopes::Moose;

use Moose::Exporter;
use Types::Standard -types;
use PerlX::Maybe 'maybe';
use Data::Dump::Streamer;
use Moose::Meta::Role;
use Carp;

Moose::Exporter->setup_import_methods(
    with_meta => [qw/get put post delete param/],
    class => {
        meta_roles => ['Rest::Repose::Mopes::ReposeAttributeTrait'],
    },
);

sub param {
    my $meta = shift;
    my $param_name = shift;
    my %settings = @_;

    my $isa = delete $settings{'isa'};

    my %attr = (
        is => 'ro',
        isa => $isa,
        predicate => 1,
    );

    if(exists $settings{'optional'}) {
        $attr{'required'} = delete $settings{'optional'} ? 0 : 1;
    }

    if(exists $settings{'printable_method'}) {
        $attr{'printable_method'} = delete $settings{'printable_method'};
        $attr{'printable_asis'} = !$attr{'printable_method'};
    }
    if(exists $settings{'printable_prefix'}) {
        $attr{'printable_prefix'} = delete $settings{'printable_prefix'};
    }

    if(exists $settings{'default'}) {
        $attr{'default'} = delete $settings{'default'};
    }

    TRAITS: {
        my $traits = ['Repose'];
    
        if(exists $settings{'traits'}) {
            if(ArrayRef->check($settings{'traits'})) {
                push @$traits => @{ delete $settings{'traits'} };
            }
            else {
                confess sprintf q{param attribute 'trait' takes an ArrayRef, in %s, param '%s'}, $meta->name, $param_name;
            }
        }
        if(ArrayRef->check($isa)) {
            push @$traits => 'Array';
        }
        elsif(HashRef->check($isa)) {
            push @$traits => 'Hash';
        }
        $attr{'traits'} = $traits;
    }

    if(scalar keys %settings) {
        carp sprintf q{The following attributes (in %s, param '%s') has no meaning: %s}, $meta->name, $param_name, join ', ' => sort keys %settings;
    }

    $meta->add_attribute($param_name, %attr);
}

sub modify_response {
    my $meta = shift;
    my $method = shift;

    $meta->add_method('modify_response', $method);
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

    prepare_http_method($meta, 'post', $destination);
}
sub delete {
    my $meta = shift;
    my $destination = shift;

    prepare_http_method($meta, 'delete', $destination);
}

sub prepare_http_method {
    my $meta = shift;
    my $method = shift;
    my $destination = shift;

    if($meta->get_attribute('http_method')) {
        confess sprintf q{You are setting the http method more than once. Use only one of get, put, post and delete in %s}, $meta->name;
    }

    $meta->add_attribute(http_method => (
        is => 'ro',
        isa => Str,
        required => 1,
        predicate => 1,
        default => $method,
    ));
    $meta->add_attribute(destination => (
        is => 'ro',
        isa => Str,
        lazy => 1,
        builder => 1,
    ));
    $meta->add_method(_build_destination => sub {
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
        return $self->base_url . join '/' => @$destination;
        
    });
}

1;
