%% Build IBI time series
Fif_fs = 1000


cfg             = [];
cfg.resamplefs      = Fif_fs %frequency at which the data will be resampled (default = 256 Hz)
cfg.detrend         = 'yes' %detrend the data prior to resampling 
cfg.trials          = 'all'
cfg.sampleindex     = 'no'
data_ecg3 = ft_resampledata(cfg, data_ecg3)
save('spectre_data', 'data_ecg3', 'timestamps', 'intervals')

intervals = stats.RR
timestamps = stats.x_spectre
IBI_timeseries = spline(timestamps, intervals, data_ecg3.time{1});

plot(timestamps, intervals)
%plot the IBI time series
figure; plot(IBI_timeseries); xlabel('time'); ylabel('IBI'); title('interpolated IBI timeseries');

save('spectre_data', 'IBI_timeseries', '-append')

IBI_timeseries_resting = data_ecg3;
IBI_timeseries_resting.trial{:} = IBI_timeseries;
%% Spectrum
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
ylim([0 2e-5])
save('spectre_data', 'IBI_spectrum', '-append')

%% Filtering

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
%% 
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
