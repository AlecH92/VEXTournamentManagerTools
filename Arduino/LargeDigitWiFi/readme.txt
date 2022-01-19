We are testing out a new method of alerting participants to the next upcoming match on a field.

Utilizing:
2x SparkFun 8530 (7-Segment Display - 6.5" Red)
2x SparkFun 13279 (Large Digit Driver)
1x Adafruit 4172 (HUZZAH32 - ESP32 Breakout Board)
Misc 12v power supply
Misc 5v power supply

The AutoHotKey script is set up for two and three field setups.
You will need to update the field___Addr variable to specify the IP addresses of your digit setups.
Ideally you want to set these with static IP addresses
The script sends the next upcoming match on a specific field to the ESP32 board.
The upcoming match is sent and then stored so repeat messages are not sent to the same board again.