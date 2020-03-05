
%structure names
labels = string(data_3down_filt.label)
for n=1:length(labels)
    labels_field{n} = strrep(labels{n}, '-', '_')
end

name_test =fieldnames(event_ok)
name_test(1:6)=[]

%determine limits of bins
nb_bins = input('how many bins?')
for var=1:6
    vector_to_cut=[event_ok.(char(name_test(var)))]
    for i=0:nb_bins %because intervals need one more than number of intervals
        bins_limits.(char(name_test(var))).(char(strcat('bin', string(i)))) = quantile(vector_to_cut,(i/nb_bins))
    end
end

%determine events for each bins
for var=1:6
    for i=1:nb_bins
        ev_index_temp=[]
        lim_bin_m = bins_limits.(char(name_test(var))).(char(strcat('bin', string(i-1))))
        lim_bin_p= bins_limits.(char(name_test(var))).(char(strcat('bin', string(i))))
        for ev=1:length(event_ok)
            if event_ok(ev).(char(name_test(var))) >=lim_bin_m && event_ok(ev).(char(name_test(var))) <=lim_bin_p
                ev_index_temp= [ev_index_temp ev];              
            end
        ev_index.(char(name_test(var))).(char(strcat('bin', string(i))))= [ev_index_temp]                      
        end
    end
end

%select data & tfr for each bin
for var=1:6
    for chann = 1:length(labels)
        cell_chan={char(labels(chann))}
        for i=1:nb_bins
            %select+freq anbalysis
            cfg=[]
            cfg.channel=cell_chan
            cfg.trials= ev_index.(char(name_test(var))).(char(strcat('bin', string(i))))
%             cfg.method = 'tfr'
%             cfg.output = 'pow'
            cfg.toi = 'all'
%             cfg.foilim =[0 20]
            cfg.method      = 'mtmconvol';
            cfg.output      = 'pow';
            cfg.foilim      = [0 20]; %freq band of interest
            cfg.taper       = 'dpss';
            cfg.tapsmofrq   = 0.5; %optimal resolution 
            cfg.t_ftimwin   = 1:20
            freq_ana_bin_data= ft_freqanalysis(cfg, clean_trials)
            
            %tfr plot
            subplot(nb_bins, 1, i)
            cfg =[]
            cfg.xlim           = [-1 .65]      %'maxmin' or [xmin xmax] (default = 'maxmin')
            %cfg.ylim           = [0 30]       %'maxmin' or [ymin ymax] (default = 'maxmin')
            ft_singleplotTFR(cfg,freq_ana_bin_data)
            end
        pause
    end
end



