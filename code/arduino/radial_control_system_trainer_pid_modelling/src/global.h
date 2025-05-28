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
#define __minDeg 0
#define __maxDeg 180
#define __maxValPWM 255
unsigned int __minRot = 0;
unsigned int __maxRot = 2370;

//PINOUT
int pinPwm = 13;  //aktifkan motor1 port 1
int dir1 = 12;    //port 3 enable  motor
int dir2 = 11;    //port 4 enable motor

int isRun = 0;
int isStop = 0;

int isStart = 1;
int isBegin = 0;
int pwm = 30;

int posADC = 0;
int pot = 0;

int limitKanan = 0;
int limitKiri = 0;

int speed = 0;
int dir = 0;
int derajatPos = 0;
int step = 0;
int x = 0;


volatile bool isEncoderActive = false;  // Status encoder aktif atau tidak
volatile int rotary = 0;
int lrotary = 1;
volatile boolean PastA = 0;
volatile boolean PastB = 0;

LiquidCrystal lcd(33, 31, 29, 27, 25, 23);  //B.
char tampil[16];

unsigned long time;
unsigned long timeNow = 0;
float error_sblmI = 0, error_sblmD = 0, outPID, set_point = 0, Tc = 0.01, error, errorI, errorD, outP, outI, outD;

float var1;
float var2;
float var3;
float var4;
float var5;
float var6;
float var7;
float var8;

double targetsin;
double sinco = 0;
double sinsweep = 0;
double integrator = 0;
double newsetpoint = 0;
