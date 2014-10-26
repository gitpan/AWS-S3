# NAME

AWS::S3 - Lightweight interface to Amazon S3 (Simple Storage Service)

# SYNOPSIS

    use AWS::S3;
    

    my $s3 = AWS::S3->new(
      access_key_id     => 'E654SAKIASDD64ERAF0O',
      secret_access_key => 'LgTZ25nCD+9LiCV6ujofudY1D6e2vfK0R4GLsI4H',
    );
    

    # Add a bucket:
    my $bucket = $s3->add_bucket(
      name    => 'foo-bucket',
    );
    

    # Set the acl:
    $bucket->acl( 'private' );
    

    # Add a file:
    my $new_file = $bucket->add_file(
      key       => 'foo/bar.txt',
      contents  => \'This is the contents of the file',
    );
    

    # You can also set the contents with a coderef:
    # Coderef should eturn a reference, not the actual string of content:
    $new_file = $bucket->add_file(
      key       => 'foo/bar.txt',
      contents  => sub { return \"This is the contents" }
    );
    

    # Get the file:
    my $same_file = $bucket->file( 'foo/bar.txt' );
    

    # Get the contents:
    my $scalar_ref = $same_file->contents;
    print $$scalar_ref;
    

    # Update the contents with a scalar ref:
    $same_file->contents( \"New file contents" );
    

    # Update the contents with a code ref:
    $same_file->contents( sub { return \"New file contents" } );
    

    # Delete the file:
    $same_file->delete();
    

    # Iterate through lots of files:
    my $iterator = $bucket->files(
      page_size   => 100,
      page_number => 1,
    );
    while( my @files = $iterator->next_page )
    {
      warn "Page number: ", $iterator->page_number, "\n";
      foreach my $file ( @files )
      {
        warn "\tFilename (key): ", $file->key, "\n";
        warn "\tSize: ", $file->size, "\n";
        warn "\tETag: ", $file->etag, "\n";
        warn "\tContents: ", ${ $file->contents }, "\n";
      }# end foreach()
    }# end while()
    

    # You can't delete a bucket until it's empty.
    # Empty a bucket like this:
    while( my @files = $iterator->next_page )
    {
      map { $_->delete } @files;
      

      # Return to page 1:
      $iterator->page_number( 1 );
    }# end while()
    

    # Now you can delete the bucket:
    $bucket->delete();

# DESCRIPTION

AWS::S3 attempts to provide an alternate interface to the Amazon S3 Simple Storage Service.

__NOTE:__ Until AWS::S3 gets to version 1.000 it will not implement the full S3 interface.

__Disclaimer:__ Several portions of AWS::S3 have been adopted from [Net::Amazon::S3](http://search.cpan.org/perldoc?Net::Amazon::S3).

__NOTE:__ AWS::S3 is NOT a drop-in replacement for [Net::Amazon::S3](http://search.cpan.org/perldoc?Net::Amazon::S3).

__TODO:__ CloudFront integration.

# CONSTRUCTOR

Call `new()` with the following parameters.

## access_key_id

Required.  String.

Provided by Amazon, this is your access key id.

## secret_access_key

Required.  String.

Provided by Amazon, this is your secret access key.

## secure

Optional.  Boolean.

Default is `0`

## ua

Optional.  Should be an instance of [LWP::UserAgent](http://search.cpan.org/perldoc?LWP::UserAgent) or a subclass of it.

Defaults to creating a new instance of [LWP::UserAgent::Determined](http://search.cpan.org/perldoc?LWP::UserAgent::Determined)

# PUBLIC PROPERTIES

## access_key_id

String.  Read-only

## secret_access_key

String.  Read-only.

## secure

Boolean.  Read-only.

## ua

[LWP::UserAgent](http://search.cpan.org/perldoc?LWP::UserAgent) object.  Read-only.

## owner

[AWS::S3::Owner](http://search.cpan.org/perldoc?AWS::S3::Owner) object.  Read-only.

# PUBLIC METHODS

## buckets

Returns an array of [AWS::S3::Bucket](http://search.cpan.org/perldoc?AWS::S3::Bucket) objects.

## bucket( $name )

Returns the [AWS::S3::Bucket](http://search.cpan.org/perldoc?AWS::S3::Bucket) object matching `$name` if found.

Returns nothing otherwise.

## add_bucket( name => $name )

Attempts to create a new bucket with the name provided.

On success, returns the new [AWS::S3::Bucket](http://search.cpan.org/perldoc?AWS::S3::Bucket)

On failure, dies with the error message.

See [AWS::S3::Bucket](http://search.cpan.org/perldoc?AWS::S3::Bucket) for details on how to use buckets (and access their files).

# SEE ALSO

[The Amazon S3 API Documentation](http://docs.amazonwebservices.com/AmazonS3/latest/API/)

[AWS::S3::Bucket](http://search.cpan.org/perldoc?AWS::S3::Bucket)

[AWS::S3::File](http://search.cpan.org/perldoc?AWS::S3::File)

[AWS::S3::FileIterator](http://search.cpan.org/perldoc?AWS::S3::FileIterator)

[AWS::S3::Owner](http://search.cpan.org/perldoc?AWS::S3::Owner)

# AUTHOR

John Drago <jdrago_999@yahoo.com>

# LICENSE AND COPYRIGHT

This software is Free software and may be used and redistributed under the same
terms as any version of perl itself.

Copyright John Drago 2011 all rights reserved.