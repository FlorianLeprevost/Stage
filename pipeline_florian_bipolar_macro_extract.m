%remplit les variables nécessaires pour l'extraction
%extraction et reunion (read_ieeg_data)
%rereference
%reunit ECG + dipole
%filtre
%down sample
%lance heart_peak_detect
%créer un eventfile (trl)
%redefine trials cerebral on R peaks
%time lock analysis : average trials on R peaks
%
%
% Il faut avoir  dans son workspace les variables HeartBeats, event_ok, trl
% et stats
% Cela peut se trouver dans la structure [patient_number '_Heart_info']
% crée grace au script heart_detect_plus_EVENT_STATS


%V0 Florian Leprévost October 2019
%florian.leprevost@gmail.com 
%%

%remplit les variables nécessaires pour l'extraction Read_iEEG
macro_name ='PrCi'
nb_plots = 4
patient_number= '2476'
recording_date='2017-04-07'
recording_time = '14-45'
experiment = 'Rest'

%idem pour le preprocessing
sample_rate = 1000
low_pass = 40
high_pass = 0.5


%% extraction et preprocessing des données de la macro electrode

%create elec name
elec_name =[]
for n=1:nb_plots
    elec_name{n} = ['0' patient_number '_' recording_date '_' recording_time '_' macro_name '_' num2str(n) '.ncs']
end


% recup data dans une structure
data_1expe = Read_iEEG_data(patient_number, recording_date, recording_time, elec_name, experiment)
f1 = figure;
plot(data_1expe.time{1,1}, data_1expe.trial{1,1}(1:3,:))
save(['data_' patient_number '_' macro_name], 'data_1expe')


%% rereference bipolar
%rereference les electrodes
cfg             = [];
cfg.channel     = data_1expe.label  ;
cfg.reref       = 'yes';
cfg.refmethod   = 'bipolar';
data_2reref = ft_preprocessing(cfg, data_1expe);

save(['data_' patient_number  '_' macro_name], 'data_2reref', '-append')


%filtre and ssample
%filtre
cfg             = [];
cfg.demean =  'no'          %'no' or 'yes', whether to apply baseline correction (default = 'no')
cfg.lpfiltord = 3       %lowpass  filter order (default set in low-level function)
cfg.hpfiltord = 3       % highpass filter order (default set in low-level function)
cfg.lpfilter = 'yes'        %'no' or 'yes'  lowpass filter (default = 'no')
cfg.hpfilter = 'yes'        %'no' or 'yes'  highpass filter (default = 'no')
cfg.lpfreq = low_pass             %lowpass  frequency in Hz
cfg.hpfreq = high_pass            %highpass frequency in Hz
data_filt = ft_preprocessing(cfg, data_2reref)

%downsample
cfg             = [];
cfg.resamplefs      = sample_rate %frequency at which the data will be resampled (default = 256 Hz)
cfg.detrend         = 'yes' %detrend the data prior to resampling 
cfg.trials          = 'all'
cfg.sampleindex     = 'yes'
data_3down_filt = ft_resampledata(cfg, data_filt)

f2 = figure;
plot(data_3down_filt.time{1,1}, data_3down_filt.trial{1,1}(1,:))

save(['data_' patient_number '_' macro_name], 'data_3down_filt', '-append')


%% timelock signal on R peaks

%redefine trials
cfg=[]
cfg.trials ='all'   %= 'all' or a selection given as a 1xN vector (default = 'all')
cfg.trl = trl       %= Nx3 matrix with the trial definition, see FT_DEFINETRIAL
data_4ok = ft_redefinetrial(cfg, data_3down_filt)

save(['data_' patient_number  '_' macro_name], 'data_4ok', '-append')

% time lock average 
cfg=[]
cfg.channel = data_4ok.label       %= Nx1 cell-array with selection of channels (default = 'all'),see FT_CHANNELSELECTION for details
cfg.trials = 'all'                  %= 'all' or a selection given as a 1xN vector (default = 'all')
cfg.latency ='all'                  %= [begin end] in seconds, or 'all', 'minperiod', 'maxperiod','prestim', 'poststim' (default = 'all')
cfg.covariance = 'no'               %= 'no' or 'yes' (default = 'no')
cfg.covariancewindow ='all'         %= [begin end] in seconds, or 'all', 'minperiod', 'maxperiod','prestim', 'poststim' (default = 'all')
cfg.keeptrials = 'no'               %= 'yes' or 'no', return individual trials or average (default = 'no')
cfg.removemean = 'no'               %= 'no' or 'yes' for covariance computation (default = 'yes')

[data_final_average] = ft_timelockanalysis(cfg, data_4ok)
save(['data_' patient_number  '_' macro_name], 'data_final_average', '-append')
f3 = figure
plot(data_final_average.time, data_final_average.avg(:,:))
title('Average of each channel')

% time lock trials 

cfg=[]
cfg.channel = data_4ok.label       %= Nx1 cell-array with selection of channels (default = 'all'),see FT_CHANNELSELECTION for details
cfg.trials = 'all'                  %= 'all' or a selection given as a 1xN vector (default = 'all')
cfg.latency ='all'                  %= [begin end] in seconds, or 'all', 'minperiod', 'maxperiod','prestim', 'poststim' (default = 'all')
cfg.covariance = 'no'               %= 'no' or 'yes' (default = 'no')
cfg.covariancewindow ='all'         %= [begin end] in seconds, or 'all', 'minperiod', 'maxperiod','prestim', 'poststim' (default = 'all')
cfg.keeptrials = 'yes'               %= 'yes' or 'no', return individual trials or average (default = 'no')
cfg.removemean = 'no'               %= 'no' or 'yes' for covariance computation (default = 'yes')

[data_final_trials] = ft_timelockanalysis(cfg, data_4ok)
save(['data_' patient_number  '_' macro_name], 'data_final_trials', '-append')
data_final_trials.trial = squeeze(data_final_trials.trial)
f4 = figure
plot(data_final_trials.time, squeeze(data_final_trials.trial(1,:,:)))
title('First trial of each channel')

