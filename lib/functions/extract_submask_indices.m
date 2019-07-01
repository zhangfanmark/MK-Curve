function submask_indices = extract_submask_indices(mask, submask)

tmp = vectorize(submask, mask);

submask_indices = find(tmp > 0);
