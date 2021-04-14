#pragma once

#include <QString>
#include <QVector>

#include <Operations/BasePlatformOperation.h>

namespace strata::platform::command {
    class CmdFlash;
}

namespace strata::platform::operation {

class Flash : public BasePlatformOperation {

public:
    Flash(const PlatformPtr& platform, int size, int chunks, const QString &md5, bool flashFirmware);
    ~Flash() = default;
    void flashChunk(const QVector<quint8>& chunk, int chunkNumber);
private:
    std::vector<std::unique_ptr<command::BasePlatformCommand>>::iterator flashCommand_;
    command::CmdFlash* cmdFlash_;
    int chunkCount_;
    bool flashFirmware_;
};

}  // namespace
