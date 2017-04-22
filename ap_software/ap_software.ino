/*
    This sketch shows how to use WiFi event handlers.

    In this example, ESP8266 works in AP mode.
    Three event handlers are demonstrated:
    - station connects to the ESP8266 AP
    - station disconnects from the ESP8266 AP
    - ESP8266 AP receives a probe request from a station

    Written by Markus Sattler, 2015-12-29.
    Updated for new event handlers by Ivan Grokhotkov, 2017-02-02.
    This example is released into public domain,
    or, at your option, CC0 licensed.
*/


#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WiFiMulti.h>
#include <elapsedMillis.h>
#include <stdio.h>

const char* ssid = "Assure";
const char* password = "";

const int LED_PIN = 2;
const String DATABASE_PATH = "http://23.92.20.162:5000/";

String mac_address= "";

ESP8266WiFiMulti WiFiMulti;

int mac_addresses[100];
int mac_addresses_pointer = 0;

String running_probe_data = "";

String targeted_device = "a0:20:a6:0f:28:9b";

bool print_probes = false;
bool print_connects = false;

WiFiEventHandler stationConnectedHandler;
WiFiEventHandler stationDisconnectedHandler;
WiFiEventHandler probeRequestPrintHandler;
WiFiEventHandler probeRequestBlinkHandler;
WiFiServer server(80);

const int POST_UPDATE_INTERVAL = 2000; // how often to post data to the database
elapsedMillis time_since_post = 0; // timer in ms for keeping track of when data was posted last

// const int GET_UPDATE_INTERVAL = 15000; // how often to get data to the database
// elapsedMillis time_since_get = 5000; // timer in ms for keeping track of when data was received from get request last

const int TIME_SINCE_RECEIVED_INTERVAL = 10000;
elapsedMillis time_since_received = 0;

bool blinkFlag;

HTTPClient http; // this is the main HTTPClient used for HTTP requests

void setup() {
  Serial.begin(115200);
  Serial.println("Hello World.");

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, HIGH);

  // Don't save WiFi configuration in flash - optional
  WiFi.persistent(false);

  connect_to_wifi(http);

  // connect to the database
  http.begin(DATABASE_PATH);

  mac_address = WiFi.macAddress();
  Serial.println("MAC Address: " + mac_address);

  // Register event handlers.
  // Callback functions will be called as long as these handler objects exist.
  // Call "onStationConnected" each time a station connects
  stationConnectedHandler = WiFi.onSoftAPModeStationConnected(&onStationConnected);
  // Call "onStationDisconnected" each time a station disconnects
  stationDisconnectedHandler = WiFi.onSoftAPModeStationDisconnected(&onStationDisconnected);
  // Call "onProbeRequestPrint" and "onProbeRequestBlink" each time
  // a probe request is received.
  // Former will print MAC address of the station and RSSI to Serial,
  // latter will blink an LED.
  probeRequestPrintHandler = WiFi.onSoftAPModeProbeRequestReceived(&onProbeRequestPrint);
  probeRequestBlinkHandler = WiFi.onSoftAPModeProbeRequestReceived(&onProbeRequestBlink);

  // Start webserver
  server.begin();
  Serial.println("Server started");
  Serial.println(WiFi.softAPIP());

  Serial.println("Staring loop");

}

void onStationConnected(const WiFiEventSoftAPModeStationConnected& evt) {
  if (print_connects){
    Serial.print("Station connected: ");
    Serial.println(macToString(evt.mac));
  }
}

void onStationDisconnected(const WiFiEventSoftAPModeStationDisconnected& evt) {
  Serial.print("Station disconnected: ");
  Serial.println(macToString(evt.mac));
}

void onProbeRequestPrint(const WiFiEventSoftAPModeProbeRequestReceived& evt) {
  int mac;
  memcpy(&mac, evt.mac, 6);
  if (!inArray(mac, mac_addresses, mac_addresses_pointer)) {
      mac_addresses[mac_addresses_pointer] = mac;
      mac_addresses_pointer++;
  }
  if (print_probes){
    Serial.print("Probe request from: ");
    Serial.println(macToString(evt.mac));
    Serial.print(" RSSI: ");
    Serial.println(evt.rssi);
    Serial.println("Total probe requests: " + String(mac_addresses_pointer));
  }

  if (macToString(evt.mac).indexOf(targeted_device) > -1) {
    running_probe_data = "from_mac=" + mac_address + "&device=" + macToString(evt.mac) + "&rssi=" + String(evt.rssi);
    time_since_received = 0;
  }

}

void onProbeRequestBlink(const WiFiEventSoftAPModeProbeRequestReceived&) {
  // We can't use "delay" or other blocking functions in the event handler.
  // Therefore we set a flag here and then check it inside "loop" function.
  blinkFlag = true;
}

void loop() {
  // Serial.println("inside loop");

  // Post the number of unique MAC addresses to the database above
  if (time_since_post >= POST_UPDATE_INTERVAL) {
    if (time_since_received > TIME_SINCE_RECEIVED_INTERVAL) {
      running_probe_data = "from_mac=" + mac_address + "&device=0" + "&rssi=0" ;
    }
    Serial.println("Going to post this data: " + running_probe_data);
    String response = send_to_server("POST", running_probe_data);
    Serial.println("POST RESPONSE: " + response);
    time_since_post = 0;
  }

  if (blinkFlag) {
    blinkFlag = false;
    digitalWrite(LED_PIN, LOW);
    delay(100);
    digitalWrite(LED_PIN, HIGH);
  }

}

String macToString(const unsigned char* mac) {
  char buf[20];
  snprintf(buf, sizeof(buf), "%02x:%02x:%02x:%02x:%02x:%02x",
           mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
  return String(buf);
}

bool inArray(int val, int *arr, int size){
    int i;
    for (i=0; i < size; i++) {
        if (arr[i] == val)
            return true;
    }
    return false;
}

// This function is used for HTTP request to/from the server and return the response as a String
String send_to_server(String request_type, String data) {
  if (request_type == "GET") {
    http.begin(DATABASE_PATH + "?" + data);
    int httpCode = http.GET();
    Serial.println(httpCode);
    if (httpCode > 0) {
      Serial.printf("[HTTP] GET... code: %d\n", httpCode);
      if(httpCode == HTTP_CODE_OK) {
        http.begin(DATABASE_PATH);
        return http.getString();
      }
    }else {
      http.begin(DATABASE_PATH);
      return "GET request failed.";
    }
  }
  else if (request_type == "POST") {
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    int httpCode = http.POST(data);
    Serial.println(httpCode);
    if (httpCode > 0) {
      Serial.printf("[HTTP] POST... code: %d\n", httpCode);
      if(httpCode == HTTP_CODE_OK) {
        return http.getString();
      }
    }else {
      return "POST request failed.";
    }
  }
  else {
    return "Error with HTTP request parameters.";
  }
}

// This is a function to connect to unprotected WiFi with the best strength
void connect_to_wifi(HTTPClient& http_client) {
  int n = WiFi.scanNetworks();
  Serial.println("Number of networks: " + String(n));

  // Set up an access point
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);

  for (int i = 0; i < n; ++i) {
    if (WiFi.encryptionType(i) == ENC_TYPE_NONE) {
      // print SSID and RSSI for each nonencrypted network around it
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.println(")");
      // Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE)?" ":"*");
    }
  }

  // cycle through the networks and try to connect
  for (int i = 0; i < n; ++i) {

    if (WiFi.encryptionType(i) == ENC_TYPE_NONE) {


      char char_array[WiFi.SSID(i).length() + 1];
      WiFi.SSID(i).toCharArray(char_array, sizeof(char_array)); // NEED TO CONVERT THIS TO char* ETHAN WEBER
      // Serial.println(char_array);
      // "6s08", "iesc6s08"
      WiFi.begin("MIT", ""); //Ethan hard coded this for the hackathon
      Serial.println("Trying to connect to MIT");
      // Serial.println("Trying to connect to " + WiFi.SSID(i) + " with SSID of " + String(WiFi.RSSI(i)));
      // WiFi.begin(char_array);
      // Serial.println("Trying to connect to " + WiFi.SSID(i) + " with SSID of " + String(WiFi.RSSI(i)));
      elapsedMillis time_since_connect_attempt = 0; // start a timer for the connection attempt
      while (time_since_connect_attempt < 20000 && WiFi.status() != WL_CONNECTED)
      {
        delay(500);
        Serial.print(".");
      }
      if (WiFi.status() == WL_CONNECTED) {
        // should add code here to verify that we have internet - Ethan
        Serial.println();
        Serial.print("Connected, IP address: ");
        Serial.println(WiFi.localIP());
        return;
      } else {
        Serial.println();
        Serial.print("Failed to connect.");
      }
    }
  }
}


// function to check wifi connectivity
// bool check_wifi_connection {}
