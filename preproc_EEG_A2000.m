% reading in, preprocessing, and performing spectral analysis on BIS data

close all
clear all
format compact
clc
restoredefaultpath

global RUN;

% get patients bin data to matlab data structures

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


% machine-contingent project path
RUN.projectPath = 'Z:\Projects\charlie\anesthesiaProject\analysis\BIS'; cd(RUN.projectPath)
RUN.dataPath = 'Z:\Projects\charlie\anesthesiaProject\data\BIS';

RUN.eeglab = 'Z:\Projects\charlie\toolboxes\eeglab13_6_5b';
RUN.fieldtrip = 'Z:\Projects\charlie\toolboxes\fieldtrip-20161028';
RUN.plot2svg = 'C:\toolbox\plot2svg_20120915';
addpath(RUN.eeglab);
addpath(RUN.fieldtrip);
addpath(RUN.plot2svg);
ft_defaults

eeglab

for i = 74:length(allPatients)
%[filename,pathname]=uigetfile('*.eeg','Select EEG File');
if isempty(allPatients(74).Ch2)
    print('no data')
else

if i>99 
    foldername = sprintf('ACT%d', i);
else
    foldername = sprintf('ACT0%d', i);
end


%RUN.subjectID = {'ACT072' 'ACT074', 'ACT075'};
%iSub = 2; % index for study number matrix

% run read_EEG_A2000.m, select the .bin file; this will extract data to Ch1 and Ch2 as below
data = zeros(2,length(allPatients(i).Ch1));
data(1,:) = allPatients(i).Ch1;
data(2,:) = allPatients(i).Ch2;
EEG = pop_importdata('dataformat','array','nbchan',2,'data','data','setname','data','srate',256,'pnts',0,'xmin',0);

% add channel locations
EEG = pop_chanedit(EEG, 'load',{'bis_montage.ced' 'filetype' 'autodetect'});

pop_eegplot( EEG, 1, 1, 1); % plot the data

% highpass filter the data at 2 Hz to remove slow drift
EEG = pop_firws(EEG, 'fcutoff', 2, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', 846, 'minphase', 0);

% manually create 3s epochs
epochs = zeros(round(EEG.xmax/3),2);
epochs(:,1) = linspace(0,EEG.xmax,round(EEG.xmax/3));

EEG = pop_importevent(EEG, 'event', epochs, 'fields', {'latency' 'type'}, 'timeunit', 1);

% redraw
%eeglab -redraw
%%
% epoch the dataset
EEG = pop_epoch( EEG, {}, [0 3]);

% create the trial structure
trialStruct = zeros(length(EEG.epoch),2);
trialStruct = array2table(trialStruct, 'VariableNames',{'index' 'event'}); % convert to a table
trialStruct.index = (1:height(trialStruct))';
trialStruct.subjectID = repmat(i, height(trialStruct),1); % add a column for subject ID
trialStruct = trialStruct(:,[3 1 2]); % move the subjectID column all the way to the left


% artifact detection

% voltage threshold artifact test
EEG = pop_eegthresh(EEG,1,[1:2],-1000,1000,0,3,0,0);
trialStruct.artThresh = [EEG.reject.rejthresh'];

% to visualize the trials that have been marked as artifacts
artifactEEG = any([trialStruct.artThresh],2)'; 
EEG.reject.rejmanualE = zeros(EEG.nbchan, EEG.trials);
EEG.reject.rejmanual = artifactEEG;
winrej = trial2eegplot(EEG.reject.rejmanual,EEG.reject.rejmanualE,EEG.pnts,[.50, .50, .50]);
eegplot(EEG.data,'eloc_file', EEG.chanlocs,'winrej',winrej,'srate',EEG.srate,...
    'limits',1000*[EEG.xmin EEG.xmax], 'winlength', 4, 'spacing', 50,...
    'dispchans', 32);


%% save files

dataFT = eeglab2fieldtrip(EEG,'preprocessing');
dataEEG = EEG;

save(fullfile(RUN.dataPath, foldername, '/dataFT.mat'), 'dataFT')
save(fullfile(RUN.dataPath, foldername, '/dataEEG.mat'), 'dataEEG')
save(fullfile(RUN.dataPath, foldername, '/trialStruct.mat'), 'trialStruct');
end
end
