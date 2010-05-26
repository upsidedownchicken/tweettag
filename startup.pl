use lib qw( /home/john/projects/tweettag/lib );

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const ();

use Encode ();
use HTML::Scrubber ();
use JSON ();
use Log::Log4perl ();
use URI ();
use WebService::Yahoo::TermExtractor ();
use XML::FeedPP ();

Log::Log4perl->init_once( '/home/john/projects/tweettag/log.conf' );
1;
