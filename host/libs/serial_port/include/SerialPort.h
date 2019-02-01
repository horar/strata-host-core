
#ifndef PLATFORM_SERIALPORT_H
#define PLATFORM_SERIALPORT_H

#include <string>

struct sp_port;
struct sp_event_set;

class SerialPort
{
public:
    SerialPort();
    ~SerialPort();

    /**
     * Opens specified serial port
     * @param port_name - name of the serial port (device)
     * @return returns true when success otherwise false
     */
    bool open(const std::string& port_name);

    /**
     * Close serial port
     */
    void close();

    /**
     * Reads from serial port into specified buffer with size.
     * @param data_buffer data buffer to read into
     * @param buffer_size size of the data buffer
     * @param timeout timeout for read
     * @return returns number of bytes read or negative number means error.
     */
    int read(unsigned char* data_buffer, size_t buffer_size, unsigned int timeout = 250);

    /**
     * Writes to serial port
     * @param data_buffer data buffer to write
     * @param buffer_size size of the data buffer
     * @param timeout timeout to write
     * @return returns number of bytes written or negative number means error
     */
    int write(unsigned char* data_buffer, size_t buffer_size, unsigned int timeout);

    /**
     * Flushes serial port in/out buffers
     * NOTE: it doesn't work properlly on Mac
     * @return returns 0 on success or negative number as error
     */
    bool flush();

    /**
     * Returns file descriptor
     * @return returns file descriptor or -1 if the port is not open
     */
    int getFileDescriptor();

    /**
     * returns name of the serial port (device)
     * @return returns name or nullptr when the port is not open
     */
    const char* getName() const;

private:
    /**
     * setup serial port for Strata boards communication
     * e.g. 115200, 8 bit, 1 stop, no flow control
     */
    void setupSGFormat();

private:
    struct sp_port* portHandle_;
    struct sp_event_set* event_;

};

/**
 * Populate list of available serial ports
 * @param result_list list of serial ports names
 * @return returns true on success or false on error
 */
bool getListOfSerialPorts(std::vector<std::string>& result_list);


#endif //PLATFORM_SERIALPORT_H
