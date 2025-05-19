void keKiri() {
  analogWrite(pinPwm, speed);
  digitalWrite(dir1, LOW);
  digitalWrite(dir2, HIGH);
}

void keKanan() {
  analogWrite(pinPwm, speed);
  digitalWrite(dir1, HIGH);
  digitalWrite(dir2, LOW);
}

void __stop() {
  analogWrite(pinPwm, 0);
  digitalWrite(dir1, LOW);
  digitalWrite(dir2, LOW);
}

void keKiri() {
  analogWrite(pinPwm, speed);
  digitalWrite(dir1, LOW);
  digitalWrite(dir2, HIGH);
}

void keKanan() {
  analogWrite(pinPwm, speed);
  digitalWrite(dir1, HIGH);
  digitalWrite(dir2, LOW);
}

void __stop() {
  analogWrite(pinPwm, 0);
  digitalWrite(dir1, LOW);
  digitalWrite(dir2, LOW);
}

void __reset() {
  lcd.clear();
  lcd.setCursor(0, 0);
  sprintf(tampil, "RESETTING...");
  lcd.print(tampil);
  while (1) {
    limitKanan = digitalRead(pin1);
    limitKiri = digitalRead(pin2);
    // Serial.print(x);
    // Serial.print("    ");
    // Serial.print(__minRot);
    // Serial.print("    ");
    // Serial.print(__maxRot);
    // Serial.print("    ");
    // Serial.println(rotary);

    switch (x) {
      case 0:
        speed = 255;
        keKiri();
        if (limitKiri == 0) {
          __stop();
          rotary = 0;
          dir = 0;
          derajatPos = -9;

          __minRot = rotary;
          delay(100);
          x = 2;
        }
        break;
      // case 1:
      //   speed = 255;
      //   keKanan();
      //   if (limitKanan == 0) {
      //     __stop();
      //     __maxRot = rotary;
      //     x = 2;
      //   }
      //   break;
      case 2:
        lcd.clear();
        x = 0;
        return;
    }
  }
}