
package AWS::S3::Owner;

use VSO;

has 'id' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'display_name' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

1;# return true:

