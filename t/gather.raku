#!/usr/bin/env raku

use lib <. ./t>;

use Draw-Two;

my @shuffled-deck = gather {
    while my $new-draw = Draw-Two::draw-two() {
        take $new-draw;
    }
}

say @shuffled-deck;

=output
/^^"["\d/
