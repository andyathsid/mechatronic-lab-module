#include <Arduino.h>
#include <LiquidCrystal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "global.h"
#include "encoder.h"
#include "motor.h"
#include "input.h"
#include "pid.h"

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);

  Kp = 0.0;
  Ki = 0.0;
  Kd = 0.0;
  set_point = 0;

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
  sprintf(tampil, "Trainer Linear");
  lcd.print(tampil);
  lcd.setCursor(1, 1);
  sprintf(tampil, "System Control");
  lcd.print(tampil);
  delay(2000);

  activateEncoder();
  __reset();
}

void loop() {
  doEncoder();
  limitKanan = digitalRead(pin1);
  limitKiri = digitalRead(pin2);
  pot = analogRead(potPin);

  set_point = map(pot, __minADC, __maxADC, __minDeg, __maxDeg);

  speed = 100 + abs(newsetpoint);
  if (speed > __maxValPWM) speed = __maxValPWM;
  if (step > 2) step = 0;
  if (limitKiri == 0 && dir <= 0) {
    __stop();
    dir = kontrol_PID(derajatPos);
  } else if (limitKanan == 0 && dir >= 0) {
    __stop();
    dir = kontrol_PID(derajatPos);
  } else if (isRun) {
    derajatPos = mapDouble(rotary, __minRot, __maxRot, __minDeg, __maxDeg);
    newsetpoint = (kontrol_PID(derajatPos));
    dir = newsetpoint;
    if (dir >= 9) dir = 9;
    if (dir <= -9) dir = -9;
    if (dir < 0) keKiri();
    if (dir > 0) keKanan();
  }

  double selisih = derajatPos - set_point;
  if (dir < 0.4 && dir > -0.4 && abs(selisih) <= 0.05) __stop();
  button();
  lcd_data();
  delay(10);
}
