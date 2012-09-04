#!/usr/bin/env perl6

use v6;

class DateTime::Format::W3CDTF;

method parse (Str $str) of DateTime {
    my Str $date-str = $str;
    my Match $m;

    # YYYY-MM-DDThh:mm:ss.sTZD --> YYYY-MM-DDThh:mm:ssTZD
    if $m = $date-str ~~ /^ ( .* T <[0..9]> ** 2 \: <[0..9]> ** 2 \: <[0..9]> ** 2) \. <[0..9]> + ( .*) $/ {
        $date-str = $m[0] ~ $m[1];
    }

    # YYYY-MM-DDThh:mmTZD --> YYYY-MM-DDThh:mm:00TZD
    if $m = $date-str ~~ /^ ( .* T <[0..9]> ** 2 \: <[0..9]> ** 2 ) ( <[Z+-]> .* ) $/ {
        $date-str = $m[0] ~ ':00' ~ $m[1];
    }

    if $date-str ~~ / . ** 16..* <[+-]> <[0..9]> ** 4 $/ {
        die 'Invalid timezone format';
    }

    if $m = $date-str ~~ /^ ( . ** 16..* <[+-]> <[0..9]> ** 2 ) \: ( <[0..9]> ** 2 ) $/ {
        $date-str = $m[0] ~ $m[1];
    }

    given $date-str {
        when /^ <[0..9]> ** 4 $/ {
            $date-str ~= '-01-01T00:00:00Z'; 
        }
        when /^ <[0..9]> ** 4 \- <[0..9]> ** 2 $/ {
            $date-str ~= '-01T00:00:00Z'; 
        }
        when /^ <[0..9]> ** 4 \- <[0..9]> ** 2 \- <[0..9]> ** 2 $/ {
            $date-str ~= 'T00:00:00Z'; 
        }
        when / ( Z | <[+-]> <[0..9]> ** 4 ) $/ {
            # ok, do nothing
        }
        default {
            die 'Timezone missing';
        }
    }
    return DateTime.new($date-str);
}

method format (DateTime $date) of Str {
    my Str $result = $date.Str;
    if my $m = $result ~~ /^( .* <[+-]> <[0..9]> ** 2 ) ( <[0..9]> ** 2 )$/ {
        $result = $m[0] ~ ':' ~ $m[1];
    }
    return $result;
}

=begin pod

=head1 NAME

A Perl 6 module to deal with W3CDTF dates

=head1 SYNOPSYS

    use DateTime::Format::W3CDTF;

    my $w3c = DateTime::Format::W3CDTF.new;
    my DateTime $datetime = $w3c.parse('2012-09-04T11:22:33.5+04:00');
    say $w3c.format($datetime);
     
=end pod

