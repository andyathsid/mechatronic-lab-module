int kontrol_PID(int16_t dir) {
  float nilai_sensor = dir;

  error = set_point - nilai_sensor;
  outP = Kp * error;

  errorI = fLimit(error* Tc + errorI,255/Ki,-255/Ki,0);
  outI = Ki * errorI ;
  //error_sblmI = errorI;

  errorD = error - error_sblmD;
  outD = (Kd * errorD);
  error_sblmD = error;

  outPID = outP + outI + outD;
  return (outPID);
}