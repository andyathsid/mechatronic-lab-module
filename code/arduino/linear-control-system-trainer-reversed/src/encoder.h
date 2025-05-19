volatile uint8_t lastState = 0;  // Menyimpan status terakhir A dan B

void doEncoder() {
  static uint8_t lastState = 0;
  uint8_t state = (digitalRead(encoder0PinA) << 1) | digitalRead(encoder0PinB);
  if (((lastState == 0b00) && (state == 0b01)) || ((lastState == 0b01) && (state == 0b11)) || ((lastState == 0b11) && (state == 0b10)) || ((lastState == 0b10) && (state == 0b00))) {
      rotary--; 
  } else if (((lastState == 0b00) && (state == 0b10)) || ((lastState == 0b10) && (state == 0b11)) || ((lastState == 0b11) && (state == 0b01)) || ((lastState == 0b01) && (state == 0b00))) {
      rotary++; 
  }
  lastState = state;
}

void activateEncoder() {
  isEncoderActive = true;
  lastState = (digitalRead(encoder0PinA) << 1) | digitalRead(encoder0PinB);
  attachInterrupt(digitalPinToInterrupt(encoder0PinA), doEncoder, CHANGE);
  attachInterrupt(digitalPinToInterrupt(encoder0PinB), doEncoder, CHANGE);
}

void deactivateEncoder() {
  isEncoderActive = false;
  detachInterrupt(digitalPinToInterrupt(encoder0PinA));
  detachInterrupt(digitalPinToInterrupt(encoder0PinB));
}
