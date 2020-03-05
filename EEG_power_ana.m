%% filtre and sample
cfg             = [];
cfg.resamplefs      = 1000   %frequency at which the data will be resampled (default = 256 Hz)
%cfg.detrend         = 'yes'         %detrend the data prior to resampling 
cfg.trials          = 'all'
cfg.sampleindex     = 'no'
data_down = ft_resampledata(cfg, data_expe)

plot(data_down.time{1,1}, data_down.trial{1,1}(1,:))


%% filtre

% cfg             = [];
% cfg.demean =  'no'          %'no' or 'yes', whether to apply baseline correction (default = 'no')
% cfg.lpfiltord = 3       %lowpass  filter order (default set in low-level function)
% cfg.hpfiltord = 3       % highpass filter order (default set in low-level function)
% cfg.lpfilter = 'yes'        %'no' or 'yes'  lowpass filter (default = 'no')
% cfg.hpfilter = 'yes'        %'no' or 'yes'  highpass filter (default = 'no')
% cfg.lpfreq = low_pass             %lowpass  frequency in Hz
% cfg.hpfreq = high_pass            %highpass frequency in Hz
% data_expe_filt = ft_preprocessing(cfg, data_expe)
% 

%% WELCH METHOD

% WELCH

cfg                 = [];
cfg.length          = 200;
cfg.overlap         = 0.75;
data_cut            = ft_redefinetrial(cfg,data_down);

% FREQUENCY ANALYSIS
cfg                 = [];
cfg.output          = 'pow';
cfg.method          = 'mtmfft';
cfg.taper           = 'hann';
cfg.keeptrials      = 'no';
cfg.foilim          = [0 100];
cfg.pad             = 1000;
FFT_elec             = ft_freqanalysis(cfg, data_cut);

save('data_2476_EEG', 'FFT_elec', '-append')
%% visualize

for i=1:length(data_expe.label)
    chann_int{1} = data_expe.label{i}

    cfg = []
    cfg.channel  = chann_int
    power_sp = ft_selectdata(cfg, FFT_elec)

    cfg.parameter   = 'powspctrm'; 
    cfg.title       = [string(data_expe.label{i}) + ' Full signal power spectrum']
    ft_singleplotER(cfg, power_sp);
    xlabel("Frequency (Hz)", 'FontSize',10)
    ylabel("power", 'FontSize',10)
    ax = gca;
    ax.FontSize = 10
    set(gca, 'YScale', 'log')
    line(8 ,ylim)
    line(15 ,ylim)

    print([string(data_expe.label{i}) + ' Full signal power spectrum.jpg'], '-djpeg')
end 


%% multiplot
load('easycapM1.mat')
M1_lay = lay

load('easycapM20.mat')
M20_lay = lay

%making hybrid lay
hybrid_lay = M1_lay
hybrid_lay.pos(77:78,:) = M20_lay.pos(8:9,:)
hybrid_lay.width(77:78,:) = M20_lay.width(8:9,:)
hybrid_lay.height(77:78,:) = M20_lay.height(8:9,:)
hybrid_lay.label(77:78,:) = M20_lay.label(8:9,:)

%selecting channels
FFT_log = FFT_elec
FFT_log.powspctrm = log(FFT_elec.powspctrm)
cfg = []
cfg.parameter   = 'powspctrm'; 
cfg.layout = hybrid_lay
cfg.channel = {'C4';'FT10';'FT9';'Fp1';'Fp2';'Fz';'Oz';'T10';'T9'; 'O1'; 'O2'; 'Cz'}
cfg.style = 'contour'
ft_multiplotER(cfg, FFT_log)
% xlabel("Frequency (Hz)", 'FontSize',10)
% ylabel("power", 'FontSize',10)
% ax = gca;
% ax.FontSize = 10
% set(gca, 'YScale', 'log')
% line(8 ,ylim)
% line(15 ,ylim)
%% layout only
cfg = []
cfg.layout = hybrid_lay
cfg.channel = {'C4';'FT10';'FT9';'Fp1';'Fp2';'Fz';'Oz';'T10';'T9'; 'O1'; 'O2'; 'Cz'; 'F9'; 'F10'}
cfg.style = 'blank'
cfg.marker    =  'labels'
cfg.markersize  = 10
ft_topoplotER(cfg, data_expe)
print('layout.jpg', '-djpeg')
