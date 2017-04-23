#include <MPU9250.h>
#include <U8g2lib.h>
#include <math.h>
#include <Wifi_S08_v2.h>
#include <SPI.h>
#include <Wire.h>

#define SPI_CLK 14
#define WIFI_SERIAL Serial1

MPU9250 imu;

int16_t acc_mag;

const float alpha = .9;

int16_t current_reading = 0;
int16_t last_reading = 0;

int loop_count = 0;
int times_fallen = 0;

int BUTTON_PIN = 9;
int GREEN_PIN = 22;
int RED_PIN = 23;
int BLUE_PIN = 21;

const String DEST = "23.92.20.162";
const int PORT = 5000;


// Global variables
String MAC = "";
String response = "";
String keyword = "";

String location = "";


ESP8266 wifi = ESP8266(0,true);

bool help_coming = false;

// bool button_state = false;

elapsedMillis time_since_alert = 35000;
const int alert_threshhold = 35000;

elapsedMillis pulse_timer = 0;

const int timer_per_pulse = 5000;
int r_val = 0;
int g_val = 255;
int b_val = 0;

String y_n = "N";

elapsedMillis check_location_timer = 0;
const int check_location_interval = 7000;

void setup()
{
  Serial.begin(115200);
  Wire.begin();
  SPI.setSCK(14);
  SPI.begin();

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);

  // start with the light off
  analogWrite(RED_PIN, 255);
  analogWrite(GREEN_PIN, 255);
  analogWrite(BLUE_PIN, 255);

  wifi.begin();
  wifi.connectWifi("MIT", "");
  while (!wifi.isConnected()); //wait for connection
  MAC = wifi.getMAC();

}


void loop() {

  pulse_led();


  // working
  // int green_output = (pulse_timer % timer_per_pulse) * 510 / timer_per_pulse;
  // if ( green_output > 255 ) {
  //   green_output = 510 -  green_output;
  // }
  // analogWrite(GREEN_PIN, green_output);
  // Serial.println(green_output);

  while ( time_since_alert < alert_threshhold && !help_coming) {
    analogWrite(RED_PIN, 0);
    analogWrite(GREEN_PIN, 255);
    analogWrite(BLUE_PIN, 255);
    if (y_n == "Y") {
      help_coming = true;
      for (int i = 0; i < 20; i ++ ) {
        analogWrite(GREEN_PIN, 0);
        delay(250);
        analogWrite(GREEN_PIN, 255);
        analogWrite(BLUE_PIN, 0);
        delay(250);
        analogWrite(BLUE_PIN, 255);
      }
    }
    if (digitalRead(BUTTON_PIN) == 0) {
      time_since_alert = alert_threshhold;
      analogWrite(RED_PIN, 255);
      analogWrite(GREEN_PIN, 0);
      analogWrite(BLUE_PIN, 255);
      delay(1000);
      break;
    }
    if (check_location_timer > check_location_interval) {
      String path = "/closestTeensy/";
      String get_response = send_to_server("get", path, "");
      Serial.println("Response: " + get_response);
      int num = get_response.substring(6, 7).toInt();
      y_n = get_response.substring(7, 8);
      set_rgb(num);
      check_location_timer = 0;
    }
  }

  if (time_since_alert > alert_threshhold) help_coming = false;

  if (check_location_timer > check_location_interval) {
    String path = "/closestTeensy/";
    String get_response = send_to_server("get", path, "");
    Serial.println("Response: " + get_response);
    int num = get_response.substring(6, 7).toInt();
    y_n = get_response.substring(7, 8);
    set_rgb(num);
    check_location_timer = 0;
  }


  if (digitalRead(BUTTON_PIN) == 0) {
    analogWrite(RED_PIN, 0);
    analogWrite(GREEN_PIN, 255);
    analogWrite(BLUE_PIN, 255);
    String get_params = "message=Grandpa%20needs%20help.";
    String path = "/lifeAlert/";
    String get_response = send_to_server("get", path, get_params);
    Serial.println("Response: " + get_response);
    time_since_alert = 0;

  } else {
    // analogWrite(RED_PIN, 255);
  }


  imu.readAccelData(imu.accelCount);
  current_reading = get_magnitude(imu.accelCount);

  if (last_reading == 0){
    last_reading = current_reading;
  }
  current_reading = int(alpha*current_reading) + int ( (1.0 - alpha) * last_reading );
  // Serial.println(current_reading);
  if (current_reading < -20000) {
    Serial.println("You fell.");
    analogWrite(RED_PIN, 0);
    analogWrite(GREEN_PIN, 255);
    analogWrite(BLUE_PIN, 255);
    String path = "/fall/";
    String get_params = "message=Your%20dad%20just%20fell%20again.";
    String get_response = send_to_server("get", path, get_params);
    Serial.println("Response: " + get_response);
    time_since_alert = 0;
    // delay(1000);
    // analogWrite(RED_PIN, 255);
  }

  last_reading = current_reading;

  delay(50);

}

int16_t get_magnitude(int16_t acc[3]) {
  return pow ( pow(acc[0], 2) + pow(acc[1], 2) + pow(acc[2], 2) , .5);
}


String send_to_server(String request_type, String path, String data) {
  if (request_type == "post") {
    wifi.sendRequest(POST, DEST, PORT, path, data);
  } else if (request_type == "get") {
    wifi.sendRequest(GET, DEST, PORT, path, data);
  }
  elapsedMillis start_timer = 0;
  while (!wifi.hasResponse() && start_timer < 5000);
  if (wifi.hasResponse()) {
    response = wifi.getResponse();
    return response;
  }
  return "Not in time.";
}


void pulse_led() {
  int red_output = (pulse_timer % timer_per_pulse) * (r_val *2) / timer_per_pulse;
  if ( red_output > r_val ) {
    red_output = r_val*2 -  red_output;
  }
  analogWrite(RED_PIN, 255 - red_output);

  int green_output = (pulse_timer % timer_per_pulse) * (g_val *2) / timer_per_pulse;
  if ( green_output > g_val ) {
    green_output = g_val*2 -  green_output;
  }
  analogWrite(GREEN_PIN, 255 - green_output);

  int blue_output = (pulse_timer % timer_per_pulse) * (b_val *2) / timer_per_pulse;
  if ( blue_output > b_val ) {
    blue_output = b_val*2 -  blue_output;
  }
  analogWrite(BLUE_PIN, 255 - blue_output);
}

void set_rgb(int n) {
  // switch n:
  switch ( n ) {
    case 2:
    {
      r_val = 255;
      g_val = 140;
      b_val = 154;
    }
    break;
    case 4:
    {
      r_val = 108;
      g_val = 164;
      b_val = 255;
    }
    break;
    case 5:
    {
      r_val = 246;
      g_val = 166;
      b_val = 35;
    }
    break;
    case 6:
    {
      r_val = 0;
      g_val = 255;
      b_val = 0;
    }
    break;
  default:
  break;
  }
}
