imagesc(channel)
title('All trials of ' + string(label) + 'in order of apparition')
xlim([800 1700])
set(gca,'XTick',[800 900 1000 1100 1200 1300 1400 1500 1600 1700] ); %This are going to be the only values affected.

set(gca,'XTickLabel',[-.2 -.1 0 .1 .2 .3 .4 .5 .6 .7] ); %This is what it's going to appear in those places

title('All trials of ' + string(label) + 'in order of apparition, in 5 bins')

peaks_amp_lat
for n=1:length(labels)
    labels_field{n} = strrep(labels{n}, '-', '_')
end
    
    
for n=1:nb_bins
    [pks_p, locs_p] = findpeaks(bin_sorted(n,:))
    [pks_n, locs_n] = findpeaks(-bin_sorted(n,:))
    if max(pks_p)> max(pks_n)
        [peak, lat] = max(pks_p)
        lat= locs_p(lat)
    else
        [peak, lat] = max(pks_n)
        lat= locs_n(lat)
    end
    
    peaks_amp_lat.(field_name).(char(labels_field{dip})) = [peak, lat]
end

structure = [];
namelist = {'first', 'second', 'third'};
for i = 1:length(namelist)
    for j = 1:10
        if 1==1
            structure.(namelist{i})='works';
        end
    end
end