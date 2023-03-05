%% This function removes mVARbox from path

function unsetmVARboxPath

path_mVARbox = fileparts(which('unsetmVARboxPath'));

% this removes folder mVARbox and all the subfolders
rmpath(genpath(path_mVARbox));

% thus, mVARbox folder needs to be added again (but not subfolders)
addpath(path_mVARbox);


disp('mVARbox path has been removed from MATLAB path. Bye bye..')


