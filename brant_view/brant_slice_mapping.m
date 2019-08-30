function brant_slice_mapping(jobman, h_con)

if isempty(jobman.vol_map{1})
    vol_file = [];
else
    vol_file = jobman.vol_map{1};
end
background_file = jobman.background{1};
draw_param.view_angle = jobman.view_angle;
draw_param.slice_order = jobman.slice_order;
if numel(draw_param.slice_order) < 1 || numel(draw_param.slice_order) > 19
    error('The number of elements of slice_order must be less than 20 and more than 0.');
end

draw_param.white_background = jobman.white_background;
draw_param.only_positive = jobman.only_positive;
draw_param.only_negative = jobman.only_negative;
if draw_param.only_positive && draw_param.only_negative
    error('You can''t choose both of two options: {only positive} and {only negative}.');
end
draw_param.expand_range = jobman.expand_range;
draw_param.colormap = jobman.colormap;
draw_param.vol_thr = jobman.vol_thr;
draw_param.vol_thr = regexpi(draw_param.vol_thr, ',', 'split');
for m = 1:numel(draw_param.vol_thr)
    draw_param.vol_thr{m} = str2num(draw_param.vol_thr{m});
end
if ~issorted([draw_param.vol_thr{:}])
    error('You need input incremental parameters in {thr vol}.');
end
if draw_param.expand_range && numel(draw_param.vol_thr) > 2
    error('You need input 0 or 2 parameters in {thr vol} when you have checked {expand display range}.');
end

draw_param.color_title = jobman.color_title;

brant_create_disp_fig(h_con, 'Slice Mapping: Draw');
if draw_param.white_background == 1
    set(gcf, 'color', 'white');
else
    set(gcf, 'color', 'black');
end
brant_draw_slice(background_file, draw_param, vol_file);
