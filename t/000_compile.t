use t::test_base;

use_ok "Eixo::Docker";

# check dependencies
exists $INC{"JSON.pm"} || BAIL_OUT("JSON module can't be loaded");
exists $INC{"LWP/UserAgent.pm"} || BAIL_OUT("LWP::UserAgent can't be loaded");
exists $INC{"Eixo/Rest/Client.pm"} || BAIL_OUT("Eixo::Rest::Client can't be loaded");


done_testing;
