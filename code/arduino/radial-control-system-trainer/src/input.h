void lcd_data() {
  if (!usingMatlab) {
    // Serial.print(set_point);
    // Serial.print("   ");
    // Serial.print(derajatPos);

    // Serial.print("   ");
    // Serial.print(rotary);
    // Serial.print("   ");
    // Serial.print(dir);
    // Serial.print("   ");
    // Serial.print(step);
    // Serial.print("   ");
    // Serial.print(isRun);
    // Serial.print("   ");
    // Serial.print(isStop);
    // Serial.print("   ");
    // Serial.println(speed);
    // Serial.print("SetPoint:");
    // Serial.print(set_point);
    // Serial.print(",");
    // Serial.print("Position:");
    // Serial.print(derajatPos);
    // Serial.println(); 
    Serial.print(set_point);
    Serial.print(",");
    Serial.print(derajatPos);
    Serial.print(",");
    Serial.print(Kp, 1);
    Serial.print(",");
    Serial.print(Ki, 1);
    Serial.print(",");
    Serial.println(Kd, 2);

  
  }

  lcd.setCursor(0, 0);
  if (step == 0) {
    dtostrf(Kp, 1, 1, tampil);
    lcd.print("Kp : ");
    lcd.print(tampil);
    lcd.print("    ");
  } else if (step == 1) {
    dtostrf(Ki, 1, 1, tampil);
    lcd.print("Ki : ");
    lcd.print(tampil);
    lcd.print("    ");
  } else if (step == 2) {
    dtostrf(Kd, 1, 2, tampil);
    lcd.print("Kd : ");
    lcd.print(tampil);
    lcd.print("    ");
  }
  lcd.setCursor(0, 1);
  sprintf(tampil, "Set:%3d  Pos:%3d", (int)set_point, (int)derajatPos);
  lcd.print(tampil);
}

void button() {
  if (digitalRead(push_2) == 0) {
    step++;
    isRun = 1;
    isStop = 0;
    time = millis();
    delay(200);
  }

  if (digitalRead(push_3) == 0) {
    if (step == 0) {
      Kp += 0.1;
    }
    if (step == 1) {
      Ki += 0.1;
    }
    if (step == 2) {
      Kd += 0.05;
    }

    delay(100);
  }

  if (digitalRead(push_4) == 0) {
    if (step == 0) {
      Kp -= 0.1;
      if (Kp < 0)
        Kp = 0;
    }
    if (step == 1) {
      Ki -= 0.1;
      if (Ki < 0)
        Ki = 0;
    }
    if (step == 2) {
      Kd -= 0.05;
      if (Kd < 0)
        Kd = 0;
    }
    delay(100);
  }

  if (digitalRead(push_1) == 0) {
    __reset();
    pot = 0;
    isRun = 0;
    isStop = 1;
    timeNow = 0;
    delay(100);
  }
}