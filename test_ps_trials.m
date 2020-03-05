%chan_cell{1} = char(data_final_average.label{i})
%%

cfg = []
cfg.channel  = chan_cell
cfg.trials = 200:300
ps_trial = ft_selectdata(cfg, clean_trials)
%% WELCH METHOD

% WELCH

cfg                 = [];
cfg.minlength       = 'maxperlen';
cfg.overlap         = 0.75;
data_cut            = ft_redefinetrial(cfg, ps_trial);

% FREQUENCY ANALYSIS
cfg                 = [];
cfg.output          = 'pow';
cfg.method          = 'mtmfft';
cfg.taper           = 'hann';
cfg.keeptrials      = 'no';
cfg.foilim          = [0 25];
cfg.pad             = 1000;
FFT_elec             = ft_freqanalysis(cfg, data_cut);

%% visualize

figure;
cfg=[]
cfg.parameter   = 'powspctrm'; 
ft_singleplotER(cfg, FFT_elec);
xlim([0 25])
