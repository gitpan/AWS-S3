
package
AWS::S3::Request;
use VSO;
use HTTP::Request;
use AWS::S3::ResponseParser;

has 's3' => (
  is        => 'ro',
  isa       => 'AWS::S3',
  required  => 1,
);

has 'type' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'protocol' => (
  is        => 'ro',
  isa       => 'Str',
  lazy      => 1,
  default   => sub {
    shift->s3->secure ? 'https' : 'http';
  }
);


sub _send_request
{
  my ($s, $method, $uri, $headers, $content) = @_;
  
  my $req = HTTP::Request->new( $method => $uri );
  $req->content( $content ) if $content;
  map { 
    $req->header( $_ => $headers->{$_} )
  } keys %$headers;
  
  my $res = $s->s3->ua->request( $req );

  unless( $res->is_success )
  {
    if( $res->header('location') )
    {
      if( $res->content =~ m{\bTemporaryRedirect\b} )
      {
        $req->uri( $res->header('location') );
        $res = $s->s3->ua->request( $req );
      }
      elsif( $res->content =~ m{\bPermanentRedirect\b} )
      {
#        $req->uri( $res->header('location') );
#        $res = $s->s3->ua->request( $req );
      }# end if()
    }# end if()
  }# end unless()

#warn $req->as_string;
#warn "="x80, "\n";
#warn $res->as_string;
#warn "\n"x10;
#warn "="x80, "\n";
#warn "="x80, "\n";
  
  # After creating a bucket and setting its location constraint, we get this
  # strange 'TemporaryRedirect' response.  Deal with it.
  if( $res->header('location') && $res->content =~ m{>TemporaryRedirect<}s )
  {
    $req->uri( $res->header('location') );
    $res = $s->s3->ua->request( $req );
  }# end if()
  return $s->parse_response( $res );
}# end _send_request()


sub parse_response
{
  my ($s, $res) = @_;
  
  die "parse_response() is not yet implemented!";
}# end parse_response()

1;# return true:

