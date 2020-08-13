// HCSTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <ws2tcpip.h>
#include "HCS.h"

int main()
{
    int result;
    HCS* hcs = new HCS();
    result = hcs->Connect("127.0.0.1", "5563");
    if (result < 0) {
        printf("%s", gai_strerrorA(result));
    }
    char buf[1000];
    result = hcs->Recive(buf, 1000);
    if (result < 0) {
        printf("%s", gai_strerrorA(WSAGetLastError()));
    }
    else {
        printf("%s", buf);

    }
    
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or P,roject > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
