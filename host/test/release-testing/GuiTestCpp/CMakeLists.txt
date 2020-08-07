project(GuiTestCpp
	LANGUAGES CXX
)
add_library(${PROJECT_NAME} SHARED StrataUI.h StrataUI.cpp HCS.cpp GuiTestCpp.cpp)
