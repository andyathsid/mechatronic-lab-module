//button
#define push_1 7
#define push_2 4
#define push_3 5
#define push_4 6

#define encoder0PinA 2
#define encoder0PinB 3

#define potPin A2  //potensiometer

//limit switch
#define pin1 A0  //Kanan
#define pin2 A1  //Kiri

//min-max variable
#define __minADC 0
#define __maxADC 1023
#define __maxValPWM 200
// unsigned long __minRot = 0;
// unsigned long __maxRot = 105629;
unsigned long __minRot;
unsigned long __maxRot;
double __minDeg = -9.0;
double __maxDeg = 9.0;

//PINOUT
int pinPwm = 13;  //aktifkan motor1 port 1
int dir1 = 12;    //port 3 enable  motor
int dir2 = 11;    //port 4 enable motor

int isRun = 0;
int isStop = 0;

int isStart = 1;
int isBegin = 0;

double posADC = 0;
double pot = 0;

int limitKanan = 0;
int limitKiri = 0;

int speed = 0;
double dir = 0;
double derajatPos = 0;
int step = 0;

int x = 0;

volatile bool isEncoderActive = false;  // Status encoder aktif atau tidak
volatile long rotary = 0;
int lrotary = 1;
volatile boolean PastA = 0;
volatile boolean PastB = 0;

LiquidCrystal lcd(33, 31, 29, 27, 25, 23);
char tampil[16];

unsigned long time;
unsigned long timeNow = 0;
float error_sblmI = 0, error_sblmD = 0, outPID, set_point = 0, Tc = 0.004, error, errorI, errorD, outP, outI, outD;
float Kp = 5.0, Ki = 5.0, Kd = 1.0;

double newsetpoint = 0;