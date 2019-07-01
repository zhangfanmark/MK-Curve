function md = dki_md_only(dt, mask)

n = size(dt, 4);
if ndims(dt)~=4
    error('size of dt needs to be [x, y, z, 21]')
end
if n~=21
    error('dt needs to contain 21')
end
if ~exist('mask','var') || isempty(mask)     
    mask = ~isnan(dt(:,:,:,1));
end
    
dt = vectorize(dt, mask);
nvoxels = size(dt, 2);


%% DTI parameters
parfor i = 1:nvoxels
    DT = dt([1:3 2 4 5 3 5 6], i);
    DT = reshape(DT, [3 3]);
    [eigvec, eigval] = eigs(DT);
    eigval = diag(eigval);
    [eigval, idx] = sort(eigval, 'descend');
    eigvec = eigvec(:, idx);
    l1(i) = eigval(1,:);
    l2(i) = eigval(2,:);
    l3(i) = eigval(3,:);
end

md = (l1+l2+l3)/3;
md = l3;
% rd = (l2+l3)/2;
% ad = l1;
% fa = sqrt(1/2).*sqrt((l1-l2).^2+(l2-l3).^2+(l3-l1).^2)./sqrt(l1.^2+l2.^2+l3.^2);


% return maps
md = vectorize(md, mask);
