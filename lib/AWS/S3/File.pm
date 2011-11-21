
package AWS::S3::File;

use VSO;
use Carp 'confess';


has 'key' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'bucket' => (
  is        => 'ro',
  isa       => 'AWS::S3::Bucket',
  required  => 1,
  weak_ref  => 1,
);

has 'size'  => (
  is        => 'ro',
  isa       => 'Int',
  required  => 0,
);

has 'etag'  => (
  is        => 'ro',
  isa       => 'Str',
  required  => 0,
);

has 'owner'  => (
  is        => 'ro',
  isa       => 'AWS::S3::Owner',
  required  => 0,
  weak_ref  => 1,
);

has 'storageclass'  => (
  is        => 'ro',
  isa       => 'Str',
  required  => 0,
);

has 'lastmodified'  => (
  is        => 'ro',
  isa       => 'Str',
  required  => 0,
);

has 'contents' => (
  is        => 'rw',
  isa       => 'ScalarRef|CodeRef',
  required  => 0,
  lazy      => 1,
  default   => \&_get_contents,
);


after 'contents' => sub {
  my ($s, $new_value) = @_;
  return unless defined $new_value;
  
  $s->_set_contents( $new_value );
  $s->{contents} = undef;
};

sub BUILD
{
  my $s = shift;
  
  return unless $s->etag;
  (my $etag = $s->etag) =~ s{^"}{};
  $etag =~ s{"$}{};
  $s->{etag} = $etag;
}# end BUILD()


sub _get_contents
{
  my $s = shift;
  
  my $type = 'GetFileContents';
  my $req = $s->bucket->s3->request($type,
    bucket  => $s->bucket->name,
    key     => $s->key,
  );
  
  return \$s->bucket->s3->ua->request( $req )->decoded_content;
}# end contents()


sub _set_contents
{
  my ($s, $ref) = @_;
  
  my $type = 'SetFileContents';
  my $req = $s->bucket->s3->request($type,
    file    => $s,
    bucket  => $s->bucket->name,
  );
  my $parser = AWS::S3::ResponseParser->new(
    type            => $type,
    response        => $s->bucket->s3->ua->request( $req ),
    expect_nothing  => 1,
  );
  (my $etag = $parser->response->header('etag')) =~ s{^"}{};
  $etag =~ s{"$}{};
  $s->{etag} = $etag;
  
  if( my $msg = $parser->friendly_error() )
  {
    die $msg;
  }# end if()
}# end set_contents()


sub delete
{
  my $s = shift;
  
  my $type = 'DeleteFile';
  my $req = $s->bucket->s3->request($type,
    bucket  => $s->bucket->name,
    key     => $s->key,
  );
  my $parser = AWS::S3::ResponseParser->new(
    type            => $type,
    response        => $s->bucket->s3->ua->request( $req ),
    expect_nothing  => 1,
  );
  
  if( my $msg = $parser->friendly_error() )
  {
    die $msg;
  }# end if()
  
  return 1;
}# end delete()

1;# return true:

