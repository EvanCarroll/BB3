use inc::Module::Install;

name     'Bot-BB3';
all_from 'lib/Bot/BB3.pm';
author   q{Robert Grimes <buu@erxz.com>};
license  'perl';

requires 'Parse::RecDescent';

build_requires 'Test::More';

auto_install;

WriteAll;

