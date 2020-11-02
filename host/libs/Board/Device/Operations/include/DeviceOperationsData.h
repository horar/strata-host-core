#pragma once

#include <QString>

namespace strata::device::command {

struct CmdSetPlatformIdData {
    QString classId;
    QString platformId;
    int boardCount;
};

struct CmdSetAssistedPlatformIdData {
    QString classId;
    QString platformId;
    int boardCount;
    QString controllerClassId;
    QString controllerPlatformId;
    int controllerBoardCount;
    QString fwClassId;
};

} // namespace
