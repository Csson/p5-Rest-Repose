use 5.14.0;
use strict;
use warnings;

package TestFor::RequestRole;

use Moose::Role;
use Types::Standard -types;

has domain => (
    is => 'ro',
    isa => Str,
    default => 'www.example.com',
);
has base_url => (
    is => 'ro',
    isa => Str,
    required => 1,
);


1;
