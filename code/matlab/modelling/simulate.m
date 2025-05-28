% Buat sistem loop tertutup dengan kontroler hasil tuning
CL1 = feedback(X2*G2*C2,X1);
CL1.InputName = 'r';
CL1.OutputName = 'y';

% Plot respons step sistem
figure;
step(CL1);
title('Respons Step dengan Kontroler PID Hasil Tuning');
grid on;

steady_state_value = y(end);
steady_state_error = abs(1 - steady_state_value)*100; % Dalam persentase

% Tampilkan hasil analisis
fprintf('\n--- ANALISIS KARAKTERISTIK RESPONS SISTEM ---\n');
fprintf('Rise Time (waktu naik)     : %.4f detik\n', rise_time);
fprintf('Peak Time (waktu puncak)    : %.4f detik\n', peak_time);
fprintf('Settling Time (waktu tunak) : %.4f detik\n', settling_time);
fprintf('Overshoot                   : %.2f%%\n', overshoot);
fprintf('Steady State Error          : %.4f%%\n', steady_state_error);