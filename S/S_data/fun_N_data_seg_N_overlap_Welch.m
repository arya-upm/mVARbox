function [N_data_seg, N_overlap] = fun_N_data_seg_N_overlap_Welch(N_data, N_seg, overlap)

% Exact value
N_data_seg = N_data/(N_seg-overlap*N_seg+overlap);

% Floor
N_data_seg = floor(N_data_seg);

% Impose even number (required for data window)
if mod(N_data_seg,2)==1
    N_data_seg = N_data_seg-1;
end

% N_overlap
N_overlap = round(N_data_seg*overlap);

