#include "FlasherConnector.h"
#include <Flasher.h>

namespace strata {

FlasherConnector::FlasherConnector(const SerialDevicePtr& device, const QString& firmwareFilename, QObject* parent) :
    QObject(parent), device_(device), fileName_(firmwareFilename) { }

FlasherConnector::~FlasherConnector() { }

void FlasherConnector::flash() {
    // TODO: backup firmware first, then flash new
    flasher_ = std::make_unique<Flasher>(device_, fileName_);

    connect(flasher_.get(), &Flasher::finished, this, &FlasherConnector::finished);
    connect(flasher_.get(), &Flasher::flashProgress, this, &FlasherConnector::flashProgress);

    flasher_->flash();
}

void FlasherConnector::stop() {
    if (flasher_) {
        flasher_->cancel();
    }
}

}  // namespace
