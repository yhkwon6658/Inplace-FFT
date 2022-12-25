clear;
clc;
close all;
%% Put the Input file name and Output file name
%% Output file must be .txt
infile = "C:\PROJECT\FFT\STFT\DATA\input\chopin_etude_op25_no11.mp3";
outfile = "C:\PROJECT\FFT\STFT\DATA\output\sample.txt";
[y, Fs_ori] = audioread(infile);
%% You can choose the start time and end time
%% Unit: sec
START = 5;
END = 6;
y = y(START*Fs_ori:END*Fs_ori);
%% Choose Sample Rate
%% Unit: Hz
Fs = 8192;
x = resample(y,Fs,Fs_ori);
%% Save data for .txt
fileID = fopen(outfile,'w');
fprintf(fileID,'%f\n',x);
fclose(fileID);
%% You can listen the resampled data
sound(x,Fs);
%% Original Data Plot
subplot(2,1,1);
L = length(x);
t = (0:L-1)/Fs;
plot(t,x);
title('Original Data');
xlabel('Time(sec)');
ylabel('x(t)');
%% FFT Plot
subplot(2,1,2);
X = fft(x);
N = round(L/2);
X = abs(X)/N;
X(2:N) = 2*X(2:N);
Y = X(1:N);
f = Fs*(0:N-1)/L;
plot(f,Y);
title('FFT Result');
xlabel('Frequency(Hz)');
ylabel('|X(f)|');