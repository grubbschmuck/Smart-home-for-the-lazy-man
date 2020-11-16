#include <WaspSensorEvent_v20.h>
float value_tilt;
float value_vibrate;
float value_force;
int servo = DIGITAL8;
int angle;
unsigned int us;
void servoWrite(int servo, int angle);
char* dataFlood="FLOOD DETECTED!!!";
char* dataNoFlood="NO FLOOD DETECTED!!!";


void setup()
{ 
  USB.ON();
  delay(1000);
// 2.1 Setting Digital 5 as an input
  pinMode(DIGITAL4,INPUT); //where OUTPUT of Water Level
//Detector connected to

  
  USB.ON();
  
  USB.println(F("start"));
  SensorEventv20.ON();

  pinMode(servo, OUTPUT);
  PWR.setSensorPower(SENS_5V,SENS_ON);
  
  
}

void loop()
{
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

/*if(num == 0)
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
*/  
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
