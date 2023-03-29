
setmVARboxPath

clear
clc
close all

phi_vector = [0 0 ];
sigma = 5.5;

AR = initialise_AR('phi_vector',phi_vector,'sigma',sigma);

k = 5;
data = initialise_data('N',10000,'k',k);


[data] = get_data_AR(AR, data);


plot(data.y_values,'.-')


