function [CData, c_map, cbr] = brant_get_vert_color(vol, vertices_coord, colorinfo)
% get colormap for vertices

% vol_h = spm_vol(vol);
% b_box = spm_get_bbox(vol);
% vol_int = spm_read_vols(vol_h);
% step_len = diag(vol_h.mat);
% b_box = bsxfun(@times, b_box, sign(step_len(1:3))');
% [X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));

if isfield(colorinfo, 'rad_mm')
    rad_mm = colorinfo.rad_mm;
else
    rad_mm = [];
end

vol_data = load_nii_mod(vol);
vol_int = single(vol_data.img);

% from brant_get_XYZ
s_mat = [vol_data.hdr.hist.srow_x; vol_data.hdr.hist.srow_y; vol_data.hdr.hist.srow_z];
if (s_mat(1, 1) < 0)
    s_mat(1, :) = s_mat(1, :) * -1;
end
size_data = size(vol_data.img);
step_len = diag(s_mat(1:3, 1:3));
b_box = [s_mat(:, 4), s_mat(:, 4) + step_len .* (size_data - 1)']';
[X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));

vol_int = permute(vol_int, [2, 1, 3]);
vol_int(~isfinite(vol_int)) = 0;

% maximum neighbour interpolation with spot light sphere
vox_len = diag(abs(s_mat(:, 1:3)));
if ~isempty(rad_mm) && all(rad_mm >= vox_len)
    rad_N = ceil(rad_mm ./ vox_len);
    [Xmm, Ymm, Zmm] = meshgrid(-1*rad_N(1):rad_N(1), -1*rad_N(2):rad_N(2), -1*rad_N(3):rad_N(3));
    vox_inds_tmp = [Xmm(:) * vox_len(1), Ymm(:) * vox_len(2), Zmm(:) * vox_len(3)];
    dist_vox = arrayfun(@(x) norm(vox_inds_tmp(x, :), 2), 1:size(vox_inds_tmp, 1)) <= rad_mm;
%     dist_vox = pdist2([0, 0, 0], vox_inds_tmp) <= rad_mm;
    vol_int = imdilate(vol_int, reshape(dist_vox, 2 * rad_N' + 1)); % find maximum in nearnest neighbour
end

if isempty(colorinfo.vol_thr)
    colorinfo.vol_thr = [vol_data.hdr.dime.glmin, vol_data.hdr.dime.glmax];
end
num_thr = numel(colorinfo.vol_thr);
if mod(num_thr, 2)
    error('The number of parameters you input in {thr vol} must be even.');
end
if colorinfo.vol_thr(1) < vol_data.hdr.dime.glmin || colorinfo.vol_thr(end) > vol_data.hdr.dime.glmax
    error(['The parameters in {thr vol} must be in the range of value of brain_vol']);
end

if colorinfo.discrete
    uniq_color = setdiff(vol_int(:), 0);
    color_N = numel(uniq_color);
    c_map = hsv(color_N);
    rand_ind = randperm(color_N, color_N);
    c_map = [1, 1, 1; c_map(rand_ind, :)];  
else
%     min_vol = min(unique(vol_int(:)));
%     max_vol = max(unique(vol_int(:))); 
%     abs_max_vq = max(abs(min_vol), abs(max_vol));
    color_N = 513;
    switch colorinfo.colormap
        case 'AFNI'
            if colorinfo.vol_thr(1) < 0 && colorinfo.vol_thr(end) > 0
                zero_location = round(interp1(linspace(colorinfo.vol_thr(1), colorinfo.vol_thr(end), color_N), 1:color_N, 0));
                c_map = [zeros(1,zero_location - 2),1,1,1,ones(1,color_N - zero_location - 1);...
                        linspace(1,0,zero_location - 2),1,1,1,linspace(0,1,color_N - zero_location - 1);...
                        ones(1,zero_location - 2),1,1,1,zeros(1,color_N - zero_location - 1)]';
            else
                error('You need input a image with negative and positive value');
            end
        case 'AFNI_neg'
            if colorinfo.vol_thr(end) <= 0
                c_map = [zeros(1,color_N);linspace(1,0,color_N);ones(1,color_N)]';
            else
                error('You need input a image with negative value only');
            end
        case 'AFNI_pos'
            if colorinfo.vol_thr(1) >= 0
                c_map = [ones(1,color_N);linspace(0,1,color_N);zeros(1,color_N)]';
            else
                error('You need input a image with positive value only');
            end
        otherwise
            c_map = eval([colorinfo.colormap, '(color_N)']);
    end
%     c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
%         [colorinfo.vol_thr(1), colorinfo.vol_thr(end)], 'Nearest');
%     c_map = c_map(c_map_lr(1):c_map_lr(2),:);
%     color_N = numel(c_map_lr(1):c_map_lr(2));
end
vq = interp3(X, Y, Z, vol_int, vertices_coord(:, 1), vertices_coord(:, 2), ...
    vertices_coord(:, 3), 'linear');
% vq(find(vq > -0.005 & vq < 0.005)) = NaN;   %don't display the value in the range of [-0.005, 0.005]

% vq = zeros(size(vertices_coord,1),1);
% s_mat(4,:) = [0, 0, 0, 1];
% vertices_coord(:,4) = 1;
% position = s_mat\vertices_coord';
% position(4,:) = [];
% for i = 1:size(vertices_coord,1)
%     cube = [floor(position(:,i))';ceil(position(:,i))'];
%     portion = position(:,i)' - cube(1,:);
%     cube(2,portion == 0) = cube(2,portion == 0) + 1;
%     tmpT = vol_int(cube(1,2):cube(2,2),cube(1,1):cube(2,1),cube(1,3):cube(2,3));
%     tmpT = (tmpT(:,:,2) - tmpT(:,:,1)) .* portion(3) + tmpT(:,:,1);
%     tmpT = (tmpT(:,2) - tmpT(:,1)) .* portion(2) + tmpT(:,1);
%     tmpT = (tmpT(2) - tmpT(1)) .* portion(1) + tmpT(1);
%     vq(i) = tmpT;
% end

if num_thr > 2
    for m = 2:2:num_thr - 1
        temp = interp1(linspace(colorinfo.vol_thr(1), colorinfo.vol_thr(end), color_N), ...
            1:color_N, [colorinfo.vol_thr(m), colorinfo.vol_thr(m + 1)],'Nearest');
        for n = temp(1):temp(2)
            c_map(n,:) = [1 1 1];
        end
    end
end
if abs(colorinfo.vol_thr(1) - colorinfo.vol_thr(end)) < eps     % add for viewing single value
    CData = nan(size(vq));
    CData(find(abs(vq - colorinfo.vol_thr(1)) < eps)) = 1;
    CData(find(isnan(CData))) = 2;
    tick_vec = [colorinfo.vol_thr(1), colorinfo.vol_thr(end)];
    cbr.xtick = [1 1.5];
    cbr.xlabel = arrayfun(@(x) num2str(x, '%d'), tick_vec, 'UniformOutput', false);
    cbr.caxis = [1, 2];
else    
    CData = interp1(linspace(colorinfo.vol_thr(1), colorinfo.vol_thr(end), color_N),...
        1:color_N, vq, 'Nearest');
    CData(find(abs(vq - colorinfo.vol_thr(1)) < eps)) = 1;
    if sum(isnan(CData))
        CData(find(isnan(CData))) = color_N + 1;
        c_map(end + 1,:) = [1 1 1];
    end
    tick_vec = colorinfo.vol_thr;
    cbr.xtick = interp1(linspace(colorinfo.vol_thr(1), colorinfo.vol_thr(end), color_N),...
        1:color_N, tick_vec, 'Nearest');
    cbr.xlabel = arrayfun(@(x) num2str(x, '%.2f'), tick_vec, 'UniformOutput', false);
    cbr.caxis = [1, color_N];
end

end