#include <stdio.h>
#include <string.h>
#include <math.h>
#include <thread>
#include <string.h>
#include <unistd.h> // for sleep function
#include <iostream>
#include "zhelpers.hpp"
#include <libserialport.h> // cross platform serial port lib
//#include "protocol.h"

struct sp_port* platform_socket_;

void serial_test(struct sp_port* platform_socket_) {

	zmq::context_t context(1);
	zmq::socket_t notify(context,ZMQ_PUB);
	notify.bind("tcp://*:5564");
	std::vector<char> response;
	response.reserve(512);
	sp_event_set *ev;
	sp_new_event_set(&ev);
	sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);

	char* cmd="{\"cmd\":\"request_platform_id\",\"host\":\"Linux\"}\n";
	sp_blocking_write(platform_socket_,(void *)cmd,strlen(cmd),5);

	while(1) {
		char temp='\0';
		sp_wait(ev,0);
		sp_nonblocking_read(platform_socket_,(void *)&temp,1);

		if(temp!= '\n' && temp != '\0') {

			response.push_back(temp);
		} else if(temp == '\n') {

			std::string new_string(response.begin(),response.end());
			std::cout << "Received Message = " << new_string  << std::endl;
			response.clear();
			s_sendmore(notify,"ALL");
			s_send(notify,new_string);
		} else {

		}
	}
}

int main() {

	sp_get_port_by_name("COM7",&platform_socket_);
	sp_open(platform_socket_, SP_MODE_READ_WRITE);
	sp_return error;

	error = sp_set_stopbits(platform_socket_,1);

	if(error == SP_OK ) {

		std::cout << "stop bit set length = 1" <<std::endl;
	}

	error = sp_set_bits(platform_socket_,8);

	if(error == SP_OK ) {

		std::cout << "data bit length = 8" <<std::endl;
	}

	error = sp_set_rts(platform_socket_,SP_RTS_OFF);
	if(error == SP_OK ) {

		std::cout << "rts disabled" <<std::endl;
	}

	error = sp_set_baudrate(platform_socket_,9600);
	if(error == SP_OK ) {

		std::cout << "baud rate = 9600" <<std::endl;
	}

	error= sp_set_dtr(platform_socket_,SP_DTR_OFF);
	if(error == SP_OK ) {

		std::cout << "dts disabled" <<std::endl;
	}

	error= sp_set_parity(platform_socket_,SP_PARITY_NONE );
	if(error == SP_OK ) {

		std::cout << "parity bit = NONE" <<std::endl;
	}

	error = sp_set_cts(platform_socket_,SP_CTS_IGNORE );
	if(error == SP_OK ) {

		std::cout << "cts = IGNORE" <<std::endl;
	}

	std::thread t(serial_test,platform_socket_);
	t.join();
	return 0;
}
