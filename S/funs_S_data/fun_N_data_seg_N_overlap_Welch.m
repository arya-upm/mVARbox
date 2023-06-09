function [N_data_seg, N_overlap] = fun_N_data_seg_N_overlap_Welch(N_data, N_seg, overlap)

% Exact value
N_data_seg = N_data/(N_seg-overlap*N_seg+overlap);

% Floor, because N_data_seg needs to be equal or smaller than that
N_data_seg = floor(N_data_seg);

% Impose even number (required for data time window)
if mod(N_data_seg,2)==1
    N_data_seg = N_data_seg-1;
end

% N_overlap needs to be equal or larger than exact value, to avoid having more
% segments than required
N_overlap = ceil(N_data_seg*overlap);




   