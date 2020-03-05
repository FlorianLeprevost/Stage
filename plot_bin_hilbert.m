data= [event_ok.hilbert_amp_high]


hist(data, 50)
hold on
lines = quantile(data, [0 0.2 0.4 0.6 0.8 1])

for n = 1:length(lines)
    line([lines(n) lines(n)],ylim, 'Color',[1-n*0.15 n*0.15 n*0.15])
end

legend(['high amplitudes' string(lines)], 'FontSize',10,'FontWeight','Bold');






