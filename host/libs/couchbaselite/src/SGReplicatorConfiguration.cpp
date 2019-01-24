/**
******************************************************************************
* @file SGReplicatorConfiguration .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/9/18
* @brief Replicator Configuration
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/

#include "SGReplicatorConfiguration.h"


using namespace std;
using namespace fleece;
using namespace fleece::impl;
#define DEBUG(...) printf("SGReplicatorConfiguration: "); printf(__VA_ARGS__)

namespace Spyglass {
    SGReplicatorConfiguration::SGReplicatorConfiguration() {
        options_ = fleece::impl::MutableDict::newDict();
    }

    SGReplicatorConfiguration::~SGReplicatorConfiguration() {}

    /** SGReplicatorConfiguration.
    * @brief Sets private members.
    * @param db The reference to the SGDatabase
    * @param url_endpoint The reference to the SGURLEndpoint object.
    */
    SGReplicatorConfiguration::SGReplicatorConfiguration(SGDatabase *db, SGURLEndpoint *url_endpoint)
            : SGReplicatorConfiguration() {
        setDatabase(db);
        setUrlEndpoint_(url_endpoint);
    }

    SGDatabase *SGReplicatorConfiguration::getDatabase() const {
        return database_;
    }

    void SGReplicatorConfiguration::setDatabase(SGDatabase *database) {
        database_ = database;
    }

    const SGURLEndpoint *SGReplicatorConfiguration::getUrlEndpoint() const {
        return url_endpoint_;
    }

    void SGReplicatorConfiguration::setUrlEndpoint_(SGURLEndpoint *url_endpoint) {
        url_endpoint_ = url_endpoint;
    }

    SGReplicatorConfiguration::ReplicatorType SGReplicatorConfiguration::getReplicatorType() const {
        return replicator_type_;
    }

    void SGReplicatorConfiguration::setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type) {
        replicator_type_ = replicator_type;
    }

    void SGReplicatorConfiguration::setAuthenticator(SGAuthenticator *authenticator) {
        authenticator_ = authenticator;
    }

    const SGAuthenticator *SGReplicatorConfiguration::getAuthenticator() const {
        return authenticator_;
    }

    void SGReplicatorConfiguration::setChannels(const std::vector<std::string> &channels) {
        // Pass vector channels by copy!
        channels_ = channels;
    }

    /** SGReplicatorConfiguration effectiveOptions.
    * @brief Initialize and build the options for the replicator
    */
    fleece::Retained<fleece::impl::MutableDict> SGReplicatorConfiguration::effectiveOptions() {

        if (authenticator_ != nullptr) {
            // This will add authentication options to the fleece dictionary.
            authenticator_->authenticate(options_);
        }
        // Here we can process more options and add it to options_

        // If >=1, notify on every doc; if >=2, on every attachment (int)
        options_->set(slice(kC4ReplicatorOptionProgressLevel), kNotifyOnEveryDocumentChange);

        // Get all channels name to be filtered by the pull replicator
        if (!channels_.empty()) {
            // Set fleece arrays the values stored in the channels_ vector
            Retained<MutableArray> channels_array = MutableArray::newArray(channels_.size());
            for (unsigned int index = 0; index < channels_.size(); index++) {
                channels_array->set(index, channels_[index]);
            }
            options_->set(slice(kC4ReplicatorOptionChannels), channels_array);

        }

        return options_;
    }
}