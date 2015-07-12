use 5.14.0;
use strict;
use warnings;

# VERSION

package #
    Rest::Repose::Standard {

    use base 'MoopsX::UsingMoose';
    use List::AllUtils();
    use MooseX::AttributeDocumented();
    use MooseX::AttributeShortcuts();
    use Types::Standard();
    use Types::RestRepose();
    use Data::Dump::Streamer();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::AllUtils'    => [qw/any none sum uniq/],
            'MooseX::AttributeDocumented' => [],
            'MooseX::AttributeShortcuts' => [],
            'Types::Standard' => [{ replace => 1 }, '-types'],
            'Types::RestRepose' => [{ replace => 1 }, '-types'],
            'Data::Dump::Streamer' => ['Dump'],
        );

        $class->SUPER::import(%opts);
    }
}

1;
