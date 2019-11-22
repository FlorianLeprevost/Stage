% simple data exploration
% 
% first part = distribution of peaks
    %assez basique
% second part = tri des essais en fonctinos des ibi n+1 ou n-1 ou difference n+1 et n-1
	%utilise script get outliers
    %rajoute les difference channels
    %pour chacune des 3 manière de trier, plot les channels, par bins
    %(nombre demandé au début)
    %le programme s'arrete entre chacune des 3 manière de trier
%

%V2 Florian Leprévost October 2019
%florian.leprevost@gmail.com 


figure
boxplot(transpose(stats.RR),'Labels', {'RR'})
title('Distribution des intervalles RR')

figure
histogram(transpose(stats.RR))
title('Distribution des intervalles RR')

figure
boxplot([transpose(stats.QR),transpose(stats.PR),transpose(stats.RT)],'Labels', {'QR', 'PR', 'RT'})
title('Distribution des intervalles QR, PR et RT')


figure
histogram(transpose(stats.RT))
hold on
histogram(transpose(stats.PR))
hold on
histogram(transpose(stats.QR))
title('Distribution des intervalles QR, PR et RT')

%spectre RR
figure
plot(1:length(interv_RR), interv_RR)

save(['data_' patient_number '_stats' ], 'interv_RR', 'interv_RT', 'interv_PR' ,'interv_QR')
pause

%%
%en supprimant les trials qui depasse la moyenne + 5*sd à au moins un sample
%get outliers
trials = data_final_trials.trial;
labels = string(data_final_trials.label);
var = data_final_average.var;
avg = data_final_average.avg;
for n=1:length(labels)
    trials_str(n).data = squeeze(trials(:,n,:))
    trials_str(n).label = labels(n)
    trials_str(n).avg = avg(n,:)
    trials_str(n).var = var(n,:)
end

% test visuellement quelle mesure prendre pour outliers
for n=1:length(labels)
    figure
    plot(data_final_trials.time, trials_str(n).data)
    hold on

    plot(data_final_average.time, (trials_str(n).avg + 5*sqrt(trials_str(n).var)))
    hold on
    plot(data_final_average.time, (trials_str(n).avg - 5*sqrt(trials_str(n).var)))

    hold on
    plot(data_final_average.time, (trials_str(n).avg + trials_str(n).var))
    hold on
    plot(data_final_average.time, (trials_str(n).avg - trials_str(n).var))
end

%remove outliers
bad_trials = [ ]
for n=1:length(labels)
    for tr = 1:length(trials_str(n).data(:,1))
        for sample=1:length(trials_str(n).data(1,:))
            %supprime le trial if condition pas respectée
            bornep = trials_str(n).avg(sample) + 5*sqrt(trials_str(n).var(sample));
            bornem = trials_str(n).avg(sample) - 5*sqrt(trials_str(n).var(sample));
            if (trials_str(n).data(tr,sample) > bornep) || (trials_str(n).data(tr,sample) < bornem)
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
figure
for n=1:length(labels)
    trials_str(n).data(bad_trials_ok,:)=[]
    figure
    plot(data_final_trials.time, trials_str(n).data)
end
save(['data_' patient_number '_stats' ], 'trials_str','bad_trials_ok', '-append')
%%
%creation de l'"event_file" ET supprimer les trials outliers
ibi = transpose(interv_RR)
%ibi post --> rajouter nan dernier trial 
ibi_post = [ibi;NaN]
%ibi pré n-1 --> rajouter nan premier trial
ibi_pre= [NaN;ibi]
%diff ibi
diff_ibi = diff(ibi)
diff_ibi= [NaN;diff_ibi;NaN]

%ajouter les interval a l'envent structure
for n = 1:length(ibi_pre);
    event_ok(n).pre  = ibi_pre(n)
    event_ok(n).post = ibi_post(n)
    event_ok(n).diff = diff_ibi(n)
end

%ET supprimer les trials outliers
ibi_post(bad_trials_ok) = []
ibi_pre(bad_trials_ok) = []
diff_ibi(bad_trials_ok) = []


%%
%last part = plot bined data by criterion
nb_bins = input('how many bins?')
name_test =[]
for tri = 1:3
    if tri == 1
        var = ibi_post
        name_test = 'interval to Next IBI'
    elseif tri == 2
        var = ibi_pre
        name_test = 'interval to Previous IBI'
    elseif tri==3 
        var= diff_ibi
        name_test = 'difference of previous and next interval '
    end

    %sort by var
    var(:,2) = 1:length(var)
    sorted_var = sortrows(var);
    sorted_var(:,3) = 1:length(var);
    sorted_var = sortrows(sorted_var,2);

    %sort trials
    fchan = figure('Name', string(name_test))
    fdiff= figure('Name', ['difference between bins' + string(name_test)])
    fcolor = figure('Name', ['colors' + string(name_test)])
    
    for dip = 1:length(trials_str)
        channel = trials_str(dip).data;
        label = trials_str(dip).label;
        %rajoute la colonne d'ordre dans sorted trials
        channel(:,2002:2004) = sorted_var(:,1:3);
        %ranger les trials en fction de ce vecteur
        channel = sortrows(channel, 2004);

        %remove lines with NaN
        for n=1:length(channel(:,1))
            try
                if any(isnan(channel(n,2002)))
                    disp('isnan')
                    channel(n,:)=[];
                end
            end
        end

        %clean
        channel(:,2002:2004)=[];
        
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
% 
%       plot superposed
        figure(fchan)
        subplot(length(trials_str),1,dip)
        plot(data_final_trials.time, bin_sorted)
        title('All trials of ' + string(label) + ' binned by ' + string(nb_bins) + ' sorted by ' + string(name_test))
% 
        figure(fdiff)
        subplot(length(trials_str),1,dip)
        plot(data_final_trials.time, diff(bin_sorted))
        
        figure(fcolor)
        subplot(length(trials_str),1,dip)
        image(channel)
        %plot with offset4
%         offset=1
%         offset_vector = (offset:offset:nb_bins*offset)';
%         bin_plus_offset = bsxfun(@plus,bin_sorted,offset_vector);
%         subplot(3,2,3:6)
%         subplot(length(trials_str),1,dip)
%         plot(data_final_trials.time, bin_plus_offset)
        %title('All trials of ' + string(label) + ' binned by ' + string(nb_bins) + ' sorted by ' + string(name_test))
        
        
        save(['data_' patient_number '_stats' ], 'fdiff', 'fchan', '-append')

    end
    pause
end

