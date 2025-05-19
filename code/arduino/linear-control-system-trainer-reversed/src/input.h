void lcd_data() {
  // Serial.print(set_point);
  // Serial.print("   ");
  // Serial.print(dir);
  // Serial.print("   ");
  // Serial.print(newsetpoint);
  // Serial.print("   ");
  // Serial.print(speed);
  // Serial.print("   ");
  // Serial.println(derajatPos);
  Serial.print(set_point);
  Serial.print(",");
  Serial.print(derajatPos, 3); 
  Serial.print(",");
  Serial.print(Kp, 1);
  Serial.print(",");
  Serial.print(Ki, 1);
  Serial.print(",");
  Serial.println(Kd, 2);


  lcd.setCursor(0, 0);
  if (step == 0) {
    dtostrf(Kp, 1, 1, tampil);  // Set 5 lebar, 1 digit di belakang koma
    lcd.print("Kp : ");
    lcd.print(tampil);
    lcd.print("    ");
  } else if (step == 1) {
    dtostrf(Ki, 1, 1, tampil);  // Set 5 lebar, 1 digit di belakang koma
    lcd.print("Ki : ");
    lcd.print(tampil);
    lcd.print("    ");
  } else if (step == 2) {
    dtostrf(Kd, 1, 2, tampil);  // Set 5 lebar, 1 digit di belakang koma
    lcd.print("Kd : ");
    lcd.print(tampil);
    lcd.print("    ");
  }
  lcd.setCursor(0, 1);
  dtostrf(set_point, 3, 1, tampil);
  lcd.print("T:");
  lcd.print(tampil);
  lcd.print("  ");  // Clear extra space
  dtostrf(derajatPos, 3, 1, tampil);
  lcd.print("P:");
  lcd.print(tampil);
  lcd.print("  ");
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

double mapDouble(double x, double in_min, double in_max, double out_min, double out_max) {
  return (x - in_min) * (out_min - out_max) / (in_max - in_min) + out_max;
}