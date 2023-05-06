%% dataset_02_VAR_2V

clear
clc
close all


%%% Parameters
N = 1000;
delta_t = 0.05;
f_max = 1/(2*delta_t);
ind_var = 't';


%%% VAR 

A1 = [  1.20  -0.15 ;
        0.05   0.75 ];

A2 = [ -0.55   0.05 ;
        0.00   0.10 ];

A5 = [  0.10   0.00 ;
        0.00   0.00 ];

A_vector = [A1 A2 A5];

j_vector = [1 2 5];

B = [ 0.5  0.0 ;
      0.0  0.4 ];

VAR = initialise_VAR('A_vector',A_vector,'B',B,'j_vector',j_vector);


%%% CMV

M = 200;

CMF_VAR = initialise_CMF('M',M);

CMF_VAR = get_CMF_VAR(VAR,CMF_VAR);


%%% CPSDM 

f_vector = linspace(0,f_max,100);

CPSDM_VAR = initialise_CPSDM('ind_var','f',...
                             'x_max',f_max,...
                             'x_values',f_vector);

CPSDM_VAR = get_CPSDM_VAR(VAR, CPSDM_VAR);



%% data simulation

data_VAR = initialise_data('ind_var',ind_var,...
                          'N',N,...
                          'delta_x',delta_t);

data_VAR = get_data_VAR(VAR,data_VAR);



%% save (uncomment to replace stored dataset)

% save dataset_02_VAR_2V.mat VAR CMF_VAR CPSDM_VAR data_VAR

