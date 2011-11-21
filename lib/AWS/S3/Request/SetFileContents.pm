
package 
AWS::S3::Request::SetFileContents;

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
  
  my $req = AWS::S3::HTTPRequest->new(
    s3      => $s->s3,
    method  => 'PUT',
    path    => $s->_uri('') . $s->file->key,
    content => $s->file->contents,
  )->http_request;
  $req->header('content-length' => length($req->content));
  return $req;
}# end http_request()

1;# return true:

