% simple data exploration
% 
% tri des essais en fonctions des ibi n+1 ou n-1 ou difference n+1 et n-1
	%utilise script get outliers
    %pour chacune des 3 mani�re de trier, plot les channels, par bins
    %(nombre demand� au d�but)
    %le programme pause entre chacune des 3 mani�re de trier
%

%V2 Florian Lepr�vost October 2019
%florian.leprevost@gmail.com 


%% select channels to keep
pl=[]
figure
for n=1:length(data_final_average.label)
    pl(n) = plot(data_final_average.time,data_final_average.avg(n,:))
    hold on
end
legend(pl(:), data_final_average.label(:))

%donner channel a garder
chan_keep = input('Donner une LISTE des index (exemple :[2 4]) des channels � GARDER : ')
labels = string(data_final_trials.label)
labels = labels(chan_keep)
for n=1:length(labels)
    chan_cell{n} = char(labels(n))
end

cfg = []
cfg.channel  = chan_cell
cfg.latency=[-1 1]
clean_trials = ft_selectdata(cfg, data_final_trials)

%% remove outliers
%en supprimant les trials hors d'un interval de distribution de l'amplitude
%de la reponse

%remove sample index if still here
rmv_ind=[]
for n=1:(length(labels))
    if labels(n) ~= 'sampleindex'
        rmv_ind{n} = char(labels(n))
    end
end
cfg = []
cfg.channel = rmv_ind
clean_trials = ft_selectdata(cfg, clean_trials)
labels = string(clean_trials.label)

% test visuellement quelle mesure prendre pour outliers
for n=1:length(labels)
    figure
    plot(clean_trials.time, squeeze(clean_trials.trial(:,n,:)))
end
title('All trials')


%transformation de la matric de chaque electrode en une seule colonne pour
%mieux determiner la limite des outliers
arrayed_channels ={};
for n=1:length(labels);
    mat_chan = squeeze(clean_trials.trial(:,n,:));
    arrayed_channels{n}=mat_chan(:);
end

%determiner l'interval
for n=1:length(labels)
    variance = nanvar(arrayed_channels{n})
    moyenne = nanmean(arrayed_channels{n})
    
    ok = 0
    outlier_lim = 0.001
    disp(['current exclusion limit = '+ string(outlier_lim)])
    while ok==0
        figure
        histogram(arrayed_channels{n}, 50)
        title('distribution of amplitudes in ' + labels(n))
        hold on
        y= ylim;
        CI = quantile(arrayed_channels{n},[outlier_lim/2 1-outlier_lim/2])
        plot([CI(1) CI(1)], [y(1) y(2)])  
        hold on
        plot([CI(2) CI(2)], [y(1) y(2)])     
        decision = input ('do you want to exclude trials outside this interval (0)?\n do you want to keep all trials ?(1)\n do you want to exclude trials outside a difference interval (answer your limit)?')
        if decision == 0
            ok=1
        elseif decision == 1
            break
        else
            outlier_lim=decision
        end
    end  
end


%get outlier trials
bad_trials = [ ]
for n=1:length(labels)
    CI = quantile(arrayed_channels{n},[outlier_lim/2 1-outlier_lim/2])
    for tr = 1:length(clean_trials.trial(:,1,1))
        for sample=1:length(clean_trials.trial(1,1,:))
            %supprime le trial if condition pas respect�e
            if (clean_trials.trial(tr,n,sample) > CI(2) || clean_trials.trial(tr,n,sample) < CI(1))
                bad_trials=[bad_trials tr];
                break
            end
        end
    end
disp(bad_trials)
end

%enleve doubles et sort
bad_trials_ok = sort(unique(bad_trials))

% supprime outliers
all_trials = 1:length(clean_trials.trial(:,1,1))
good_trials = setdiff(all_trials,bad_trials_ok)

cfg =[]
cfg.trials= good_trials
clean_trials = ft_selectdata(cfg, clean_trials)

for n=1:length(labels)
    figure
    plot(clean_trials.time, squeeze(clean_trials.trial(:,n,:)))
end

cd('Z:/modulation_HER_florian_2019/Data/2nd ana .5-30 and .05-.12 .3-.4')
save(['data_' patient_number '_' macro_name '34_stats' ], 'clean_trials','bad_trials_ok')

%ET supprimer les trials outliers dans les info sur le coeur
ibi_post = [event_ok.interval_post]
ibi_pre = [event_ok.interval_pre]
diff_ibi = [event_ok.interval_diff]

ibi_post(bad_trials_ok) = []
ibi_pre(bad_trials_ok) = []
diff_ibi(bad_trials_ok) = []

%if spectral analysis done
try
    hil_amp_low = [event_ok.hilbert_amp_low]
    hil_amp_high = [event_ok.hilbert_amp_high]
    hil_amp_low(bad_trials_ok) = []
    hil_amp_high(bad_trials_ok) = []
end


%% last part = plot bined data by criterion
nb_obs=0

nb_col =length(clean_trials.trial(1,1,:))
labels = string(clean_trials.label)
for n=1:length(labels)
    labels_field{n} = strrep(labels{n}, '-', '_')
end
nb_bins = input('how many bins?')

legends=[]
for n=1:nb_bins
    name_leg = 'part ' + string(n)+'/'+string(nb_bins)
    legends = [legends name_leg]
end
name_test =[]

%% skip this if you dont want all tests 
for tri = 1:6
    if tri ==1
        name_test = 'order of apparition'
        field_name = 'order'
    elseif tri == 2
        var = transpose(ibi_post)
        name_test = 'interval to Next IBI' 
        field_name = 'next_ibi'       
    elseif tri == 3
        var = transpose(ibi_pre)
        name_test = 'interval to Previous IBI'
        field_name = 'prev_ibi'       
    elseif tri== 4
        var= transpose(diff_ibi)
        name_test = 'difference of previous and next interval '
        field_name = 'diff_ibi'
    elseif tri== 5
        var= transpose(hil_amp_low)
        name_test = 'low feq hilbert amplitude '
        field_name = 'hil_amp_low'
    elseif tri== 6
        var= transpose(hil_amp_high)
        name_test = 'high feq hilbert amplitude'
        field_name = 'hil_amp_high'
    end
    
    
% if you want only 1 "tri" , set tri, name_test & field name, and then launch this cell

    if tri ~= 1
    %sort by var
        var(:,2) = 1:length(var)
        sorted_var = sortrows(var);
        sorted_var(:,3) = 1:length(var);
        sorted_var = sortrows(sorted_var,2);
    end

    %sort trials
    fchan = figure('Name', string(name_test))
    %fdiff= figure('Name', ['difference between bins' + string(name_test)])
    fcolor = figure('Name', ['colors' + string(name_test)])
%     
    for dip = 1:length(labels)
        channel = squeeze(clean_trials.trial(:,dip,:));
        label =labels(dip);
        if tri ~=1
            %rajoute la colonne d'ordre dans sorted trials
            channel(:,nb_col+1:nb_col+3) = sorted_var(:,1:3);
            %ranger les trials en fction de ce vecteur
            channel = sortrows(channel, nb_col+3);

            %remove lines with NaN
            for n=1:length(channel(:,1))
                try
                    if any(isnan(channel(n,nb_col+1)))
                        disp('isnan')
                        channel(n,:)=[];
                    end
                end
            end
        end

        if tri ~=1
        %clean
            channel(:,nb_col+1:nb_col+3)=[];
        end
        
        %bin data
        bornem = 1
        bornep=1
        bin_size = round(length(channel(:,1))/nb_bins)
        for n=1:nb_bins
            bornep = n*bin_size
            if bornep > length(channel(:,1))
                bornep=length(channel(:,1))
            end
            bin_sorted(n,:) = mean(channel(bornem:bornep,:))
            bornem=bornep
        end
        
        
        
        %stats peaks latency and amplitude      
        %       P250     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%P250
        
        for n=1:nb_bins
            [pks_p, locs_p] = findpeaks(-bin_sorted(n,1260:1320))
            [peak, lat] = max(pks_p)
            lat= locs_p(lat)

            %find previous peak
            [pre_peak, pre_lat] = findpeaks(bin_sorted(n,1:lat+1270))
            pre_lat = pre_lat(length(pre_lat))
            pre_peak= pre_peak(length(pre_peak))                
        
            nb_obs=nb_obs+1
            
            peaks_amp_lat(nb_obs).var_tri = field_name
            peaks_amp_lat(nb_obs).electrodes = char(labels_field{dip})
            peaks_amp_lat(nb_obs).bin = n
            peaks_amp_lat(nb_obs).peak = 'N250'          
            peaks_amp_lat(nb_obs).amplitude = -peak
            peaks_amp_lat(nb_obs).latence = clean_trials.time(lat+1270)
            peaks_amp_lat(nb_obs).prev_amp = pre_peak
            peaks_amp_lat(nb_obs).prev_lat = clean_trials.time(pre_lat)
            peaks_amp_lat(nb_obs).p2p_amp = -peak - pre_peak
            peaks_amp_lat(nb_obs).p2p_lat = clean_trials.time(lat)- clean_trials.time(pre_lat)
            

        end   
        
        % N300    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%N300
        for n=1:nb_bins
            [pks_n, locs_n] = findpeaks(bin_sorted(n,1292:1372))
            [peak, lat] = max(pks_n)
            lat= locs_n(lat)

            %find previous peak
            [pre_peak, pre_lat] = findpeaks(-bin_sorted(n,1:lat+1292))
            pre_lat = pre_lat(length(pre_lat))
            pre_peak= pre_peak(length(pre_peak))
                                           
            nb_obs=nb_obs+1
            
            peaks_amp_lat(nb_obs).var_tri = field_name
            peaks_amp_lat(nb_obs).electrodes = char(labels_field{dip})
            peaks_amp_lat(nb_obs).bin = n
            peaks_amp_lat(nb_obs).peak = 'P300' 
            peaks_amp_lat(nb_obs).amplitude = peak
            peaks_amp_lat(nb_obs).latence = clean_trials.time(lat+1292)
            peaks_amp_lat(nb_obs).prev_amp = -pre_peak
            peaks_amp_lat(nb_obs).prev_lat = clean_trials.time(pre_lat)
            peaks_amp_lat(nb_obs).p2p_amp = peak + pre_peak
            peaks_amp_lat(nb_obs).p2p_lat = clean_trials.time(lat)- clean_trials.time(pre_lat)
            

        end   
    
%        
        figure(fchan)
        subplot(length(labels),1,dip)       
        colorspec = { [1 0 0] ;[.9 .3 0]; [1 .6 0] ;[1 .9 0]; [.9 .8 .3 ]; [.6 1 .4] ; [0 .8 .6] ; [0 .6 .9]};
        hold on
        for i = 1:nb_bins
          plot(clean_trials.time, bin_sorted(i, :), 'Color', colorspec{i}, 'LineWidth',1)
        end
        title('All trials of ' + string(label) + ' binned by ' + string(nb_bins) + ' sorted by ' + string(name_test))
        xlim([-0.1 .6])
        legend(legends)
% %         
        clims = [-20 20]
        figure(fcolor)
        subplot(length(labels),1,dip)
        imagesc(channel,clims)
        colormap(winter)
        title('All trials of ' + string(label) + ' sorted by ' + string(name_test))
        xlim([900 1800])
        set(gca,'XTick',[900 1000 1100 1200 1300 1400 1500 1600 1700] ); %This are going to be the only values affected.
        set(gca,'XTickLabel',[-0.1 0 .1 .2 .3 .4 .5 .6 .7] ); %This is what it's going to appear in those places   
        
        saveas(fcolor, ['All trials of ' + string(label) + ' sorted by ' + string(name_test) + '.jpg'])
        saveas(fchan, ['All trials of ' + string(label) + ' binned by ' + string(nb_bins) + ' sorted by ' + string(name_test) + '.jpg'])
        save(['data_' patient_number '_' macro_name '34_stats' ], 'peaks_amp_lat', '-append')

    end
	pause
end

save(['data_' patient_number '_' macro_name '34_peaks' ], 'peaks_amp_lat')
