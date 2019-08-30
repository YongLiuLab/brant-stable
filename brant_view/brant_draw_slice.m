function brant_draw_slice(background, draw_param, vol)

% load background and vol 
background_data = load_nii_mod(background);
vol_data = load_nii_mod(vol);

[CData, c_map, cbr] = brant_get_slice_color(background_data, vol_data, draw_param);

% normallized the background.img
background_data.img = background_data.img /(background_data.hdr.dime.glmax - background_data.hdr.dime.glmin);

%% draw slice 
sub_num = numel(draw_param.slice_order);
background_data.img = permute(background_data.img, [2, 1, 3]);
if sub_num == 1
    sub_pos = [0, 0.2, 0.4, 0.6; 0.5, 0.2, 0.4, 0.6];
    colorbar_pos = [sub_pos(end,1) + 0.16, sub_pos(end,2) + 0.05, 0.08, 0.4];
    
elseif sub_num < 6
    sub_pos = [0, 0.5, 1/3, 0.5; 1/3, 0.5, 1/3, 0.5; 2/3, 0.5, 1/3, 0.5; ...
               0, 0,   1/3, 0.5; 1/3, 0,   1/3, 0.5; 2/3, 0  , 1/3, 0.5];
    colorbar_pos = [sub_pos(end,1) + 1/6 - 0.03, sub_pos(end,2) + 0.03, 0.06, 0.35];
    
elseif sub_num < 12
    sub_pos = [0, 2/3, 1/4, 1/3; 1/4, 2/3, 1/4, 1/3; 1/2, 2/3, 1/4, 1/3; 3/4, 2/3, 1/4, 1/3; ...
               0, 1/3, 1/4, 1/3; 1/4, 1/3, 1/4, 1/3; 1/2, 1/3, 1/4, 1/3; 3/4, 1/3, 1/4, 1/3; ...
               0, 0  , 1/4, 1/3; 1/4, 0  , 1/4, 1/3; 1/2, 0  , 1/4, 1/3; 3/4, 0  , 1/4, 1/3;];
    colorbar_pos = [sub_pos(end,1) + 1/8 - 0.02, sub_pos(end,2) + 0.03, 0.04, 0.2];
   
elseif sub_num < 20
    sub_pos = [0, 3/4, 1/5, 1/4; 1/5, 3/4, 1/5, 1/4; 2/5, 3/4, 1/5, 1/4; 3/5, 3/4, 1/5, 1/4; 4/5, 3/4, 1/5, 1/4;...
               0, 1/2, 1/5, 1/4; 1/5, 1/2, 1/5, 1/4; 2/5, 1/2, 1/5, 1/4; 3/5, 1/2, 1/5, 1/4; 4/5, 1/2, 1/5, 1/4;...
               0, 1/4, 1/5, 1/4; 1/5, 1/4, 1/5, 1/4; 2/5, 1/4, 1/5, 1/4; 3/5, 1/4, 1/5, 1/4; 4/5, 1/4, 1/5, 1/4;...
               0, 0  , 1/5, 1/4; 1/5, 0  , 1/5, 1/4; 2/5, 0  , 1/5, 1/4; 3/5, 0  , 1/5, 1/4; 4/5, 0  , 1/5, 1/4];
    colorbar_pos = [sub_pos(end,1) + 1/10 - 0.02, sub_pos(end,2) + 0.03, 0.04, 0.15];

end

switch draw_param.view_angle
    case 'transverse'
        for m = 1:sub_num
            h_sub = subplot('position', sub_pos(m,:));
            brant_draw_sl(gca, CData(:,:,draw_param.slice_order(m)), ...
                c_map, background_data.img(:,:,draw_param.slice_order(m)), ...
                draw_param.white_background);
            h_text = text('parent', h_sub, 'string', ...
                ['z = ',num2str(background_data.hdr.hist.srow_z(4) + background_data.hdr.hist.srow_z(3) * (draw_param.slice_order(m) - 1)), 'mm'], ...
                'units', 'normalized', 'position', [0.02 0.9], 'FontSize', 14, ...
                'horizontalAlignment', 'left');
            if draw_param.white_background == 1
                set(h_text, 'color', 'r');
            else
                set(h_text, 'color', 'white');
            end
        end
    case 'coronal'
        background_data.img = permute(background_data.img, [3, 2, 1]);
        CData = permute(CData, [3, 2, 1]);
        for m = 1:sub_num
            h_sub = subplot('position', sub_pos(m,:));
            brant_draw_sl(gca, CData(:,:,draw_param.slice_order(m)), ...
                c_map, background_data.img(:,:,draw_param.slice_order(m)), ...
                draw_param.white_background);
            h_text = text('parent', h_sub, 'string', ...
                ['y = ',num2str(background_data.hdr.hist.srow_y(4) + background_data.hdr.hist.srow_y(2) * (draw_param.slice_order(m) - 1)), 'mm'], ...
                'units', 'normalized', 'position', [0.02 0.9], 'FontSize', 14, ...
                'horizontalAlignment', 'left', 'color', 'w');
            set(h_sub, 'xTick', [], 'yTick', []);
            if draw_param.white_background == 1
                set(h_text, 'color', 'r');
            else
                set(h_text, 'color', 'white');
            end
        end
    case 'sagittal'
        background_data.img = permute(background_data.img, [3, 1, 2]);
        CData = permute(CData, [3, 1, 2]);
        for m = 1:sub_num
            h_sub = subplot('position', sub_pos(m,:));
            brant_draw_sl(gca, CData(:,:,draw_param.slice_order(m)), ...
                c_map, background_data.img(:,:,draw_param.slice_order(m)), ...
                draw_param.white_background);
            if background_data.hdr.hist.srow_x(1) < 0
                background_data.hdr.hist.srow_x = background_data.hdr.hist.srow_x * -1;
            end
            h_text = text('parent', h_sub, 'string', ...
                ['x = ',num2str(background_data.hdr.hist.srow_x(4) + background_data.hdr.hist.srow_x(1) * (draw_param.slice_order(m) - 1)), 'mm'], ...
                'units', 'normalized', 'position', [0.02 0.9], 'FontSize', 14, ...
                'horizontalAlignment', 'left', 'color', 'w');
            set(h_sub, 'xTick', [], 'yTick', []);
            if draw_param.white_background == 1
                set(h_text, 'color', 'r');
            else
                set(h_text, 'color', 'white');
            end
        end
end

h_sub = subplot('position', sub_pos(end,:));
h_c = colorbar('Location', 'East', 'Position', colorbar_pos,...
     'XTick', cbr.xtick,  'XTickLabel', cbr.xlabel, 'FontSize', 13);
colormap(c_map);
caxis(cbr.caxis);
h_t = text('parent', h_sub, 'string', draw_param.color_title, ...
    'units', 'normalized', 'position', [0.5 0.85], 'FontSize', 15, ...
    'horizontalAlignment', 'center');
if draw_param.white_background == 1
    set(h_sub, 'color', 'white');
    set(h_c, 'color', 'black');
    set(h_t, 'color', 'black');
else
    set(h_sub, 'color', 'black');
    set(h_c, 'color', 'white');
    set(h_t, 'color', 'white');
end
set(gca, 'visible', 'off');

end

function [CData, c_map, cbr] = brant_get_slice_color(background_data, vol_data, draw_param)
%% create colormap

vol_int = single(vol_data.img);
min_vol = min(unique(vol_int(:)));
max_vol = max(unique(vol_int(:))); 
abs_max_vq = max(abs(min_vol), abs(max_vol));
color_N = 513;
num_thr = numel(draw_param.vol_thr);
if num_thr == 1 && isempty(draw_param.vol_thr{1})
    draw_param.vol_thr = {min_vol,max_vol};
    num_thr = 2;
end
if mod(num_thr, 2)
    error('The number of parameters you input in {thr vol} must be even.');
end
if draw_param.vol_thr{1} < vol_data.hdr.dime.glmin || draw_param.vol_thr{end} > vol_data.hdr.dime.glmax
    error(['The parameters in {thr vol} must be in the range of value of brain_vol']);
end
c_map = eval([draw_param.colormap, '(color_N)']);

[X, Y, Z] = get_XYZ(vol_data);
[Xq, Yq, Zq] = get_XYZ(background_data);
vol_int = permute(vol_int, [2, 1, 3]);
vol_int(vol_int == 0) = NaN;

if num_thr == 2
    if draw_param.expand_range
        if draw_param.vol_thr{1} > 0
            vol_int(vol_int > draw_param.vol_thr{2}) = draw_param.vol_thr{2};
        elseif draw_param.vol_thr{2} < 0
            vol_int(vol_int < draw_param.vol_thr{1}) = draw_param.vol_thr{1};
        else
            vol_int(vol_int < draw_param.vol_thr{1}) = draw_param.vol_thr{1};
            vol_int(vol_int > draw_param.vol_thr{2}) = draw_param.vol_thr{2};
        end
        vq = interp3(X, Y, Z, vol_int, Xq, Yq, Zq, 'Nearest');
        lr = sort([draw_param.vol_thr{1}, draw_param.vol_thr{end}, 0]);
        if draw_param.only_positive
            if lr(3) == 0
                c_map = [];
                CData = nan(size(vq));
                tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            else
                c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                    [lr(2), lr(3)], 'Nearest');
                c_map = c_map(c_map_lr(1):c_map_lr(2),:);
                color_N = numel(c_map_lr(1):c_map_lr(2));
                length_thr  = abs(lr(3) - lr(2));
                CData = interp1(linspace(lr(2) - length_thr/color_N, ...
                    lr(3) + length_thr/color_N, color_N + 2), 0:color_N + 1, ...
                    vq, 'Nearest');
                CData(CData == 0) = NaN;
                CData(CData == color_N + 1) = NaN;
                tick_vec = [lr(2), lr(3)];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            end 
        elseif draw_param.only_negative
            if lr(1) == 0
                c_map = [];
                CData = nan(size(vq));
                tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            else
                c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                    [lr(1), lr(2)], 'Nearest');
                c_map = c_map(c_map_lr(1):c_map_lr(2),:);
                color_N = numel(c_map_lr(1):c_map_lr(2));
                length_thr  = abs(lr(2) - lr(1));
                CData = interp1(linspace(lr(1) - length_thr/color_N, ...
                    lr(2) + length_thr/color_N, color_N + 2), 0:color_N + 1, ...
                    vq, 'Nearest');
                CData(CData == 0) = NaN;
                CData(CData == color_N + 1) = NaN;
                tick_vec = [lr(1), lr(2)];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            end 
        else
            c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                [draw_param.vol_thr{1}, draw_param.vol_thr{end}], 'Nearest');
            c_map = c_map(c_map_lr(1):c_map_lr(2),:);
            color_N = numel(c_map_lr(1):c_map_lr(2));
            length_thr  = abs(draw_param.vol_thr{1} - draw_param.vol_thr{2});
            CData = interp1(linspace(draw_param.vol_thr{1} - length_thr/color_N, ...
                draw_param.vol_thr{2} + length_thr/color_N, ...
                color_N + 2), 0:color_N + 1, vq, 'Nearest');
            CData(CData == 0) = NaN;
            CData(CData == color_N + 1) = NaN;
            tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{2}];
            cbr.xtick = [1, color_N];
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        end
        
    else
        vq = interp3(X, Y, Z, vol_int, Xq, Yq, Zq, 'Nearest');
        lr = sort([draw_param.vol_thr{1}, draw_param.vol_thr{end}, 0]);
        if draw_param.only_positive
            if lr(3) == 0
                c_map = [];
                CData = nan(size(vq));
                tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            else
                c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), ...
                    1:color_N, [lr(2), lr(3)], 'Nearest');
                c_map = c_map(c_map_lr(1):c_map_lr(2),:);
                color_N = numel(c_map_lr(1):c_map_lr(2));
                CData = interp1(linspace(lr(2), lr(3), color_N), 1:color_N, ...
                    vq, 'Nearest');
                tick_vec = [lr(2), lr(3)];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            end 
        elseif draw_param.only_negative
            if lr(1) == 0
                c_map = [];
                CData = nan(size(vq));
                tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            else
                c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                    [lr(1), lr(2)], 'Nearest');
                c_map = c_map(c_map_lr(1):c_map_lr(2),:);
                color_N = numel(c_map_lr(1):c_map_lr(2));
                CData = interp1(linspace(lr(1), lr(2), color_N), 1:color_N, ...
                    vq, 'Nearest');
                tick_vec = [lr(1), lr(2)];
                cbr.xtick = [1, color_N];
                cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
                cbr.caxis = [1, color_N];
            end 
        else
            c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                [draw_param.vol_thr{1}, draw_param.vol_thr{end}], 'Nearest');
            c_map = c_map(c_map_lr(1):c_map_lr(2),:);
            color_N = numel(c_map_lr(1):c_map_lr(2));
            CData = interp1(linspace(draw_param.vol_thr{1}, draw_param.vol_thr{2}, ...
                color_N), 1:color_N, vq, 'Nearest');
            tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{2}];
            cbr.xtick = [1, color_N];
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        end
    end
else 
    vq = interp3(X, Y, Z, vol_int, Xq, Yq, Zq, 'Nearest');
    lr = sort([draw_param.vol_thr{1}, draw_param.vol_thr{end}, 0]);
    if draw_param.only_positive
        if lr(3) == 0
            c_map = [];
            CData = nan(size(vq));
            tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
            cbr.xtick = [1, color_N];
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        else
            c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), ...
                1:color_N, [lr(2), lr(3)], 'Nearest');
            c_map = c_map(c_map_lr(1):c_map_lr(2),:);
            color_N = numel(c_map_lr(1):c_map_lr(2));
            CData = interp1(linspace(lr(2), lr(3), color_N), 1:color_N, ...
                vq, 'Nearest');
            for m = 2:2:num_thr - 1
                if draw_param.vol_thr{m} - lr(2) > eps
                    temp = interp1(linspace(lr(2), lr(3), color_N), 1:color_N, ...
                        [draw_param.vol_thr{m}, draw_param.vol_thr{m + 1}], 'Nearest');
                elseif draw_param.vol_thr{m + 1} - lr(2) > eps
                    temp = interp1(linspace(lr(2), lr(3), color_N), 1:color_N, ...
                        [lr(2), draw_param.vol_thr{m + 1}], 'Nearest');
                else
                    continue;
                end
                for n = temp(1):temp(2)
                    c_map(n,:) = [1 1 1];
                    CData(find(CData == n)) = NaN;
                end
            end
            thr = [draw_param.vol_thr{:}];
            tick_vec = thr(find(thr > 0));
            if thr(1) < eps
                tick_vec = [0, tick_vec];
            end
            cbr.xtick = interp1(linspace(lr(2), lr(3), color_N), 1:color_N, ...
                tick_vec, 'Nearest');
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        end 
    elseif draw_param.only_negative
        if lr(1) == 0
            c_map = [];
            CData = nan(size(vq));
            tick_vec = [draw_param.vol_thr{1}, draw_param.vol_thr{end}];
            cbr.xtick = [1, color_N];
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        else
            c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
                [lr(1), lr(2)], 'Nearest');
            c_map = c_map(c_map_lr(1):c_map_lr(2),:);
            color_N = numel(c_map_lr(1):c_map_lr(2));
            CData = interp1(linspace(lr(1), lr(2), color_N), 1:color_N, ...
                vq, 'Nearest');
            for m = 2:2:num_thr - 1
                if draw_param.vol_thr{m + 1} - lr(2) < eps
                    temp = interp1(linspace(lr(1), lr(2), color_N), 1:color_N, ...
                        [draw_param.vol_thr{m}, draw_param.vol_thr{m + 1}], 'Nearest');
                elseif draw_param.vol_thr{m} - lr(2) < eps
                    temp = interp1(linspace(lr(1), lr(2), color_N), 1:color_N, ...
                        [draw_param.vol_thr{m}, lr(2)], 'Nearest');
                else
                    continue;
                end
                for n = temp(1):temp(2)
                    c_map(n,:) = [1 1 1];
                    CData(find(CData == n)) = NaN;
                end
            end
            thr = [draw_param.vol_thr{:}];
            tick_vec = thr(find(thr < 0));
            if thr(end) > eps
                tick_vec = [tick_vec, 0];
            end
            cbr.xtick = interp1(linspace(lr(1), lr(2), color_N), 1:color_N, ...
                tick_vec, 'Nearest');
            cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
            cbr.caxis = [1, color_N];
        end 
    else
        c_map_lr = interp1(linspace(-abs_max_vq, abs_max_vq, color_N), 1:color_N, ...
            [draw_param.vol_thr{1}, draw_param.vol_thr{end}], 'Nearest');
        c_map = c_map(c_map_lr(1):c_map_lr(2),:);
        color_N = numel(c_map_lr(1):c_map_lr(2));
        CData = interp1(linspace(draw_param.vol_thr{1}, draw_param.vol_thr{end}, ...
            color_N), 1:color_N, vq, 'Nearest');
        for m = 2:2:num_thr - 1
            temp = interp1(linspace(draw_param.vol_thr{1}, draw_param.vol_thr{end}, color_N), ...
                1:color_N, [draw_param.vol_thr{m}, draw_param.vol_thr{m + 1}], 'Nearest');
            for n = temp(1):temp(2)
                c_map(n,:) = [1 1 1];
                CData(find(CData == n)) = NaN;
            end
        end
        tick_vec = [draw_param.vol_thr{:}];
        cbr.xtick =  interp1(linspace(draw_param.vol_thr{1}, draw_param.vol_thr{end}, ...
            color_N), 1:color_N, tick_vec, 'Nearest');
        cbr.xlabel = arrayfun(@(x) num2str(x, '%0.2f'), tick_vec, 'UniformOutput', false);  
        cbr.caxis = [1, color_N];
    end
end

end


function [X, Y, Z] = get_XYZ(data)
%% from brant get XYZ
s_mat = [data.hdr.hist.srow_x; data.hdr.hist.srow_y; data.hdr.hist.srow_z];
if (s_mat(1, 1) < 0)
    s_mat(1, :) = s_mat(1, :) * -1;
end
size_data = size(data.img);
step_len = diag(s_mat(1:3, 1:3));
b_box = [s_mat(:, 4), s_mat(:, 4) + step_len .* (size_data - 1)']';
[X, Y, Z] = meshgrid(b_box(1, 1):step_len(1):b_box(2, 1), b_box(1, 2):step_len(2):b_box(2, 2), b_box(1, 3):step_len(3):b_box(2, 3));
end

function brant_draw_sl(h_axis, CData, c_map, background, white_background)
[m, n] = size(CData);
%% draw image
image_data = zeros([m, n,3]);
for x = 1:m
    for y = 1:n
        for z = 1:3
            if isnan(CData(x,y))
                if background(x,y) == 0
                    if white_background == 1
                        image_data(x,y,z) = 1;
                    else
                        image_data(x,y,z) = 0;
                    end
                else
                    image_data(x,y,z) = background(x,y);
                end
            else
                t = c_map(CData(x,y),:);
                image_data(x,y,z) = t(z);
            end
        end
    end
end
image_data = flipdim(image_data, 1);
imshow(image_data);
set(gca, 'visible', 'off');
end
