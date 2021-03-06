f_names = fieldnames(peaks_amp_lat)
for n=1:numel(f_names)
    
    test_field_names= fieldnames(peaks_amp_lat.(f_names{n}))
    for m=1:length(test_field_names)
        stats = peaks_amp_lat.(f_names{n}).(test_field_names{m})
        for p =1:numel(stats)
            if(~isfile('peak_stats_better.csv'))
                dlmwrite('peak_stats_better.csv', stats(p), 'delimiter', ',');
            else
                dlmwrite('peak_stats_better.csv', stats(p), 'delimiter', ',', '-append');
            end
        end
    end

end