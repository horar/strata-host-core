/**
******************************************************************************
* @file SGUtility .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 1/15/19
* @brief Utility
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*/

#include "SGUtility.h"
#include "FleeceImpl.hh"
namespace Spyglass{

    bool isC4Error(C4Error &err){
        static const uint32_t kSGNoCouchBaseError_ = 0;
        if(err.code != kSGNoCouchBaseError_ && err.code < kC4NumErrorCodesPlus1){
            fleece::alloc_slice error_message = c4error_getDescription(err);
            printf("%s -- ", error_message.asString().c_str());

            // C4Error is usually private member and reusable.
            // The C API for couchbase-lite-core requires multiple function call to do one operation.
            // Because of this, a successful call does not change the property of C4Error, hence it’s only for reporting errors.
            // So, reset needs to be done either in this function or after each call to isC4Error().
            err = {};
            return true;
        }
        return false;
    }
}
