/*
 * HostControllerService.cpp
 *
 *  Created on: Aug 14, 2017
 *      Author: abhishek
 */

#include "HostControllerService.h"
#include "nimbus.h"

using namespace std;

AttachmentObserver::AttachmentObserver(void *hostP) {
	host = (host_packet *)hostP;
}

void AttachmentObserver::ValidateDocumentCallback(jsonString jsonBody) {
	 Connector::messageProperty message;
     message.message = jsonBody;
     host->service->sendNotification(message,host->notify);
}

HostControllerService::HostControllerService(string ipRouter,string ipPub) {

	_connect = false;
	conObj= new(ConnectFactory);

	context = new(zmq::context_t);
	notifyAll = new zmq::socket_t(*context,ZMQ_PUB);
	commandAck = new zmq::socket_t(*context,ZMQ_ROUTER);

	notifyAll->bind(ipPub.c_str());
	hostP.notify=notifyAll;

	commandAck->bind(ipRouter.c_str());
	hostP.command=commandAck;
}

HostControllerService::~HostControllerService() {}

/*!
 * \brief
 * 		 parse the received JSON from HostControllerClient
 * 		 verify if the command is supported and respond back
 */
bool HostControllerService::verifyReceiveCommand(string command, string *response) {

	StaticJsonBuffer<2000> jsonBuffer;
	StaticJsonBuffer<2000> tempBuf;
	StaticJsonBuffer<2000> returnBuffer;

	JsonObject& root = jsonBuffer.parseObject(command.c_str());
	JsonObject& returnRoot = tempBuf.createObject();
	JsonObject& retBuf = returnBuffer.createObject();

	if(!root.success()) {

		printf("PARSING UNSUCCESSFUL CHECK JSON BUFFER SIZE %s\n",command);
		return "Unsuccessful";
	}

	if(root.containsKey("events")) {

		string event = root["events"][0];

		if(!event.compare("ALL_EVENTS")) {

			returnRoot["cmd"]="register_event_notification";
			returnRoot["response_verbose"]="command_valid";
			returnRoot["return_value"]=true;
			retBuf["ack"]=returnRoot;

			//Convert json to string
			retBuf.printTo(*response);
			return true;
		} else {

			returnRoot["cmd"]="register_event_notification";
			returnRoot["response_verbose"]="command_valid";
			returnRoot["port_existence"]=false;
			retBuf["nack"]=returnRoot;
			retBuf.printTo(*response);
			return false;
		}
	} else if(root.containsKey("cmd")) {

		if(root["cmd"] == "request_platform_id") {

			if(root["Host_OS"] == "Linux") {

				root.printTo(*response);
				return true;
			} else {

				return false;
			}
		}
		else if(root["cmd"] == "request_usb_pd_output_voltage") {
			root.printTo(*response);
			return true;
		}
		else {

			return false;
		}
	} else {

		returnRoot["cmd"]="not_recognised";
		returnRoot["response_verbose"]="command_invalid";
		returnRoot["update_interval"]=1000;
		retBuf["nack"]=returnRoot;
		retBuf.printTo(*response);
		return false;
	}
	return false;
}

/*
 * \brief :
 *      callback function to to handle service side requests
 */
void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP) {

	HostControllerService::host_packet *host = (HostControllerService::host_packet *)hostP;
	HostControllerService *obj= host->hcs;
	zmq::socket_t *send = host->command;

	unsigned int     zmq_events;
	size_t           zmq_events_size  = sizeof(zmq_events);
	send->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);

	Connector::messageProperty message = host->service->receive(host->command);

	if(!message.message.compare("DISCONNECTED")) {

		cout << "Platform Disconnect detected " <<endl;
		event_base_loopbreak(host->base);
	}
	string response;

	bool ack=host->hcs->verifyReceiveCommand(message.message,&response);
	message.message=response;
	host->service->sendAck(message,host->command);

	if(ack == true ) {

		bool success = host->platform->sendNotification(message,host->hcs);

		if(success == true) {
			string log = "<--- To Platform = " + message.message;
			cout << "<--- To Platform = " << message.message <<endl;
		} else {

			cout << "Message send to platform failed " <<endl;
		}
	}
}

/*
 * \brief :
 *    Function to handle notification from platform
 */
void HostControllerService::callbackPlatformHandler(void* hostP) {

	HostControllerService::host_packet *host = (HostControllerService::host_packet *)hostP;
	HostControllerService *obj = host->hcs;
	zmq::socket_t *notify = host->notify;
	Connector::messageProperty message;

	sp_new_event_set(&ev);
	sp_add_port_events(ev, platform_socket_, SP_EVENT_RX_READY);

	while(1) {

		message = host->platform->receive((void *)host->hcs);

//  debug statements
		if(!message.message.compare("")) {

				//Do Nothing
		} else if(!message.message.compare("DISCONNECTED")) {

			cout << "Platform disconnected " <<endl;

			host->hcs->disconnect=message.message;
			message.message="{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
			host->service->sendNotification(message,host->notify);

			sp_close(platform_socket_);
			//Signal
			zmq::context_t context(1);
			zmq::socket_t signal(context,ZMQ_DEALER);
			signal.setsockopt(ZMQ_IDENTITY,"BREAK");
			signal.connect("tcp://127.0.0.1:5564");
			s_send(signal,"DISCONNECTED");
			return ;
		} else {

			if(!host->service->sendNotification(message,host->notify)) {

				string log = "Notification to UI Failed = " + message.message ;
				cout << "Notification to UI Failed = " << message.message <<endl;
			}
		}
	}
}

/*!
 * \brief :
 *    Open serial port to platform
 */
bool HostControllerService::openPlatformSocket() {

#ifndef _WIN32
	error = sp_get_port_by_name("/dev/ttyUSB0",&platform_socket_);
#else
	error = sp_get_port_by_name("COM7",&platform_socket_);
#endif

	if(error == SP_OK) {

		error = sp_open(platform_socket_, SP_MODE_READ_WRITE);
		if(error == SP_OK) {
			cout << "Serial PORT OPEN SUCCESS "<<endl;
			Connector::messageProperty message;
			message.message="{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"connected\"}}}";
			hostP.service->sendNotification(message,hostP.notify);
			return true;
		} else {
			cout << "SERIAL PORT OPEN FAILED "<<endl;
			return false;
		}
	} else {
		cout << "REQUESTED PORT NOT PRESENT "<<endl;
		return false;
	}
}

/*!
 * \brief:
 *    Initialzes serial port configuration to match platform
 */
void HostControllerService::initPlatformSocket() {

	error = sp_set_stopbits(platform_socket_,1);

	if(error == SP_OK ) {

		cout << "stop bit set length = 1" <<endl;
	}

	error = sp_set_bits(platform_socket_,8);

	if(error == SP_OK ) {

		cout << "data bit length = 8" <<endl;
	}

	error = sp_set_rts(platform_socket_,SP_RTS_OFF);
	if(error == SP_OK ) {

		cout << "rts disabled" <<endl;
	}

	error = sp_set_baudrate(platform_socket_,115200);
	if(error == SP_OK ) {

		cout << "baud rate = 9600" <<endl;
	}

	error= sp_set_dtr(platform_socket_,SP_DTR_OFF);
	if(error == SP_OK ) {

		cout << "dts disabled" <<endl;
	}

	error= sp_set_parity(platform_socket_,SP_PARITY_NONE );
	if(error == SP_OK ) {

		cout << "parity bit = NONE" <<endl;
	}

	error = sp_set_cts(platform_socket_,SP_CTS_IGNORE );
	if(error == SP_OK ) {

		cout << "cts = IGNORE" <<endl;
	}

}

/*!
 * \brief:
 * 		  Initializes the HostContorllerService
 */
string HostControllerService::setupHostControllerService(string ipRouter, string ipPub) {

	Connector *cons = conObj->getServiceTypeObject("SERVICE");
	hostP.service = cons;

	Connector *conp = conObj->getServiceTypeObject("PLATFORM");
	hostP.platform = conp;

	// cloud integration
	// Initialize Nimbus object
    Nimbus local_db = Nimbus();
// Use the test database to observe
    local_db.Open(NIMBUS_TEST_PLATFORM_JSON);
    // NIMBUS integration **Needs better organisation --Prasanth**
	AttachmentObserver blobObserver((void *)&hostP);
	local_db.Register(&blobObserver);


	string cmd = "{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}";

	while(!openPlatformSocket()) {

		cout << "Waiting for Board to get Connected" <<endl;
#ifndef _WIN32
		sleep(2);
#else
		Sleep(2000);
#endif
	}

	initPlatformSocket();
	Connector::messageProperty message;
	message.message=cmd;
	conp->sendNotification(message,this);

#ifndef _WIN32
	int sockService=0;
	size_t size_sockService = sizeof(sockService);
#else
	unsigned long long int sockService=0;
	size_t size_sockService = sizeof(sockService);
#endif

	hostP.command->getsockopt(ZMQ_FD,&sockService,&size_sockService);

	hostP.hcs=this;

	struct event_base *base = event_base_new();
	hostP.base = base;

	thread t(&HostControllerService::callbackPlatformHandler,this,(void *)&hostP);
	//EV_ET says its edge triggered. EV_READ and EV_WRITE are both
	//needed when event is added else it doesn't function properly
	//As libevent READ and WRITE functionality is affected by edge triggered events.
	struct event *service = event_new(base, sockService ,
			EV_READ | EV_WRITE | EV_ET | EV_PERSIST ,
			callbackServiceHandler,(void *)&hostP);

	if (event_base_set(base,service) <0 )
		cout <<"Event BASE SET SERVICE FAILED "<<endl;

	if(event_add(service,NULL) <0 )
		cout<<"Event SERVICE ADD FAILED "<<endl;



	event_base_dispatch(base);
	t.join();
	cout << "returnting " <<endl;
	return disconnect;
}
