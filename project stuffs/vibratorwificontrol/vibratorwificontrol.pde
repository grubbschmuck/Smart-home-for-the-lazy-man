
#include <WaspWIFI.h>
#include <WaspSensorEvent_v20.h>
#include <WaspXBeeZB.h>
#include <WaspFrame.h>

float valuetemp,valuehum,valueres,valuepir,valuedoorpressure;

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET1;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID   "ANDROID3"
#define AUTHKEY "password3"
/////////////////////////////////

// Specifies the message that is sent to the WiFi module.
char tosend[128];

// answer parser
char buffer[100];
uint8_t field1;
uint8_t field2;
uint8_t field3;
uint8_t field4;

void setup()
{
  // Initialize the accelerometer
  ACC.ON();

  // Switch on the WIFI module on the desired socket.
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
  SensorEventv20.ON();
  pinMode(DIGITAL4,OUTPUT);
  PWR.setSensorPower(SENS_5V,SENS_ON);
}

void loop()
{
  
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
            
  valuetemp = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
  valuehum = SensorEventv20.readValue(SENS_SOCKET6, SENS_HUMIDITY);
  valueres = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);
  valuedoor = SensorEventv20.readValue(SENS_SOCKET2, SENS_RESISTIVE);
  valuepir = SensorEventv20.readValue(SENS_SOCKET7);
  
  
  
  char tmp[10];
  char hum[10];
  char res[10];
  char pir[10];
  int n;
  
  dtostrf(valuetemp,5,2,tmp);
  dtostrf(valuehum,5,2,hum);
  dtostrf(valueres,5,2,res);
  dtostrf(valuepir,5,2,pir);
  char sensorinfo[50];
  
  if( valuedoor >= 1)
  {
    digitalWrite(DIGITAL2,HIGH); //closes the door
  }
  else if(valuedoor <= 1)
  {
    digitalWrite(DIGITAL2,LOW); // opens door
  }
  
  USB.print(F("Temp: "));
  USB.print(valuetemp);
  USB.println("Celsius\n");
  USB.print(F("Humidity: "));
  USB.print(valuehum);
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
          sprintf(tosend,"Group3;%s;%s;%s;-;%s;-;%d;%d;%d;",tmp, hum, res, pir,ACC.getY(),ACC.getX(),ACC.getZ());
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
              digitalWrite(DIGITAL2,HIGH);
            }
            else
            {
              digitalWrite(DIGITAL2,LOW);              
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

}







