cfg= []
cfg.trials = [1:300]
cfg.avgoverchan = 'yes'
cfg.nanmean     = 'yes'
data_test = ft_timelockanalysis(cfg, data_final_trials)


cfg.trials = [1231:1531]
data_test2 = ft_timelockanalysis(cfg, data_final_trials)


plot(data_test.time(1,2800:3700),data_final_average.avg(:,2800:3700), 'LineWidth',1.5)
hold on

plot(data_test.time(1,2800:3700),data_test.avg(2,2800:3700),'LineWidth',1.5)
plot(data_test.time(1,2800:3700),data_test2.avg(2,2800:3700),'LineWidth',1.5)

legend({'all trials', '300 first trials', '300 last trials'} ,'FontSize',20)
title("OpPC2-3")
xlim([0.2 0.5])
xlabel("time in s", 'FontSize',20)
ylabel("amplitude in µV", 'FontSize',20)
ax = gca;
ax.FontSize = 20


legend({'PoCi 1-2', 'PoCi 2-3', 'PoCi 3-4'}, 'FontSize',20)

