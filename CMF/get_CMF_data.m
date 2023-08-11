function [CMF] = get_CMF_data(data, CMF)
 

%% Description of the function
%
% This function provides the sampled covariance matrix function of a k-variate 
% data series.
%
%
%% Inputs:
%           data:   An object (structure) class 'data'.
%                   The following fields need to be defined:
%                       .y_values   
%
%           CMF:    An object (structure) class 'CMF'.
%                   The following fields need to be defined:
%                       .x_parameters.M
%                       (.method) < Optional field. If empty, the default value is 
%                                   employed (see function 'fun_default_value')
% 
% 
%% Outputs:
%           CMF:    An object (structure) class 'CMF'
%                   The following fields are added to the object:
%                       .type = 'data'
%                       .y_values
%                       (.ind_var)  < inherited from data.ind_var
%                       (.x_parameters.delta_x)  < inherited from 
%                                                  data.x_parameters.delta_x
% 
%
%% References:
% 
% [1] Gallego-Castillo, C. et al., A tutorial on reproducing a predefined autocovariance 
%     function through AR models: Application to stationary homogeneous isotropic 
%     turbulence, Stochastic Environmental Research and Risk Assessment, 2021. 
%     DOI: 10.1007/s00477-021-02156-0
% 
% [2] S. Lawrence Marple Jr. Digital Spectral Analysis 2019 (see chapter 5)
% 
%



%% Checks

% CMF.method
if isempty(CMF.method)
    CMF = fun_append_CMF(CMF,'method',fun_default_value('CMF.method'));
end

% M maximum lag larger than the data length
if CMF.x_parameters.M > size(data.y_values,1)-1
    error(['Error: Maximum lag M=%d introduced for computing the CMF ' ...
           'is equal or higher than data length N=%d'], ...
           CMF.x_parameters.M, size(data.y_values,1))
end

% k
if isempty(data.k)
    data = fun_append_data(data,'k',size(data.y_values,2));
end



%% Unwrap relevant variables

% k
k               = data.k;

% y_values_data
y_values_data   = data.y_values;

% M
M               = CMF.x_parameters.M;

% method
method          = CMF.method;



%% Code
 
%%% Select estimation method

switch method


    case 'unbiased'

        y_values_CMF = zeros(k,k,2*M+1);
        
        gamma_fun0 = initialise_gamma('M',M,'method',method);

        for k_i = 1:k
        
            for k_j = k_i:k

                [gamma_fun] = get_gamma_data(data, gamma_fun0, [k_i k_j]);
                gamma_fun_y_values = gamma_fun.y_values;
        
                y_values_CMF(k_i,k_j,:) = gamma_fun_y_values;
        
                if k_i ~= k_j
                    y_values_CMF(k_j,k_i,:) = flipud(gamma_fun_y_values);        
                end
        
            end
        
        end



    case 'biased'

        y_values_CMF = zeros(k,k,2*M+1);

        gamma_fun0 = initialise_gamma('M',M,'method',method);
        
        for k_i = 1:k

            for k_j = k_i:k

                [gamma_fun] = get_gamma_data(data, gamma_fun0, [k_i k_j]);
                gamma_fun_y_values = gamma_fun.y_values;
        
                y_values_CMF(k_i,k_j,:) = gamma_fun_y_values;
        
                if k_i ~= k_j
                    y_values_CMF(k_j,k_i,:) = flipud(gamma_fun_y_values);
                end
        
            end
        
        end



    case 'unbiased_matlab'

        y_values_CMF = zeros(k,k,2*M+1);
        
        gamma_fun0 = initialise_gamma('M',M,'method',method);

        for k_i = 1:k
        
            for k_j = k_i:k

                [gamma_fun] = get_gamma_data(data, gamma_fun0, [k_i k_j]);
                gamma_fun_y_values = gamma_fun.y_values;
        
                y_values_CMF(k_i,k_j,:) = gamma_fun_y_values;
        
                if k_i ~= k_j
                    y_values_CMF(k_j,k_i,:) = flipud(gamma_fun_y_values);        
                end
        
            end
        
        end



    case 'biased_matlab'

        y_values_CMF = zeros(k,k,2*M+1);

        gamma_fun0 = initialise_gamma('M',M,'method',method);
        
        for k_i = 1:k

            for k_j = k_i:k

                [gamma_fun] = get_gamma_data(data, gamma_fun0, [k_i k_j]);
                gamma_fun_y_values = gamma_fun.y_values;
        
                y_values_CMF(k_i,k_j,:) = gamma_fun_y_values;
        
                if k_i ~= k_j
                    y_values_CMF(k_j,k_i,:) = flipud(gamma_fun_y_values);
                end
        
            end
        
        end



    case 'unbiased_matlab_v2'

        y_values_CMF_matrix = xcov(y_values_data,M,'unbiased');
        
        % Reshape to adapt to (k)x(k)x(2M+1) array
        y_values_CMF = nan(k,k,2*M+1);
        
        for ii = 1:k*k    
            fil = ceil(ii/k);
            col  = mod(ii,k);
            if col==0 ; col=k; end            
            y_values_CMF(fil,col,:) = y_values_CMF_matrix(:,ii);            
        end



    case 'biased_matlab_v2'

        y_values_CMF_matrix = xcov(y_values_data,M,'biased');
        
        % Reshape to adapt to (k)x(k)x(2M+1) array
        y_values_CMF = nan(k,k,2*M+1);
        
        for ii = 1:k*k    
            fil = ceil(ii/k);
            col  = mod(ii,k);
            if col==0 ; col=k; end            
            y_values_CMF(fil,col,:) = y_values_CMF_matrix(:,ii);
        end        
    
end



%% inherited 

if ~isempty(data.ind_var)
	CMF= fun_append_CMF(CMF,'ind_var',data.ind_var);
end

if ~isempty(data.x_parameters.delta_x)
	CMF = fun_append_CMF(CMF,'delta_x',data.x_parameters.delta_x);
end



%% Assign outputs

CMF = fun_append_CMF(CMF,...
                     'type','data',...
                     'y_values',y_values_CMF);

