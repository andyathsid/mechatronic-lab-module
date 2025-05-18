void tahap2() {
  //if(targetsin>90){
  //  set_point=150;
  //}else{
  //  set_point=30;
  //}
  //set_point=in[0].raw;
  
  sinsweep = sinsweep + 0.003;
  sinco = sinco + 0.05 * pow(3.0, sin(sinsweep));
  targetsin = sin(sinco) * 80.0 + 90.0;
  set_point = targetsin;
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
  // Store PID parameters to preserve them
  float tempKp = Kp;
  float tempKi = Ki;
  float tempKd = Kd;

  lcd.clear();
  lcd.setCursor(0, 0);
  sprintf(tampil, "RESETTING...");
  lcd.print(tampil);
  
  // Reset control variables
  set_point = 0;
  derajatPos = 0;
  
  // Reset PID variables
  error = 0;
  errorI = 0;
  errorD = 0;
  error_sblmI = 0;
  error_sblmD = 0;
  outP = 0;
  outI = 0;
  outD = 0;
  outPID = 0;
  
  // Reset motor control
  dir = 0;
  speed = 0;
  __stop();

  // Force sending zeros to MATLAB
  if (!usingMatlab) {
    Serial.print("0,0");
    Serial.println();
    delay(50);  // Give time for serial to send
  }

  // Complete the calibration sequence
  x = 0;  // Start with moving to left limit
  
  while (1) {
    limitKanan = digitalRead(pin1);
    limitKiri = digitalRead(pin2);
    
    switch (x) {
      case 0:
        // Move to left limit (0 degrees position)
        speed = 150;
        keKiri();
        if (limitKiri == 0) {
          __stop();
          rotary = 0;  // Reset encoder count at the left limit
          dir = 0;
          __minRot = rotary;
          delay(100);
          x = 1;
        }
        break;
        
      case 1:
        // Move to right limit to calibrate full range
        speed = 150;
        keKanan();
        if (limitKanan == 0) {
          __stop();
          __maxRot = rotary;  // Set maximum rotation value
          x = 2;
        }
        break;
        
      case 2:
        // Move back to left limit (0 degrees)
        speed = 150;
        keKiri();
        if (limitKiri == 0) {
          __stop();
          rotary = 0;  // Ensure encoder is reset at zero
          derajatPos = 0;  // Ensure position is zero
          x = 3;
        }
        break;
        
      case 3:
        // Complete the reset process
        lcd.clear();
        lcd.setCursor(0, 0);
        sprintf(tampil, "RESET COMPLETE");
        lcd.print(tampil);
        delay(500);
        lcd.clear();
        
        // Ensure all variables are properly zeroed
        set_point = 0;
        derajatPos = 0;
        
        // Force sending zeros to MATLAB again
        if (!usingMatlab) {
          Serial.print("0,0");
          Serial.println();
        }
        
        return;  // Exit the reset function
    }
    
    // Short delay during the calibration process
    delay(10);
  }
}