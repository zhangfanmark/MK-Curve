function [ mk_vs_syn_b0 ] = MK_versus_synthetic_b0(dwi, grad, mask, syn_b0_range, output_dir)

orignal_b0_img = dwi(:, :, :, 1);
orignal_b0_vec = vectorize(orignal_b0_img, mask);

% % Sanity check, not always useful.
% mean_b0_value = mean(orignal_b0_vec);
% if mean_b0_value < 2*syn_b0_range(1) || mean_b0_value > syn_b0_range(end) / 2
%     disp('syn_b0_range is not valid')
%     return;
% end

syn_dir = fullfile(output_dir, 'MK_curves_syn_b0');

if exist(syn_dir, 'dir') == 0
    mkdir(syn_dir)
end

%% Compute MK curves versus b0
fprintf('\n')
fprintf('  * synthetic b0 : 000');
curve_file = fullfile(output_dir, 'mk_vs_syn_b0.mat');
if ~exist(curve_file, 'file')
    
    mk_vs_syn_b0 = zeros(length(syn_b0_range), length(orignal_b0_vec));
    for s_idx = 1:length(syn_b0_range)
        syn_b0 = syn_b0_range(s_idx);        
        fprintf('\b\b\b');
        fprintf('%s%%', num2str(round(s_idx/length(syn_b0_range)*100), '%02d'))
        
        mat_file = fullfile(syn_dir, ['mk_' num2str(syn_b0) '.mat']);

        if ~exist(mat_file, 'file')
            dwi(:, :, :, 1) = syn_b0;
            [~, dt] = dki_fit(dwi, grad, mask, [0, 0, 0]);
            mk = dki_mk_only(dt, mask);
            
            save(mat_file, 'mk');
        else
            load(mat_file);
        end
        mk_vs_syn_b0(s_idx, :) = vectorize(mk, mask);
    end
    fprintf('\n')
    
    save(curve_file, 'mk_vs_syn_b0');
else
    load(curve_file)
end
fprintf('\n')

