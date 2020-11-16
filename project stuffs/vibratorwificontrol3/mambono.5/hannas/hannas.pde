#include <WaspSensorEvent_v20.h>
#include <WaspWIFI.h>
#include <WaspXBeeZB.h>
#include <WaspFrame.h>
////////////////CONTENTS/////////////////
//    1.sensor variables/functions
//    2.wifi settings

///////////WATER LEVEL ////////////////////
float value_tilt,value_vibrate,value_force;
int servo = DIGITAL8;
int servo1 = DIGITAL2;
int angle;
unsigned int us;
void servoWrite(int servo, int angle);
char* dataFlood="FLOOD DETECTED!!!";
char* dataNoFlood="NO FLOOD DETECTED!!!";
/////////////////////////////////////////////

//////////SERVO MOTOR (DOOR LOCK)//////////////////////
int servolock = DIGITAL6;
int anglelock;
unsigned int uslock;
void servolockWrite(int servolock, int anglelock);

void servolockWrite(int servolock, int anglelock)
{
  for(int i=0; i<20; i++)
  {
    uslock = (anglelock*11) + 450;  // Convert angle to microseconds
    digitalWrite(servolock, HIGH);
    delayMicroseconds(uslock);
    digitalWrite(servolock, LOW);
    delay(50);    // Refresh cycle of servo
  }               
}
////////////////////////////////////////////

//////////////WIFI STUFF////////////////////
float valuetemp,valuehum,valueres,valuepir,valuedoor;
//select socket
uint8_t socket=SOCKET1;
//wifi settings
#define ESSID   "2pass2curious"
#define AUTHKEY "hanandnas"
//specify message to send via wifi
char tosend[128];
//answer parser
char buffer[100];
uint8_t field1;
uint8_t field2;
uint8_t field3;
uint8_t field4;
/////////////////////////////////////////////



void setup()
{ 
  USB.ON();
  ACC.ON();
// 2.1 Setting Digital 5 as an input
  pinMode(DIGITAL4,INPUT); //where OUTPUT of Water Level
//Detector connected to

  WIFI.ON(socket);
  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(UDP);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  // 3. Configure how to connect the AP.
  WIFI.setJoinMode(MANUAL);
  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 5. Save Data to module's memory
  WIFI.storeData();
  
  USB.println(F("start"));
  SensorEventv20.ON();

  pinMode(servo, OUTPUT);
  pinMode(DIGITAL4,OUTPUT);
  pinMode(servolock, OUTPUT);
  
  PWR.setSensorPower(SENS_5V,SENS_ON);
 }

void loop()
{
  /////////////WIFI LOOP////////////////////
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {   
    USB.println(F("Switched on"));

    // If it is manual, call join giving the name of the AP 
    if(WIFI.join(ESSID)) 
    { 
      // Switches on green led to show us it's connected.
      Utils.setLED(LED1, LED_ON);

      // 4. Creates UDP connection.
      if (WIFI.setUDPclient("255.255.255.255",12345,2000))
      {
        // 5. Now we can use send and read functions to send and
        // receive UDP messages.
        while(1)
        {

          valueres = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);
          valuedoor = SensorEventv20.readValue(SENS_SOCKET3, SENS_RESISTIVE);
          valuepir = SensorEventv20.readValue(SENS_SOCKET7);

          char door[10];
          char res[10];
          char pir[10];
          int n;
  
          dtostrf(valuetemp,5,2,door);
          dtostrf(valueres,5,2,res);
          dtostrf(valuepir,5,2,pir);
          char sensorinfo[50];
  
  
  
  
          USB.println("%RH\n");
          USB.print(F("Luminosity: "));
          USB.print(valueres);
          USB.println("Ohms\n");
          USB.print(F("PIR: "));
          USB.print(valuepir);
          USB.println("\n");
          USB.print(F("Door pressure: "));    
          USB.print(valuedoor);
          USB.println("\n");
          delay(1000);
          // 6. Send data to the IOS smartphone
          sprintf(tosend,"Group3;%s;%s;-;-;%s;-;%d;%d;%d;", door, res, pir,ACC.getY(),ACC.getX(),ACC.getZ());
          WIFI.send(tosend);
          
          // Reads data to the IOS smartphone
          if( WIFI.read(NOBLO) > 0 )
          {          
            // get answers
            field1 = WIFI.answer[0] - 48;
            field2 = WIFI.answer[2] - 48;
            field3 = WIFI.answer[4] - 48;
                     
            // manage green LED with switch1
            if( field1 == 0 )
            {
              Utils.setLED( LED1, LED_ON );
            }
            else
            {
              Utils.setLED( LED1, LED_OFF );              
            }
            
            // manage red LED with switch2
            if( field2 == 0 )
            {
              servolockWrite(servolock, 90);
              USB.printf("door unlocked");
              delay(50);
            }
            else
            {
              servolockWrite(servolock,0);          
              USB.printf("door locked");
              delay(50);   
            } 
      
            if( field3 == 0)
            {
              digitalWrite(DIGITAL4,HIGH);
            }
            else
            {
              digitalWrite(DIGITAL4,LOW);
            }      
               
          }
        }
      }
      
      
      else
      {
        USB.println(F("ERROR setting UDP client"));
      }
    }
    else
    {
      USB.println(F("ERROR joining"));
    }
  }
  else
  {
    USB.println(F("ERROR switching on"));
  }
  
  ///////////////////END OF WIFI LOOP/////////////////////////
  
  
  USB.print("Value read from Digital 4: ");
  USB.println(digitalRead(DIGITAL4),DEC);
  if (digitalRead(DIGITAL4) == 0)
  {
     servoWrite(servo, 0); 
    USB.printf("0 degrees\n");
    Utils.blinkLEDs(1000);
    USB.println(dataFlood);
  }
  else
  {
    servoWrite(servo, 180); 
    USB.printf("150 degrees\n");
    USB.println(dataNoFlood);
    delay(3000);
}
  
  value_tilt = SensorEventv20.readValue(SENS_SOCKET2);
// Print the info
USB.print(F("Tilt Sensor output: "));    
USB.print(value_tilt);
USB.println(F(" Volts"));
// 1.2 Read the vibration sensor output
value_vibrate = SensorEventv20.readValue(SENS_SOCKET4);
// Print the info
USB.print(F("Vibration Sensor output: "));    
USB.print(value_vibrate);
USB.println(F(" Volts"));
// 1.3. Read the strain gauge sensor voltage output
value_force = SensorEventv20.readValue(SENS_SOCKET3);
// Print the info
USB.print(F("Sensor output: "));    
USB.print(value_force);
USB.println(F(" Volts"));
// 1.3. Read the flexi force sensor output
value_force = SensorEventv20.readValue(SENS_SOCKET3, SENS_RESISTIVE);
// Print the info
USB.print(F("Resistance: "));    
USB.print(value_force);
USB.println(F("kohms\n"));
delay(1000);

int num = int(value_force);

USB.println(num);
delay(1000);

if(num == 0)
{
  servoWrite(servo, 0); 
  USB.printf("0 degrees\n");
  digitalWrite(DIGITAL4, LOW);
  delay(500);
}
else
{
  servoWrite(servo, 150); 
  USB.printf("150 degrees\n");
  digitalWrite(DIGITAL4, HIGH);
  delay(500);
}
  
}
void servoWrite(int servo, int angle)
{
  for(int i=0; i<20; i++){
  us = (angle*11) + 450;  // Convert angle to microseconds
  digitalWrite(servo, HIGH);
  delayMicroseconds(us);
  digitalWrite(servo, LOW);
  delay(50);    // Refresh cycle of servo
}    
}
void servoWrite1(int servo1, int angle)
{
  for(int i=0; i<20; i++){
  us = (angle*11) + 450;  // Convert angle to microseconds
  digitalWrite(servo1, HIGH);
  delayMicroseconds(us);
  digitalWrite(servo1, LOW);
  delay(50);    // Refresh cycle of servo
}    
}

