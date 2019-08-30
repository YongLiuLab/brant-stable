function brant_surface_mapping(jobman, h_con)

if isempty(jobman.vol_map{1})
    vol_file = [];
else
    vol_file = jobman.vol_map{1};
end

mode_display = jobman.mode_display;

surface_file = jobman.surface{1};
draw_param.material_type = jobman.material_type;
draw_param.lighting_type = jobman.lighting_type;
draw_param.shading_type = jobman.shading_type;
draw_param.alpha = jobman.alpha;
draw_param.discrete = jobman.discrete;
% draw_param.smooth = jobman.smooth;
% draw_param.zero_color = jobman.zero_color;
draw_param.vol_thr = jobman.vol_thr;
draw_param.vol_thr = regexpi(draw_param.vol_thr, ',', 'split');
for m = 1:numel(draw_param.vol_thr)
    draw_param.vol_thr{m} = str2num(draw_param.vol_thr{m});
end
draw_param.vol_thr = [draw_param.vol_thr{:}];
if ~issorted(draw_param.vol_thr(:))
    error('You need input incremental parameters in {thr vol}.');
end
% if numel(draw_param.vol_thr) ~= numel(unique(draw_param.vol_thr))
%     error('You need input different parameters in {thr vol}.');
% end
draw_param.colorbar_ind = jobman.colorbar;
draw_param.colormap = jobman.colormap;
draw_param.rad_mm = jobman.rad_mm;
brant_create_disp_fig(h_con, 'Surface Mapping: Draw');
brant_draw_surface(surface_file, mode_display, draw_param, vol_file);








