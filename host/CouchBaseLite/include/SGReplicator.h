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
    bool stop();
    void addChangeListener(const std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress)>& callback);
    void addDocumentErrorListener(const std::function<void(bool, std::string, std::string, bool)>& callback );


private:
    C4Replicator *c4replicator_;
    SGReplicatorConfiguration *replicator_configuration_;
    C4ReplicatorParameters replicator_parameters_;

    std::function<void(SGReplicator::ActivityLevel, SGReplicatorProgress progress)> on_status_changed_callback_;
    std::function<void(bool, std::string, std::string, bool)> on_document_error_callback;

    std::thread replicator_thread_;
    std::promise<void> replicator_exit_signal;

    void setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type);
    bool _start(std::future<void> future_obj);
};


#endif //SGREPLICATOR_H
