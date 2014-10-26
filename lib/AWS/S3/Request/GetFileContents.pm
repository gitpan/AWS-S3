
package
AWS::S3::Request::GetFileContents;

use VSO;
use AWS::S3::Signer;
use AWS::S3::ResponseParser;

extends 'AWS::S3::Request';

has 'bucket' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'key' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);


sub request
{
  my $s = shift;
  
  my $uri = '';
  if( $s->bucket =~ m{[A-Z]} )
  {
    $uri = $s->protocol . '://s3.amazonaws.com/' . $s->bucket . '/' . $s->key;
  }
  else
  {
    $uri = $s->protocol . '://' . $s->bucket . '.s3.amazonaws.com/' . $s->key;
  }# end if()
  my $signer = AWS::S3::Signer->new(
    s3            => $s->s3,
    method        => 'GET',
    uri           => $uri,
  );
  $s->_send_request( $signer->method => $signer->uri => {
    Authorization => $signer->auth_header,
    Date          => $signer->date,
  });
}# end request()

sub parse_response
{
  my ($s, $res) = @_;
  
  AWS::S3::ResponseParser->new(
    response        => $res,
    expect_nothing  => 0,
    type            => $s->type,
  );
}# end http_request()

1;# return true:

