% Program to open *.bin file containing 2 channels of EEG data recorded using the ASPECT BIS Monitor A-2000
% The *.bin file is created after running the LabVIEW program to read the *.eeg files.

% Select bin file
%[filename,pathname]=uigetfile('*.bin','Select BIN File');
%filename=[pathname,filename];
%fid=fopen(filename,'r','ieee-be');
clear all; 
allPatients = struct; 
for i = 74:122

if i>99 
    filename = sprintf('ACT%d\\ACT%d.bin', i, i);
else
    filename = sprintf('ACT0%d\\ACT0%d.bin', i, i);
end

folder = 'Z:\Projects\charlie\anesthesiaProject\data\BIS\';
pathname = fullfile(folder, filename);
if exist(pathname, 'file')
allPatients(i).fid=fopen(pathname,'r','ieee-be');
disp(pathname);
disp(allPatients(i).fid); 

%structString = sprintf('ACT%d', i);

allPatients(i).fs = fread(allPatients(i).fid,[1],'int16');
allPatients(i).data = fread(allPatients(i).fid,[2 inf],'int16');
allPatients(i).ch2 = allPatients(i).data(1:2:end);
allPatients(i).ch1 = allPatients(i).data(2:2:end);

sclngfctr = 0.0500438; % uV/quantization level for BIS A2000
offset = -3231.17;     % for BIS A2000

% sclngfctr = 0.05; % for BIS Vista m/c 
% offset = -3234;     % for BIS Vista

allPatients(i).Ch1 = (allPatients(i).ch1-offset)*sclngfctr; % scaled data
allPatients(i).Ch2 = (allPatients(i).ch2-offset)*sclngfctr; % scaled data

allPatients(i).seg_Ch1 = allPatients(i).Ch1; 
allPatients(i).seg_Ch2 = allPatients(i).Ch2; 

allPatients(i).taxs = (1:length(allPatients(i).seg_Ch1))/(allPatients(i).fs*60);

%figure; plot(taxs,seg_Ch1); title('EEG Ch1'); 
%xlabel('Time (Min)'); ylabel('uV');

%figure; plot(taxs,seg_Ch2); title('EEG Ch2'); 
%xlabel('Time (Min)');  ylabel('uV');

%window = hamming(4*fs);
%noverlap = 2*fs;  % 2 
%nfft = 8*fs;

%[s1,f1,t1] = spectrogram(seg_Ch1,window,noverlap,nfft,fs);
%[s2,f2,t2] = spectrogram(seg_Ch2,window,noverlap,nfft,fs);

%clim=[50 80];
%figure;
%imagesc(t1/60,f1,20*log10(abs(s1)),clim); colorbar; axis('xy'),ylim([0 20]);
%xlabel('Time (Min)'); ylabel('Frequency (Hz)'); title('EEG Ch1'); 
%figure;
%imagesc(t2/60,f2,20*log10(abs(s2)),clim); colorbar; axis('xy'),ylim([0 20]);
%xlabel('Time (Min)'); ylabel('Frequency (Hz)'); title('EEG Ch2'); 

else 
    message = sprintf('act subj %d dne', i)
    disp(message)
end
end
