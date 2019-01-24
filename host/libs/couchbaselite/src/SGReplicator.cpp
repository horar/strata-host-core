/**
******************************************************************************
* @file SGReplicator .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/6/18
* @brief Replicator API
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include <string>
#include <algorithm>
#include <chrono>
#include <future>
#include <thread>
#include <set>

#include "CivetWebSocket.hh"

#include "SGReplicator.h"
#include "SGUtility.h"

using namespace std;
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("SGReplicator: "); printf(__VA_ARGS__)

namespace Spyglass {
    SGReplicator::SGReplicator() {}

    SGReplicator::~SGReplicator() {
        c4repl_free(c4replicator_);
    }

    SGReplicator::SGReplicator(SGReplicatorConfiguration *replicator_configuration) {
        replicator_configuration_ = replicator_configuration;
        setReplicatorType(replicator_configuration_->getReplicatorType());
        replicator_parameters_.callbackContext = this;
        c4socket_registerFactory(C4CivetWebSocketFactory);
    }

    void SGReplicator::stop() {
        c4repl_stop(c4replicator_);
    }

    bool SGReplicator::start() {
        return _start();
    }

    bool SGReplicator::_start() {
        Encoder encoder;

        if (!isValidSGReplicatorConfiguration()) {
            return false;
        }

        encoder.writeValue(replicator_configuration_->effectiveOptions());
        alloc_slice fleece_data = encoder.finish();
        replicator_parameters_.optionsDictFleece = fleece_data;

        // Callback function for outgoing revision event
        // This is used for log purposes!
        replicator_parameters_.pushFilter = [](C4String docID, C4RevisionFlags ref, FLDict body, void *context) {
            DEBUG("pushFilter\n");
            alloc_slice fleece_body = FLValue_ToJSON((FLValue) body);
            DEBUG("Doc ID: %s, pushing body json:%s\n", slice(docID).asString().c_str(),
                  fleece_body.asString().c_str());
            return true;
        };

        c4replicator_ = c4repl_new(replicator_configuration_->getDatabase()->getC4db(),
                                   replicator_configuration_->getUrlEndpoint()->getC4Address(),
                                   slice(replicator_configuration_->getUrlEndpoint()->getPath()),
                                   nullptr,
                                   replicator_parameters_,
                                   &c4error_
        );

        if(c4replicator_ == nullptr){
            logC4Error(c4error_);
            DEBUG("Replication failed.\n");
            return false;
        }
        return true;
    }

    void SGReplicator::setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type) {

        switch (replicator_type) {
            case SGReplicatorConfiguration::ReplicatorType::kPushAndPull:
                replicator_parameters_.push = kC4Continuous;
                replicator_parameters_.pull = kC4Continuous;
                break;
            case SGReplicatorConfiguration::ReplicatorType::kPush:
                replicator_parameters_.push = kC4Continuous;
                replicator_parameters_.pull = kC4Disabled;

                break;
            case SGReplicatorConfiguration::ReplicatorType::kPull:
                replicator_parameters_.push = kC4Disabled;
                replicator_parameters_.pull = kC4Continuous;
                break;
            default:
            DEBUG("No replicator type has been provided.");
                break;
        }

    }

    bool SGReplicator::isValidSGReplicatorConfiguration() {
        return  replicator_configuration_ != nullptr &&
                replicator_configuration_->getDatabase() != nullptr &&
                replicator_configuration_->getDatabase()->getC4db() != nullptr &&
                !replicator_configuration_->getUrlEndpoint()->getPath().empty();
    }

    void SGReplicator::addChangeListener(
            const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress progress)> &callback) {
        //TODO: push to List of callbacks listening
        on_status_changed_callback_ = callback;

        replicator_parameters_.onStatusChanged = [](C4Replicator *, C4ReplicatorStatus replicator_status,
                                                    void *context) {
            DEBUG("onStatusChanged\n");
            SGReplicatorProgress progress;
            progress.total = replicator_status.progress.unitsTotal;
            progress.completed = replicator_status.progress.unitsCompleted;
            progress.document_count = replicator_status.progress.documentCount;

            //This is blocking
            ((SGReplicator *) context)->on_status_changed_callback_(
                    (SGReplicator::ActivityLevel) replicator_status.level, progress);
            //TODO: notify change listeners
            //((SGReplicator*)context)->notifyChangeListeners((SGReplicator::ActivityLevel) replicator_status.level, progress);
            //TODO: Walk registered listening callback passing each level and propgress
            // Use/pass EV_SIGNAL
            //Dispatched as an event loop
        };
    }

    void SGReplicator::addDocumentEndedListener(
            const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,
                                     bool error_is_transient)> &callback) {
        on_document_error_callback_ = callback;
        replicator_parameters_.onDocumentEnded = [](C4Replicator *C4NONNULL,
                                                    bool pushing,
                                                    C4HeapString docID,
                                                    C4HeapString revID,
                                                    C4RevisionFlags flags,
                                                    C4Error error,
                                                    bool errorIsTransient,
                                                    void *context) {

            alloc_slice error_message = c4error_getDescription(error);
            ((SGReplicator *) context)->on_document_error_callback_(pushing, slice(docID).asString(),
                                                                    error_message.asString(), error.code > 0,
                                                                    errorIsTransient);
        };
    }

    void SGReplicator::addValidationListener(
            const std::function<void(const std::string &doc_id, const std::string &json_body)> &callback) {
        on_validation_callback_ = callback;
        DEBUG("addValidationListener\n");
        replicator_parameters_.validationFunc = [](C4String docID, C4RevisionFlags ref, FLDict body, void *context) {
            DEBUG("validationFunc\n");

            alloc_slice fleece_json_string = FLValue_ToJSON((FLValue) body);
            ((SGReplicator *) context)->on_validation_callback_(slice(docID).asString(), fleece_json_string.asString());

            // Accept All documents
            return true;
        };
    }
}