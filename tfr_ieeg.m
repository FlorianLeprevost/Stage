%%donner channel a garder
for i=1:length(data_final_trials.label)

    chan_cell{1} = char(data_final_average.label{i})


    cfg = []
    cfg.channel  = chan_cell
    elec_ok = ft_selectdata(cfg, data_final_average)


    % TFR
    cfg =[]
    cfg.method = 'tfr'
    cfg.output = 'pow'
    cfg.toi = 'all'
    poci_avg_tfr = ft_freqanalysis(cfg, elec_ok)

    cfg =[]
    cfg.xlim           = [-.3 8]      %'maxmin' or [xmin xmax] (default = 'maxmin')
    cfg.ylim           = [0 30]       %'maxmin' or [ymin ymax] (default = 'maxmin')
    %cfg.parameter      = 'powspcrtrm'
    figure
    ft_singleplotTFR(cfg,poci_avg_tfr)

    % Power
    cfg =[]
    cfg.parameter   = 'powspctrm'
    figure
    ft_singleplotER(cfg, poci_avg_tfr);
end

