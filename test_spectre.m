plot(stats.x_spectre,stats.RR)

spline interpolation







spect_data = transpose(spect_data)

spec_re =resample(spect_data(:,2), spect_data(:,1))

pxx = pwelch(spec_re)
plot(pxx)
hil = hilbert(spec_re)
plot(hil)
x= 1:length(spec_re)
plot(x,real(hil))
hold on
plot(x,imag(hil))

figure
hil2 = hilbert(pxx)
plot(hil2)
x= 1:length(hil2)
plot(x,real(hil2))
hold on
plot(x,imag(hil2))


spec_re(:,2) = spec_re(:,1)
spec_re(:,1) = 1:length(spec_re(:,1))

plot(spec_re(:,1), (spec_re(:,2)))


Nx = length(spec_re(:,2));
nsc = floor(Nx/4.5);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));

t = pwelch(spec_re(:,2),hamming(nsc),nov,nff);
plot(t)

pxx = pwelch(test)


pxx = fft(stats.RR,.1)
plot(pxx)



