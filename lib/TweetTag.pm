package TweetTag;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw/OK NOT_FOUND/;

use Encode ();
use HTML::Scrubber ();
use JSON ();
use Log::Log4perl ();
use URI ();
use WebService::Yahoo::TermExtractor ();
use XML::FeedPP ();

my $TWITTER_TERMS_APP_ID = 'c1upeuvV34Eqn8Y_7SVt1mzNN9u9o6JyZfI.D0L_UDKlA5TNuL4GrGiFUiN1SXVL6Q--';

sub handler {
  my $r = shift;
  my $log = Log::Log4perl->get_logger( 'TweetTag' );

  ## parse query string
  my @pairs = split /&/, $r->args;
  my %qs = map { split /=/, $_ } @pairs;

  my $url = $qs{url};
  my $tags = TweetTag->tag_url( $url );
  my $json = JSON->new;
	
  $r->content_type( 'text/plain' );
  $r->print( $json->encode({tags => $tags}) );

  return Apache2::Const::OK;
}

sub tag_url {
  my( $class, $url ) = @_;
  my $log = Log::Log4perl->get_logger( 'TweetTag' );

  $log->debug( $url );

	my $uri = URI->new( $url );#'http://search.twitter.com/search.atom?geocode=29.425037%2C-98.493722%2C25km' );
	my $tx = WebService::Yahoo::TermExtractor->new( appid => $TWITTER_TERMS_APP_ID );
	my $feed = XML::FeedPP->new( $uri );
	
	my @tags = ();
	
	for my $item ( $feed->get_item ){
	  my $scrubber = HTML::Scrubber->new;
	  my $description = $scrubber->scrub( Encode::decode_utf8 $item->description );
	  my $terms = $tx->get_terms( $description );
	  my $ts = time;

    $log->debug( join(', ', @$terms) );
	  
	  for my $term ( @$terms ){
	    push @tags, { term => $term, ts => $ts };
	  }
	}

  return \@tags;
}

1;
