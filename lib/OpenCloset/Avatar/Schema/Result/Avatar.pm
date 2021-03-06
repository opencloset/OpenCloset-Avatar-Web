use utf8;
package OpenCloset::Avatar::Schema::Result::Avatar;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

OpenCloset::Avatar::Schema::Result::Avatar

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<OpenCloset::Avatar::Schema::Base>

=cut

use base 'OpenCloset::Avatar::Schema::Base';

=head1 TABLE: C<avatar>

=cut

__PACKAGE__->table("avatar");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 md5sum

  data_type: 'char'
  is_nullable: 0
  size: 32

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
  "md5sum",
  { data_type => "char", is_nullable => 0, size => 32 },
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

=head1 UNIQUE CONSTRAINTS

=head2 C<md5sum>

=over 4

=item * L</md5sum>

=back

=cut

__PACKAGE__->add_unique_constraint("md5sum", ["md5sum"]);

=head1 RELATIONS

=head2 avatar_images

Type: has_many

Related object: L<OpenCloset::Avatar::Schema::Result::AvatarImage>

=cut

__PACKAGE__->has_many(
  "avatar_images",
  "OpenCloset::Avatar::Schema::Result::AvatarImage",
  { "foreign.avatar_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-07-28 14:47:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mdaus94nXe2ustTFn8DKZw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
