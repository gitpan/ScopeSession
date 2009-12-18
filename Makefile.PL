use inc::Module::Install;

name     'ScopeSession';
all_from 'lib/ScopeSession.pm';
author   q{Daichi Hiroki <hirokidaichi<AT>gmail.com>};
license  'perl';
for(qw/
    Test::More
    Test::Exception
/){
    test_requires $_;
}
for(qw/
    Error::Simple
    Scalar::Util
    Carp
/){
    requires $_
}
auto_install;

WriteAll;

