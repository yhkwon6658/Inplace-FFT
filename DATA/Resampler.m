clear;
clc;
close all;
%% Put the Input file name and Output file name
%% Output file must be .txt
infile = "input\chopin_etude_op25_no11.mp3";
outfile = "C:output\sample.txt";
[y, Fs_ori] = audioread(infile);
%% Select Option(Start time, End time, Sample rate, Write mode)
START = 5;
END = 6;
Fs = 8192;
mode = 0; % 0 : SW, 1 : HW

y = y(round(START*Fs_ori):round(END*Fs_ori));
x = resample(y,Fs,Fs_ori);
L = length(x)-1;
fileID = fopen(outfile,'w');
if (mode == 0)
    fprintf(fileID,'%f\n',x);
else
    xx = zeros(1,2*L);
    for i = 1:L
        xx(2*i-1) = x(i);
        xx(2*i) = 0;
    end
    formatSpec = '%tx%tx\n';
    fprintf(fileID,formatSpec,xx);
end
fclose(fileID);
fprintf('Sample Rate: %d\n', Fs);
fprintf('# Sample: %d\n',L);
fprintf('DONE\n');

%% You can listen the resampled data
%%sound(x,Fs);
%% Original Data Plot
%%subplot(2,1,1);
%%L = length(x);
%%t = (0:L-1)/Fs;
%%plot(t,x);
%%title('Original Data');
%%xlabel('Time(sec)');
%%ylabel('x(t)');
%% FFT Plot
%%subplot(2,1,2);
%%X = fft(x);
%%N = round(L/2);
%%X = abs(X)/N;
%%X(2:N) = 2*X(2:N);
%%Y = X(1:N);
%%f = Fs*(0:N-1)/L;
%%plot(f,Y);
%%title('FFT Result');
%%xlabel('Frequency(Hz)');
%%ylabel('|X(f)|');