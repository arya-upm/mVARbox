%% dataset_01_AR

clear
clc
close all


%%% Parameters
N = 1000;
delta_t = 0.05;
f_max = 1/(2*delta_t);
ind_var = 't';


%%% AR 

a_vector    = [1.2 -0.5 0.1];

j_vector    = [1 2 5];

b           = 0.5;

AR = initialise_AR('a_vector',a_vector,'b',b,'j_vector',j_vector);


%%% gamma_fun

M = 200;

gamma_AR = initialise_gamma('M',M);

gamma_AR = get_gamma_AR(AR,gamma_AR);


%%% S 

f_vector = linspace(0,f_max,N);

S_AR = initialise_S('ind_var','f',...                             
                    'x_max',f_max,...
                    'x_values',f_vector);

S_AR = get_S_AR(AR,S_AR);



%% data simulation

data_AR = initialise_data('ind_var',ind_var,...
                          'N',N,...
                          'delta_x',delta_t);

data_AR = get_data_AR(AR,data_AR);



%% save (uncomment to replace stored dataset)

% save dataset_01_AR.mat AR gamma_AR S_AR data_AR

