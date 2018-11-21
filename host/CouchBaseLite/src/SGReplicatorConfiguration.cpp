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

#define DEBUG(...) printf("SGReplicatorConfiguration: "); printf(__VA_ARGS__)

SGReplicatorConfiguration::SGReplicatorConfiguration() {}

SGReplicatorConfiguration::~SGReplicatorConfiguration() {}

/** SGReplicatorConfiguration.
* @brief Sets private members.
* @param db The reference to the SGDatabase
* @param url_endpoint The reference to the SGURLEndpoint object.
*/
SGReplicatorConfiguration::SGReplicatorConfiguration(class SGDatabase *db, SGURLEndpoint *url_endpoint) {
    database_ = db->getC4db();
    url_endpoint_ = url_endpoint;
}

C4Database *SGReplicatorConfiguration::getDatabase() const {
    return database_;
}

void SGReplicatorConfiguration::setDatabase(const class SGDatabase &database) {
    database_ = database.getC4db();
}

const SGURLEndpoint *SGReplicatorConfiguration::getUrlEndpoint() const {
    return url_endpoint_;
}

void SGReplicatorConfiguration::setUrlEndpoint_(class SGURLEndpoint *url_endpoint) {
    url_endpoint_ = url_endpoint;
}

SGReplicatorConfiguration::ReplicatorType SGReplicatorConfiguration::getReplicatorType() const {
    return replicator_type_;
}

void SGReplicatorConfiguration::setReplicatorType(SGReplicatorConfiguration::ReplicatorType replicator_type_) {
    SGReplicatorConfiguration::replicator_type_ = replicator_type_;
}
