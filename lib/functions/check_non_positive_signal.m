function dwi = check_non_positive_signal(dwi, mask)

[x, y, z, ndwis] = size(dwi);
for g = 1:ndwis
   g_img = dwi(:, :, :, g);

   bad_signals_indices = union(find(isnan(g_img) & mask), find(g_img <= 0 & mask));
   
   if ~isempty(bad_signals_indices)
       fprintf('%d non-positive singals at direction %d. \n', length(bad_signals_indices), g);
   
       for vox = bad_signals_indices'
           nbr = GetNeighbor(vox, [x, y, z]);
           nbr(2,2,2) = -1;
           nbr = setdiff(nbr(:),-1);   
           nbr(g_img(nbr)<=0) = [];
           g_img(vox) = mean(g_img(nbr));
       end
   end

   dwi(:, :, :, g) = g_img;
end