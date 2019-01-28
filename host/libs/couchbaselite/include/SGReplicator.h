/**
******************************************************************************
* @file SGReplicator .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/6/18
* @brief Replicator API
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#ifndef SGREPLICATOR_H
#define SGREPLICATOR_H

#include <functional>
#include <future>
#include <thread>

#include <c4.h>

#include "SGDatabase.h"
#include "SGReplicatorConfiguration.h"
namespace Spyglass {
    typedef struct {
        uint64_t completed;// The number of completed changes processed.
        uint64_t total;// The total number of changes to be processed.
        uint64_t document_count;// Number of documents transferred so far.
    } SGReplicatorProgress;

    class SGReplicator {
    public:
        SGReplicator();

        /** SGReplicator.
        * @brief Initial setup the replicator.
        * @param replicator_configuration The SGReplicator configuration object.
        */
        SGReplicator(SGReplicatorConfiguration *replicator_configuration);

        virtual ~SGReplicator();

        enum ActivityLevel {
            kStopped = 0,
            kOffline,
            kConnecting,
            kIdle,
            kBusy
        };

        /** SGReplicator start.
        * @brief Starts a replicator background thread by calling _start().
        */
        bool start();

        /** SGReplicator stop.
        * @brief Stop a running replicator thread.
        */
        void stop();

        /** SGReplicator addChangeListener.
        * @brief Adds the callback function to the replicator's onStatusChanged event.
        * @param callback The callback function.
        */
        void addChangeListener(const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress)> &callback);

        /** SGReplicator addDocumentErrorListener.
        * @brief Adds the callback function to the replicator's onDocumentEnded event. (This can notifiy for error and also for added Doc to local DB)
        * @param callback The callback function.
        */
        void addDocumentEndedListener(
                const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,
                                         bool error_is_transient)> &callback);

        /** SGReplicator addValidationListener.
        * @brief Adds the callback function to the replicator's validationFunc event. All incoming revisions from SyncGateway will be accepted!
        * @param callback The callback function.
        */
        void addValidationListener(
                const std::function<void(const std::string &doc_id, const std::string &json_body)> &callback);


    private:
        C4Replicator *c4replicator_{nullptr};
        SGReplicatorConfiguration *replicator_configuration_{nullptr};
        C4ReplicatorParameters replicator_parameters_;
        C4Error c4error_ {};

        std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress progress)> on_status_changed_callback_;
        std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,
                           bool error_is_transient)> on_document_error_callback_;
        std::function<void(const std::string &doc_id, const std::string &json_body)> on_validation_callback_;

        /** SGReplicator setReplicatorType.
        * @brief Set the replicator type to the C4ReplicatorParameters.
        * @param replicator_type The enum replicator type to be used for the replicator.
        */
        void setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type);

        /** SGReplicator _start.
        * @brief Starts the replicator.
        * @param future_obj The future object used to send a signal to its running thread.
        */
        bool _start();

        bool isValidSGReplicatorConfiguration();
    };
}

#endif //SGREPLICATOR_H
