%% lance heart_peak_detect et crée event+trl file SI nécessaire

    elec_name{1}=['0' patient_number '_' recording_date '_' recording_time '_' hb_detect '_' num2str(n) '.ncs']
    data_coeur = Read_iEEG_data(patient_number, recording_date, recording_time, elec_name, experiment)
    cfg=[]
    cfg.channel = hb_detect %the one channel to be read and taken as ECG channel
    [HeartBeats] = heart_peak_detect(cfg,data_coeur)
    save(['data_' patient_number '_' macro_name], 'HeartBeats', '-append')
    save([patient_number '_Heart_info'], 'HeartBeats')


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
    save(['data_' patient_number '_' macro_name], 'event_ok', 'stats', '-append')
    save([patient_number '_Heart_info'], 'event_ok', 'stats', '-append')
    
    %créer trl file
    interval_pre = input('how many seconds before the R peak?')
    interval_post = input('how many seconds after the R peak?')

    trl(:,1) = [event_ok.sample] - interval_pre*sample_rate
    trl(:,2) = [event_ok.sample] + interval_post*sample_rate
    trl(:,3) = -interval_pre*sample_rate
    save(['data_' patient_number '_' macro_name], 'trl', '-append')
    save([patient_number '_Heart_info'], 'trl', '-append')

    end

%% use stats to plot distrbution of interval PQRST
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
plot(stats.x_spectre, stats.RR)


pause
