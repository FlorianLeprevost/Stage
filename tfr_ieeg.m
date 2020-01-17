%donner channel a garder
chan_keep = input('Donner une LISTE des index (exemple :[2 4]) des channels à GARDER : ')
labels = string(data_final_trials.label)
labels = labels(chan_keep)
for n=1:length(labels)
    chan_cell{n} = char(labels(n))
end

cfg = []
cfg.channel  = chan_cell
Poci_1 = ft_selectdata(cfg, data_final_average)


%% TFR
cfg =[]
cfg.method = 'tfr'
cfg.output = 'pow'
cfg.toi = 'all'
poci_avg_tfr = ft_freqanalysis(cfg, Poci_1)

cfg =[]
cfg.xlim           = [-.3 8]      %'maxmin' or [xmin xmax] (default = 'maxmin')
cfg.ylim           = [0 30]       %'maxmin' or [ymin ymax] (default = 'maxmin')
%cfg.parameter      = 'powspcrtrm'
ft_singleplotTFR(cfg,poci_avg_tfr)

%% Power
cfg =[]
cfg.parameter   = 'powspctrm'
ft_singleplotER(cfg, poci_avg_tfr);

