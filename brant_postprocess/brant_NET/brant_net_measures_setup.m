function hfig_inputdlg = brant_net_measures_setup(h_parent)

figColor = [1 1 1];

current_pos.x = 30;
current_pos.y = 230;
current_pos.length = 120;
current_pos.height = 20;
dis_interval = 5;

vals = get(h_parent, 'Userdata');
net_vals = vals.net_calcs;

prompt{1} = {   'shortest path length',...
    'clustering coefficient',...
    'global efficiency',...
    'local efficiency',...
    'betweenness centrality',...
    'transitivity',...
    ...'betweenness rw',...
    ...'betweenness spe',...
    ...'betweenness spv',...
    };

prompt{2} = {   'degree',...
    'neighbor degree',...
    'assortative mixing',...
    'resilience',...
    'fault tolerance',...
    'vulnerability',...
    };

prompt_options = {'small worldness'};
len_prompt = length(prompt{1});

fig.x = 400;
fig.y = 200;
fig.len = current_pos.length + 2 * current_pos.x;
fig.height = len_prompt * current_pos.height + (len_prompt - 1) * dis_interval + 30 * 2 + length(prompt_options) * 25 + 25 + 150;
fig_pos = [fig.x, fig.y, 400, fig.height];

% h_brant = findobj(0, 'Tag', 'figBRANT');
brant_config_figure(h_parent, 'pixel');
pos_console = get(h_parent, 'Position');
brant_config_figure(h_parent, 'normalized');
pos_tmp = [pos_console(1) + pos_console(3) + 10, pos_console(2), fig_pos(3:4)];

hfig_inputdlg = figure(...
    'IntegerHandle',    'off',...
    'Position',         pos_tmp,...
    'Color',            figColor,...
    'Name',             'Brant Net Measure Options',...
    'UserData',         '',...
    'NumberTitle',      'off',...
    'Units',            'pixels',...
    'Resize',           'off',...
    'MenuBar',          'none');

guidata(hfig_inputdlg, h_parent);
half_prompt = fix(numel(prompt) / 2);


for m = 1:2
    for n = 1:numel(prompt{m})
        pox_x = current_pos.x + (m == 2) * 150;
        pos_y = current_pos.y + (n - half_prompt) * 25;
        
        var_str = prompt{m}{numel(prompt{m}) - n + 1};
        if any(strcmpi(var_str, {'fault tolerance', 'vulnerability', 'local efficiency'}))
            var_str = [var_str, '(*)']; %#ok<AGROW>
        end
        
        var_field = strrep(prompt{m}{numel(prompt{m}) - n + 1}, ' ', '_');
        
        %         net_options.(var_tmp) = 0;
        h_chb = uicontrol(...
            'Parent',               hfig_inputdlg,...
            'String',               var_str,...
            'UserData',             '',...
            'Tag',                  var_field,...
            'Position',             [pox_x, pos_y, 200, 20],...
            'Style',                'checkbox',...
            'BackgroundColor',      figColor,...
            'Value',                net_vals.(var_field),...
            'Callback',             @checkbox_cb);
        brant_resize_ui(h_chb);
    end
end

% set(hfig_inputdlg, 'Userdata', net_options);

uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               repmat('=', 1, 55),...
    'HorizontalAlignment',  'left',...
    'UserData',             '',...
    'Tag',                  '',...
    'Position',             [current_pos.x, current_pos.y - 25, 400, 20],...
    'Style',                'text',...
    'BackgroundColor',      figColor);

for m = 1:numel(prompt_options)
    var_field = strrep(prompt_options{m}, ' ', '_');
    %     net_options.(var_tmp) = 0;
    h_chb = uicontrol(      'Parent',               hfig_inputdlg,...
        'String',               [prompt_options{m}, '(*)'],...
        'UserData',             '',...
        'Tag',                  strrep(prompt_options{m}, ' ', '_'),...
        'Position',             [current_pos.x, current_pos.y - 45, 100, 20],...
        'Style',                'checkbox',...
        'BackgroundColor',      figColor,...
        'Callback',             @sw_cb,...
        'Value',                net_vals.(var_field));
    brant_resize_ui(h_chb);
end

if net_vals.(var_field) == 1
    state_tmp = 'on';
else
    state_tmp = 'off';
end

h_panel_option = uipanel(...
    'Parent',           hfig_inputdlg,...
    'Units',            'pixels',...
    'Position',         [current_pos.x, current_pos.y - 170, 330, 120],...
    'Title',            'Options',...
    'BackgroundColor',  figColor * 0.9,...
    'BorderType',       'line',...
    'BorderWidth',      2);

% Options of small worldness
options_sw = {'keep connectivity', 'integrate result'};
var_field = 'sw';
for m = 1
    tag_tmp = strrep(options_sw{m}, ' ', '_');
    h_chb = uicontrol(  'Parent',               h_panel_option,...
        'String',               options_sw{m},...
        'UserData',             '',...
        'Tag',                  tag_tmp,...
        'Position',             [10, 120 - 25 * m - 20, 120, 20],...
        'Style',                'checkbox',...
        'BackgroundColor',      figColor * 0.9,...
        'Callback',             @sw_opt,...
        'Enable',               state_tmp,...
        'Value',                net_vals.(var_field).(tag_tmp));
    brant_resize_ui(h_chb);
end

h_tmp = uicontrol(...
    'Parent',               h_panel_option,...
    'String',               'Time of Simulation',...
    'HorizontalAlignment',  'left',...
    'UserData',             '',...
    'Tag',                  '',...
    'Position',             [150, 120 - 25 * 1 - 25, 100, 20],...
    'Style',                'text',...
    'BackgroundColor',      figColor * 0.9,...
    'Enable',               state_tmp);
brant_resize_ui(h_tmp);

tag_tmp = 'num_simulation';
uicontrol(...
    'Parent',               h_panel_option,...
    'String',               num2str(net_vals.(var_field).(tag_tmp)),...
    'HorizontalAlignment',  'left',...
    'UserData',             '',...
    'Tag',                  tag_tmp,...
    'Position',             [260, 120 - 25 * 1 - 20, 40, 20],...
    'Style',                'edit',...
    'BackgroundColor',      figColor,...
    'Callback',             @sw_opt,...
    'Enable',               state_tmp);


% h_tmp = uicontrol(...
%             'Parent',               h_panel_option,...
%             'String',               'Parallel Workers',...
%             'HorizontalAlignment',  'left',...
%             'UserData',             '',...
%             'Tag',                  '',...
%             'Position',             [150, 120 - 25 * 2 - 25, 100, 20],...
%             'Style',                'text',...
%             'BackgroundColor',      figColor * 0.9,...
%             'Enable',               state_tmp);
% brant_resize_ui(h_tmp);

% tag_tmp = 'num_paral';
% uicontrol(...
%             'Parent',               h_panel_option,...
%             'String',               num2str(net_vals.(var_tmp).(tag_tmp)),...
%             'HorizontalAlignment',  'left',...
%             'UserData',             '',...
%             'Tag',                  tag_tmp,...
%             'Position',             [260, 120 - 25 * 2 - 20, 40, 20],...
%             'Style',                'edit',...
%             'BackgroundColor',      figColor,...
%             'Callback',             @sw_opt,...
%             'Enable',               state_tmp);



net_options = net_vals;
set(hfig_inputdlg, 'Userdata', net_options);

button_len = 51;

uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               'ok',...
    'UserData',             '',...
    'Tag',                  '',...
    'Position',             [current_pos.x, current_pos.y - 200, button_len, 20],...
    'Style',                'pushbutton',...
    'BackgroundColor',      figColor,...
    'Callback',             @ok_cb);

uicontrol(...
    'Parent',               hfig_inputdlg,...
    'String',               'Cancel',...
    'UserData',             '',...
    'Tag',                  '',...
    'Position',             [current_pos.x + 100, current_pos.y - 200, button_len, 20],...
    'Style',                'pushbutton',...
    'BackgroundColor',      figColor,...
    'Callback',             @cancel_cb);



function sw_opt(obj, evd)
h_panel = get(obj, 'Parent');
h_parent = get(h_panel, 'Parent');
net_options = get(h_parent, 'Userdata');
opt_type = get(obj, 'Style');
field_name = get(obj, 'Tag');

switch(opt_type)
    case 'edit'
        num_tmp = get(obj, 'String');
        net_options.sw.(field_name) = str2num(num_tmp);
    case 'checkbox'
        value_tmp = get(obj, 'Value');
        net_options.sw.(field_name) = value_tmp;
    otherwise
        disp(repmat('o', 1, 65535));
end
set(h_parent, 'Userdata', net_options);

function sw_cb(obj, evd)
h_parent = get(obj, 'Parent');
net_options = get(h_parent, 'Userdata');
field_name = get(obj, 'Tag');
net_options.(field_name) = get(obj, 'Value');
set(h_parent, 'Userdata', net_options);

h_panel = findobj(h_parent, 'Type', 'uipanel');
panel_eles = get(h_panel, 'Child');

if net_options.(field_name) == 0
    for m = 1:numel(panel_eles)
        set(panel_eles(m), 'Enable', 'off');
    end
else
    for m = 1:numel(panel_eles)
        set(panel_eles(m), 'Enable', 'on');
    end
end
set(h_parent, 'Userdata', net_options);

function ok_cb(obj, evd) %#ok<*INUSD>
h_parent = get(obj, 'Parent');
net_options = get(h_parent, 'Userdata');
fath_fig = guidata(h_parent);
jobman_tmp = get(fath_fig, 'Userdata');

jobman_tmp.net_calcs = net_options;
set(fath_fig, 'Userdata', jobman_tmp);

fns_tmp = fieldnames(net_options);
struc_ind = cell2mat(cellfun(@(x) ~isstruct(net_options.(x)), fns_tmp, 'UniformOutput', false));
fns_options = fns_tmp(struc_ind);
selected_ind = cellfun(@(x) net_options.(x) == 1, fns_options, 'UniformOutput', false);
selected_opts = strrep(fns_options(cell2mat(selected_ind)), '_', ' ');
edit_tmp = findobj(fath_fig, 'Style', 'edit', 'Tag', 'net_calcs:disp');
set(edit_tmp, 'String', selected_opts);
delete(h_parent);

function cancel_cb(obj, evd) %#ok<*INUSD>
h_parent = get(obj,'Parent');
delete(h_parent);

function checkbox_cb(obj, evd) %#ok<*INUSD>
h_parent = get(obj, 'Parent');
net_options = get(h_parent, 'Userdata');
field_name = get(obj, 'Tag');
net_options.(field_name) = get(obj, 'Value');
set(h_parent, 'Userdata', net_options);
