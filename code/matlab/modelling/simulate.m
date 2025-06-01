% Buat sistem loop tertutup dengan kontroler hasil tuning
CL1 = feedback(X2*G2*C2,X1);
CL1.InputName = 'r';
CL1.OutputName = 'y';

% Plot respons step sistem dan tangkap data respons
figure;
[y, t] = step(CL1);
plot(t, y);
title('Respons Step dengan Kontroler PID Hasil Tuning');
grid on;

% Hitung karakteristik respons menggunakan stepinfo
info = stepinfo(y, t);

% Ekstrak metrik respons
rise_time = info.RiseTime;
settling_time = info.SettlingTime;
overshoot = info.Overshoot;

% Hitung steady-state error
steady_state_value = y(end);
steady_state_error = abs(1 - steady_state_value)*100; % dalam persentase

% Tampilkan hasil
fprintf('\n--- KARAKTERISTIK RESPONS SISTEM ---\n');
fprintf('Rise Time      : %.4f detik\n', rise_time);
fprintf('Settling Time  : %.4f detik\n', settling_time);
fprintf('Overshoot      : %.2f%%\n', overshoot);
fprintf('Steady State Error : %.4f%%\n', steady_state_error);