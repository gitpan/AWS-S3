

package 
AWS::S3::Request::SetBucketAccessControl;

use VSO;
use AWS::S3::Signer;

extends 'AWS::S3::Request';

has 'bucket' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'acl_short' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 0,
);

has 'acl_xml' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 0,
);


sub request
{
  my $s = shift;
  
  if( $s->acl_short )
  {
    my $signer = AWS::S3::Signer->new(
      s3            => $s->s3,
      method        => 'PUT',
      uri           => $s->protocol . '://' . $s->bucket . '.s3.amazonaws.com/?acl',
      headers       => [
        'x-amz-acl' => $s->acl_short
      ]
    );
    return $s->_send_request( $signer->method => $signer->uri => {
      Authorization => $signer->auth_header,
      Date          => $signer->date,
      'x-amz-acl'   => $s->acl_short
    }, $s->acl_xml);
  }
  elsif( $s->acl_xml )
  {
    my $signer = AWS::S3::Signer->new(
      s3            => $s->s3,
      method        => 'PUT',
      uri           => $s->protocol . '://' . $s->bucket . '.s3.amazonaws.com/?acl',
      content       => \$s->acl_xml,
      'content-type'  => 'text/xml',
    );
    return $s->_send_request( $signer->method => $signer->uri => {
      Authorization => $signer->auth_header,
      Date          => $signer->date,
    }, $s->acl_xml);
  }# end if()
}# end request()

sub parse_response
{
  my ($s, $res) = @_;
  
  AWS::S3::ResponseParser->new(
    response        => $res,
    expect_nothing  => 1,
    type            => $s->type,
  );
}# end http_request()

1;# return true:


