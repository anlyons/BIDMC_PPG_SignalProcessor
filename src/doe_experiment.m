function results = doe_experiment()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    % -------------------------
    % 1. Load all data
    % -------------------------
    [ppg_all, ekg_all, resp_all, fs_all, meta] = quick_load_bidmc();
    nSubjects = numel(ppg_all);

    % -------------------------
    % 2. Define DOE grid
    % -------------------------
    filterOrders = [2, 4, 6];
    lowCutoffs   = [0.1, 0.5];
    highCutoffs  = [5, 10];
    winLengths   = [8, 16];   % example window sizes (seconds)

    DOE_combos = combinations(filterOrders,lowCutoffs,highCutoffs,winLengths);
    DOE = table2array(DOE_combos);
    nConfigs = size(DOE,1);

    % -------------------------
    % 3. Preallocate results
    % -------------------------
    results = table('Size', [nSubjects*nConfigs, 8], ...
        'VariableTypes', {'string','double','double','double','double','double','double','double'}, ...
        'VariableNames', {'SubjectID','FilterOrder','LowCutoff','HighCutoff','WinLength','HR_RMSE','RR_RMSE','LenSec'});

    row = 1;

    % -------------------------
    % 4. Main DOE loop
    % -------------------------
    for subj = 1:nSubjects
        fprintf('Processing subject %d/%d\n', subj, nSubjects);

        ppg  = ppg_all{subj};
        ekg  = ekg_all{subj};
        resp = resp_all{subj};
        fs   = fs_all(subj);
        id   = string(meta{subj}.id);  % subject ID string

        lenSec = length(ppg)/fs;

        for cfg = 1:nConfigs
            order = DOE(cfg,1);
            lo    = DOE(cfg,2);
            hi    = DOE(cfg,3);
            win   = DOE(cfg,4);

            % -------------------------
            % 5. Run evaluation function
            % -------------------------
            try
                [hr_rmse, rr_rmse] = evaluate_pipeline(ppg, ekg, resp, fs, order, lo, hi, win);
            catch ME
                warning("Subject %s, Config %d failed: %s", id, cfg, ME.message);
                hr_rmse = NaN; rr_rmse = NaN;
            end

            % -------------------------
            % 6. Store results
            % -------------------------

            if numel(hr_rmse) > 1
                hr_rmse = mean(hr_rmse, 'omitnan');
            end
            if numel(rr_rmse) > 1
                rr_rmse = mean(rr_rmse, 'omitnan');
            end

            results(row,:) = {id, order, lo, hi, win, hr_rmse, rr_rmse, lenSec};
            row = row + 1;
        end
    end

    % -------------------------
    % 7. Save results
    % -------------------------
    save('doe_results.mat','results');
    writetable(results,'doe_results.csv');

    fprintf('DOE complete! Saved %d rows\n', height(results));



end