#include <WaspXBeeZB.h>
#include <WaspFrame.h>
#include <WaspSensorEvent_v20.h>

//Pointer to an XBee packet structure 
packetXBee* packet; 

// Destination MAC address
///////////////////////////////////////////////
char* MAC_ADDRESS="0013A20041030D70";
///////////////////////////////////////////////
float value_temp,valuehum,valueres,valuepir;

void setup() 
{
  //////////////////////////
  // 1. Init XBee
  //////////////////////////
  xbeeZB.ON();  
  
  delay(3000);	//delay 3 seconds
  
  //////////////////////////////////////////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////////////////////////////////////////
  checkNetworkParams();

  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);
  SensorEventv20.ON();
  
}

void loop() 
{    
  xbeeZB.ON();
  //////////////////////////
  // 3. create new frame
  //////////////////////////
 
  // 3.1. create new frame
  frame.createFrame(ASCII, "WASPMOTE_XBEE");  

  // 3.2. add frame fields
  frame.addSensor(SENSOR_STR, "XBee frame");
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

  
  //////////////////////////
  // 4. create new frame
  //////////////////////////
  value_temp = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
  valuehum = SensorEventv20.readValue(SENS_SOCKET6, SENS_HUMIDITY);
  valueres = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);
  valuepir = SensorEventv20.readValue(SENS_SOCKET7);
  
  char tmp[10];
  dtostrf(value_temp,5,2,tmp);

  // 4.1. set parameters to packet:
  packet=(packetXBee*) calloc(1,sizeof(packetXBee)); // Memory allocation
  packet->mode=UNICAST; // Choose transmission mode: UNICAST or BROADCAST 
  
  // 4.2. set destination XBee parameters to packet
  //xbeeZB.setDestinationParams( packet, MAC_ADDRESS, frame.buffer, frame.length);  
  xbeeZB.setDestinationParams( packet, MAC_ADDRESS, tmp,(unsigned)strlen(tmp)); 
  // 4.3. send XBee packet
  xbeeZB.sendXBee(packet);
  // 4.4. check TX flag
  if( xbeeZB.error_TX == 0) 
  {
    USB.println(F("ok"));
  }
  else 
  {
    USB.println(F("error"));
  }

  // 4.5. free variables
  free(packet);
  packet=NULL;

  // 4.6. wait for five seconds
  delay(5000);
}

/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();
 
  while( xbeeZB.associationIndication != 0 )
  { 
    delay(2000);
    
    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     
    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();
}
