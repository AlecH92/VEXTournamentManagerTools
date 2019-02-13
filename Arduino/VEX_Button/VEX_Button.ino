#include <XBee.h>
XBee xbee = XBee();
//xbee receive
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();

uint8_t option = 0;
//xbee send
uint8_t payload[] = { 0 };
Tx16Request tx = Tx16Request(0x2, payload, sizeof(payload));
TxStatusResponse txStatus = TxStatusResponse();

unsigned long sendTime = 0; //delay to send 'connected' (12)
boolean notSentYet = true;
boolean HIGHLOW = LOW;

void setup() {
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);
  Serial3.begin(38400);
  xbee.setSerial(Serial3);
  pinMode(3, INPUT_PULLUP);
  Serial.begin(38400);
  //payload[0] = 12 & 0xff; //connected
  payload[0] = 11 & 0xff; //start match
  xbee.send(tx);
  xbee.readPacket();
  if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {}
  else if (xbee.getResponse().isError()) {}
  else {}
  sendTime = millis();
  digitalWrite(13, LOW);
}

void loop() {
  /*
  if(millis() - sendTime > 1000) {
    payload[0] = 12 & 0xff;
    xbee.send(tx);
    xbee.readPacket();
    if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {}
    else if (xbee.getResponse().isError()) {}
    else {}
    sendTime = millis();
  }
  
  if (millis() > 2100 && notSentYet){
    payload[0] = 11 & 0xff;
    xbee.send(tx);
    xbee.readPacket();
    if (xbee.getResponse().getApiId() == RX_16_RESPONSE) {}
    else if (xbee.getResponse().isError()) {}
    else {}
    notSentYet = false;
    digitalWrite(13, LOW);
  }*/
}
