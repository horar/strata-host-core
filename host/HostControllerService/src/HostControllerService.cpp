/*
 * HostControllerService.cpp
 *
 *  Created on: Aug 14, 2017
 *      Author: abhishek
 */

#include "HostControllerService.h"

/*!
 * \brief :
 * 			Initialize ZMQ && USB related global parameters
 */

HostControllerService::HostControllerService(string ipRouter,string ipPub) {

	_platformSocket=0;
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

		dbgprint(LOG_DEBUG,"PARSING UNSUCCESSFUL CHECK JSON BUFFER SIZE");
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
		} else {

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


/*!
 * 	\brief:
 * 		Callback handle for servicing commands from HostControllerClient
 * 		@params: hostP, struct of type host_packet
 */
void callbackServiceHandler(evutil_socket_t fd ,short what, void* hostP ){

	HostControllerService::host_packet *host = (HostControllerService::host_packet *)hostP;
	int _plat = host->_plat;
	zmq::socket_t *send = host->command;

	unsigned int     zmq_events;
	size_t           zmq_events_size  = sizeof(zmq_events);
	send->getsockopt(ZMQ_EVENTS, &zmq_events, &zmq_events_size);

	if (zmq_events & ZMQ_POLLIN) {

		Connector::messageProperty message = host->service->receive((void *)host->command);

		string response;

		bool ack=host->hcs->verifyReceiveCommand(message.message,&response);
		message.message=response;
		host->service->sendAck(message,(void *) host->command);

		if(ack == true ) {

			bool success = host->platform->sendNotification(message,host->hcs);

			if(success == true) {
				string log = "<--- To Platform = " + message.message;
				dbgprint(LOG_WARNING,log.c_str());
				//cout << "<--- To Platform = " << message.message <<endl;
			} else {

				dbgprint(LOG_WARNING," Message send to platform failed ");
				//cout << "Message send to platform failed " <<endl;
			}
		}
	} else {
		//do nothing Has nothing available to receive
	}
}

/*!
 * 	\brief:
 * 		Callback handle, for notifying HostControllerClient about platform changes
 * 		@params: hostP, is of type struct host_packet
 */
void callbackPlatformHandler(evutil_socket_t fd ,short what, void* hostP) {


	HostControllerService::host_packet *host = (HostControllerService::host_packet *)hostP;
	int _plat = host->_plat;
	zmq::socket_t *notify = host->notify;
	Connector::messageProperty message;

	message = host->platform->receive((void *)host->hcs);

	if(!message.message.compare("")) {


	} else if(!message.message.compare("DISCONNECTED")) {

		host->hcs->disconnect=message.message;
		close(host->hcs->_platformSocket);
		message.message="{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"disconnected\"}}}";
		host->service->sendNotification(message,host->notify);
		event_base_loopbreak(host->base);
	} else {

		if(!host->service->sendNotification(message,(void *)host->notify)) {

			string log = "Notification to UI Failed = " + message.message ;
			dbgprint(LOG_WARNING,log.c_str());
			//cout << "Notification to UI Failed = " << message.message <<endl;
		}
	}
}

/*!
 * \brief:
 * 		Opens default serial socket path
 */
bool HostControllerService::openPlatformSocket() {

	_platformSocket = open(DEFAULT_SERIAL_PATH, O_RDWR | O_NOCTTY |O_NONBLOCK);

	if(_platformSocket < 0) {

		dbgprint(LOG_WARNING,"Platform Socket open failed ");
		//cout << "Platform Socket open failed " <<endl;
		close(_platformSocket);
		return false;
	} else {

		_connect = true;
		hostP._plat = _platformSocket;

		if(tcflush(_platformSocket,TCIOFLUSH) <0 ) {

			dbgprint(LOG_WARNING,"Socket Buffer clear failed ");
			//cout << "Socket Buffer clear failed "<<endl;
			close(_platformSocket);
		} else {

			dbgprint(LOG_WARNING,"Connection Opened to PLATFORM ");
			//cout << "Connection Opened to PLATFORM "<<endl;
			sleep(2);
			return true;
		}
		return false;
	}
}

/*
 * \brief:
 * 		Initializes the default serial socket
 * 		with needed parameters to start fruitful communication
 */
void HostControllerService::initPlatformSocket() {

	int rc = tcgetattr(_platformSocket, &_options);

	if(rc < 0) {

		string log = "failed to get errno = "+(string) strerror(errno);
		dbgprint(LOG_WARNING,log.c_str());
		//fprintf(stderr, "failed to get errno: %s\n", strerror(errno));
	}

	_options.c_cflag &= ~CRTSCTS;// Disable hardware flow control
	_options.c_cflag &= ~CSTOPB;// 1 stop bit
	_options.c_cflag= CBAUD | CS8 | CLOCAL | CREAD;
	_options.c_iflag=IGNPAR;
	_options.c_oflag=0;
	_options.c_lflag=0;
	_options.c_cc[VMIN]= 1;
	_options.c_cc[VTIME] = 2;
	cfsetospeed(&_options,9600);
	cfsetispeed(&_options,9600);

	rc = tcsetattr(_platformSocket, TCSANOW, &_options);

	if (rc < 0) {

		string log = "failed to get attr: errno = "+ (string)strerror(errno);
		dbgprint(LOG_WARNING,log.c_str());
		//printf("failed to get attr: errno: %s\n", strerror(errno));
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

	string cmd = "{\"cmd\":\"request_platform_id\",\"Host_OS\":\"Linux\"}\n";

	while(!openPlatformSocket()) {

		dbgprint(LOG_DEBUG,"Waiting for Board to get Connected ");
		//cout << "Waiting for Board to get Connected" <<endl;
		sleep(2);
	}

	initPlatformSocket();
	//Send board platform id request to USB PD Board
	Connector::messageProperty message;
	message.message=cmd;
	conp->sendNotification(message,this);

	//Send Platform Connected notification to HostControllerClient
	cmd="{\"notification\":{\"value\":\"platform_connection_change_notification\",\"payload\":{\"status\":\"connected\"}}}";
	message.message=cmd;
	cons->sendNotification(message,(void *)hostP.notify);

	int sockService=0;
	size_t size_sockService = sizeof(sockService);
	hostP.command->getsockopt(ZMQ_FD,&sockService,&size_sockService);

	hostP.hcs=this;

	struct event_base *base = event_base_new();
	hostP.base = base;
	struct event *platform = event_new(base,_platformSocket ,
			 	 	 	 	 	 	   EV_READ | EV_PERSIST ,
									   callbackPlatformHandler,(void *)&hostP);

	//EV_ET says its edge triggered. EV_READ and EV_WRITE are both
	//needed when event is added else it doesn't function properly
	//As libevent READ and WRITE functionality is affected by edge triggered events.
	struct event *service = event_new(base, sockService ,
									  EV_READ | EV_WRITE | EV_ET | EV_PERSIST ,
									  callbackServiceHandler,(void *)&hostP);

	if (event_base_set(base,platform) <0 )
		//cout <<"Event BASE SET PLATFORM FAILED "<<endl;
		dbgprint(LOG_DEBUG,"Event BASE SET PLATFORM FAILED ");

	if(event_add(platform,NULL) <0 )
		//cout<<"Event SEND PLATFORM FAILED "<<endl;
		dbgprint(LOG_DEBUG,"Event SEND PLATFORM FAILED ");

	//timeval i = {0,500};
	if (event_base_set(base,service) <0 )
		//cout <<"Event BASE SET SERVICE FAILED "<<endl;
		dbgprint(LOG_DEBUG,"Event BASE SET SERVICE FAILED ");

	if(event_add(service,NULL) <0 )
		//cout<<"Event SERVICE ADD FAILED "<<endl;
		dbgprint(LOG_DEBUG,"Event SERVICE ADD FAILED ");

	event_base_dispatch(base);
	return disconnect;
}
