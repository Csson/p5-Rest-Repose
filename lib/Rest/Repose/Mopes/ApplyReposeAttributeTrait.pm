use 5.14.0;
use strict;
use warnings;

package Rest::Repose::Mopes::ApplyReposeAttributeTrait {

    # VERSION
    # ABSTRACT: ..

    use Moose;
    use Moose::Exporter;

    Moose::Exporter->setup_import_methods(
        class_metaroles => {
            attribute => ['Rest::Repose::Mopes::ReposeAttributeTrait'],
        }
    );

}

1;
