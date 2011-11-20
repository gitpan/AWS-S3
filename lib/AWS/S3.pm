
package AWS::S3;

use VSO;
use Carp 'confess';
use LWP::UserAgent;
use Class::Load 'load_class';
use AWS::S3::ResponseParser;

use AWS::S3::Owner;
use AWS::S3::Bucket;


our $VERSION = '0.001';

has 'access_key_id' => (
  is    => 'ro'
);

has 'secret_access_key' => (
  is    => 'ro'
);

has 'secure' => (
  is      => 'ro',
  isa     => 'Int',
  default => sub { 0 },
);

has 'ua' => (
  is      => 'ro',
  default => sub { LWP::UserAgent->new }
);


sub request
{
  my ($s, $type, %args) = @_;
  
  my $class = "AWS::S3::Request::$type";
  load_class($class);
  return $class->new( s3 => $s, %args )->http_request;
}# end request()


sub owner
{
  my ($s) = @_;
  
  my $type = 'ListAllMyBuckets';
  my $req = $s->request( $type,
    bucket  => '',
  );
  
  my $parser = AWS::S3::ResponseParser->new(
    response        => $s->ua->request( $req ),
    type            => $type,
    expect_nothing  => 0,
  );
  
  my $xpc = $parser->xpc;
  
  return AWS::S3::Owner->new(
    id            => $xpc->findvalue('//s3:Owner/s3:ID'),
    display_name  => $xpc->findvalue('//s3:Owner/s3:DisplayName'),
  );
}# end owner()


sub buckets
{
  my ($s) = @_;
  
  my $type = 'ListAllMyBuckets';
  my $req = $s->request( $type,
    bucket  => '',
  );
  
  my $parser = AWS::S3::ResponseParser->new(
    response        => $s->ua->request( $req ),
    type            => $type,
    expect_nothing  => 0,
  );
  
  my $xpc = $parser->xpc;
  my @buckets = ( );
  foreach my $node ( $xpc->findnodes('.//s3:Bucket') )
  {
    push @buckets, AWS::S3::Bucket->new(
      name          => $xpc->findvalue('.//s3:Name', $node ),
      creation_date => $xpc->findvalue('.//s3:CreationDate', $node),
      s3            => $s,
    );
  }# end foreach()
  
  return @buckets;
}# end buckets()


sub bucket
{
  my ($s, $name) = @_;
  
  my ($bucket) = grep { $_->name eq $name } $s->buckets
    or return;
  $bucket;
}# end bucket()


sub add_bucket
{
  
}# end add_bucket()


1;# return true:

=pod

=head1 NAME

AWS::S3 - Lightweight interface to Amazon S3 (Simple Storage Service)

=head1 SYNOPSIS

  # TBD

=head1 DESCRIPTION

AWS::S3 attempts to provide an alternate interface to the Amazon S3 Simple Storage Service.

B<NOTE:> Until AWS::S3 gets to version 1.000 it will not implement the full S3 interface.

B<Disclaimer:> Several portions of AWS::S3 have been adopted from L<Net::Amazon::S3>.

B<NOTE:> AWS::S3 is NOT a drop-in replacement for L<Net::Amazon::S3>.

=head1 AUTHOR

John Drago <jdrago_999@yahoo.com>

=head1 LICENSE AND COPYRIGHT

This software is Free software and may be used and redistributed under the same
terms as any version of perl itself.

Copyright John Drago 2011 all rights reserved.

=cut

