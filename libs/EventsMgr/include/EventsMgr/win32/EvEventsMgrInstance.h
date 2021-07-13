#pragma once

namespace strata::events_mgr {

// class for initializing WSA sockets on Windows
// on Mac/Linux has no effect
class EvEventsMgrInstance
{
public:
    EvEventsMgrInstance();
    ~EvEventsMgrInstance();

private:
    static bool wsa_init_done;
};

} // namepsace
