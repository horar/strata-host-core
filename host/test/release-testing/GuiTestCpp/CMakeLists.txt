project(GuiTestCpp
	LANGUAGES CXX
)
add_library(${PROJECT_NAME} SHARED StrataUI.cpp HCS.cpp GuiTestCpp.cpp)
