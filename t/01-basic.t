use strict;
use warnings;

use Test::More;
use Test::Moose;
use Path::Tiny;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

BEGIN {
	use_ok 'Rest::Repose';
}

use lib path(qw/t corpus lib/)->absolute->stringify;

use TestFor::Repose::Domain;

my $request = TestFor::Repose::Domain::Add::Request->new(name => 'example.com', smtp_password => 'exAmple', base_url => 'https://base.example.org/api');

isa_ok $request, 'TestFor::Repose::Domain::Add::Request';

is $request->repose_http_method, 'post', 'Class has correct http method';

is $request->repose_destination, 'https://base.example.org/api/domains', 'Correct destination';

is $request->name, 'example.com', 'Correct name';

my $response = $request->make_request;

isa_ok $response, 'TestFor::Repose::Domain::Add::Response';

does_ok $response, 'TestFor::Role::Domain::CompleteDomainProperties', 'The response does the correct role';





#is $request->make_request->smtp_password, 'yes its done', 'Response has correct password';

#is $request->_printable->{'smtp_password'}, 'exAmple', 'Request has correct password after being printified.';

#is $response->does('Rest::Repose::Role::ResponseHandler'), 1, 'Response does ResponseHandler';
#
#is_deeply $response->handle_response(q|{ "tag" : "you're it" }|), { tag => q{you're it} }, 'Correctly parsed json response';

done_testing;
