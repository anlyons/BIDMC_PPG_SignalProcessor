function [hr_rmse, rr_rmse] = evaluate_pipeline(ppg, ekg, resp, fs, order, lo, hi, win)

    % Example bandpass filter
    [b,a] = butter(order, [lo hi]/(fs/2), 'bandpass');
    ppg_filt = filtfilt(b,a,ppg);

    % Heart rate from EKG (reference)
    hr_ref = ekg_to_hr(ekg, fs);

    % Heart rate from PPG (test)
    hr_est = ppg_to_hr(ppg_filt, fs, win);

    % Respiration rate from reference
    rr_ref = resp_to_rr(resp, fs);

    % Respiration rate from PPG (test)
    rr_est = ppg_to_rr(ppg_filt, fs);

    % RMSE evaluation
    hr_rmse = sqrt(mean((hr_ref - hr_est).^2,'omitnan'));
    rr_rmse = sqrt(mean((rr_ref - rr_est).^2,'omitnan'));
end

function hr = ekg_to_hr(ekg, fs)
% Simple R-peak detection and HR calculation
% Input: ekg (vector), fs (sampling freq)
% Output: hr (heart rate time series, in bpm, one value per beat)

% 1. Bandpass filter ECG
[b,a] = butter(2, [0.5 40]/(fs/2), 'bandpass');
ecg_f = filtfilt(b,a,ekg);

% 2. Detect R-peaks (tune these for your data)
minPeakHeight = 0.3*max(ecg_f);
minPeakDist   = round(0.4*fs);  % 0.4 s ≈ 150 bpm max
[~,locs] = findpeaks(ecg_f, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDist);

% 3. Compute RR intervals (seconds)
rr_intervals = diff(locs)/fs;

% 4. Instantaneous HR (bpm)
hr = 60 ./ rr_intervals;
end

function hr = ppg_to_hr(ppg, fs, win)
% PPG peak detection + sliding window HR
% Input: ppg (vector), fs (Hz), win (seconds for sliding window)
% Output: hr (HR in bpm, uniform time series)

% 1. Bandpass filter PPG (typical HR band)
[b,a] = butter(2, [0.5 8]/(fs/2), 'bandpass');
ppg_f = filtfilt(b,a,ppg);

% 2. Peak detection
minPeakHeight = 0.15*max(ppg_f);
minPeakDist   = round(0.4*fs); % 0.4 s
[~,locs] = findpeaks(ppg_f, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDist);

% 3. Compute pulse intervals (s)
pi_intervals = diff(locs)/fs;

% 4. Instantaneous HR
hr_inst = 60 ./ pi_intervals;

% 5. Sliding window averaging
t_peaks = locs(2:end)/fs;  % time vector aligned with intervals
edges = 0:win:(length(ppg)/fs);  % window edges
hr = zeros(size(edges)-[0 1]);
for i = 1:length(edges)-1
    idx = t_peaks >= edges(i) & t_peaks < edges(i+1);
    if any(idx)
        hr(i) = mean(hr_inst(idx));
    else
        hr(i) = NaN;
    end
end
end

function rr = resp_to_rr(resp, fs)
% Respiration rate estimation from impedance or annotated breaths
% Input: resp (vector), fs (Hz)
% Output: rr (resp rate in bpm)

% 1. Bandpass filter respiration signal (0.1–0.5 Hz typical)
[b,a] = butter(2, [0.1 0.5]/(fs/2), 'bandpass');
resp_f = filtfilt(b,a,resp);

% 2. Peak detection (breaths)
minPeakDist = round(1.5*fs);  % min 1.5s between breaths (~40 bpm max)
[~,locs] = findpeaks(resp_f, 'MinPeakDistance', minPeakDist);

% 3. Compute intervals and RR
if length(locs) < 2
    rr = NaN;
else
    rr_intervals = diff(locs)/fs;
    rr_inst = 60 ./ rr_intervals; % bpm

    % average over entire record
    rr = mean(rr_inst);
end
end

function rr = ppg_to_rr(ppg, fs)
%PPG_TO_RR Estimate respiratory rate (breaths/min) from PPG signal
%
%   rr = ppg_to_rr(ppg, fs)
%
% Uses low-frequency baseline modulation of the PPG to estimate breathing rate.

    % Ensure column, double precision
    ppg = double(ppg(:));
    
    % Remove NaNs
    if any(isnan(ppg))
        ppg = fillmissing(ppg, 'linear');
    end

    % Step 1. Bandpass filter for respiration range (~0.1–0.5 Hz)
    [b,a] = butter(2, [0.1 0.5]/(fs/2), 'bandpass');
    ppg_resp = filtfilt(b,a,ppg);

    % Step 2. Find peaks in the respiratory signal
    [~, locs] = findpeaks(ppg_resp, 'MinPeakDistance', round(fs*1.2));  % assume ≥1.2 s between breaths

    % Step 3. Convert to rate (breaths per minute)
    if numel(locs) > 1
        ibi = diff(locs)/fs;                % seconds per breath
        rr = 60 ./ median(ibi);             % breaths per minute
    else
        rr = NaN; % not enough peaks
    end
end

