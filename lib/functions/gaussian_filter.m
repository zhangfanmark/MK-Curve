function dwi_gauss = gaussian_filter(dwi)

fwhm = 1.25;
gauss_std = fwhm / sqrt(8 * log(2));

[~, ~, ~, ndwis] = size(dwi);
for g = 1:ndwis
   g_img = dwi(:, :, :, g);
   g_img_guass = imgaussfilt3(g_img, gauss_std);
   dwi(:, :, :, g) = g_img_guass;
end

dwi_gauss = dwi;