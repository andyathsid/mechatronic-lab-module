% Script untuk mengekstrak data sesuai rentang yang diinginkan
% Tentukan rentang data yang akan digunakan
indeks_awal = 1;      
indeks_akhir = 12345;  % Ganti sesuai tabel rentang data kelompok

var1 = var1(indeks_awal:indeks_akhir);
var2 = var2(indeks_awal:indeks_akhir);
var3 = var3(indeks_awal:indeks_akhir);
var4 = var4(indeks_awal:indeks_akhir);
var5 = var5(indeks_awal:indeks_akhir);
var6 = var6(indeks_awal:indeks_akhir);
var7 = var7(indeks_awal:indeks_akhir);
var8 = var8(indeks_awal:indeks_akhir);

disp(['Data dari indeks ', num2str(indeks_awal), ' sampai ', num2str(indeks_akhir), ' telah disiapkan.']);

t = (0:length(var2)-1)*0.01; % waktu sampling 10ms
figure;
plot(t, var2, 'b', t, var3, 'r');
legend('Setpoint (Input)', 'Posisi Aktual (Output)');
title('Data Sistem Kendali Radial');
xlabel('Waktu (detik)');
ylabel('Posisi (derajat)');