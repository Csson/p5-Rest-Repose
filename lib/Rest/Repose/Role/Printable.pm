use 5.14.0;
use strict;
use warnings;
use MoopsX::UsingMoose;

# PODCLASSNAME

role Rest::Repose::Role::Printable {

    use List::UtilsBy 'extract_by';

    method printable(--> HashRef but assumed) {

        my @all_attributes = map { $self->meta->get_attribute($_) } $self->meta->get_attribute_list;
        my @printable_attributes = extract_by { $_->does('Repose') } @all_attributes;
        my @wanted_attributes = extract_by { my $predicate = sprintf 'has_%s', $_->name; !$_->optional || $self->$predicate } @printable_attributes;

        my $printable = {};

        ATTR:
        foreach my $attr (@wanted_attributes) {
            my $prefix = $attr->has_printable_prefix ? $attr->printable_prefix : '';

            if($attr->printable_asis) {
                my $predicate = sprintf 'has_%s', $attr->name;
                next ATTR if $attr->optional && !$self->$predicate;

                $printable->{ $prefix . $attr->name } = $attr->get_value($self);
                next ATTR;
            }
            elsif($attr->printable_method) {
                my $method = sprintf '%s_printable', $attr->name;
                $printable->{ $prefix . $attr->name } = $self->$method;
            }
        }
        return $printable;
    }



}

1;
