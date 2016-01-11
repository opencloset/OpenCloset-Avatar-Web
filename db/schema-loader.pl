use strict;
use warnings;

my $config = require('avatar.conf');

return {
    schema_class => "OpenCloset::Avatar::Schema",
    connect_info => {
        dsn  => $config->{database}{dsn},
        user => $config->{database}{user},
        pass => $config->{database}{pass},
        %{ $config->{database}{opts} },
    },
    loader_options => {
        dump_directory            => 'lib',
        naming                    => { ALL => 'v8' },
        skip_load_external        => 1,
        relationships             => 1,
        col_collision_map         => 'column_%s',
        result_base_class         => 'OpenCloset::Avatar::Schema::Base',
        overwrite_modifications   => 1,
        datetime_undef_if_invalid => 1,
        custom_column_info        => sub {
            my ( $table, $col_name, $col_info ) = @_;
            if ( $col_name eq 'create_date' ) {
                return { %$col_info, set_on_create => 1, inflate_datetime => 1 };
            }

            if ( $col_name eq 'update_date' ) {
                return { %$col_info, set_on_create => 1, set_on_update => 1, inflate_datetime => 1 };
            }
        },
    },
};
