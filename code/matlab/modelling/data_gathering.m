%menghapus komunikasi sebelumnya
clear
clear a;

%uncomment untuk menghapus semua variable
clear all;

%total jumlah data yang ingin diterima
totaldata = 1000;

%total tipe var6iable yang diterima
totaltype =8;

%setting baudrate dan COM sesuai program arduino
a = serialport("COM4",115200 )

%reset variable ke kondisi awal
countdata = 0;

data = zeros(1,totaldata,totaltype);

tempread = zeros(1,20);
sinus = single(1);
vars1 = typecast(sinus,"uint8");
c = clock;
while (countdata<totaldata)
    %cek jumlah variable yang tersedia di buffer, comment jika
    %mengganggu
   % a.NumBytesAvailable
    
    if (  a.NumBytesAvailable>totaltype*4)%jika data di buffer mencukupi, proses data
        tempread =uint8( read(a,totaltype*4,"uint8"));
        %menampilkan idx array yang sedang diproses, comment jika
        %mengganggu
        countdata = countdata+1
        timenow = clock-c;
        %memasukkan data yang terbaca ke array
        for i=1:totaltype    
            data(1,countdata,i)   =typecast(tempread(1,1+(i-1)*4:4+(i-1)*4),"single");
        end
        %pause(0.002);
        %write(a,vars1,"uint8");
    end
end

%mengelompokkan data berdasarkan tipe
var1 = data(1,:,1);
var2 = data(1,:,2);
var3 = data(1,:,3);
var4 = data(1,:,4);
var5 = data(1,:,5);
var6 = data(1,:,6);
var7 = data(1,:,7);
var8 = data(1,:,8);

%menghapus komunikasi sebelumnya
clear a;