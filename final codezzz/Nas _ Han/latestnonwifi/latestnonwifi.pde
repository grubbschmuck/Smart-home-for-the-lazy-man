#include <WaspWIFI.h>



#include <WaspSensorEvent_v20.h>
float value_tilt;
float value_vibrate;
float valuedoor;
int servo = DIGITAL8;
int servo1 = DIGITAL2;
int angle;
unsigned int us;
void servoWrite(int servo, int angle);
char* dataFlood="Its Raining";
char* dataNoFlood="Dry weather";
const int LED=DIGITAL3;
const int GSR=ANALOG2;
int threshold=0;
int sensorValue;

// Variable to store the GSR Sensor value
char GSR_str[20];

// Specifies the message that is sent to the WiFi module. 
char message_str[100];

// define variable
float value_GSR;

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET1;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "WTCAP"
#define AUTHKEY "WTC1997@SEG"    
/////////////////////////////////

//build the String with the data that you will send
//through REST calls to your ThingSpeak server
char data_str[800];
char url_str[80];
char message[100];


// define variable for communication status
uint8_t status;

//How many values you will be pushing to ThingWorx
#define propertyCount 2

// The IP address will be dependent on your local network:
char server[] = "api.thingspeak.com";
    
//ThingSpeak Api key which replaces login credentials)
const char * myWriteAPIKey = "RLRB2MAL8GXG38OY";




//Interval of time at which you want the properties values to be sent to ThingSpeak server
int timeBetweenRefresh = 10000;
    
// last time you connected to the server, in milliseconds
unsigned long lastConnectionTime = 0;
unsigned long timeNow = 0;

// state of the connection last time through the main loop
boolean lastConnected = false;


void setup()
{

// Init USB port
USB.ON();

delay(50);
// 2.1 Setting Digital 5 as an input
pinMode(DIGITAL4,INPUT); //where OUTPUT of Water Level
pinMode(servo, OUTPUT);

timeNow = millis(); 
     if (timeNow - lastConnectionTime >= timeBetweenRefresh) 
     {
       // Switch ON the WiFi module on the desired socket
       if( WIFI.ON(socket) == 1 )
       {    
        USB.println(F("Acquiring data....."));
        USB.println(timeNow);
        lastConnectionTime = timeNow;
        acquireSensorValues();
  
        // If it is manual, call join giving the name of the AP 
        if( WIFI.join(ESSID) ) 
        { 
           USB.println(F("Post data using GET method..."));
           postSensorValues();
        } 
        else
        {
           USB.println(F("NOT joined"));
        }
       }
       else
       {
         USB.println(F("WiFi did not initialize correctly"));
       }
       WIFI.OFF(); 
     }


long sum=0;

pinMode(LED, OUTPUT);
digitalWrite(LED,LOW);
delay(1000);
for(int i=0;i<500;i++)
{
sensorValue=analogRead(GSR);
sum += sensorValue;
delay(5);
}
threshold = sum/500;
USB.print("threshold =");
USB.println(threshold);

//Detector connected to
PWR.setSensorPower(SENS_5V,SENS_ON);

USB.println(F("start"));
// Turn on the sensor board
SensorEventv20.ON();


  
    // Firstly, wait for signal stabilization  
    while( digitalRead(DIGITAL3) == 1 )
    {    
        USB.println(F("...wait for PIR sensor's stabilization"));
        delay(1000);
    }
    
    // Switch ON the WiFi module on the desired socket
    if( WIFI.ON(socket) == 1 )
    {    
        USB.println(F("WiFi switched ON"));
    }
    else
    {
        USB.println(F("WiFi did not initialize correctly"));
    }

    // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
    WIFI.setConnectionOptions(HTTP|CLIENT_SERVER);
    // 2. Configure the way the modules will resolve the IP address.
    WIFI.setDHCPoptions(DHCP_ON);
    // 3. Configure how to connect the AP 
    WIFI.setJoinMode(MANUAL);   
    // 4. Set the AP authentication key
    WIFI.setAuthKey(WPA1, AUTHKEY); 
    // 5. Save Data to module's memory
    WIFI.storeData(); 

    USB.println(F("**********WiFi setup done***********"));
    
    strcpy(url_str, "GET$/update"); 
    strcat(url_str,"?");

    lastConnectionTime = 0;
    timeNow = 0;



}


    void acquireSensorValues()
{
    // Read the sensor output
    value_GSR = SensorEventv20.readValue(SENS_SOCKET3);
    
    // Display the 4 sensor data
     dtostrf(value_GSR,1,2,GSR_str);

    // Convert sensor data from Float to String
    sprintf ( "#;%s;#", GSR_str);
    

    snprintf( message, sizeof(message), "GSR = %s \n"
    , GSR_str);
    USB.println( message );
}

void postSensorValues()
{        
    strcpy(data_str, "api_key=");
    strcat(data_str, myWriteAPIKey);
    
    strcat(data_str,"&field1=");
    strcat(data_str,GSR_str);
    
    strcat(data_str,"&field2=");
    strcat(data_str,GSR_str);
    
    strcat(data_str,"&field3=");
    strcat(data_str,GSR_str);
    
       
    
    
    USB.println(url_str);
    USB.println(data_str);

    status = WIFI.getURL(DNS,server,80,url_str,data_str);
    USB.println(status);
    USB.println(F("\n******************************\n"));
}

void loop()
{

  int temp;
  sensorValue=analogRead(GSR);
  USB.print("sensorValue=");
  USB.println(sensorValue);

  temp = threshold - sensorValue;
  if(abs(temp)>50)
  {
    sensorValue=analogRead(GSR);
    temp = threshold - sensorValue;
    if(abs(temp)>50)
    {
      digitalWrite(LED,HIGH);
      USB.println("YES!");
      delay(50);
      digitalWrite(LED,LOW);
      delay(50);
    }
  }
  delay(50);





// 1.3. Read the flexi force sensor output
valuedoor = SensorEventv20.readValue(SENS_SOCKET3, SENS_RESISTIVE);
// Print the info
USB.print(F("Value Door: "));    
USB.print(valuedoor);
USB.println(F("kohms\n"));
delay(50);

int num = int(valuedoor);

USB.println(num);
delay(50);

if(num == 0)
{
  servoWrite(servo, 0); 
  USB.printf("Door closed\n");
  delay(50);
}
else
{
  servoWrite(servo, 150); 
  USB.printf("Door open\n");
  delay(50);
}

  
// Getting Value from Digital 5
USB.print("Value read from Digital 5: ");
USB.println(digitalRead(DIGITAL4),DEC);
if (digitalRead(DIGITAL4) == 0)
{
 USB.println(dataNoFlood);
servoWrite(servo1, 270); 
USB.printf(" Open\n");
delay(50);


}
else
{
  USB.println(dataFlood);
  servoWrite(servo1, 0); 
  USB.printf("Close\n");
  delay(50);
Utils.blinkLEDs(1000);
}
}

void servoWrite(int servo, int angle)
{
  for(int i=0; i<20; i++)
  {
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
