package Graphics::Grid::Viewport;

# ABSTRACT: Viewport

use Graphics::Grid::Class;

# VERSION

use Types::Standard qw(Int InstanceOf Num Str ArrayRef HashRef);

use Graphics::Grid::Types qw(:all);
use Graphics::Grid::Unit;

=include attr_x_y@Graphics::Grid::Positional

=include attr_width_height@Graphics::Grid::Dimensional

=include attr_just@Graphics::Grid::HasJust

=include attr_gp@Graphics::Grid::HasGPar

=cut

=attr clip

=cut

has clip => (is => 'ro', isa => Clip, default => 'inherit' );

=attr xscale

A numeric array ref of length two indicating the minimum and maximum on
the x-scale. The limits may not be identical.

Default is C<[0, 1]>.

=attr yscale

A numeric array ref of length two indicating the minimum and maximum on
the y-scale. The limits may not be identical.

Default is C<[0, 1]>.

=cut

my $Scale = ( ArrayRef [Num] )->where( sub { @$_ == 2 } );

has [ "xscale", "yscale" ] => (
    is      => 'ro',
    isa     => $Scale,
    default => sub { [ 0, 1 ] },
);

=attr angle

A numeric value indicating the angle of rotation of the viewport. Positive
values indicate the amount of rotation, in degrees, anticlockwise from the
positive x-axis. Default is 0.

=cut

has angle => (
    is      => 'ro',
    isa     => Num,
    default => 0
);

=attr layout

A L<Graphics::Grid::Layout> object which splits the viewport into subregions.

=attr layout_pos_row

Indices of rows occupied by this viewport in its parent's layout.

=attr layout_pos_col

Indices of columns occupied by this viewport in its parent's layout.

=cut

has layout => (
    is  => 'ro',
    isa => InstanceOf ["Graphics::Grid::Layout"],
    writer => '_set_layout',
);
has [qw(layout_pos_row layout_pos_col)] => (
    is  => 'ro',
    isa => ( ArrayRef [Int] )->plus_coercions(ArrayRefFromAny),
    coerce => 1,
);



=include attr_name@Graphics::Grid::ViewportLike

=cut

with qw(
  Graphics::Grid::ViewportLike
  Graphics::Grid::Positional
  Graphics::Grid::Dimensional
  Graphics::Grid::HasJust
);

sub _build_name { $_[0]->_uid; }

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use Graphics::Grid::Viewport;
    use Graphics::Grid::GPar;
    
    my $vp = Graphics::Grid::Viewport->new(
            x => 0.6, y => 0.6,
            width => 1, height => 1,
            angle => 45,
            gp => Graphics::Grid::GPar->new(col => "red") );

=head1 DESCRIPTION

Viewports describe rectangular regions on a graphics device and define a
number of coordinate systems within those regions.

=head1 SEE ALSO

L<Graphics::Grid>

L<Graphics::Grid::ViewportLike>

