#include <XBee.h>
XBee xbee = XBee();
HardwareSerial Uart = HardwareSerial();
//xbee receive
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();
uint8_t option = 0;
//
int ID = 0;
int joy1 = 0, joy2 = 0, joy3 = 0, joy4 = 0, joy5 = 0, joy6 = 0, joy7 = 0;

unsigned long sendTime = 0;

void setup() {
  pinMode(11, OUTPUT);
  pinMode(19, INPUT_PULLUP);
  pinMode(18, INPUT_PULLUP);
  pinMode(17, INPUT_PULLUP);
  pinMode(16, OUTPUT);
  analogWrite(A1, 170); //set pin 19 (xbee voltage) to ~3.3v
  pinMode(0, INPUT_PULLUP); //red - saved
  pinMode(1, INPUT_PULLUP); //white - start
  pinMode(13, INPUT_PULLUP); //blue - queue
  pinMode(14, INPUT_PULLUP); //yellow - intro
  Uart.begin(38400);
  xbee.setSerial(Uart);
  Serial.begin(38400);
}

void loop() {
  if(millis() - sendTime > 1500) {
    digitalWrite(16, LOW);
    sendTime = millis();
  }
  
  
  if(digitalRead(0)) {
    joy1 = 0;
  }
  else
  {
    joy1 = 1;
  }
  if(digitalRead(1)) {
    joy2 = 0;
  }
  else
  {
    joy2 = 1;
  }
  if(digitalRead(14)) {
    joy3 = 0;
  }
  else
  {
    joy3 = 1;
  }
  if(digitalRead(13)) {
    joy4 = 0;
  }
  else
  {
    joy4 = 1;
  }
  if(digitalRead(19)) {
    joy5 = 0;
  }
  else
  {
    joy5 = 1;
  }
  if(digitalRead(18)) {
    joy6 = 0;
  }
  else
  {
    joy6 = 1;
  }
  if(digitalRead(17)) {
    joy7 = 0;
  }
  else
  {
    joy7 = 1;
  }
  
  xbee.readPacket();
  if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {
    xbee.getResponse().getRx16Response(rx16);
    option = rx16.getOption();
    ID = rx16.getData(0);
    Serial.println(ID);
    if(ID == 11) {
      //click start
      joy2 = 1;
    }
    if(ID == 12) {
      sendTime = millis();
      digitalWrite(16, HIGH);
    }
  }
  Joystick.button(1, joy1);
  Joystick.button(2, joy2);
  Joystick.button(3, joy3);
  Joystick.button(4, joy4);
  Joystick.button(5, joy6); //red
  Joystick.button(6, joy5); //white
  Joystick.button(7, joy7); //blue
  delay(50);
}
