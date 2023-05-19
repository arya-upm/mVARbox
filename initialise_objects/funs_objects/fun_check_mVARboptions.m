function [mVARboptions] = fun_check_mVARboptions(mVARboptions)


%% Description of the function
%
% This function checks fields of a mVARboptions object, and complete empty fields if possible. 
% It is always employed at the end of a fun_append_(class) function.
%
%



if strcmp(mVARboptions.get_VAR_eqs_steps,'2-steps') && ...
   ( strcmp(mVARboptions.impose_BBT,'symmetric') || strcmp(mVARboptions.impose_BBT,'diagonal') )
	warning('mVARboptions says get_VAR_eqs_steps = 2-steps, but impose_BBT is different from "none". Changing impose_BBT to "none"')
	mVARboptions.impose_BBT = 'none';
end


