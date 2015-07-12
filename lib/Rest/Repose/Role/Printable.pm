use 5.14.0;
use strict;
use warnings;
use MoopsX::UsingMoose;

# PODCLASSNAME

role Rest::Repose::Role::Printable {

    use List::UtilsBy 'extract_by';

    method _printable(--> ArrayRef but assumed) {

        my @all_attributes = map { $self->meta->get_attribute($_) } $self->meta->get_attribute_list;
        my @printable_attributes = extract_by { $_->does('Repose') } @all_attributes;
        my @wanted_attributes = extract_by { my $predicate = sprintf 'has_%s', $_->name; !$_->optional || $self->$predicate } @printable_attributes;

        my $printable = [];

        ATTR:
        foreach my $attr (@wanted_attributes) {
            my $real_attr_name = $attr->has_real_name ? $attr->real_name : $attr->name;

            if($attr->printable_asis) {
                my $predicate = sprintf 'has_%s', $attr->name;
                next ATTR if $attr->optional && !$self->$predicate;

                push @$printable => ($real_attr_name => $attr->get_value($self));
            }
            elsif($attr->printable_method) {
                my $method = sprintf '%s_printable', $attr->name;
                push @$printable => $self->$method;
            }
        }
        return $printable;
    }



}

1;
