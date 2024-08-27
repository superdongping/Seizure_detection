function [P, EEG_power] = EEG_freq_analysis(EEG_rawdata, start_t, end_t)
% Parameters
Fs = 400;            % Sampling frequency
L = Fs;              % Length of each segment for FFT (1 second bins)
T = 1 / Fs;          % Sampling period
duration_t = end_t - start_t;

% Frequency analysis using FFT
X = EEG_rawdata;
num_bins = floor(length(X) / L); % Number of full 1-second bins
Y = zeros(num_bins, L); % Preallocate for speed

for i = 1:num_bins
    c = (i-1) * L + 1;
    d = i * L;
    Y(i, :) = fft(X(c:d));
end

% Calculate power spectrum
P2 = abs(Y / L);
P1 = P2(:, 1:L/2 + 1);
P1(:, 2:end-1) = 2 * P1(:, 2:end-1);

% Define frequency axis
f = Fs * (0:(L/2)) / L;

% Select the desired frequency range (1 to 50 Hz)
freq_range = (f >= 1 & f <= 50);
P1_selected = P1(:, freq_range);

% Transpose for correct orientation in visualization
P = P1_selected';

% Visualize the power spectrum from 1 to 50 Hz
color = max(P(:));

% Determine the dynamic range for the heatmap
min_val = min(P(:));
max_val = max(P(:));

clims = [0 color / 3];
surfc(P(1:50, :), 'edgecolor', 'none'); % Updated to remove edge color
colormap(hot);
% colorbar;
view(0, 90);
% caxis([min_val max_val]);  % Set the color axis to the range of P
caxis([0 100]);
xlim([1 num_bins]);

xlabel('Time [s]');
ylabel('Frequency [Hz]');

% Calculate the total power in the spectrum within the selected range
EEG_power = sum(P1_selected(:));
end
