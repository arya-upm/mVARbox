function fun_write_log(message,log_name,log_path)


% Matlab 2022a and beyond
% writelines(message,[log_path log_name],WriteMode="append")


fid = fopen([log_path log_name],'a');

fprintf(fid,'\n');
fprintf(fid,'%s:   ',string(datetime));
fprintf(fid,message);
fprintf(fid,'\n');

fclose(fid);

