use utf8;
package OpenCloset::Avatar::Schema::Result::AvatarImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OpenCloset::Avatar::Schema::Result::AvatarImage

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<OpenCloset::Avatar::Schema::Base>

=cut

use base 'OpenCloset::Avatar::Schema::Base';

=head1 TABLE: C<avatar_image>

=cut

__PACKAGE__->table("avatar_image");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 avatar_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 image

  data_type: 'blob'
  is_nullable: 0

=head2 rating

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 create_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "avatar_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "image",
  { data_type => "blob", is_nullable => 0 },
  "rating",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "create_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    inflate_datetime => 1,
    is_nullable => 1,
    set_on_create => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 avatar

Type: belongs_to

Related object: L<OpenCloset::Avatar::Schema::Result::Avatar>

=cut

__PACKAGE__->belongs_to(
  "avatar",
  "OpenCloset::Avatar::Schema::Result::Avatar",
  { id => "avatar_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-28 14:47:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BdyXiwR/b8P4fIqqeDP5aw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
