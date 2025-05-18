#define DOUBLE_SIZE 8
float *mvar_double[DOUBLE_SIZE];
float *mvarin_double[DOUBLE_SIZE];
uint8_t intemp[DOUBLE_SIZE * 4];

union floatToBytes {
  float raw;
  uint8_t bytes[4];
};

floatToBytes in[DOUBLE_SIZE], out[DOUBLE_SIZE];

void initmvar() {
  Serial.begin(2000000  );
}

void pointTo(float *a, int b) {
  mvar_double[b] = a;
}

void sendAll() {
  for (int i = 0; i < DOUBLE_SIZE; i++) {
    out[i].raw = *mvar_double[i];
    Serial.write(&out[i].bytes[0], 4);
  }
}

double readAll() {
 // while (Serial.available() < DOUBLE_SIZE);
  if (Serial.available() >= 4*DOUBLE_SIZE) {
    for (int i = 0; i < DOUBLE_SIZE; i++) {
      //an.bytes[i] = Serial.read();
      in[i].bytes[0] = Serial.read();
      in[i].bytes[1] = Serial.read();
      in[i].bytes[2] = Serial.read();
      in[i] .bytes[3] = Serial.read();
    }
    //an.bytes[0] = Serial.read();
    //an.bytes[1] = Serial.read();
    //an.bytes[2] = Serial.read();
    //an.bytes[3] = Serial.read();
  }
  return 0;
}
