#!/usr/bin/perl -w

use strict;
use warnings 'all';
use Test::More 'no_plan';
use Data::Dumper;

use_ok('AWS::S3');

unless( $ENV{AWS_ACCESS_KEY_ID} && $ENV{AWS_SECRET_ACCESS_KEY} )
{
  warn '$ENV{AWS_ACCESS_KEY_ID} && $ENV{AWS_SECRET_ACCESS_KEY} must both be defined to run these tests.', "\n";
  exit(0);
}# end unless()


my $s3 = AWS::S3->new(
  access_key_id     => $ENV{AWS_ACCESS_KEY_ID},
  secret_access_key => $ENV{AWS_SECRET_ACCESS_KEY},
);

isa_ok $s3->ua, 'LWP::UserAgent';

ok my $owner = $s3->owner(), "s3.owner returns a value";
isa_ok $owner, 'AWS::S3::Owner';
ok $owner->id, 'owner.id';
ok $owner->display_name, 'owner.display_name';

my $bucket_name = "aws-s3-test-" . int(rand() * 1_000_000) . '-' . time() . "-foo";
ok my $bucket = $s3->add_bucket( name => $bucket_name ), "created bucket '$bucket_name'";
if( $bucket )
{
  my $acl = $bucket->acl;
  ok $bucket->acl( 'private' ), 'set bucket.acl to private';
  is $acl, $bucket->acl, 'get bucket.acl returns private';
  ok $bucket->location_constraint( 'us-west-1' ), 'set bucket.location_constraint to us-west-1';
  is $bucket->location_constraint, 'us-west-1', 'get bucket.location returns us-west-1';
  
  is $bucket->policy, '', 'get bucket.policy returns empty string';
  
  my $test_str = "This is the original value right here!"x20;
  my $filename = 'foo/bar.txt';
  ADD_FILE: {
    my $file = $bucket->add_file(
      key       => $filename,
      contents  => \$test_str
    );
    ok( $file, 'bucket.add_file() works' );
    unlike $file->etag, qr("), 'file.etag does not contain any double-quotes (")';
  };
  
  GET_FILE: {
    ok my $file = $bucket->file($filename), 'bucket.file(filename) works';
    is ${ $file->contents }, $test_str, 'file.contents is correct';
  };
  
  # Set contents:
  SET_CONTENTS: {
    my $new_contents = "This is the updated value"x10;
    ok my $file = $bucket->file($filename), 'bucket.file(filename) works';
    $file->contents( \$new_contents );
    
    # Now check it:
    is ${$bucket->file($filename)->contents}, $new_contents, "set file.contents works";
  };
  
  DELETE_FILE: {
    eval { $bucket->delete };
    ok $@, 'bucket.delete fails when bucket is not empty.';
    like $@, qr/BucketNotEmpty/, 'error looks like BucketNotEmpty';
    ok $bucket->file($filename)->delete, 'file.delete';
    ok ! $bucket->file($filename), 'file no longer exists in bucket';
  };
  
  ADD_MANY_FILES: {
    my %info = ( );
    
    # Add the files:
    for( 0..20 )
    {
      my $contents  = "Contents of file $_\n"x$_;
      my $key       = "bar/baz/foo.$_.txt";
      $info{$key} = $contents;
      ok $bucket->add_file(
        key       => $key,
        contents  => \$contents,
      ), "Added file $_";
    }# end for()
    
    # Make sure they all worked:
    foreach my $key ( sort keys %info )
    {
      my $contents = $info{$key};
      ok my $file = $bucket->file($key), "bucket.file($key) returned a file";
      is $file->size, length($contents), 'file.size is correct';
      is ${$file->contents}, $contents, 'file.contents is correct';
    }# end for()
    
    # Try iterating through the files:
    my $iter = $bucket->files( page_size => 2, page_number => 1 );
    while( my @files = $iter->next_page )
    {
      foreach my $file ( @files )
      {
        is ${$file->contents}, $info{$file->key}, 'file.contents works on iterated files';
      }# end foreach()
    }# end while()
    
    # Delete the files:
    map {
      ok $bucket->file($_)->delete && ! $bucket->file($_), "bucket.file($_).delete worked"
    } sort keys %info;
  };
  
  # Cleanup:
  ok $bucket->delete, 'bucket.delete succeeds when bucket IS empty.';
}# end if()




