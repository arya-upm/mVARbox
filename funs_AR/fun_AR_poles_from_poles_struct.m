function [AR] = fun_AR_poles_from_poles_struct(AR)


%% Description of the function
% 
% This function transfer poles info in an AR object from field 'poles_AR_struct'
% towards field 'poles_AR'
% 
% 
%% Inputs:
%           AR: An object (structure) class 'AR'
%               The following fields need to be defined:
%                   .poles.poles_AR_struct.real     < empty if no real poles
%                   .poles.poles_AR_struct.complex  < empty if no complex poles
% 
%
%% Outputs:
%           AR: An object (structure) class 'AR'
%               The following fields are added to the object:
%                   .poles.poles_AR
% 
% 



%% Unwrap relevant variables

poles_real      = AR.poles.poles_AR_struct.real;
poles_complex   = AR.poles.poles_AR_struct.complex;



%% Code

poles_AR = poles_real;

for ii = 1:numel(poles_complex)
    poles_AR = [poles_AR ; poles_complex(ii) ; conj(poles_complex(ii)) ];
end



%% Assign outputs

AR = fun_append_AR(AR,'poles_AR',poles_AR);


