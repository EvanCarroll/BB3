use inc::Module::Install;

name     'Bot-BB3';
all_from 'lib/Bot/BB3.pm';
author   q{Robert Grimes <buu@erxz.com>};
license  'perl';

requires 'Parse::RecDescent';
requires 'POE';
requires 'POE::Component::Server::SimpleHTTP';
requires 'POE::Component::IRC';
requires 'POE::Wheel::SocketFactory';

recommends 'BSD::Resource';

build_requires 'Test::More';

auto_install;

WriteAll;

