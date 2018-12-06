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

using namespace std;
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("SGReplicator: "); printf(__VA_ARGS__)

SGReplicator::SGReplicator() {}

SGReplicator::~SGReplicator() {
    stop();

}

/** SGReplicator.
* @brief Initial setup the replicator.
* @param replicator_configuration The SGReplicator configuration object.
*/
SGReplicator::SGReplicator(SGReplicatorConfiguration *replicator_configuration) {
    replicator_configuration_ = replicator_configuration;
    setReplicatorType(replicator_configuration_->getReplicatorType());
    replicator_parameters_.callbackContext = this;
}

/** SGReplicator stop.
* @brief Stop a running replicator thread.
*/
bool SGReplicator::stop(){
    if(replicator_thread_.joinable()){
        // Send a termination signal to the running thread.
        replicator_exit_signal_.set_value();
        replicator_thread_.join();

        // Free the replicator reference
        c4repl_free(c4replicator_);
    }
}

/** SGReplicator start.
* @brief Starts a replicator background thread by calling _start().
*/
bool SGReplicator::start(){
    // Start the replication thread and pass the promise object to it.
    replicator_thread_ = thread(&SGReplicator::_start, this, std::move(replicator_exit_signal_.get_future()));
}

/** SGReplicator _start.
* @brief Starts the replicator.
* @param future_obj The future object used to send a signal to its running thread.
*/
bool SGReplicator::_start(std::future<void> future_obj){
    C4Error c4error;
    c4socket_registerFactory(C4CivetWebSocketFactory);

    Encoder encoder;

    encoder.writeValue(replicator_configuration_->effectiveOptions());
    alloc_slice fleece_data = encoder.finish();
    replicator_parameters_.optionsDictFleece = fleece_data;

    // Callback functions
    replicator_parameters_.pushFilter = [](C4String docID, C4RevisionFlags ref, FLDict body, void *context){
        DEBUG("pushFilter\n");
        FLStringResult f = FLValue_ToJSON((FLValue)body);
        string doc_id = string((char *)docID.buf, docID.size);
        string body_json = string((char *)f.buf, f.size);
        DEBUG("Doc ID: %s, received body json:%s\n",doc_id.c_str(), body_json.c_str());
        return true;
    };

    c4replicator_ = c4repl_new(replicator_configuration_->getDatabase(),
                               replicator_configuration_->getUrlEndpoint()->getC4Address(),
                               c4str(replicator_configuration_->getUrlEndpoint()->getPath().c_str()),
                               NULL,
                               replicator_parameters_,
                               &c4error
    );

    if (c4error.code != NO_CB_ERROR && (c4error.code < kC4NumErrorCodesPlus1) ) {
        DEBUG("Replication failed.\n");

        C4SliceResult sliceResult = c4error_getDescription(c4error);
        string slice2string = string((char*)sliceResult.buf,sliceResult.size);

        DEBUG("Error Msg:%s\n", slice2string.c_str());

        // free sliceResult
        c4slice_free(sliceResult);

        return false;
    }
    //TODO: Remove this. This is only used because we don't want to exit the program. Since replicator stuff are async and work on the background!
    while ( (c4repl_getStatus(c4replicator_).level != kC4Stopped) && future_obj.wait_for(std::chrono::milliseconds(1)) == std::future_status::timeout){
        this_thread::sleep_for(chrono::milliseconds(1000));
    }
    return true;
}

/** SGReplicator setReplicatorType.
* @brief Set the replicator type to the C4ReplicatorParameters.
* @param replicator_type The enum replicator type to be used for the replicator.
*/
void SGReplicator::setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type){

    switch (replicator_type){
        case SGReplicatorConfiguration::ReplicatorType::kPushAndPull:
            replicator_parameters_.push = kC4Continuous;
            replicator_parameters_.pull = kC4Continuous;
            break;
        case SGReplicatorConfiguration::ReplicatorType::kPush:
            replicator_parameters_.push = kC4Continuous;
            replicator_parameters_.pull = kC4Disabled;

            break;
        case SGReplicatorConfiguration::ReplicatorType::kPull:
            replicator_parameters_.push = kC4Disabled ;
            replicator_parameters_.pull = kC4Continuous;
            break;
        default:
            DEBUG("No replicator type has been provided.");
            break;
    }

}

/** SGReplicator restart.
* @brief Restarts the replicator.
*/
bool SGReplicator::restart() {
    stop();
    start();
    return true;
}

/** SGReplicator addChangeListener.
* @brief Adds the callback function to the replicator's onStatusChanged event.
* @param callback The callback function.
*/
void SGReplicator::addChangeListener(const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress progress)>& callback) {
    //TODO: push to List of callbacks listening
    on_status_changed_callback_ = callback;

    replicator_parameters_.onStatusChanged = [](C4Replicator *, C4ReplicatorStatus replicator_status, void *context){
        DEBUG("onStatusChanged\n");
        SGReplicatorProgress progress;
        progress.total = replicator_status.progress.unitsTotal;
        progress.completed = replicator_status.progress.unitsCompleted;
        progress.document_count = replicator_status.progress.documentCount;

        //This is blocking
        ((SGReplicator*)context)->on_status_changed_callback_((SGReplicator::ActivityLevel) replicator_status.level, progress);
        //TODO: notify change listeners
        //((SGReplicator*)context)->notifyChangeListeners((SGReplicator::ActivityLevel) replicator_status.level, progress);
        //TODO: Walk registered listening callback passing each level and propgress
        // Use/pass EV_SIGNAL
        //Dispatched as an event loop
    };
}

/** SGReplicator addDocumentErrorListener.
* @brief Adds the callback function to the replicator's onDocumentEnded event. (This can notifiy for error and also for added Doc to local DB)
* @param callback The callback function.
*/
void SGReplicator::addDocumentEndedListener(const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool error_is_transient)> &callback) {
    on_document_error_callback_ = callback;
    replicator_parameters_.onDocumentEnded = [](C4Replicator* C4NONNULL,
                                                bool pushing,
                                                C4HeapString docID,
                                                C4HeapString revID,
                                                C4RevisionFlags flags,
                                                C4Error error,
                                                bool errorIsTransient,
                                                void *context){

        string doc_id = string((char *)docID.buf, docID.size);
        char error_message[200];
        c4error_getDescriptionC(error, error_message, sizeof(error_message));
        DEBUG("Error code: %d\n", error.code);

        ((SGReplicator*)context)->on_document_error_callback_(pushing, doc_id, error_message, error.code > 0 ,errorIsTransient);
    };
}

/** SGReplicator addValidationListener.
* @brief Adds the callback function to the replicator's validationFunc event. All incoming revisions from SyncGateway will be accepted!
* @param callback The callback function.
*/
void SGReplicator::addValidationListener(const std::function<void(const std::string& doc_id, const std::string& json_body )>& callback){
    on_validation_callback_ = callback;
    DEBUG("addValidationListener\n");
    replicator_parameters_.validationFunc = [](C4String docID, C4RevisionFlags ref, FLDict body, void *context){
        DEBUG("validationFunc\n");

        FLStringResult fleece_json_string = FLValue_ToJSON((FLValue)body);
        string doc_id = string((char *)docID.buf, docID.size);
        string body_json = string((char *)fleece_json_string.buf, fleece_json_string.size);

        ((SGReplicator*)context)->on_validation_callback_(doc_id, body_json);

        // Accept All documents as of now
        return true;
    };
}


