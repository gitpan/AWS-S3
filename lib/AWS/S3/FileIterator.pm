
package AWS::S3::FileIterator;

use strict;
use warnings 'all';
use base 'Iterator::Paged';
use Carp 'confess';
use AWS::S3::Owner;
use AWS::S3::File;


sub _init
{
  my ($s) = @_;
  
  foreach(qw( bucket page_size page_number ))
  {
    confess "Required argument '$_' was not provided"
      unless $s->{$_};
  }# end foreach()
  
  $s->{page_number}--;
  $s->{marker} = '' unless defined($s->{marker});
}# end _init()

sub marker { shift->{marker} }
sub pattern { shift->{pattern} }
sub bucket { shift->{bucket} }

sub page_number
{
  my $s = shift;
  @_ ? $s->{page_number} = $_[0] - 1 : $s->{page_number}
}# end page_number()


sub next_page
{
  my $s = shift;
  
  my @files = ( );
  if( $s->{pattern} )
  {
    while( 1 )
    {
      my $number = $s->{page_size} - scalar(@files);
      my @chunk = grep { $_->{key} =~ $s->{pattern} } $s->_fetch($number)
        or last;
      push @files, @chunk;
      last if @files >= $s->{page_size};
    }# end while()
  }
  else
  {
    push @files, $s->_fetch();
  }# end if()
  
  return unless @files;
  $s->{page_number}++;

  wantarray ? @files : \@files;
}# end next_page()


sub _fetch
{
  my ($s, $number) = @_;

  my $path = $s->{bucket}->name . '/';
  my %params = ();
  $params{marker} = $s->{marker} if $s->{marker};
  $params{max_keys} = ( $number || $s->{page_size} );
  $params{prefix} = $s->{prefix} if $s->{prefix};
  $params{delimiter} = $s->{delimiter} if $s->{delimiter};
  
  my $type = 'ListBucket';
  my $req = $s->{bucket}->s3->request($type,
    %params,
    bucket  => $s->{bucket}->name,
  );
  my $parser = AWS::S3::ResponseParser->new(
    type      => $type,
    response  => $s->{bucket}->s3->ua->request( $req ),
  );

  my @files = ( );
  foreach my $node ( $parser->xpc->findnodes('//s3:Contents') )
  {
    my ($owner_node) = $parser->xpc->findnodes('.//s3:Owner', $node);
    my $owner = AWS::S3::Owner->new(
      id            => $parser->xpc->findvalue('.//s3:ID', $owner_node),
      display_name  => $parser->xpc->findvalue('.//s3:DisplayName', $owner_node)
    );
    my $etag = $parser->xpc->findvalue('.//s3:ETag', $node);
    push @files, AWS::S3::File->new(
      bucket        => $s->{bucket},
      key           => $parser->xpc->findvalue('.//s3:Key', $node),
      lastmodified  => $parser->xpc->findvalue('.//s3:LastModified', $node),
      etag          => $parser->xpc->findvalue('.//s3:ETag', $node),
      size          => $parser->xpc->findvalue('.//s3:Size', $node),
      owner         => $owner,
    );
  }# end foreach()
  
  if( @files )
  {
    $s->{marker} = $files[-1]->key;
  }# end if()
  
  @files ? return @files : return;
}# end _fetch()

1;# return true:

