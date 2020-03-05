cfg= []
cfg.avgoverchan = 'yes'
cfg.nanmean     = 'yes'
test_avg = ft_timelockanalysis(cfg, clean_trials_test2)



figure
plot(clean_trials.time, squeeze(test_avg.avg(2,:)))
title('Bad trials OpPC 3-4 after clean')
xlabel("time in s", 'FontSize',20)
ylabel("amplitude in µV", 'FontSize',20)
ax = gca;
ax.FontSize = 20

line(xlim ,[50 50])
line(xlim ,[-50 -50])

line(xlim ,[45 45], 'Color', 'red')
line(xlim ,[-45 -45], 'Color', 'red')

line(xlim ,[55 55], 'Color', 'green')
line(xlim ,[-55 -55], 'Color', 'green')

line(xlim ,[60 60], 'Color', 'yellow')
line(xlim ,[-60 -60], 'Color', 'yellow')