requires 'DBIx::Class::InflateColumn::DateTime';
requires 'DBIx::Class::Schema';
requires 'DBIx::Class::TimeStamp';
requires 'Digest::MD5';
requires 'HTTP::Tiny';
requires 'Image::Imlib2';
requires 'Image::Info';
requires 'Mojolicious::Types';
requires 'Path::Tiny';
requires 'Try::Tiny';

# from opencloset cpan
requires 'OpenCloset::Plugin::Helpers';

# OpenCloset::Plugin::Helpers 의 의존성인데 현재 버전에서는 빠져있음
requires 'OpenCloset::Calculator::LateFee';
