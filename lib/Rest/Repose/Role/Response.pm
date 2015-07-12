use 5.14.0;
use strict;
use warnings;

use Rest::Repose::Standard;

# VERSION
# PODCLASSNAME
# ABSTRACT: ..

role Rest::Repose::Role::Response
with Rest::Repose::Role::Printable {

    use Data::DPath 'dpath';
    use PerlX::Maybe 'maybe';
    use List::UtilsBy 'extract_by';

    has repose_raw_response => (
        is => 'ro',
        isa => HashRef,
        required => 1,
    );
    has repose_request => (
        is => 'ro',
        isa => ConsumerOf['Rest::Repose::Role::Request'],
        required => 1,
    );
    has repose_response => (
        is => 'ro',
        isa => HttpResponse,
        coerce => 1,
        required => 1,
    );


    method BUILD {
        my @all_attributes = map { $self->meta->get_attribute($_) } $self->meta->get_attribute_list;
        warn 'all attributes: ' . join ', ' => map { $_->name } @all_attributes;
        my @structure_attributes = extract_by { $_->does('Array') || $_->does('Hash') } @all_attributes;
        warn 'all structured: ' . join ', ' => map { $_->name } @structure_attributes;

        foreach my $attr (@structure_attributes) {
            my $attr_name = $attr->name;
            my $path_name = sprintf 'repose_dpath_%s', $attr_name;

            my $result = (dpath($self->$path_name)->match($self->repose_raw_response))[0];
warn 'BUILDING: ' . $attr_name;
            try {
                $self->$attr_name($result);
            }
            catch {
                warn 'FAILED ' . $attr_name.': '.$_;
            };
        }

    }
}

1;
