G2 = ss1;
C20 = tunablePID('C2','pid',0.01);%tunableSS('C2',2  ,1,1, 0.01);%tunablePID('C2','pi');%tunableSS('C2',1  ,1,1, 0.0026);%tunablePID('C2','pi');

X1 = AnalysisPoint('X1');
X2 = AnalysisPoint('X2');
G2
%InnerLoop = feedback(X2*G2*C20,1);
CL0 = feedback(X2*G2*C20,X1);
CL0.InputName = 'r';
CL0.OutputName = 'y';
controlSystemTuner(CL0)

CL1 = feedback(X2*G2*C2,X1);
CL1.InputName = 'r';
CL1.OutputName = 'y';
step(CL1)