/**
******************************************************************************
* @file SGReplicatorConfiguration .H
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/9/18
* @brief Replicator Configuration
******************************************************************************
* @copyright Copyright 2018 ON Semiconductor
*/

#ifndef SGREPLICATORCONFIGURATION_H
#define SGREPLICATORCONFIGURATION_H

#include "SGDatabase.h"
#include "SGURLEndpoint.h"
#include "SGAuthenticator.h"
namespace Spyglass {
    class SGReplicatorConfiguration {
    public:
        SGReplicatorConfiguration();

        /** SGReplicatorConfiguration.
        * @brief Sets private members.
        * @param db The reference to the SGDatabase
        * @param url_endpoint The reference to the SGURLEndpoint object.
        */
        SGReplicatorConfiguration(SGDatabase *db, SGURLEndpoint *url_endpoint);

        virtual ~SGReplicatorConfiguration();

        enum class ReplicatorType {
            kPushAndPull = 0,
            kPush,
            kPull
        };

        SGDatabase *getDatabase() const;

        void setDatabase(SGDatabase *database);

        const SGURLEndpoint *getUrlEndpoint() const;

        void setUrlEndpoint_(SGURLEndpoint *url_endpoint);

        ReplicatorType getReplicatorType() const;

        void setReplicatorType(ReplicatorType replicator_type);

        void setAuthenticator(SGAuthenticator *authenticator);

        const SGAuthenticator *getAuthenticator() const;

        void setChannels(const std::vector<std::string> &channels);

        /** SGReplicatorConfiguration effectiveOptions.
        * @brief Initialize and build the options for the replicator
        */
        fleece::Retained<fleece::impl::MutableDict> effectiveOptions();

        /** SGReplicatorConfiguration isValid.
        * @brief Validate database_ and url_endpoint_ references.
        */
        bool isValid() const;

    private:
        SGDatabase *database_{nullptr};
        SGAuthenticator *authenticator_{nullptr};

        SGURLEndpoint *url_endpoint_{nullptr};

        ReplicatorType replicator_type_;

        std::vector<std::string> channels_;

        //Holds all extra configuration for the replicator
        fleece::Retained<fleece::impl::MutableDict> options_;

        // Options for the replicator progress level
        const int kNotifyOnEveryDocumentChange = 1;
        const int kNotifyOnEveryAttachmentChange = 2;
    };
}

#endif //SGREPLICATORCONFIGURATION_H
