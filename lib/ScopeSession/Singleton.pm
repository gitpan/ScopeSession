package ScopeSession::Singleton;
use strict;
use warnings;


our $VERSION = '0.01';
use ScopeSession;

use constant FORMAT_OF_POOL_KEY => q|scope-session-singleton:%s|;

sub instance {
    my $class    = shift;
    my $instance = $class->_get_instance;
    unless ( defined $instance ) {
        $instance = $class->_new_instance(@_);
        $class->_set_instance($instance);
    }
    return $instance;
}

sub _new_instance {
    bless {}, shift;
}

sub _get_instance {
    my $class = shift;
    ScopeSession->notes->get( sprintf( $class->FORMAT_OF_POOL_KEY, $class ) );
}

sub _set_instance {
    my ( $class, $instance ) = @_;
    ScopeSession->notes->set(
        sprintf( $class->FORMAT_OF_POOL_KEY, $class ) => $instance );
}

1;
__END__
=head1 NAME

ScopeSession::Singleton - Singleton class for ScopeSession

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

ScopeSession::Singleton works the same as Class::Singleton or Apache::Singleton, but with scope base lifetime.

    package Something::UniqueInSession;
    use base 'ScopeSession::Singleton';

    ScopeSession::start {
        my $foo = Something::UniqueInSession->instance;
    };

=head1 METHODS

=head2 instance

get the scope unique instance of subclass.

=cut

=head1 SEE ALSO

L<Class::Singleton> ,L<Apache::Singleton>


=head1 AUTHOR

Daichi Hiroki, C<< <hirokidaichi<AT>gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2009 Daichi Hiroki.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

