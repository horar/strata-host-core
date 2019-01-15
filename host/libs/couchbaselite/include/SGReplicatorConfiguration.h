/**
******************************************************************************
* @file SGReplicatorConfiguration .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/9/18
* @brief Replicator Configuration
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/

#ifndef SGREPLICATORCONFIGURATION_H
#define SGREPLICATORCONFIGURATION_H

#include "SGDatabase.h"
#include "SGURLEndpoint.h"
#include "SGAuthenticator.h"
class SGReplicatorConfiguration {
public:
    SGReplicatorConfiguration();
    SGReplicatorConfiguration(SGDatabase *db, SGURLEndpoint *url_endpoint);
    virtual ~SGReplicatorConfiguration();

    enum class ReplicatorType{
        kPushAndPull = 0,
        kPush,
        kPull
    };

    C4Database* getDatabase() const;

    void setDatabase(const SGDatabase &database_);

    const SGURLEndpoint *getUrlEndpoint() const;

    void setUrlEndpoint_(SGURLEndpoint *url_endpoint_);

    ReplicatorType getReplicatorType() const;

    void setReplicatorType(ReplicatorType replicator_type);

    void setAuthenticator(const SGAuthenticator *authenticator);
    const SGAuthenticator* getAuthenticator() const;

    fleece::Retained<fleece::impl::MutableDict> effectiveOptions();

    void setChannels(const std::vector<std::string>& channels);

private:
    C4Database          *database_ {nullptr};
    SGAuthenticator     *authenticator_ {nullptr};
    class SGURLEndpoint *url_endpoint_ {nullptr};
    ReplicatorType      replicator_type_;

    std::vector<std::string> channels_;

    //Holds all extra configuration for the replicator
    fleece::Retained<fleece::impl::MutableDict> options_;

    // Options for the replicator progress level
    const int kNotifyOnEveryDocumentChange = 1;
    const int kNotifyOnEveryAttachmentChange = 2;
};


#endif //SGREPLICATORCONFIGURATION_H
