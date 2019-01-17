
#include <libserialport.h>
#include <string>
#include <thread>
#include <chrono>
#include <iostream>
#include <cstring>

#ifdef __APPLE__
        static const char* usb_keyword = "usb";
#elif __linux__
        static const char* usb_keyword = "USB";
#elif _WIN32
        static const char*  usb_keyword = "COM";
#endif

sp_port* g_port_handle = nullptr;


std::string enumerate_ports()
{
    sp_return ret;
    struct sp_port** ports;

    ret = sp_list_ports(&ports);

    std::string port_name;
    for (int i = 0; ports[i]; i++) {
        port_name = std::string(sp_get_port_name(ports[i]));

        size_t found = port_name.find(usb_keyword);
        if (found != std::string::npos) {
            break;
        }

    }

    sp_free_port_list(ports);
    return port_name;
}

bool write_command(const char* command)
{
    sp_return ret;
    size_t size = strlen(command);
    ret = sp_blocking_write(g_port_handle, command, size, 120);
    if(ret < 0) {
        return false;
    }
    return true;
}

bool read_data(std::string& data)
{
    sp_return ret;
    char buffer[1024];

    ret = sp_blocking_read(g_port_handle, buffer, sizeof(buffer), 200);
    if (ret < 0) {
        return false;
    }

    data.append(buffer, (size_t)ret);
    return true;
}

int main(int argc, char* argv[])
{
    const char* version = sp_get_lib_version_string();

    std::cout << "LibSerial version:" << std::string(version) << std::endl;


    std::string port_name = enumerate_ports();

    sp_return ret;

    ret = sp_get_port_by_name(port_name.c_str(), &g_port_handle);
    if(ret != SP_OK) {
        return -1;
    }
    ret = sp_open(g_port_handle, SP_MODE_READ_WRITE);
    if (ret != SP_OK) {
        return -1;
    }

    sp_set_stopbits(g_port_handle, 1);
    sp_set_bits(g_port_handle, 8);
    sp_set_baudrate(g_port_handle, 115200);
    sp_set_rts(g_port_handle, SP_RTS_OFF);
    sp_set_dtr(g_port_handle, SP_DTR_OFF);
    sp_set_parity(g_port_handle, SP_PARITY_NONE);
    sp_set_cts(g_port_handle, SP_CTS_IGNORE);

    ret = sp_flush(g_port_handle, SP_BUF_INPUT);

    //Flush reading buffer
//    do {
//        char buf_null[512];
//        ret = sp_blocking_read(port_handle, buf_null, sizeof(buf_null), 200);
//    } while(ret > 0);


    std::string read_buffer;
    read_buffer.reserve(1024);

    for(;;) {

//        char* cmd = "{\"cmd\":\"request_platform_id\",\"host\":\"Linusd,mfjgdksjsjkdfhsdgfhjsfasdfasddsdhskfaskfaksjdfnxgajkdsfngxkjadnsgfxjkansgxfajksdgnfxajksdnfxgfkasjfgajksfgkajdgsfkajajsgdfnxlksadhfm kxasxdfjkasjdjhfgh,cfo'hcifohicodfgi.hc'dof.hido'.chi'odf.i'hcodf,hdjmcicsdsdjflk;sjdf;lkasjd,fklsjdflkajsdflk;jasdklf;ja;lskdfjla;ksdjfl;aksjdfl;kadsjflk;asdjfl;kasjdflkjasdlfkjasl;kdfjklogus,doiugcisf,xkjasd,fxkljasxasdpxofas.mcsirugm;sirucg,osrducg,orgp,dfkxlhmdfichasdkfax\"}\n";
        const char* cmd = "{\"cmd\":\"request_platform_id\",\"host\":\"Linux\"}\n";
        write_command(cmd);

        if (read_data(read_buffer)) {
            std::cout << read_buffer;
            read_buffer.clear();
        }
    }

    return 0;
}
