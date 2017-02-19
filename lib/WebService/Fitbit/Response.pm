package WebService::Fitbit::Response;

use Moo;

use JSON::MaybeXS qw( decode_json );
use Types::Standard qw( Bool InstanceOf Maybe HashRef );

has content => (
    is      => 'ro',
    isa     => Maybe [HashRef],
    lazy    => 1,
    builder => '_build_content',
);

has raw => (
    is       => 'ro',
    isa      => InstanceOf ['HTTP::Response'],
    handles  => { as_string => 'as_string', code => 'code', },
    required => 1,
    clearer  => '_clear_raw',
    writer   => '_set_raw',
);

has success => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    clearer => '_clear_success',
    builder => '_build_success',
);

sub _build_content {
    my $self    = shift;
    my $content = $self->raw->decoded_content;

    return $content ? decode_json($content) : undef;
}

sub _build_success {
    my $self = shift;
    return $self->raw->is_success && !$self->raw->header('X-Died');
}

1;
__END__

# ABSTRACT: Thin wrapper around HTTP::Response objects

=pod

=head1 CONSTRUCTOR ARGUMENTS

=over

=item raw

An L<HTTP::Response> object.

=back

=head1 METHODS

=head2 content

This is the parsed JSON body of the response.  Generally this will be a C<HashRef>.

=head2 raw

Returns the raw L<HTTP::Response> object.

=head2 success

Returns true if the Fitbit API returns a 2xx code and the C<X-Died> header has
not been set..

=cut
