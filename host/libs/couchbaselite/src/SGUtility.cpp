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
            err = {};
            return true;
        }
        return false;
    }
}
