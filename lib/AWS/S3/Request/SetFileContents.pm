
package AWS::S3::Request::SetFileContents;

use VSO;
use AWS::S3::HTTPRequest;

extends 'AWS::S3::Request';

has 'file' => (
  is        => 'ro',
  isa       => 'AWS::S3::File',
  required  => 1,
);

sub http_request
{
  my $s = shift;
  
  return AWS::S3::HTTPRequest->new(
    s3      => $s->s3,
    method  => 'PUT',
    path    => $s->_uri('') . $s->file->key,
    content => $s->file->contents,
  )->http_request;
}# end http_request()

1;# return true:

