#include <WaspWIFI.h>
#include <WaspSensorEvent_v20.h>
#include <WaspXBeeZB.h>
#include <WaspFrame.h>

float valuetemp,valuehum,valueres,valuepir,valuedoor;



int servo = DIGITAL1;
int angle;
unsigned int us;

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


void setup() {
    // put your setup code here, to run once:
    USB.ON();
    pinMode(servo, OUTPUT);
    PWR.setSensorPower(SENS_5V,SENS_ON);

}


void loop() {
    // put your main code here, to run repeatedly:
    //valuedoor = SensorEventv20.readValue(SENS_SOCKET3, SENS_RESISTIVE);
    
     USB.print(F("/npressure: "));
    USB.print(valuedoor);
    USB.print(angle);
    
    servoWrite(servo, 0); //opens door 90 degrees
     delay(500);
    servoWrite(servo, 45); // closes door??
    delay(500);
    
    digitalWrite(DIGITAL1,HIGH);
    delay(500);
    digitalWrite(DIGITAL1,LOW);
   USB.print(angle);
}

