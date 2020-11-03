#pragma once

#include <QString>

namespace strata::device::command {

struct CmdSetPlatformIdData {
    QString classId;
    QString platformId;
    int boardCount;
};

} // namespace
