    /*
 Controlling large 7-segment displays
 By: Nathan Seidle
 SparkFun Electronics
 Date: February 25th, 2015
 License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

 This code demonstrates how to post two numbers to a 2-digit display usings two large digit driver boards.

 Here's how to hook up the Arduino pins to the Large Digit Driver IN

 Arduino pin 6 -> CLK (Green on the 6-pin cable)
 5 -> LAT (Blue)
 7 -> SER on the IN side (Yellow)
 5V -> 5V (Orange)
 Power Arduino with 12V and connect to Vin -> 12V (Red)
 GND -> GND (Black)

 There are two connectors on the Large Digit Driver. 'IN' is the input side that should be connected to
 your microcontroller (the Arduino). 'OUT' is the output side that should be connected to the 'IN' of addtional
 digits.

 Each display will use about 150mA with all segments and decimal point on.

*/

//GPIO declarations
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
byte segmentLatch = 27;
byte segmentClock = 26;
byte segmentData = 25;



//#include <WiFi.h>
#include <ESPAsyncWebServer.h>

/*Put your SSID & Password*/
const char* ssid = "SSID";  // Enter SSID here
const char* password = "Password";  //Enter Password here

//WebServer server(80);
AsyncWebServer server(80);


uint8_t LED1pin = 4;
bool LED1status = LOW;

uint8_t LED2pin = 5;
bool LED2status = LOW;
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

const char index_html[] PROGMEM = R"rawliteral(
<!DOCTYPE HTML><html><head>
  <title>Field 1 Queue</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"></head><body>
  <form action="/post" method="post">
    <input type="number" name="number" id="number">
    <input type="submit" value="Submit">
  </form>
</body></html>)rawliteral";


void setup()
{
  Serial.begin(9600);
  Serial.println("Field 1 Queue");

  pinMode(segmentClock, OUTPUT);
  pinMode(segmentData, OUTPUT);
  pinMode(segmentLatch, OUTPUT);

  digitalWrite(segmentClock, LOW);
  digitalWrite(segmentData, LOW);
  digitalWrite(segmentLatch, LOW);
  delay(100);
  showNumber(88);
  //pinMode(LED1pin, OUTPUT);
  //pinMode(LED2pin, OUTPUT);

  Serial.println("Connecting to ");
  Serial.println(ssid);

  //connect to your local wi-fi network
  WiFi.begin(ssid, password);
  float toShow = 1.00;

  //check wi-fi is connected to wi-fi network
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
    showNumber(toShow);
    toShow = toShow + 1.00;
  }
  showNumber(99);
  Serial.println("");
  Serial.println("WiFi connected..!");
  Serial.print("Got IP: ");  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send_P(200, "text/html", index_html);
  });
 
  server.on("/post", HTTP_POST, [](AsyncWebServerRequest *request){

 //List all parameters (Compatibility)
int args = request->args();
for(int i=0;i<args;i++){
  Serial.printf("ARG[%s]: %s\n", request->argName(i).c_str(), request->arg(i).c_str());
}
    int paramsNr = request->params();
    Serial.println(paramsNr);
 
    for(int i=0;i<paramsNr;i++){
 
        AsyncWebParameter* p = request->getParam(i);
        Serial.print("Param name: ");
        Serial.println(p->name());
        Serial.print("Param value: ");
        Serial.println(p->value());
        Serial.println("------");
        if(p->name() == "number")
        {
          showNumber(p->value().toFloat());
        }
    }
 
    request->send(200, "text/plain", "message received");
  });

  server.begin();
  Serial.println("HTTP server started");
}

int number = 0;

void loop()
{
  //server.handleClient();
  /*showNumber(number); //Test pattern
  number++;
  number++;
  number %= 100; //Reset x after 99

  Serial.println(number); //For debugging

  delay(500);*/
}

//Takes a number and displays 2 numbers. Displays absolute value (no negatives)
void showNumber(float value)
{
  int number = abs(value); //Remove negative signs and any decimals
  if(number > 100)
  {
    postNumber(number-100, false);
    postNumber(' ', true);
    //Latch the current segment data
    digitalWrite(segmentLatch, LOW);
    digitalWrite(segmentLatch, HIGH); //Register moves storage register on the rising edge of RCK
    return;
  }

  //Serial.print("number: ");
  //Serial.println(number);

  for (byte x = 0 ; x < 2 ; x++)
  {
    int remainder = number % 10;

    postNumber(remainder, false);

    number /= 10;
  }

  //Latch the current segment data
  digitalWrite(segmentLatch, LOW);
  digitalWrite(segmentLatch, HIGH); //Register moves storage register on the rising edge of RCK
}

//Given a number, or '-', shifts it out to the display
void postNumber(byte number, boolean decimal)
{
  //    -  A
  //   / / F/B
  //    -  G
  //   / / E/C
  //    -. D/DP

#define a  1<<0
#define b  1<<6
#define c  1<<5
#define d  1<<4
#define e  1<<3
#define f  1<<1
#define g  1<<2
#define dp 1<<7

  byte segments;

  switch (number)
  {
    case 1: segments = b | c; break;
    case 2: segments = a | b | d | e | g; break;
    case 3: segments = a | b | c | d | g; break;
    case 4: segments = f | g | b | c; break;
    case 5: segments = a | f | g | c | d; break;
    case 6: segments = a | f | g | e | c | d; break;
    case 7: segments = a | b | c; break;
    case 8: segments = a | b | c | d | e | f | g; break;
    case 9: segments = a | b | c | d | f | g; break;
    case 0: segments = a | b | c | d | e | f; break;
    case ' ': segments = 0; break;
    case 'c': segments = g | e | d; break;
    case '-': segments = g; break;
  }

  if (decimal) segments |= dp;

  //Clock these bits out to the drivers
  for (byte x = 0 ; x < 8 ; x++)
  {
    digitalWrite(segmentClock, LOW);
    digitalWrite(segmentData, segments & 1 << (7 - x));
    digitalWrite(segmentClock, HIGH); //Data transfers to the register on the rising edge of SRCK
  }
}
