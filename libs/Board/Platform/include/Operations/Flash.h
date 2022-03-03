/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
