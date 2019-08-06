function hpc_submit_job(function_name, varargin)
%% This code is used to submit a FW job to the high performance cluster (hpc).
% To run this, replace:
%   FreeWater_OneCase(case_id, input_dwi, input_bval, input_bvec, input_mask, output_folder);
% with:
%   hpc_submit_job('FreeWater_OneCase', case_id, input_dwi, input_bval, input_bvec, input_mask, output_folder);
%
% This code call 'bsub' to submit FreeWater_OneCase to the cluster.
% Parameters can be modified for 'bsub' by changing the paramter options of the variable cmd in line 35. 
% For example, one can specify a machine to run the job by adding '-m cmuXX'. 

str_function = function_name;
str_function = [str_function, '('];
for vi = 1:length(varargin)
    if isempty(varargin{vi})
       str_function = [str_function, '[]', ', '];
    elseif ischar(varargin{vi})
       str_function = [str_function, '''%s''', ', '];
    elseif isnumeric(varargin{vi})
       str_function = [str_function, '%d', ', '];
    end
    str_function = sprintf(str_function, varargin{vi});
end
str_function = [str_function(1:end-2), ')'];

%%
case_id = varargin{1};
output_folder = varargin{end};

% These three parameters are for debug only
n = 1;
q = 'medium';
echo = '';

cmd = ['bsub -n ', num2str(n), ' ', ...
            '-q ', q, ' ', ...
            '-e ', fullfile(output_folder, [case_id, '_log.err']), ' ', ...
            '-o ', fullfile(output_folder, [case_id, '_log.out']), ' ', ...
       'matlab -nodesktop -nosplash -r "', str_function, '; exit;"'];

system([echo, ' ', cmd]);
