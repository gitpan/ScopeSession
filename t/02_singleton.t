#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
use Scalar::Util qw/refaddr/;
BEGIN{
    use_ok('ScopeSession');
    use_ok('ScopeSession::Singleton');
}

{
    package Test;
    use base 'ScopeSession::Singleton';
    use base 'Class::Accessor::Fast';
    __PACKAGE__->mk_accessors(qw/hoge fuga/);
}

my $p_instance;
ScopeSession::start {
    my $test_instance = Test->instance;

    ::ok $test_instance ,q|create instance|;

    $test_instance->hoge(q|hello|);
    $test_instance->fuga(q|fuga|);

    ::is 
        refaddr( $test_instance) ,
        refaddr( Test->instance ),
        q|is same instance| ;

    $p_instance = refaddr( $test_instance );
};

ScopeSession::start{
    ::isnt
        refaddr(Test->instance),
        $p_instance,
        q|not same instance|;
};
