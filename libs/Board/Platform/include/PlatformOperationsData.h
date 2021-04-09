#pragma once

#include <QString>

namespace strata::platform::command {

struct CmdSetPlatformIdData {
    QString classId;
    QString platformId;
    int boardCount;
};

} // namespace
