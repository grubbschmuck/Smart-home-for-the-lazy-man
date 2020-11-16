#include <WaspSensorEvent_v20.h>
#include <WaspWIFI.h>
#include <WaspXBeeZB.h>
#include <WaspFrame.h>
////////////////CONTENTS/////////////////
//    1.sensor variables/functions
//    2.wifi settings
//digital 6 motor
//digital 2 buzzer
//digital 8 lights
//////////////WIFI STUFF////////////////////
float valuepir;
//select socket
uint8_t socket=SOCKET1;
//wifi settings
#define ESSID   "ANDROID6"
#define AUTHKEY "password6"
//specify message to send via wifi
char tosend[128];
//answer parser
char buffer[100];
uint8_t field1;
uint8_t field2;
uint8_t field3;
uint8_t field4;
int wificheck = 0;
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





void setup()
{ 
  USB.ON();
  ACC.ON();
// 2.1 Setting Digital 5 as an input
  //pinMode(DIGITAL4,INPUT); //where OUTPUT of Water Level
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
  
  pinMode(DIGITAL2, OUTPUT);
   pinMode(DIGITAL8, OUTPUT);
  
  USB.println(F("start"));
  SensorEventv20.ON();

  
  //pinMode(DIGITAL4,OUTPUT);
  pinMode(servolock, OUTPUT);
  
  PWR.setSensorPower(SENS_5V,SENS_ON);
 }

void loop()
{

  
  /////////////WIFI LOOP////////////////////
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {   
    USB.println(F("\nWi-Fi Connected."));

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
        //while(1)
        //{


//          valuepir = SensorEventv20.readValue(SENS_SOCKET7);
//
//
//          char pir[10];
//          int n;
//  
//
//          dtostrf(valuepir,5,2,pir);
//          char sensorinfo[50];
          
          valuepir = SensorEventv20.readValue(SENS_SOCKET7);
          wificheck = 1;
          char strpir[10];
          dtostrf(valuepir,5,2,strpir);
          int intpir = int(valuepir);
          USB.print(F("PIR: "));
          USB.println(intpir);
          USB.println("\n");
          
//          while( intpir == 1 )
//          { 
          
          if(intpir == 0)
          {
            digitalWrite(DIGITAL2,LOW);
            digitalWrite(DIGITAL8,LOW);
            USB.printf("No burglar detected. Buzzer and light OFF. \n");
          }
          else
          {
            digitalWrite(DIGITAL2,HIGH);
            digitalWrite(DIGITAL8,HIGH);
            USB.printf("Burglar detected! Buzzer and light ON! \n");
          }
          
          
          
          sprintf(tosend,"Group3;%s;-;-;-;-;-;%d;%d;%d;",strpir,ACC.getY(),ACC.getX(),ACC.getZ());
          WIFI.send(tosend);  
          wificheck = 1;
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
              USB.printf("\ndoor unlocked\n");
            }
            else
            {
              servolockWrite(servolock,0);          
              USB.printf("\ndoor locked\n");
            } 
      
            if( field3 == 0)
            {
              digitalWrite(DIGITAL8,HIGH);
              USB.printf("Lights on");
            }
            else
            {
              digitalWrite(DIGITAL8,LOW);
              USB.printf("Lights off");
            }      
               
          }
        //}
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

  /////////////PIR Burglar alarm(buzzer and lights)/////////
// valuepir = SensorEventv20.readValue(SENS_SOCKET7);
// 
//
//  USB.print(F("PIR: "));
//  USB.print(valuepir);
//  USB.println("\n");
//  
//  
//  int intpir = int(valuepir);
//  USB.println(intpir);
//  
//  if (intpir == 0)
//  {
//    digitalWrite(DIGITAL1, LOW);
//    digitalWrite(DIGITAL7, LOW);
//  }
//  else
//  {
//    digitalWrite(DIGITAL1, HIGH);
//    digitalWrite(DIGITAL7, HIGH);
//  }
//
//  delay(50);

  ///////////////////////END///////////////////////////////


}


