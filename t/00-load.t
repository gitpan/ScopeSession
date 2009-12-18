#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'ScopeSession' ) || print "Bail out!
";
}

diag( "Testing ScopeSession $ScopeSession::VERSION, Perl $], $^X" );
