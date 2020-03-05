%% extracvtion 
macro_name ='PoCi'
nb_plots = 4
patient_number= '2757'
recording_date='2019-09-16'
recording_time = '14-33'
experiment = 'Rest'


%create elec name
elec_name =[]
for n=1:nb_plots
    elec_name{n} = ['0' patient_number '_' recording_date '_' recording_time '_' macro_name '_' num2str(n) '.ncs']
end

data_expe = Read_iEEG_data(patient_number, recording_date, recording_time, elec_name, experiment)




%% WELCH METHOD

% WELCH

cfg                 = [];
cfg.length          = 200;
cfg.overlap         = 0.75;
data_cut            = ft_redefinetrial(cfg,data_expe);

% FREQUENCY ANALYSIS
cfg                 = [];
cfg.output          = 'pow';
cfg.method          = 'mtmfft';
cfg.taper           = 'hann';
cfg.keeptrials      = 'no';
cfg.foilim          = [0 100];
cfg.pad             = 1000;
FFT_elec             = ft_freqanalysis(cfg, data_cut);

%% visualize

for i=1:length(data_expe.label)
    chann_int{1} = data_expe.label{i}

    cfg = []
    cfg.channel  = chann_int
    power_sp = ft_selectdata(cfg, FFT_elec)

    figure;
    cfg.parameter   = 'powspctrm'; 
    cfg.title       = [string(data_expe.label{i}) + ' Full signal power spectrum']
    ft_singleplotER(cfg, power_sp);
    ylim([0 30])
    xlim([0 40])
    xlabel("Frequency (Hz)", 'FontSize',20)
    ylabel("power", 'FontSize',20)
    ax = gca;
    ax.FontSize = 20

    saveas(figure, [string(data_expe.label{i}) + ' Full signal power spectrum.jpg'])
end 
