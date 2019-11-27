%blabla
%blabla

%%ITC
%


% spectral analysis
data = clean_trials

cfg = [];
cfg.method = 'wavelet';
cfg.toi    = 0:0.01:1;
cfg.output = 'fourier';
freq = ft_freqanalysis(cfg, data);

% make a new FieldTrip-style data structure containing the ITC
% copy the descriptive fields over from the frequency decomposition

itc = [];
itc.label     = freq.label;
itc.freq      = freq.freq;
itc.time      = freq.time;
itc.dimord    = 'chan_freq_time';

F = freq.fourierspctrm;   % copy the Fourier spectrum
N = size(F,1);           % number of trials

% compute inter-trial phase coherence (itpc)
itc.itpc      = F./abs(F);         % divide by amplitude
itc.itpc      = sum(itc.itpc,1);   % sum angles
itc.itpc      = abs(itc.itpc)/N;   % take the absolute value and normalize
itc.itpc      = squeeze(itc.itpc); % remove the first singleton dimension

% compute inter-trial linear coherence (itlc)
itc.itlc      = sum(F) ./ (sqrt(N*sum(abs(F).^2)));
itc.itlc      = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc      = squeeze(itc.itlc); % remove the first singleton dimension

figure
subplot(2, 1, 1);
imagesc(itc.time, itc.freq, squeeze(itc.itpc(2,:,:)));
axis xy
title('inter-trial phase coherence ' + string(char(itc.label(2))));
subplot(2, 1, 2);
imagesc(itc.time, itc.freq, squeeze(itc.itlc(2,:,:)));
axis xy
title('inter-trial linear coherence'+ string(char(itc.label(2))));

save(['data_' patient_number '_' macro_name '_stats' ], 'itc', '-append')

%% spectral ana
data = clean_trials

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'OpPC_2-OpPC_3';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -1:0.05:1;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
TFRhann_oppc23 = ft_freqanalysis(cfg, data);    


ft_singleplotTFR(cfg, TFRhann_oppc23)