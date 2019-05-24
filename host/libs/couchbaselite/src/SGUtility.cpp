/**
******************************************************************************
* @file SGUtility .CPP
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 1/15/19
* @brief Utility
******************************************************************************
* @copyright Copyright 2018 ON Semiconductor
*/

#include "SGUtility.h"
#include <FleeceImpl.hh>
namespace Spyglass{

    void logC4Error(const C4Error &err){
        fleece::alloc_slice error_message = c4error_getDescription(err);
        printf("%s -- ", error_message.asString().c_str());
    }
}
