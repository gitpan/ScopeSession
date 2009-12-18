package ScopeSession;
use strict;
use warnings;
use Error qw/:try/;
use Carp qw/croak/;
{
    package ScopeSession::Notes;
    our $DATA_STORE = {};
    sub get_instance { bless {} => shift; }
    sub set { $DATA_STORE->{ $_[1] } = $_[2];}
    sub get { $DATA_STORE->{ $_[1] };}
    sub exists { exists $DATA_STORE->{ $_[1] };}
}
our $VERSION = q{0.01};
our $_INSTANCE      = undef;
our $_IS_IN_SESSION = 0;

sub get_instance {
    my ($class)      = @_;
    unless( $_INSTANCE ){
        $_INSTANCE = $class->_new_instance;
    }
    return $_INSTANCE;
}

sub _new_instance{
    my ($class) = @_;
    return bless {},$class;
}
sub _on_error {
    my ( $self, $error ) = @_;
    my @handlers = map { $_->{handler} }
        grep { $error->isa( $_->{target} ) } @{ $self->_handlers };

    if ( scalar @handlers > 0 ) {
        $_->($error) for @handlers;
    }
    else {
        croak $error;
    }
}

sub _handlers {
    my $self = shift;
    $self->{_handlers} = [] unless $self->{_handlers};
    return $self->{_handlers};
}

sub add_error_handler{
    my ($self,$target,$handler) = @_;
    push @{ $self->_handlers },{
        target  => '' . $target,
        handler => $handler,
    };
}

sub is_started {
    return ($_IS_IN_SESSION) ? 1 : 0;
}

sub notes {
    my $class  = shift;
    my $length = scalar(@_);
    if ( $length == 0 ) {
        return ScopeSession::Notes->get_instance;
    }
    elsif ( $length == 1 ) {
        return ScopeSession::Notes->get(shift);
    }
    else {
        return ScopeSession::Notes->set(@_);
    }
}

sub _option {
    my $self = (ref $_[0]) ? shift : shift->get_instance;
    $self->{_option} = {} unless $self->{_option};
    return $self->{_option};
}

sub set_option {
    my ( $self, $key, $val ) = @_;
    $self->_option->{$key} = $val;
}

sub get_option {
    my ( $self, $key ) = @_;
    return $self->_option->{$key};
}


sub start(&){
    my $code  = shift;
    my $class = __PACKAGE__;

    croak(q{scope session is alreay started}) 
        if( $_IS_IN_SESSION );

    local $ScopeSession::Notes::DATA_STORE = {};
    local $_INSTANCE         = undef;
    local $_IS_IN_SESSION    = 1;
    my $instance = $class->get_instance;
    try{
        $code->($instance);
    }
    catch Error::Simple with{
        my $error = shift;
        $instance->_on_error( $error );
    };

}

1;

__END__

=head1 NAME

ScopeSession - a scope based object note and option store 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

ScopeSession is a Scope lifetime object store , which can use as a replacement of Apache::Request::Util::pnotes.

    use ScopeSession;

    ScopeSession::start {
        my $session = shift;
        $session->notes( $key => $value );
        # your great code.
        #
    };

=head1 METHODS

=head2 start

get a block and start session 

=cut

=head2 get_instance

B<get_instance> returns instance of ScopeSession.
It is unique in the block called at B<ScopeSession::start>.

    use ScopeSession;
    
    ScopeSession::start {
        my $session  = ScopeSession->get_instance;
    };

=head2 set_option

to set a session unique option value

    ScopeSession->set_option( KEY => VALUE )
    
=head2 get_option

to get a session unique option value

    ScopeSession->get_option( KEY );

=head2 notes

=over 4

=item B<AS SETTER>

    ScopeSession->notes( KEY => VALUE );

=item B<AS GETTER>

    ScopeSession->notes( KEY );

=item B<AS ACCESSOR OF NOTE>


    ScopeSession->notes->set( KEY => VALUE );
    ScopeSession->notes->get( KEY );
    ScopeSession->notes->exists( KEY );

=back


=head2 add_error_handler($error_class,$handler)

push error handler

    ScopeSession::start {
        ScopeSession->add_error_handler( 'Error::DB::Refused' ,sub {
            # log it
        });

        # ...
        
        die with Error::DB::Refused;
    }

=head2 is_started

ask to be in a session.

    ScopeSession::start {
        ScopeSession->is_started ; # 1 
    };

    ScopeSession->is_started ; # 0

=cut

=head1 AUTHOR

Daichi Hiroki, C<< <hirokidaichi<AT>gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-scopesession at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ScopeSession>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ScopeSession


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


