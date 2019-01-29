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
#include <FleeceImpl.hh>
using namespace std;
using namespace fleece;
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

        // c4address_fromURL won't set proper or complete path
        // ws://localhost:4984/staging
        // schema: ws
        // hostname: localhsot
        // port: 4984
        // path: /
        // Note: staging will be set in dbname. which is the remote DB to replicate from
        if (c4address_fromURL(c4str(uri.c_str()), &c4address_, &dbname)) {
            DEBUG("c4address_fromURL is valid\n");
            setHost( slice(c4address_.hostname).asString() );
            // HACK
            setPath( slice(dbname).asString() );
            setSchema( slice(c4address_.scheme).asString() );
            setPort(c4address_.port);
        } else {
            DEBUG("Failed c4address_fromURL is not valid\n");
            throw logic_error("Failed to parse uri");
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
        c4address_.hostname = slice(host_);
    }

    const std::string &SGURLEndpoint::getSchema() const {
        return schema_;
    }

    void SGURLEndpoint::setSchema(const std::string &schema) {
        schema_ = schema;
        c4address_.scheme = slice(schema_);
    }

    const std::string &SGURLEndpoint::getPath() const {
        return path_;
    }

    void SGURLEndpoint::setPath(const std::string &path) {
        //Warning: Don't set c4address_.path here like other setters!
        // Given a url ws://localhost:4984/staging
        // staging would be the path
        path_ = path;
    }

    const uint16_t &SGURLEndpoint::getPort() const {
        return port_;
    }

    void SGURLEndpoint::setPort(const uint16_t &port) {
        port_ = port;
        c4address_.port = port_;
    }
}