package ScopeSession::Flyweight;

use warnings;
use strict;

our $VERSION = '0.01';

use Carp qw/croak/;
use Scalar::Util qw/blessed/;
use base qw/ScopeSession::Singleton/;

sub import{
    my ($class,%args ) = @_;
    my ($caller)      = caller 0;
    if( $args{'acquire'} and $caller ne 'main'){
        no strict 'refs';
        push @{"$caller\::ISA"}, 'ScopeSession::Flyweight::_Base';
    }
    $class->SUPER::import;
}

{
    package ScopeSession::Flyweight::_Base;
    sub acquire{
        my ($class,@args) = @_;
        return ScopeSession::Flyweight->acquire( $class => @args );
    }
}
sub acquire {
    my $self = ( blessed $_[0] ) ? shift : shift->instance;
    my ( $target_class, @args ) = @_;
    my $key = _compose_key( $target_class, $target_class->identifier(@args) );
    if ( defined( my $ret = $self->_get_stash($key) ) ) {
        return $ret;
    }
    else {
        my $object = $target_class->new(@args);
        $self->_set_stash( $key => $object );
    }
}

sub _get_stash {
    my ( $self, $key ) = @_;
    return $self->{$key} ;
}

sub _set_stash {
    my ( $self, $key , $obj) = @_;
    $self->{$key} = $obj;
}

sub _compose_key {
    my ( $target_class, $instance_identifier ) = @_;
    Crap::croak( 'no identifier') unless $instance_identifier;
    return sprintf( 'scope-session-flyweight:%s#%s', $target_class, $instance_identifier );
}
1; # End of ScopeSession::Flyweight

__END__

=head1 NAME

ScopeSession::Flyweight - Attach light-weight instance creation for ScopeSession

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

work as factory

    use ScopeSession::Flyweight;
    my $flyweight
        = ScopeSession::Flyweight->acquire( q|Test::Object| => ( id => 10 ) );
    my $flyweight2
        = ScopeSession::Flyweight->acquire( q|Test::Object| => ( id => 10 ) );


work as role

    package Test::Object;
    use ScopeSession::Flyweight acquire => 1;
    sub identifier {
        my ( $class, %args ) = @_;
        return $args{id};
    }
    sub new {
        my ( $class, %args ) = @_;
        return bless {%args} => $class;
    }
    my $flyweight  = Test::Object->acquire( id => 10 );
    my $flyweight2 = Test::Object->acquire( id => 10 );

=head1 METHODS

=head2 acquire

get a same identifier instance

=cut


=head1 AUTHOR

Daichi Hiroki, C<< <hirokidaichi<AT>gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-scopesession at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ScopeSession>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ScopeSession::Flyweight


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ScopeSession>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ScopeSession>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ScopeSession>

=item * Search CPAN

L<http://search.cpan.org/dist/ScopeSession/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2009 Daichi Hiroki.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


