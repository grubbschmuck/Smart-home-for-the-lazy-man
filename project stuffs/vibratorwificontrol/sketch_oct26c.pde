/*  
 *  ------ Waspmote Pro Code Example -------- 
 *  
 *  Explanation: This is the basic Code for Waspmote Pro
 *  
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 */
     
// Put your libraries here (#include ...)

#include <WaspSensorEvent_v20.h>

float value_temp,valuehum,valueres,valuepir;
int num;

void setup() {
    // put your setup code here, to run once:
  USB.ON();
  pinMode(DIGITAL4, OUTPUT);
  PWR.setSensorPower(SENS_5V,SENS_ON);
  USB.println(F("start"));
  
  SensorEventv20.ON();
}


void loop() {
  value_temp = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
  valuehum = SensorEventv20.readValue(SENS_SOCKET6, SENS_HUMIDITY);
  valueres = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);
  valuepir = SensorEventv20.readValue(SENS_SOCKET7);
  
  //Temperature
  USB.print(F("Temperature: "));
  USB.print(value_temp);
  USB.println(F(" Celsius\n"));
  
  //Humidity
  USB.print(F("Humidity: "));
  USB.print(valuehum);
  USB.println(F(" RH\n"));
  
  //Resistance
  USB.print(F("Resistance: "));
  USB.print(valueres);
  USB.println(F(" kohms\n"));
  num=valueres;
  
  //PIR output
  USB.print(F("PIR output: "));
  USB.print(valuepir);
  USB.print(F("\n"));
  
  if(num > 4)
  {
  digitalWrite(DIGITAL4, HIGH);
  delay(500);
  }
  else
  {
  digitalWrite(DIGITAL4, LOW);
  delay(500);
  }
  

}

