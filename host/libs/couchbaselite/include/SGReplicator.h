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

#include "c4.h"

#include "SGDatabase.h"
#include "SGReplicatorConfiguration.h"

typedef struct{
    uint64_t completed;// The number of completed changes processed.
    uint64_t total;// The total number of changes to be processed.
    uint64_t document_count;// Number of documents transferred so far.
}SGReplicatorProgress;
class SGReplicator {
public:
    SGReplicator();
    SGReplicator(SGReplicatorConfiguration *replicator_configuration);
    virtual ~SGReplicator();

    enum ActivityLevel{
        kStopped=0,
        kOffline,
        kConnecting,
        kIdle,
        kBusy
    };
    bool start();
    void stop();
    void addChangeListener(const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress)>& callback);
    void addDocumentEndedListener(const std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool error_is_transient)>& callback );
    void addValidationListener(const std::function<void(const std::string& doc_id, const std::string& json_body )>& callback);


private:
    C4Replicator                *c4replicator_ {nullptr};
    SGReplicatorConfiguration   *replicator_configuration_ {nullptr};
    C4ReplicatorParameters      replicator_parameters_;

    std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress progress)> on_status_changed_callback_;
    std::function<void(bool pushing, std::string doc_id, std::string error_message, bool is_error,bool error_is_transient)> on_document_error_callback_;
    std::function<void(const std::string& doc_id, const std::string& json_body )> on_validation_callback_;

    void setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type);
    bool _start();
    bool isValidSGReplicatorConfiguration();
};


#endif //SGREPLICATOR_H
