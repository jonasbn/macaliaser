use Test2::V0;
use Test::Script;

script_compiles('macaliaser');
script_runs(['macaliaser', '--help']);

done_testing;
