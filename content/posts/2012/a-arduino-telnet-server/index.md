---
layout: post
title: Arduino telnet server
date: 2012-06-25 12:39:00
tags: [ arduino, telnet server]
---
 
Today I want to present you a little bit Arduino code because i've searched a lot for a working telnet server to control I/O's over network.
The code is based on the "Examples - Ethernet - ChatServer". So here is my version of the server:

```arduino 
#include <SPI.h>
#include <Ethernet.h>

#define MAX_CMD_LENGTH   25

byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0xE3, 0x5B };

IPAddress ip(192, 168, 1, 177);
IPAddress gateway(192, 168, 1, 1);
IPAddress subnet(255, 255, 255, 0);

EthernetServer server = EthernetServer(23);
EthernetClient client;
boolean connected = false; 

String cmd;
```

First declaring all needed variables, configure the MAC address, IP address, gateway and subnet mask. The port is set to 23, which is the default telnet port.

```arduino 
void setup()
{
  Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
  pinMode(2, OUTPUT);
  pinMode(7, INPUT_PULLUP);
}
```

Start the server, and configur one output and input pin.

```arduino 
void loop()
{
  client = server.available();

  if (client == true) {
    if (!connected) {
      client.flush();   
      connected = true;
    }
    
    if (client.available() > 0) {
      readTelnetCommand(client.read());
    }
    
  }

  // check for input
  if(digitalRead(7) == LOW) {
    while(digitalRead(7) == LOW);
    server.println("Input triggered :-)");
  }

  delay(10);
}
```

Here we wait that a clinet connects to the server. If that happens we flush the buffer and set a flag to make sure to not flush the buffer each loop cycle.
Then we proof for received data each cycle and jump into the readTelnetCommand function if so. Furthermore we check for input signals and write a text to the client if an input signal is detected.

```arduino 
void readTelnetCommand(char c) {

  if(cmd.length() == MAX_CMD_LENGTH) {
    cmd = "";
  }
  
  cmd += c;
  
  if(c == '\n') {
    if(cmd.length() > 2) {
      // remove \r and \n from the string
      cmd = cmd.substring(0,cmd.length() - 2);
      parseCommand();
    }
  }
}
```

For each received char we check if the maximum command length is exceeded and clear the commad if that happens.
Otherwise we append the char to the command. Then we check if the char was a newline. If so we know Return was hit and a commad is completely sent.
Now we remove newline and carriage return and try to parse the command.

```arduino 
void parseCommand() {
  
  if(cmd.equals("quit")) {
      client.stop();
      connected = false;
  } else if(cmd.equals("help")) {
      server.println("--- Telnet Server Help ---");
      server.println("on    : switch on the Main Power");      
      server.println("off   : switch off the Main Power");      
      server.println("quit  : close the connection");       
  } else if(cmd.equals("on")) {
      digitalWrite(2, HIGH);
  } else if(cmd.equals("off")) {
      digitalWrite(2, LOW);
  } else {
      server.println("Invalid command, type help");
  }
  cmd = "";
}
```

The last step is to check if the received string is a valid command. Then we do the apropriate action for the command or send an error message back if the command was invalid.

Thats it :-) 
