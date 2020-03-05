%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% 1) Intitialization:
%%% Specify all the directories and parameters
%%% * detect heart beat
%%% * look at distribution
%%% * get rid of outliers
%%% 2) Build IBI time series
%%%
%%% 3) Spectrum 
%%%
%%% 4) Filtering
%%%
%%% 5) Hilbert transform 
%%%
%%%
%%% Author: Magdalena Sabat
%%% Email: magdalena.sabat@ens.fr
%%% Version: 19/11/2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1) Intitialization: 
% preparation for data analysis - Remove items from workspace, freeing up
% system memory; closes all figures; clears cmd 
clear all; close all; clc; 

% location of the server (where the data is - this project PUPIL; creates a
% variaple with a path of the location of the server
PUPIL_location = strcat(['R:' filesep]);

% add location of the scripts - not used here yet
addpath(genpath(strcat([PUPIL_location 'Scripts'])));

% Enter subject number - can be a list? 
sub_id = '02';

% Enter number of blocks for this subject
nBlocks = 1;

% Location of raw data
raw_data_path = strcat([PUPIL_location 'Data_raw' filesep]);

% Location for the analysed data
work_dir = strcat([PUPIL_location 'Data_work' filesep]);

% Location for the figures
fig_dir = strcat([PUPIL_location 'Figures' filesep]);

% Add Fieldtrip to the path - library you're using for the analysis - adds
% the folder to the top of the search path for current session
addpath(strcat([PUPIL_location 'Toolboxes' filesep 'fieldtrip-20191113']));

% sets some general settings in the global variable (ft_default, stores
% global configuration defaults - call at the begining of the file)
ft_defaults;

% MEG sampling rate - needed when you work with meg as well, if  not skip
% (usually kept in the initialization 
Fif_fs = 1000;


% Eyelink sampling frequency
eyelink_fs = 1000;

%% Heart peak detection 

% load original events sturcture (resting)
load(strcat([work_dir 'Events' filesep 'Fif' filesep 'Subject' sub_id filesep 'Subject' sub_id '_events_original_resting']), 'events_original_resting')

% read ECG (resting)   
cfg                 = [];
cfg.continuous      = 'yes';
cfg.channel         = {'BIO002'};
cfg.dataset         = [raw_data_path sub_id filesep 'FIF' filesep 'resting_trans_tsss.fif'];
ECG_resting  = ft_preprocessing(cfg);

%save(strcat([work_dir 'Subject' sub_id filesep 'Subject' sub_id '_ECG.mat']), 'ECG', '-v7.3')
save(strcat([work_dir filesep 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_ECG_resting.mat']), 'ECG_resting', '-v7.3')

% mark R- and T-peaks
events_heartbeats_resting = events_original_resting;
    
cfg = [];
cfg.fsample = Fif_fs;

%%% resting block
[HeartBeats, R_time] = heart_peak_detect(cfg,ECG_resting);
samples_Rpeaks = [HeartBeats.R_sample];
samples_Tpeaks = [HeartBeats.T_sample];

% add markers for R-peaks and T-peaks
events_heartbeats_resting = my_addmarker(events_heartbeats_resting, 'R-Peak', samples_Rpeaks, Fif_fs);
events_heartbeats_resting = my_addmarker(events_heartbeats_resting, 'T-Peak', samples_Tpeaks, Fif_fs);

%save(strcat([work_dir 'ECG' filesep 'Subject' sub_id '_events_heartbeats.mat']), 'events_heartbeats', '-v7.3');
save(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_events_heartbeats_resting.mat']), 'events_heartbeats_resting', '-v7.3');

%%% Show result (optional) 
load(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_events_heartbeats_resting.mat']), 'events_heartbeats_resting');
ind_tpeaks = my_findmarkers(events_heartbeats_resting, 'T-Peak');
samples_tpeaks = [events_heartbeats_resting(ind_tpeaks).sample];
ind_rpeaks = my_findmarkers(events_heartbeats_resting, 'R-Peak');
samples_rpeaks = [events_heartbeats_resting(ind_rpeaks).sample];


figure;
plot(ECG_resting.trial{1});
vline(samples_tpeaks, 'g'); vline(samples_rpeaks, 'r');
 




%% 2) Build IBI time series
% for each pair of consequtive beats, substract the time at which they
% occur from each other and built a time series 

% get the timestamps of r peaks
load(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_events_heartbeats_resting.mat']), 'events_heartbeats_resting');
load(strcat([work_dir filesep 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_ECG_resting.mat']), 'ECG_resting');


ind_rpeaks = my_findmarkers(events_heartbeats_resting, 'R-Peak');
timestamps_rpeaks = [events_heartbeats_resting(ind_rpeaks).timestamp];

% create an array with the ibi intervals
IBI_resting = [];
for i = 1:(length(timestamps_rpeaks)-1)
    x = timestamps_rpeaks(i+1) - timestamps_rpeaks(i);
    IBI_resting = cat(1, IBI_resting, x);
    
end


% create an array with time points for ibi time series (each point is a
% mean of two r peaks)
IBI_timepoints = [];
for i = 1:(length(timestamps_rpeaks)-1);
    x = (timestamps_rpeaks(i+1) + timestamps_rpeaks(i)) / 2;
    IBI_timepoints = cat(1, IBI_timepoints, x);
    
end

%interpolate IBI timepoints with IBI intervals over trial timecourse 
IBI_timeseries = spline(IBI_timepoints, IBI_resting, ECG_resting.time{1});


%plot the IBI time series
figure; plot(IBI_timeseries); xlabel('time'); ylabel('IBI'); title('interpolated IBI timeseries');


save(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_IBI_timeseries_resting.mat']), 'IBI_timeseries');




%% 3) Spectrum 

%load IBI timeseries &put it into a fieldtrip-style structure 
load(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_IBI_timeseries_resting.mat']), 'IBI_timeseries');
load(strcat([work_dir filesep 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_ECG_resting.mat']), 'ECG_resting'); 

%very ugly fix this!!!! - maybe consider creating only the parts you need 
IBI_timeseries_resting = ECG_resting;
IBI_timeseries_resting.trial{:} = IBI_timeseries;
%IBI_timeseries_resting = struct('label','BIO002','time',ECG_resting.time{1}, 'trial',IBI_timeseries, 'fsample',1000, 'sampleinfo',[1,825000], 'cfg',ECG_resting.cfg); 


%power spectrum -set parameters 
cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'pow';
cfg.foilim      = [0. 0.5]; %freq band of interest
cfg.taper       = 'dpss';
cfg.tapsmofrq   = 0.005; %optimal resolution 
cfg.pad         = 'maxperlen';

%run the analysis
[IBI_spectrum]= ft_freqanalysis(cfg, IBI_timeseries_resting); 

%visualize - sanity check - does the data follow the usuall model?
figure;
cfg.parameter   = 'powspctrm'; 
cfg.title       = 'IBI time series power spectrum'
ft_singleplotER(cfg, IBI_spectrum);

%save the file 
save(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_IBI_timeseries_spectrum.mat']), 'IBI_spectrum');


%% 4) Filtering

%load IBI timeseries &put it into a fieldtrip-style structure 
load(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_IBI_timeseries_resting.mat']), 'IBI_timeseries');
load(strcat([work_dir filesep 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_ECG_resting.mat']), 'ECG_resting'); 

%very ugly fix this!!!! - maybe consider creating only the parts you need 
IBI_timeseries_resting = ECG_resting;
IBI_timeseries_resting.trial{:} = IBI_timeseries;
%IBI_timeseries_resting = struct('label','BIO002','time',ECG_resting.time{1}, 'trial',IBI_timeseries, 'fsample',1000, 'sampleinfo',[1,825000], 'cfg',ECG_resting.cfg); 

%%%%%%%%%%%%%%%%%%%%%%%%%
%filter low (0.04–0.15 Hz)
LF_band = [0.04 0.15];
LF_HRV_but1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, LF_band, 1, 'but');
LF_HRV_fir5 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, LF_band, 5, 'fir');
LF_HRV_brickw1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, LF_band, 1, 'brickwall');
LF_HRV_firws41250 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, LF_band, 41250, 'firws');


%filterlow with design filter
% set up filter
srate               = Fif_fs;
center_frequency    = 0.1; % depends on data % , center frequency for LFHRV 0.1 Hz ± 0.06 Hz,
bandwidth           = 0.06;
transition_width    = 0.15;
nyquist             = srate/2;
ffreq(1)            = 0;
ffreq(2)            = (1-transition_width)*(center_frequency-bandwidth);
ffreq(3)            = (center_frequency-bandwidth);
ffreq(4)            = (center_frequency+bandwidth);
ffreq(5)            = (1+transition_width)*(center_frequency+bandwidth);
ffreq(6)            = nyquist;
ffreq               = ffreq/nyquist;
fOrder              = 4; % in cycles changed from 7
filterOrder         = fOrder*fix(srate/(center_frequency - bandwidth));
%in samples
idealresponse       = [ 0 0 1 1 0 0 ];
filterweights       = fir2(filterOrder,ffreq,idealresponse);

%run the filter
disp('Filtering ECG - this will take some time');
LF_HRV4   = filtfilt(filterweights,1,IBI_timeseries_resting.trial{1});

%plot the results of all filter types
figure('NumberTitle', 'off', 'Name', 'low freq (0.04–0.15 Hz) bandpassed IBI time series');
subplot(5,1,1); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,1); plot(IBI_timeseries_resting.time{1}, LF_HRV_but1); title('Butterworth IIR filter - 1st order');
hold off; 
subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, LF_HRV_fir5); title('FIR filter using MATLAB fir1 function - 5th order');
hold off; 
subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, LF_HRV_firws41250); title('windowed sinc FIR filter - 41250');
hold off; 
subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, LF_HRV_brickw1); title('Frequency-domain filter using MATLAB FFT and iFFT function - 1st order');
hold off; 
subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, LF_HRV4); title('design filter based on fir2 MARTLAB filter - 4th order') 
hold off
%set legend
hL = legend({'original','filtered'});
% Programatically move the Legend
newPosition = [0.9 0.9 0.1 0.1];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits);

%chosen filtering
LF_HRV_filt = IBI_timeseries_resting
LF_HRV_filt.trial{1} = LF_HRV_brickw1



%%%%%%%%%%%%%%%%%%%%%%%%%
%filter high (0.15–0.4 Hz) 

HF_band = [0.15 0.4];
HF_HRV_but1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, HF_band, 1, 'but');
HF_HRV_fir5 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, HF_band, 5, 'fir');
HF_HRV_brickw1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, HF_band, 1, 'brickwall');
HF_HRV_firws41250 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, Fif_fs, HF_band, 41250, 'firws');

%filter high with design filter
% set up filter
srate               = Fif_fs;
center_frequency    = 0.275; % depends on data % , center frequency for LFHRV 0.1 Hz ± 0.06 Hz,
bandwidth           = 0.125; % change only these two
transition_width    = 0.15;
nyquist             = srate/2;
ffreq(1)            = 0;
ffreq(2)            = (1-transition_width)*(center_frequency-bandwidth);
ffreq(3)            = (center_frequency-bandwidth);
ffreq(4)            = (center_frequency+bandwidth);
ffreq(5)            = (1+transition_width)*(center_frequency+bandwidth);
ffreq(6)            = nyquist;
ffreq               = ffreq/nyquist;
fOrder              = 4; % in cycles changed from 7
filterOrder         = fOrder*fix(srate/(center_frequency - bandwidth));
%in samples
idealresponse       = [ 0 0 1 1 0 0 ];
filterweights       = fir2(filterOrder,ffreq,idealresponse);

%run the filtering
disp('Filtering ECG - this will take some time');
HF_HRV4   = filtfilt(filterweights,1,IBI_timeseries_resting.trial{1});

%plot the results of all filter types
figure('NumberTitle', 'off', 'Name', 'high freq (0.15–0.4 Hz) bandpassed IBI time series');
subplot(5,1,1); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,1); plot(IBI_timeseries_resting.time{1}, HF_HRV_but1); title('Butterworth IIR filter - 1st order');
hold off; 
subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, HF_HRV_fir5); title('FIR filter using MATLAB fir1 function - 5th order');
hold off; 
subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, HF_HRV_firws41250); title('windowed sinc FIR filter - 41250');
hold off; 
subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, HF_HRV_brickw1); title('Frequency-domain filter using MATLAB FFT and iFFT function - 1st order');
hold off; 
subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, HF_HRV4); title('design filter based on fir2 MARTLAB filter - 4th order');
hold off
%set legend
hL = legend({'original','filtered'});
% Programatically move the Legend
newPosition = [0.9 0.9 0.1 0.1];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits);

%chosen filtering
HF_HRV_filt = IBI_timeseries_resting
HF_HRV_filt.trial{1} = HF_HRV_brickw1

save(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_data_LF_HRV.mat']), 'LF_HRV_filt');
save(strcat([work_dir 'ECG' filesep 'Subject' sub_id filesep 'Subject' sub_id '_data_HF_HRV.mat']), 'HF_HRV_filt');


%% 5) Hilbert Transform

% analytic LF_HRV
LF_HRV_phase = LF_HRV_filt;
LF_HRV_phase.trial{1}      = angle(hilbert(LF_HRV_filt.trial{1}'))';
LF_HRV_phase.trial{1}(2,:) = abs(hilbert(LF_HRV_filt.trial{1}'))';        
LF_HRV_phase.label      = {'phase', 'amplitude'};

figure; plot(LF_HRV_phase.trial{1}(2, :)); hold on; plot(LF_HRV_filt.trial{1});

data_LF_HRV = ft_appenddata([],LF_HRV_phase,LF_HRV_filt);

% analytic HF_HRV
HF_HRV_phase = HF_HRV_filt;
HF_HRV_phase.trial{1}      = angle(hilbert(HF_HRV_filt.trial{1}'))';
HF_HRV_phase.trial{1}(2,:) = abs(hilbert(HF_HRV_filt.trial{1}'))';        
HF_HRV_phase.label      = {'phase', 'amplitude'};

figure; plot(HF_HRV_phase.trial{1}(2, :)); hold on; plot(HF_HRV_filt.trial{1});

data_HF_HRV = ft_appenddata([],HF_HRV_phase,HF_HRV_filt); 

%save the file 



