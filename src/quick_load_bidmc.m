function [ppg,resp,ekg,fs,meta] = quick_load_bidmc(dataFile)
% Input (optional): path to bidmc_data.mat
% Output cell arrays of ppg, resp, ekg, and meta for all 53 patients

    if nargin < 1
        dataFile = fullfile(fileparts(pwd),"data","bidmc_data.mat");
    end

    s = load(dataFile);
    data = s.data; 
    nRecords = numel(data);

    % preallocate cell arrays
    ppg  = cell(nRecords,1);
    ekg  = cell(nRecords,1);
    resp = cell(nRecords,1);
    fs   = zeros(nRecords,1);
    meta = cell(nRecords,1);
    
    for i = 1:nRecords
        rec = data(i);
        
        ppg{i}  = rec.ppg.v(:);
        ekg{i}  = rec.ekg.v(:);
        resp{i} = rec.ref.resp_sig.imp.v(:);
        fs(i)   = rec.ppg.fs;   % usually 125 Hz
        meta{i}     = rec.fix;      % subject ID, location, etc.
    end
end

