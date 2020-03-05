figure
plot(clean_trials.time, squeeze(clean_trials.trial(:,2,:)))
title('All trials PoCi 2-3')
xlabel("time in s", 'FontSize',20)
ylabel("amplitude in µV", 'FontSize',20)
ax = gca;
ax.FontSize = 20

line(xlim ,[160 160])
line(xlim ,[-105 -105])

line(xlim ,[170 170], 'Color', 'red')
line(xlim ,[-115 -115], 'Color', 'red')

line(xlim ,[55 55], 'Color', 'green')
line(xlim ,[-55 -55], 'Color', 'green')

line(xlim ,[60 60], 'Color', 'yellow')
line(xlim ,[-60 -60], 'Color', 'yellow')

ylim([-100 120])
