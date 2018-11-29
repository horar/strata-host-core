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
    enum ReplicatorType{
        kPushAndPull = 0,
        kPush,
        kPull
    };

    virtual ~SGReplicatorConfiguration();

    C4Database* getDatabase() const;

    void setDatabase(const SGDatabase &database_);

    const SGURLEndpoint *getUrlEndpoint() const;

    void setUrlEndpoint_(SGURLEndpoint *url_endpoint_);

    ReplicatorType getReplicatorType() const;

    void setReplicatorType(ReplicatorType replicator_type);

    void setAuthenticator(const SGAuthenticator *authenticator);
    const SGAuthenticator* getAuthenticator() const;

    fleece::Retained<fleece::impl::MutableDict> effectiveOptions();

private:
    C4Database          *database_;
    class SGURLEndpoint *url_endpoint_;
    ReplicatorType      replicator_type_;
    SGAuthenticator     *authenticator_;

    //Holds all extra configuration for the replicator
    fleece::Retained<fleece::impl::MutableDict> options_;
};


#endif //SGREPLICATORCONFIGURATION_H
