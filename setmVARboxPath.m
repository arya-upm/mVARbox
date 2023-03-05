%% This function adds mVARbox to path

function setmVARboxPath

path_mVARbox = fileparts(which('setmVARboxPath'));

addpath(genpath(path_mVARbox));

disp('mVARbox path has been added to MATLAB path')


