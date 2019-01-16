/**
******************************************************************************
* @file SGURLEndpoint .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 11/9/18
* @brief Simple URI interface
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/
#include "SGURLEndpoint.h"
using namespace std;
#define DEBUG(...) printf("SGURLEndpoint: "); printf(__VA_ARGS__)

namespace Spyglass {
    SGURLEndpoint::SGURLEndpoint() {}

    SGURLEndpoint::~SGURLEndpoint() {}

    /** SGReplicatorConfiguration.
    * @brief Initial setup the replicator.
    * @param db The reference to the SGDatabase
    * @param url_endpoint The reference to the SGURLEndpoint object.
    */
    SGURLEndpoint::SGURLEndpoint(const std::string &full_url) : uri(full_url) {
        C4String dbname;

        if (c4address_fromURL(c4str(uri.c_str()), &c4address_, &dbname)) {
            DEBUG("c4address_fromURL is valid\n");
            setHost(string((char *) c4address_.hostname.buf, c4address_.hostname.size));
            setPath(string((char *) dbname.buf, dbname.size));
            setSchema(string((char *) c4address_.scheme.buf, c4address_.scheme.size));
            setPort(c4address_.port);
        } else {
            DEBUG("Failed c4address_fromURL is not valid\n");
        }
    }

    const C4Address &SGURLEndpoint::getC4Address() const {
        return c4address_;
    }

    const std::string &SGURLEndpoint::getHost() const {
        return host_;
    }

    void SGURLEndpoint::setHost(const std::string &host) {
        host_ = host;
    }

    const std::string &SGURLEndpoint::getSchema() const {
        return schema_;
    }

    void SGURLEndpoint::setSchema(const std::string &schema) {
        schema_ = schema;
    }

    const std::string &SGURLEndpoint::getPath() const {
        return path_;
    }

    void SGURLEndpoint::setPath(const std::string &path) {
        path_ = path;
    }

    const uint16_t &SGURLEndpoint::getPort() const {
        return port_;
    }

    void SGURLEndpoint::setPort(const uint16_t &port) {
        port_ = port;
    }
}