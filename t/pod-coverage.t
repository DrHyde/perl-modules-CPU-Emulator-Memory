# $Id: pod-coverage.t,v 1.1 2008/02/28 20:40:13 drhyde Exp $
use strict;

$^W=1;

use Test::More;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
all_pod_coverage_ok();
