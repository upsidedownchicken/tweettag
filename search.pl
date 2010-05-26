#! /usr/bin/perl -w
use strict;

use Encode ();
use HTML::Scrubber ();
use URI ();
use WebService::Yahoo::TermExtractor ();
use XML::FeedPP ();

my $TWITTER_TERMS_APP_ID = 'c1upeuvV34Eqn8Y_7SVt1mzNN9u9o6JyZfI.D0L_UDKlA5TNuL4GrGiFUiN1SXVL6Q--';

my $uri = URI->new( 'http://search.twitter.com/search.atom?geocode=29.425037%2C-98.493722%2C25km' );
my $tx = WebService::Yahoo::TermExtractor->new( appid => $TWITTER_TERMS_APP_ID );
my $feed = XML::FeedPP->new( $uri );

my @tags = ();

for my $item ( $feed->get_item ){
  my $scrubber = HTML::Scrubber->new;
  my $description = $scrubber->scrub( Encode::decode_utf8 $item->description );
  my $terms = $tx->get_terms( $description );
  my $ts = time;
  
  for my $term ( @$terms ){
    push @tags, { term => $term, ts => $ts };
  }
}

use Data::Dump qw/dump/;
print dump( \@tags ), "\n";
