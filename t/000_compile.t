use t::test_base;

use_ok "Eixo::Docker";

# check dependencies
exists $INC{"Attribute/Handlers.pm"} || BAIL_OUT("Attribute::Handlers can't be loaded");
exists $INC{"JSON.pm"} || BAIL_OUT("JSON module can't be loaded");
exists $INC{"LWP/UserAgent.pm"} || BAIL_OUT("LWP::UserAgent can't be loaded");
exists $INC{"Net/HTTP.pm"} || BAIL_OUT("Net::HTTP can't be loaded");
exists $INC{"Eixo/Base/Clase.pm"} || BAIL_OUT("Eixo::Base::Clase can't be loaded");
exists $INC{"Eixo/Rest/Client.pm"} || BAIL_OUT("Eixo::Rest::Client can't be loaded");

done_testing;
