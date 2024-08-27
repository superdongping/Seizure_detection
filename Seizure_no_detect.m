function [Seizure_no_output, Seizure_event_time] = Seizure_no_detect(P, duration_t, threshold_factor)
% threshold_factor: Number of standard deviations above baseline mean to set as the threshold
if nargin < 3
    threshold_factor = 3; % Default threshold factor
end

% Define baseline period
baseline_start = 1;
baseline_end = 250;  % Baseline period from 0 to 250 seconds

% Sum power in different frequency bands based on the 1-50 Hz range
max_freq_index = size(P, 1);  % Maximum available frequency index

a1 = sum(P(2:min(5, max_freq_index), :));    % Delta band (1-4 Hz)
a2 = sum(P(6:min(9, max_freq_index), :));    % Theta band (5-8 Hz)
a3 = sum(P(10:min(14, max_freq_index), :));  % Alpha band (9-13 Hz)
a4 = sum(P(15:min(31, max_freq_index), :));  % Beta band (14-30 Hz)
a5 = sum(P(32:min(50, max_freq_index), :));  % Low gamma band (31-50 Hz)

% Calculate the threshold for each band based on the baseline period
baseline_a1 = a1(baseline_start:baseline_end);
baseline_a2 = a2(baseline_start:baseline_end);
baseline_a3 = a3(baseline_start:baseline_end);
baseline_a4 = a4(baseline_start:baseline_end);
baseline_a5 = a5(baseline_start:baseline_end);

threshold_a1 = mean(baseline_a1) + threshold_factor * std(baseline_a1);
threshold_a2 = mean(baseline_a2) + threshold_factor * std(baseline_a2);
threshold_a3 = mean(baseline_a3) + threshold_factor * std(baseline_a3);
threshold_a4 = mean(baseline_a4) + threshold_factor * std(baseline_a4);
threshold_a5 = mean(baseline_a5) + threshold_factor * std(baseline_a5);

% Apply the calculated thresholds to detect seizure events
e1 = a1;
e2 = a2;
e3 = a3;
e4 = a4;
e5 = a5;

e1(e1 < threshold_a1) = 0;
e2(e2 < threshold_a2) = 0;
e3(e3 < threshold_a3) = 0;
e4(e4 < threshold_a4) = 0;
e5(e5 < threshold_a5) = 0;

%% Figure 1: Plot each frequency band (e1-e5) in separate subplots
figure;

subplot(5,1,1);
plot(1:duration_t, e1, 'b', 'LineWidth', 1.5); % Delta band - Blue
hold on
[b1, c1] = findpeaks(e1);
plot(c1, b1, 'k*'); % Mark detected peaks - Black stars
ylabel('Delta (1-4 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,2);
plot(1:duration_t, e2, 'g', 'LineWidth', 1.5); % Theta band - Green
ylabel('Theta (5-8 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,3);
plot(1:duration_t, e3, 'r', 'LineWidth', 1.5); % Alpha band - Red
ylabel('Alpha (9-13 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,4);
plot(1:duration_t, e4, 'c', 'LineWidth', 1.5); % Beta band - Cyan
ylabel('Beta (14-30 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,5);
plot(1:duration_t, e5, 'm', 'LineWidth', 1.5); % Low gamma band - Magenta
ylabel('Low Gamma (31-50 Hz)');
xlabel('Time [s]');
set(gca, 'LineWidth', 1.5);

% Adjust axis limits for each subplot in Figure 1
for i = 1:5
    subplot(5,1,i);
    axis([1 duration_t 0 max([e1, e2, e3, e4, e5]) + 100]);
end

%% Figure 2: Plot each frequency band (a1-a5) in separate subplots
figure;

subplot(5,1,1);
plot(1:duration_t, a1, 'b', 'LineWidth', 1.5); % Delta band - Blue
ylabel('Delta (1-4 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,2);
plot(1:duration_t, a2, 'g', 'LineWidth', 1.5); % Theta band - Green
ylabel('Theta (5-8 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,3);
plot(1:duration_t, a3, 'r', 'LineWidth', 1.5); % Alpha band - Red
ylabel('Alpha (9-13 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,4);
plot(1:duration_t, a4, 'c', 'LineWidth', 1.5); % Beta band - Cyan
ylabel('Beta (14-30 Hz)');
set(gca, 'LineWidth', 1.5);

subplot(5,1,5);
plot(1:duration_t, a5, 'm', 'LineWidth', 1.5); % Low gamma band - Magenta

ylabel('Low Gamma (31-50 Hz)');
xlabel('Time [s]');
set(gca, 'LineWidth', 1.5);

% Adjust axis limits for each subplot in Figure 2
for i = 1:5
    subplot(5,1,i);
    axis([1 duration_t 0 max([a1, a2, a3, a4, a5]) + 100]);
end

% Output number of detected events and their time indices
Seizure_no_output = length(b1);
Seizure_event_time = c1;
end
