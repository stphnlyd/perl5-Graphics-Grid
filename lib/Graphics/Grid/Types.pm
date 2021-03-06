package Graphics::Grid::Types;

# ABSTRACT: Custom types and coercions

use 5.014;
use warnings;

# VERSION

use Ref::Util qw(is_plain_arrayref);
use Type::Library -base, -declare => qw(
  UnitName Unit UnitArithmetic UnitLike
  ViewportLike
  GPar
  PlottingCharacter
  LineType LineEnd LineJoin
  FontFace
  Color
  Justification Clip
);

use Type::Utils -all;
use Types::Standard -types;

class_type Unit, { class => 'Graphics::Grid::Unit' };
coerce Unit,
  from Value,    via { 'Graphics::Grid::Unit'->new($_) },
  from ArrayRef, via { 'Graphics::Grid::Unit'->new($_) };

class_type UnitArithmetic, { class => 'Graphics::Grid::UnitArithmetic' };

declare UnitLike, as ConsumerOf ["Graphics::Grid::UnitLike"];
coerce UnitLike,
  from Value,    via { 'Graphics::Grid::Unit'->new($_) },
  from ArrayRef, via { 'Graphics::Grid::Unit'->new($_) };

declare ViewportLike, as ConsumerOf ["Graphics::Grid::ViewportLike"];

class_type GPar, { class => 'Graphics::Grid::GPar' };
coerce GPar, from HashRef, via { 'Graphics::Grid::GPar'->new($_) };

class_type Color, { class => 'Graphics::Color::RGB' };
coerce Color, from Str, via {
    if ( $_ =~ /^\#[[:xdigit:]]+$/ ) {
        'Graphics::Color::RGB'->from_hex_string($_);
    }
    else {
        'Graphics::Color::RGB'->from_color_library($_);
    }
};

declare Justification, as ArrayRef [Num], where { @$_ == 2 };
coerce Justification, from Str, via {
    state $mapping;
    unless ($mapping) {
        $mapping = {
            left   => [ 0,   0.5 ],
            top    => [ 0.5, 1 ],
            right  => [ 1,   0.5 ],
            bottom => [ 0.5, 0 ],
            center => [ 0.5, 0.5 ],
            centre => [ 0.5, 0.5 ],
        };
        my @setup = (
            [ [qw(bottom left)],  [ 0, 0 ] ],
            [ [qw(top left)],     [ 0, 1 ] ],
            [ [qw(bottom right)], [ 1, 0 ] ],
            [ [qw(top right)],    [ 1, 1 ] ],
        );
        for my $item (@setup) {
            my ( $names, $just ) = @$item;
            my ( $a,     $b )    = @$names;
            $mapping->{"$a$b"} = $mapping->{"$b$a"} = $mapping->{"${a}_$b"} =
              $mapping->{"${b}_$a"} = $just;
        }
    }

    unless ( exists $mapping->{$_} ) {
        die "invalid justification";
    }
    return $mapping->{$_};
};

# For unit with multiple names, like "inches" and "in", we directly support
#  only one of its names, and handle other names via coercion.
declare UnitName, as Enum [
    qw(
      npc char native null
      cm inches mm points picas
      lines
      grobwidth grobheight
      )
];
coerce UnitName, from Str, via {
    state $mapping;
    unless ($mapping) {
        $mapping = {
            "in"          => "inches",
            "pt"          => "points",
            "pc"          => "picas",
            "centimetre"  => "cm",
            "centimeter"  => "cm",
            "centimetres" => "cm",
            "centimeters" => "cm",
            "millimiter"  => "mm",
            "millimeter"  => "mm",
            "millimiters" => "mm",
            "millimeters" => "mm",
        };
    }
    return ( $mapping->{$_} // $_ );
};

declare PlottingCharacter, as( Int | Str ), where { length($_) > 0 };

declare LineType,
  as Enum [qw(blank solid dashed dotted dotdash longdash twodash)];
declare LineEnd,  as Enum [qw(round butt square)];
declare LineJoin, as Enum [qw(round mitre bevel)];

declare FontFace, as Enum [qw(plain bold italic oblique bold_italic)];
coerce FontFace, from Str, via {
    sub { $_ =~ s/\./_/gr; }
};

declare Clip, as Enum [qw(on off inherit)];

declare_coercion "ArrayRefFromAny", to_type ArrayRef, from Any, via { [$_] };

1;

__END__

=head1 SYNOPSIS

    use Graphics::Grid::Types qw(:all);

=head1 DESCRIPTION

This module defines custom L<Type::Tiny> types and coercions used
by the library.

=head1 SEE ALSO

L<Type::Tiny>
