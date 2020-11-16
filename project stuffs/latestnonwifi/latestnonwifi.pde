#include <WaspSensorEvent_v20.h>
float value_tilt;
float value_vibrate;
float valuedoor;
int servo = DIGITAL8;
int servo1 = DIGITAL2;
int angle;
unsigned int us;
void servoWrite(int servo, int angle);
char* dataFlood="FLOOD DETECTED!!!";
char* dataNoFlood="NO FLOOD DETECTED!!!";


void setup()
{

// Init USB port
USB.ON();

delay(50);
// 2.1 Setting Digital 5 as an input
pinMode(DIGITAL5,INPUT); //where OUTPUT of Water Level
pinMode(servo, OUTPUT);
//Detector connected to
PWR.setSensorPower(SENS_5V,SENS_ON);

USB.println(F("start"));
// Turn on the sensor board
SensorEventv20.ON();

}


void loop()
{


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
USB.println(digitalRead(DIGITAL5),DEC);
if (digitalRead(DIGITAL5) == 0)
{
  USB.println(dataFlood);
  servoWrite(servo1, 0); 
  USB.printf("Close\n");
  delay(50);
Utils.blinkLEDs(1000);

}
else
{
USB.println(dataNoFlood);
servoWrite(servo1, 270); 
USB.printf(" Open\n");
delay(50);
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
