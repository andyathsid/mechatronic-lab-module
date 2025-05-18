int kontrol_PID(int16_t dir) {
  float nilai_sensor = dir;

  error = set_point - nilai_sensor;
  outP = Kp * error;

  errorI = error + error_sblmI;
  outI = Ki * errorI * Tc;
  error_sblmI = errorI;

  // errorD = error - error_sblmD;
  errorD = (error - error_sblmD) / Tc;
  outD = (Kd * errorD);
  error_sblmD = error;

  outPID = (outP + outI + outD);

  // // Batasi outPID jika diperlukan (opsional)
  if (outPID > 255) outPID = 255;
  if (outPID < -255) outPID = -255;
  if (errorI > 25) errorI = 25;  // Sesuaikan batas maksimal
  if (errorI < -25) errorI = -25;


  return (outPID);
}