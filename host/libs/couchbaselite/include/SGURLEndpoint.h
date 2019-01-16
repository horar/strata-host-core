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
#ifndef SGURLENDPOINT_H
#define SGURLENDPOINT_H

#include <string>

#include "c4.h"

namespace Spyglass {
    class SGURLEndpoint {

    public:
        SGURLEndpoint();

        SGURLEndpoint(const std::string &full_url);

        virtual ~SGURLEndpoint();

        const std::string &getHost() const;

        void setHost(const std::string &host);

        const std::string &getSchema() const;

        void setSchema(const std::string &schema);

        const std::string &getPath() const;

        void setPath(const std::string &path);

        const uint16_t &getPort() const;

        void setPort(const uint16_t &port);

        const C4Address &getC4Address() const;

    private:
        std::string uri;
        std::string host_;
        std::string schema_;
        std::string path_;
        uint16_t port_;

        C4Address c4address_;
    };
}

#endif //SGURLENDPOINT_H
