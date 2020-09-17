#include <gtest/gtest.h>
#include "SGUserSettings-test.h"

int main(int argc, char** argv)
{
    testing::InitGoogleTest(&argc, argv);
    testing::AddGlobalTestEnvironment(new SGUserSettingsTestEnvironment);
    return RUN_ALL_TESTS();
}
