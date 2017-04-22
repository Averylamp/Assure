#include <MPU9250.h>
#include <U8g2lib.h>
#include <math.h>
#include <Wifi_S08_v2.h>
#include <SPI.h>
#include <Wire.h>

#define SPI_CLK 14

MPU9250 imu;


int16_t acc_mag;

const float alpha = .9;
const float alpha2 = .9;

int sizeofarray = 10000;

int last_readings[10000];

int16_t current_reading = 0;
int16_t last_reading = 0;

int16_t current_reading2 = 0;
int16_t last_reading2 = 0;

int loop_count = 0;
int times_fallen = 0;

int BUTTON_PIN = 9;
int GREEN_PIN = 22;
int RED_PIN = 23;
int BLUE_PIN = 21;

// String DATABASE_PATH = "/6S08dev/ejweber/ex03/slack.py";
const String DATABASE_PATH = "http://23.92.20.162/";

ESP8266 wifi = ESP8266(0,true);

// bool button_state = false;

elapsedMillis time_since_fall = 0;

void setup()
{
  Serial.begin(115200);
  Wire.begin();
  SPI.setSCK(14);
  SPI.begin();

  byte c = imu.readByte(MPU9250_ADDRESS, WHO_AM_I_MPU9250);
  Serial.print("MPU9250 "); Serial.print("I AM "); Serial.print(c, HEX);
  Serial.println("MPU9250 is online...");

  // Calibrate gyro and accelerometers, load biases in bias registers
  imu.MPU9250SelfTest(imu.selfTest);
  imu.initMPU9250();
  imu.calibrateMPU9250(imu.gyroBias, imu.accelBias);
  imu.initMPU9250();
  imu.initAK8963(imu.factoryMagCalibration);

  imu.getMres();
  imu.getAres();
  imu.getGres();

  wifi.begin();
  wifi.connectWifi("MIT", "");

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);

  // start with the light off
  analogWrite(RED_PIN, 255);
  analogWrite(GREEN_PIN, 255);
  analogWrite(BLUE_PIN, 255);

  // inialize last readings all to zero
  for (int i = 0; i < sizeofarray; i = i + 1) {
    last_readings[i] = 0;
  }

}


void loop() {
  // compass.update();
  // Serial.println(imu.)
  // int16_t holder;

  //print button state
  // Serial.println(digitalRead(BUTTON_PIN));

  if (digitalRead(BUTTON_PIN) == 0) {
    analogWrite(BLUE_PIN, 0);
  } else {
    analogWrite(BLUE_PIN, 255);
  }

  if (loop_count % 50 == 0) {
    loop_count = 0;
    times_fallen = 0;
  }


  imu.readAccelData(imu.accelCount);
  // current_reading = imu.accelCount[1];
  current_reading = get_magnitude(imu.accelCount);

  // Serial.print(imu.accelCount[0]);
  // Serial.print(",");
  // Serial.print(imu.accelCount[1]); //this is the one to use
  // Serial.print(",");
  // Serial.println(imu.accelCount[2]);

  if (last_reading == 0){
    last_reading = current_reading;
  }
  if (last_reading2 == 0){
    last_reading2 = current_reading;
  }

  current_reading = int(alpha*current_reading) + int ( (1.0 - alpha) * last_reading );
  // Serial.println(current_reading);

  if (current_reading < -20000) {
    Serial.println("You fell.");
    analogWrite(RED_PIN, 0);
    wifi.sendRequest(GET, DATABASE_PATH + "sendTest/?message=hello", 5000, "", "", true);
    while (wifi.isBusy()) {}
    delay(1000);
    analogWrite(RED_PIN, 255);
  }
  last_reading = current_reading;
  // int16_t last_reading2 = int(alpha2*current_reading) + int ( (1.0 - alpha) * last_reading2 );

  // int nothing = get_entire_average(last_reading);
  // Serial.println(last_reading);


  if (last_reading > 5000) {
    times_fallen++;
  }
  if (times_fallen > 3) {
    // Serial.println("You fell.");
    times_fallen = 0;
  }

  // Serial.print(",");
  // Serial.println(last_reading2);
  delay(50);

  loop_count++;

}

int16_t get_magnitude(int16_t acc[3]) {
  return pow ( pow(acc[0], 2) + pow(acc[1], 2) + pow(acc[2], 2) , .5);
}

// int get_entire_average(int16_t current){
//   for (int i = 0; i < sizeofarray - 1; i++){
//     last_readings[i + 1] = last_readings[i];
//   }
//   last_readings[0] = current;
//
//   int sum = 0;
//   for (int i = 0; i < sizeofarray - 1; i++){
//     sum += last_readings[i];
//   }
//
//   return (int)(sum*1.0 / sizeofarray*1.0);
// }

// void record_audio() {
//   int sample_num = 0;    // counter for samples
//   int enc_index = PREFIX_SIZE-1;    // index counter for encoded samples
//   float time_between_samples = 1000000/SAMPLE_FREQ;
//   int value = 0;
//   int8_t raw_samples[3];   // 8-bit raw sample data array
//   char enc_samples[4];     // encoded sample data array
//
//   while (sample_num<NUM_SAMPLES) {   //read in NUM_SAMPLES worth of audio data
//     time_since_sample = 0;
//     value = analogRead(AUDIO_IN);
//     raw_samples[sample_num%3] = mulaw_encode(value-24427);
//     sample_num++;
//     if (sample_num%3 == 0) {
//       base64_encode(enc_samples, (char *) raw_samples, 3);
//       for (int i = 0; i < 4; i++) {
//         speech_data[enc_index+i] = enc_samples[i];
//       }
//       enc_index += 4;
//     }
//
//     // wait till next time to read
//     while (time_since_sample <= time_between_samples) delayMicroseconds(10);
//   }
// }
//
// void send_from_teensy() {
//   Serial.println("sending audio data from Teensy");
//   wifi.sendBigRequest("speech.googleapis.com", 443, "/v1beta1/speech:syncrecognize?key=AIzaSyAoWHhpQixMaNuOtRhi1yIpNXL2ffICQTI", speech_data);
// }
//
//
// /* This code was obtained from
// http://dystopiancode.blogspot.com/2012/02/pcm-law-and-u-law-companding-algorithms.html
// */
// int8_t mulaw_encode(int16_t number)
// {
//    const uint16_t MULAW_MAX = 0x1FFF;
//    const uint16_t MULAW_BIAS = 33;
//    uint16_t mask = 0x1000;
//    uint8_t sign = 0;
//    uint8_t position = 12;
//    uint8_t lsb = 0;
//    if (number < 0)
//    {
//       number = -number;
//       sign = 0x80;
//    }
//    number += MULAW_BIAS;
//    if (number > MULAW_MAX)
//    {
//       number = MULAW_MAX;
//    }
//    for (; ((number & mask) != mask && position >= 5); mask >>= 1, position--)
//         ;
//    lsb = (number >> (position - 4)) & 0x0f;
//    return (~(sign | ((position - 5) << 4) | lsb));
// }
