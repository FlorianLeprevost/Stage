%% augmented heart_peak_detect
%crée event et trl structures

%% info a remplir pour l'extraction
macro_name ='ECG1'
patient_number= '2757'
recording_date='2019-09-16'
recording_time = '14-33'
experiment = 'Rest'
sample_rate=1024

%% lance heart_peak_detect et crée event+trl file
elec_name{1}=['0' patient_number '_' recording_date '_' recording_time '_' macro_name '.ncs']
data_coeur = Read_iEEG_data(patient_number, recording_date, recording_time, elec_name, experiment)
cfg=[]
cfg.channel = macro_name
[HeartBeats] = heart_peak_detect(cfg,data_coeur)
save([patient_number '_Heart_info'], 'HeartBeats', 'data_coeur')

%save([patient_number '_Heart_info_corrected_outliers'], 'HeartBeats', 'data_coeur')


% remettre heartbeats à la bonne sample rate (?)
x= [HeartBeats.R_sample]
trials=[]
sample_ratio = data_coeur.fsample/sample_rate
trials=round(x/sample_ratio)

%stats des intervalles pour les ajouter dans l'event file
P = [HeartBeats.P_time]
Q = [HeartBeats.Q_time]
R = [HeartBeats.R_time]
T = [HeartBeats.T_time]

interv_RR = diff(R)
interv_RT = T-R
interv_PR = R-P
interv_QR = R-Q

for n = 1:length(interv_RR);
    stats.index(n) = n;
    stats.RR(n) = interv_RR(n);
    stats.RT(n) = interv_RT(n);
    stats.PR(n) = interv_PR(n);
    stats.QR(n) = interv_QR(n);
    stats.x_spectre(n) = R(n) + interv_RR(n)/2;
end

%creation de l'"event_file" ET supprimer les trials outliers
ibi = transpose(interv_RR)
%ibi post --> rajouter nan dernier trial 
ibi_post = [ibi;NaN]
%ibi pré n-1 --> rajouter nan premier trial
ibi_pre= [NaN;ibi]
%diff ibi
diff_ibi= [NaN; diff(ibi);NaN]

%créer un event file
for n = 1:length(trials);
    event_ok(n).type = char('R_peak')
    event_ok(n).value = 0
    event_ok(n).sample = trials(n)
    event_ok(n).timestamp = trials(n)
    event_ok(n).duration = 0
    event_ok(n).offset = 0
    event_ok(n).number = n
    event_ok(n).interval_pre = ibi_pre(n)
    event_ok(n).interval_post = ibi_post(n)
    event_ok(n).interval_diff = diff_ibi(n)
end

for n = 1:length(trials)
    event_ok(n).duration = []
    event_ok(n).offset = []
end
save([patient_number '_Heart_info'], 'event_ok', 'stats', '-append')

%créer trl file
interval_pre = input('how many seconds before the R peak?')
interval_post = input('how many seconds after the R peak?')

trl(:,1) = [event_ok.sample] - interval_pre*sample_rate
trl(:,2) = [event_ok.sample] + interval_post*sample_rate
trl(:,3) = -interval_pre*sample_rate
save([patient_number '_Heart_info'], 'trl', '-append')


%% use stats to plot distrbution of interval PQRST
figure
boxplot(transpose(stats.RR),'Labels', {'RR'})
title('Distribution des intervalles RR')
ylabel('time in s')

figure
histogram(transpose(stats.RR))
title('Distribution des intervalles RR')
xlabel('time in s')

figure
boxplot([transpose(stats.QR),transpose(stats.PR),transpose(stats.RT)],'Labels', {'QR', 'PR', 'RT'})
title('Distribution des intervalles QR, PR et RT')
ylabel('time in s')

figure
histogram(transpose(stats.RT))
hold on
histogram(transpose(stats.PR))
hold on

histogram(transpose(stats.QR))
title('Distribution des intervalles QR, PR et RT')
xlabel('time in s')


%spectre RR
figure
plot(stats.x_spectre, stats.RR)
title('IBI through time')
ylabel('duration in s')
xlabel('time in sample')


%% Copy code from Magdalena
%% Build IBI time series
cfg             = [];
cfg.resamplefs      = sample_rate %frequency at which the data will be resampled (default = 256 Hz)
cfg.detrend         = 'yes' %detrend the data prior to resampling 
cfg.trials          = 'all'
cfg.sampleindex     = 'no'
data_coeur_spectre = ft_resampledata(cfg, data_coeur)

intervals = stats.RR
timestamps = stats.x_spectre
IBI_timeseries = spline(timestamps, intervals, data_coeur_spectre.time{1});

save('spectre_data', 'data_coeur_spectre', 'timestamps', 'intervals')

%plot the IBI time series
figure; plot(IBI_timeseries); xlabel('time'); ylabel('IBI'); title('interpolated IBI timeseries');

save('spectre_data', 'IBI_timeseries', '-append')

IBI_timeseries_resting = data_coeur_spectre;
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
LF_HRV_but2 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, LF_band, 2, 'but');
% LF_HRV_fir5 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, LF_band, 5, 'fir');
% LF_HRV_brickw1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, LF_band, 1, 'brickwall');
% LF_HRV_firws41250 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, LF_band, 41250, 'firws');
% 
% %filterlow with design filter
% % set up filter
% srate               = sample_rate;
% center_frequency    = 0.1; % depends on data % , center frequency for LFHRV 0.1 Hz ± 0.06 Hz,
% bandwidth           = 0.06;
% transition_width    = 0.15;
% nyquist             = srate/2;
% ffreq(1)            = 0;
% ffreq(2)            = (1-transition_width)*(center_frequency-bandwidth);
% ffreq(3)            = (center_frequency-bandwidth);
% ffreq(4)            = (center_frequency+bandwidth);
% ffreq(5)            = (1+transition_width)*(center_frequency+bandwidth);
% ffreq(6)            = nyquist;
% ffreq               = ffreq/nyquist;
% fOrder              = 4; % in cycles changed from 7
% filterOrder         = fOrder*fix(srate/(center_frequency - bandwidth));
% %in samples
% idealresponse       = [ 0 0 1 1 0 0 ];
% filterweights       = fir2(filterOrder,ffreq,idealresponse);
% 
% %run the filter
% disp('Filtering ECG - this will take some time');
% LF_HRV4   = filtfilt(filterweights,1,IBI_timeseries_resting.trial{1});


%plot the results of all filter types
figure('NumberTitle', 'off', 'Name', 'low freq (0.04–0.15 Hz) bandpassed IBI time series');
plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
plot(IBI_timeseries_resting.time{1}, LF_HRV_but2); title('Butterworth IIR filter - 2nd order');
hold off; 
% subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, LF_HRV_fir5); title('FIR filter using MATLAB fir1 function - 5th order');
% hold off; 
% subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, LF_HRV_firws41250); title('windowed sinc FIR filter - 41250');
% hold off; 
% subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, LF_HRV_brickw1); title('Frequency-domain filter using MATLAB FFT and iFFT function - 1st order');
% hold off; 
% subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, LF_HRV4); title('design filter based on fir2 MARTLAB filter - 4th order') 
% hold off
% %set legend
hL = legend({'original','filtered'});
% Programatically move the Legend
newPosition = [0.9 0.9 0.1 0.1];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits);

%chosen filtering
LF_HRV_filt = IBI_timeseries_resting
LF_HRV_filt.trial{1} = LF_HRV_but2

%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%filter high (0.15–0.4 Hz) 

HF_band = [0.15 0.4];
HF_HRV_but2 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, HF_band, 2, 'but');
% HF_HRV_fir5 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, HF_band, 5, 'fir');
% HF_HRV_brickw1 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, HF_band, 1, 'brickwall');
% HF_HRV_firws41250 = ft_preproc_bandpassfilter(IBI_timeseries_resting.trial{1}, sample_rate, HF_band, 41250, 'firws');
% 
% %filter high with design filter
% % set up filter
% srate               = sample_rate;
% center_frequency    = 0.275; % depends on data % , center frequency for LFHRV 0.1 Hz ± 0.06 Hz,
% bandwidth           = 0.125; % change only these two
% transition_width    = 0.15;
% nyquist             = srate/2;
% ffreq(1)            = 0;
% ffreq(2)            = (1-transition_width)*(center_frequency-bandwidth);
% ffreq(3)            = (center_frequency-bandwidth);
% ffreq(4)            = (center_frequency+bandwidth);
% ffreq(5)            = (1+transition_width)*(center_frequency+bandwidth);
% ffreq(6)            = nyquist;
% ffreq               = ffreq/nyquist;
% fOrder              = 4; % in cycles changed from 7
% filterOrder         = fOrder*fix(srate/(center_frequency - bandwidth));
% %in samples
% idealresponse       = [ 0 0 1 1 0 0 ];
% filterweights       = fir2(filterOrder,ffreq,idealresponse);
% 
% %run the filtering
% disp('Filtering ECG - this will take some time');
% HF_HRV4   = filtfilt(filterweights,1,IBI_timeseries_resting.trial{1});

%plot the results of all filter types
figure('NumberTitle', 'off', 'Name', 'high freq (0.15–0.4 Hz) bandpassed IBI time series');
plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
hold on; 
plot(IBI_timeseries_resting.time{1}, HF_HRV_but2); title('Butterworth IIR filter - 2nd order');
hold off; 
% subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,2); plot(IBI_timeseries_resting.time{1}, HF_HRV_fir5); title('FIR filter using MATLAB fir1 function - 5th order');
% hold off; 
% subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,3); plot(IBI_timeseries_resting.time{1}, HF_HRV_firws41250); title('windowed sinc FIR filter - 41250');
% hold off; 
% subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,4); plot(IBI_timeseries_resting.time{1}, HF_HRV_brickw1); title('Frequency-domain filter using MATLAB FFT and iFFT function - 1st order');
% hold off; 
% subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, detrend(IBI_timeseries_resting.trial{1}, 0), 'color', [0.5 0.5 0.5]);
% hold on; 
% subplot(5,1,5); plot(IBI_timeseries_resting.time{1}, HF_HRV4); title('design filter based on fir2 MARTLAB filter - 4th order');
% hold off
% %set legend
hL = legend({'original','filtered'});
% Programatically move the Legend
newPosition = [0.9 0.9 0.1 0.1];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits);

%chosen filtering
HF_HRV_filt = IBI_timeseries_resting
HF_HRV_filt.trial{1} = HF_HRV_but2

save('spectre_data','LF_HRV_filt','HF_HRV_filt', '-append')

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
save('spectre_data','HF_HRV_phase','LF_HRV_phase', 'data_LF_HRV','data_HF_HRV', '-append')

%% 6) creation de fenetre phase ascendante et descendante
% borne_p=0
% % borne_m=HF_HRV_phase.trial{1}(2, 1)
% phases.ascend{1} = [0 0]
% phases.descend{1} = [0 0]
% % 
% % for n=2:length(HF_HRV_phase.trial{1}(2, :))
% %     if HF_HRV_phase.trial{1}(2, :)
% %         phase.ascend
% %     end
% 
% [pks_p, locs_p] = findpeaks(HF_HRV_phase.trial{1}(2, :))
% [pks_n, locs_n] = findpeaks(-HF_HRV_phase.trial{1}(2, :))
% if locs_p(1) < locs_n(1)
%     


%% 7) add Hilbert amplitude in event ok
histogram(HF_HRV_phase.trial{1}(2, :),50)
histogram(LF_HRV_phase.trial{1}(2, :),50)

for n = 1:length(event_ok);
    event_ok(n).hilbert_amp_low = LF_HRV_phase.trial{1}(2, event_ok(n).timestamp)
    event_ok(n).hilbert_amp_high = HF_HRV_phase.trial{1}(2, event_ok(n).timestamp)
end


save([patient_number '_Heart_info'], 'event_ok', '-append')


