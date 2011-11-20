#!/usr/bin/perl -w

use strict;
use warnings 'all';
use Test::More tests => 14;
use Data::Dumper;

use_ok('AWS::S3');

SKIP: {
  skip '$ENV{AWS_ACCESS_KEY_ID} and $ENV{AWS_SECRET_ACCESS_KEY} not set', 13
    unless $ENV{AWS_ACCESS_KEY_ID} && $ENV{AWS_SECRET_ACCESS_KEY};

  my $s3 = AWS::S3->new(
    access_key_id     => $ENV{AWS_ACCESS_KEY_ID},
    secret_access_key => $ENV{AWS_SECRET_ACCESS_KEY},
  );

  isa_ok $s3->ua, 'LWP::UserAgent';

  ok my $owner = $s3->owner(), "s3.owner returns a value";
  isa_ok $owner, 'AWS::S3::Owner';


  if( my @buckets = $s3->buckets() )
  {
    is $s3->bucket($buckets[0]->name)->name, $buckets[0]->name, "s3.buckets and s3.bucket(name) works";
  }
  else
  {
    ok 1;
  }# end if()

  ok my $bucket = $s3->bucket('unit-test'), 's3.bucket(unit-test) works';

  my $acl = $bucket->acl;

  $bucket->acl( 'private' );

  is $acl, $bucket->acl;

  eval { $bucket->location_constraint( 'us-west-1' ) };
  if( $@ )
  {
    like $@, qr{\[BucketAlreadyOwnedByYou\]}, "Warning looks like '[BucketAlreadyOwnedByYou]'";
  }
  else
  {
    ok ! $@, "Got no error";
  }# end if()

  is $bucket->location_constraint, 'us-west-1';


  is $bucket->policy, '';

  my $test_str = "This is the value right here!";
  ADD_FILE: {
    my $file = $bucket->add_file(
      key       => 'foo/bar.txt',
      contents  => \$test_str
    );
  };

  GET_FILE: {
    my $file = $bucket->file('foo/bar.txt');
    is ${ $file->contents }, $test_str, 'file.contents is correct';
    is length(${ $file->contents }), length($test_str), 'length of returned value is correct';
    is $file->size, length($test_str), 'file.size is correct';
  };

  my $iter = $bucket->files( page_size => 5, page_number => 1 );
  while( my @files = $iter->next_page )
  {
    warn "Page: ", $iter->page_number, " Marker: ", $iter->marker, "\n";
    foreach my $file ( @files )
    {
      warn "\t", $file->key, "\n";
    }# end foreach()
    last;
  }# end while()

};




