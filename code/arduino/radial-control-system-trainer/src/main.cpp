#include <Arduino.h>
#include <LiquidCrystal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "standardHelper.h"

bool usingMatlab = false;
bool sinus = true;
float Kp = 1.0, Ki = 1.0, Kd = 0.1;

#include "global.h"
#include "encoder.h"
#include "motor.h"
#include "input.h"
#include "pid.h"
#include "matvar.h"

void setup() {
  if (!usingMatlab) {
    Serial.begin(9600); 
    Kp = 0, Ki = 0, Kd = 0;
  } else {
    Serial.begin(115200);
    if (sinus) Kp = 1, Ki = 1.0, Kd = 1.0;
  }
  lcd.begin(16, 2);

  pinMode(pinPwm, OUTPUT);
  pinMode(dir1, OUTPUT);
  pinMode(dir2, OUTPUT);

  pinMode(pin1, INPUT_PULLUP);
  pinMode(pin2, INPUT_PULLUP);
  pinMode(push_4, INPUT_PULLUP);
  pinMode(push_3, INPUT_PULLUP);
  pinMode(push_2, INPUT_PULLUP);
  pinMode(push_1, INPUT_PULLUP);

  pinMode(encoder0PinA, INPUT_PULLUP);
  pinMode(encoder0PinB, INPUT_PULLUP);

  isEncoderActive = false;
  time = millis();

  lcd.clear();
  lcd.setCursor(1, 0);
  sprintf(tampil, "Trainer Radial");
  lcd.print(tampil);
  lcd.setCursor(1, 1);
  sprintf(tampil, "System Control");
  lcd.print(tampil);
  delay(2000);

  activateEncoder();
  __reset();

  pointTo(&var1, 0);
  pointTo(&var2, 1);
  pointTo(&var3, 2);
  pointTo(&var4, 3);
  pointTo(&var5, 4);
  pointTo(&var6, 5);
  pointTo(&var7, 6);
  pointTo(&var8, 7);
}

void loop() {
  doEncoder();
  limitKanan = digitalRead(pin1);
  limitKiri = digitalRead(pin2);

  pot = analogRead(potPin);
  if (usingMatlab) {
    if (sinus) {
      sinsweep = sinsweep + 0.003;
      sinco = sinco + 0.05 * pow(3.0, sin(sinsweep));
      targetsin = sin(sinco) * 80.0 + 90.0;
      tahap2();
    } else set_point = map(pot, __minADC, __maxADC, __minDeg, __maxDeg);
  } else {
    set_point = map(pot, __minADC, __maxADC, __minDeg, __maxDeg);
  }

  speed = abs(dir);
  if (set_point > 180) set_point = 180;
  if (set_point < 0) set_point = 0;

  if (speed > __maxValPWM) speed = __maxValPWM;
  if (step > 2) step = 0;

  if (limitKiri == 0 && dir < 0) {
    __stop();
    dir = kontrol_PID(derajatPos);
  } else if (limitKanan == 0 && dir > 0) {
    __stop();
    dir = kontrol_PID(derajatPos);
  } else if (isRun) {
    if (usingMatlab) {
      derajatPos = map(rotary, __minRot, __maxRot, __minDeg, __maxDeg);
      newsetpoint = kontrol_PID(derajatPos) + set_point;

      //tahap 1
      integrator = newsetpoint - derajatPos;
      dir = integrator;
      var1 = float(speed);
      var2 = float(set_point);
      var3 = float(derajatPos);
      var4 = float(dir);
      var5 = float(error);
      var6 = errorI;
      var7 = float(outD);
      var8 = float(in[0].raw);
      sendAll();
      readAll();

    } else {
      derajatPos = map(rotary, __minRot, __maxRot, __minDeg, __maxDeg);
      newsetpoint = kontrol_PID(derajatPos);
      integrator = newsetpoint - derajatPos;
      dir = integrator;
    }
    if (dir < 0) keKiri();
    if (dir > 0) keKanan();
    if (dir == 0) __stop();
  }
  button();
  lcd_data();
  delay(10);
}

