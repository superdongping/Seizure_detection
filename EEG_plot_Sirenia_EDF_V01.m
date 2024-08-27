clc;
close all;
clear all;

% Load the EEG data
edffile = dir('*.edf');
edffile_number = size(edffile, 1);

start_time = 1.23; % in seconds

sample_Freq = 400; % in Hz
duration = 25 * 60; % 25 minutes

start_t = start_time;
end_t = start_t + duration;

EEG_x_time = linspace(0, duration, sample_Freq * duration);

threshold=4; % std * threshold

for i = 1:edffile_number
    [hdr, record] = edfread(edffile(i).name);
    
    % Check if record has at least 3 channels
    if size(record, 1) < 3
        error('The record does not have at least 3 channels');
    end
    
    EEG1 = record(1, sample_Freq * start_time:sample_Freq * start_time + sample_Freq * duration - 1);
    EEG2 = record(2, sample_Freq * start_time:sample_Freq * start_time + sample_Freq * duration - 1);
    EMG = record(3, sample_Freq * start_time:sample_Freq * start_time + sample_Freq * duration - 1);
    
    figure(i);
    subplot(3, 1, 1);
    plot(EEG_x_time, EEG1);
    ylabel('EEG1');
    xlabel('Time (s)');  % Added x-axis label
    axis([0 duration -500 500]);
    
    subplot(3, 1, 2);
    plot(EEG_x_time, EEG2);
    ylabel('EEG2');
    xlabel('Time (s)');  % Added x-axis label
    axis([0 duration -500 500]);
    
    subplot(3, 1, 3);
    plot(EEG_x_time, EMG);
    ylabel('EMG');
    xlabel('Time (s)');  % Added x-axis label
    axis([0 duration -500 500]);
end

% Example EEG frequency analysis and SWD detection
EEG_power_sum = []; % Initialize this before use

for i = 1:edffile_number
    figure(10 + i);
    hFig = figure(10 + i);
    set(hFig, 'Position', [40 40 450 90]);
    
    % Assuming start_t and end_t are defined elsewhere
    [P, EEG_power] = EEG_freq_analysis(EEG1, start_t, end_t);
    EEG_power_sum = [EEG_power_sum EEG_power];
    
    hFig70 = figure(70 + i);
    set(hFig70, 'Position', [40 40 450 90]);
    
    [Seizure_no_output, Seizure_event_time] = Seizure_no_detect(P, duration , threshold);
end


%%

for i = 1:edffile_number
    % Plot EEG1 data
    figure(100 + i);
    subplot(9, 1, 1:4);
    plot(EEG_x_time, EEG1);
    ylabel('EEG1');
    xlabel('Time (s)');
    hold on;

    % Plot seizure event markers with aligned x-axis
    subplot(9, 1, 5);
    for t = Seizure_event_time
        xline(t, 'r', 'LineWidth', 2); % Red vertical line at each seizure event
    end
    hold off;
    title('EEG1 with Seizure Events');

    % Align the x-axis of this subplot with the EEG1 plot
    xlim([EEG_x_time(1) EEG_x_time(end)]);

    % Create heatmap from EEG frequency analysis on EEG1
    subplot(9, 1, 6:9);
    [P, EEG_power] = EEG_freq_analysis(EEG1, start_t, end_t);
end