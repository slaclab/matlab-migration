function pdudiag()
% pdudiag PDUDIAG is a GUI application for diagnosing PDU channels

% (Leave a blank line following the help.)

%  Initialization tasks
BG_COLOR = 0.8 * [1 1 1];
WINDOW_HEIGHT = 700;
WINDOW_WIDTH = 1000;

[sys,accelerator]=getSystem();

LOCATIONS = {};

if isequal(accelerator,'LCLS')
    for i=20:30
        LOCATIONS{end + 1} = sprintf('LI%d', i);
    end
end

if isequal(accelerator,'FACET')
    for i=10:10
        LOCATIONS{end + 1} = sprintf('LI%d', i);
    end
end

%TEST
%LOCATIONS = {'LI17', 'LI18', 'B34'};



    function row_layout(left, uicontrols, bottoms, widths, heights, margins)
        for i = 1:size(uicontrols, 2)
            set(uicontrols{i}, 'Position', [left bottoms{i} widths{i} heights{i}]);
            left = left + widths{i} + margins{i};
        end
    end



%  Construct the components
fh = figure('Name', 'PDUDiag',...
    'Color', BG_COLOR,...
    'Menubar', 'none',...
    'Resize', 'off',...
    'Toolbar', 'none',...
    'Units', 'pixels');
fig_position = get(fh, 'position');
fig_position(3) = WINDOW_WIDTH;
fig_position(4) = WINDOW_HEIGHT;
set(fh, 'position', fig_position);

location_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'left',...
    'String','Location:');
location_popupmenu = uicontrol(fh,'Style','popupmenu',...
    'String', LOCATIONS,...
    'Value',1);
crate_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'left',...
    'String','Crate:');
crate_popupmenu = uicontrol(fh,'Style','popupmenu',...
    'String',{'n/a'},...
    'Value',1);
channel_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'left',...
    'String','Channel:');
channel_popupmenu = uicontrol(fh,'Style','popupmenu',...
    'String',{'n/a'},...
    'Value',1);
collect_data_button = uicontrol(fh,'Style','pushbutton',...
    'String','Collect data',...
    'BusyAction', 'cancel');
collecting_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'left',...
    'String','Collecting data...',...
    'Visible', 'off');

text_bottom = WINDOW_HEIGHT - 40;
popupmenu_bottom = text_bottom + 4;
button_bottom = text_bottom;

row_layout(20,...
    {location_text, location_popupmenu, crate_text, crate_popupmenu, channel_text, channel_popupmenu, collect_data_button, collecting_text},...
    {text_bottom, popupmenu_bottom, text_bottom, popupmenu_bottom, text_bottom, popupmenu_bottom, button_bottom, text_bottom},...
    {60, 100, 40, 50, 60, 50, 120, 200},...
    {20, 20, 20, 20, 20, 20, 30, 20},...
    {5 10 5 10 5 20 10 0});

slider = uicontrol(fh,'Style','slider',...
    'Max', 100,...
    'Min', 1,...
    'Value', 100,...
    'SliderStep',[0.01 0.01],...
    'Position',[fig_position(3) - 20 30 20 WINDOW_HEIGHT - 130]);


overall_status_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'right',...
    'Position', [fig_position(3) - 400 10 200 20]);

timestamp_text = uicontrol(fh,'Style','text',...
    'BackgroundColor', BG_COLOR,...
    'HorizontalAlignment', 'right',...
    'Position', [fig_position(3) - 200 10 190 20]);

% table

% headers
col_headers = {'#',...
    'Delay',...
    'Delay',...
    'Beamcode',...
    'Timeslot',...
    'MOD6',...
    'MOD5',...
    'MOD4',...
    'MOD3',...
    'MOD2',...
    'MOD1',...
    'Pulse ID',...
    'Status'};

sub_headers = {'(pdu ticks)',...
    '(nsecs)',...
    '(dec)'};

bits_headers = {'191....160',...
    '159....128',...
    '127.......96',...
    '95........64',...
    '63........32',...
    '31..........0'};

col_widths = [25,...
    110,...
    100,...
    80,...
    80,...
    70,...
    70,...
    70,...
    70,...
    70,...
    70,...    
    60,...
    85];

OFFSET_X = 20;

    function pos = header_position(col)
        width = col_widths(col);
        left = OFFSET_X + sum(col_widths(1:col-1));
        height = 30;
        top = WINDOW_HEIGHT - 90;
        pos = [left top width height];
    end

    function pos = sub_position(col)
        width = col_widths(col);
        left = OFFSET_X + sum(col_widths(1:col-1));
        height = 30;
        top = WINDOW_HEIGHT - 105;
        pos = [left top width height];
    end

    function pos = bits_position(col)
        width = col_widths(col);
        left = OFFSET_X + sum(col_widths(1:col-1));
        height = 30;
        top = WINDOW_HEIGHT - 105;
        pos = [left top width height];
    end


    function pos = cell_position(row, col)
        OFFSET_Y = WINDOW_HEIGHT - 130;
        width = col_widths(col);
        left = OFFSET_X + sum(col_widths(1:col-1));
        height = 30;
        top = OFFSET_Y - (row - 1) * 30;
        pos = [left top width height];
    end

for col = 1:size(col_headers, 2)
    uicontrol(fh,'Style','text',...
        'HorizontalAlignment', 'center',...
        'BackgroundColor', BG_COLOR,...
        'String',col_headers{col},...
        'Position', header_position(col))
end

for item = 1:size(sub_headers, 2)
    col = item+1;
    uicontrol(fh,'Style','text',...
        'HorizontalAlignment', 'center',...
        'BackgroundColor', BG_COLOR,...
        'String',sub_headers{item},...
        'Position', sub_position(col))
end

for item = 1:size(bits_headers, 2)
    col = item+5;
    uicontrol(fh,'Style','text',...
        'HorizontalAlignment', 'center',...
        'BackgroundColor', BG_COLOR,...
        'String',bits_headers{item},...
        'Position', bits_position(col))
end


% data cells
    function color = row_color(row)
        if mod(floor((row - 1)/3), 2) == 1
            color = BG_COLOR;
        else
            color = [1 1 1] * 0.9;
        end
    end

table = {};
for row = 1:19
    for col = 1:size(col_headers, 2)
        if col == 1
            val = row;
        else
            val = [];
        end
        table{row, col} = uicontrol(fh,'Style','text',...
            'HorizontalAlignment', 'center',...
            'BackgroundColor', row_color(row),...
            'String', val,...
            'Position', cell_position(row, col));
    end
end

update_crate_channel()


%  Callbacks for MYGUI
    function update_table(hObject, eventdata)
        first_sample_nr = 1 + floor((100 - get(slider, 'Value')) * 360/100);
        for row = 1:size(table, 1)
            sample_nr = first_sample_nr + (row - 1);
            for col = 1:size(table, 2)
                if sample_nr <= 360
                    set(table{row, col}, 'Visible', 'on');
                else
                    set(table{row, col}, 'Visible', 'off');
                end
                if col == 1
                    val = sample_nr;
                else
                    sample = get_sample(sample_nr);
                    if isempty(sample)
                        val = [];
                    else
                        switch col
                            case 2
                                %pdu ticks
                                val = int2str((sample(3) - 7)/2);
                            case 3
                                %delays nsecs
                                val = int2str(sample(3) * 4.2);
                            case 4
                                %beamcode
                                val = bitand(bitshift(sample(4), -8), hex2dec('0000001f'));
                            case 5
                                %timeslot
                                val = bitand(bitshift(sample(7), -29), hex2dec('00000007'));
                            case 12
                                %pulse id
                                val = epicsTs2PulseId(sample(11));
                            case 13
                                % status
                                status = sample(1);
                                
                                val = dec2hex(status);
                                set(table{row, col}, 'ForegroundColor', status_color(status));
                            otherwise
                                %modifier bits
                                val = dec2hex(sample(15-col), 8);
                        end
                    end
                end
                set(table{row, col}, 'String', val);
            end
        end
    end

    function update_crate_channel(hObject, eventdata)
        try
            crate_pv = get_crate_pv();
            min_crate = lcaGet([crate_pv '.LOPR']);
            max_crate = lcaGet([crate_pv '.HOPR']);
            vals = num2cell(min_crate:max_crate);
            set(crate_popupmenu, 'String', vals);

            channel_pv = get_channel_pv();
            min_channel = lcaGet([channel_pv '.DRVL']);
            max_channel = lcaGet([channel_pv '.DRVH']);
            vals = num2cell(min_channel:max_channel);
            set(channel_popupmenu, 'String', vals);
        catch
            err = lasterror;
            disp(err.message);
        end
    end

    function blink_collecting_text()
        if strcmp(get(collecting_text, 'Visible'), 'off')
            set(collecting_text, 'Visible','on');
        else
            set(collecting_text, 'Visible','off');
        end
    end

    function collect_data(hObject, eventdata)
        if strcmp(get(collect_data_button, 'String'), 'Stop')
            set(collect_data_button, 'String', 'Collect data');
            return
        else
            set(collect_data_button, 'String', 'Stop');
        end
        blink_collecting_text();
        pause(0.1);

        data_pv = get_data_pv();
        [val, previous_ts] = lcaGet(data_pv);

        crates = get(crate_popupmenu, 'String');
        crate = crates{get(crate_popupmenu, 'Value')};
        channels = get(channel_popupmenu, 'String');
        channel = channels{get(channel_popupmenu, 'Value')};

        lcaPut(get_crate_pv(), crate);
        lcaPut(get_channel_pv(), channel);
        lcaPut([get_data_pv() '.PROC'], 1);

        while strcmp(get(collect_data_button, 'String'), 'Stop')
            blink_period = 0.5;
            i = 0;
            while i < blink_period * 4
                try
                    % is GUI up?
                    get(fh, 'Visible');
                    blink_collecting_text();
                    i = i + blink_period;
                    pause(blink_period);
                catch
                    return;
                end
            end
            [waveform, ts] = lcaGet(data_pv);
            if real(ts) ~= real(previous_ts) || imag(ts) ~= imag(previous_ts)
                set(fh, 'UserData', waveform);
                
                update_table();
                
                ts = epics2matlabTime(waveform(3), waveform(4));
                set(timestamp_text, 'String', datestr(ts, 'mm/dd/yy HH:MM:SS.FFF'));
                
                overall_status = waveform(5);
                str = sprintf('Overall status: %s', dec2hex(overall_status));
                set(overall_status_text, 'String', str);
                set(overall_status_text, 'ForegroundColor', status_color(overall_status));
                break;
            end
        end
        set(collecting_text, 'Visible', 'off');
        set(collect_data_button, 'String', 'Collect data');
        

    end

     function my_closereq(hObject, eventdata)
        util_appClose(hObject);
     end

set(slider, 'Callback', {@update_table});
set(location_popupmenu, 'Callback', {@update_crate_channel});
set(collect_data_button, 'Callback', {@collect_data});
set(fh,'CloseRequestFcn',{@my_closereq});

%  Utility functions for MYGUI
    function sample = get_sample(sample_nr)
        waveform = get(fh, 'UserData');
        if isempty(waveform)
            sample = [];
            return
        end
        OFFSET = 6;
        SIZE = 11;
        first = OFFSET + (sample_nr - 1) * SIZE;
        last = first + SIZE - 1;
        sample = waveform(first:last);
    end

    function pv = get_crate_pv()
        pv = sprintf('PDU:%s:CV01:CRATE_SELECT', LOCATIONS{get(location_popupmenu, 'Value')});
    end

    function pv = get_channel_pv()
        pv = sprintf('PDU:%s:CV01:CHAN_SELECT', LOCATIONS{get(location_popupmenu, 'Value')});
    end

    function pv = get_data_pv()
        pv = sprintf('PDU:%s:CV01:DATA', LOCATIONS{get(location_popupmenu, 'Value')});
    end

    function pulseId = epicsTs2PulseId(tsNsecs)
        pulseId = bitand(uint32(tsNsecs), hex2dec('1FFFF'));
    end

    function matlabTS = epics2matlabTime(epicsTSSecs, epicsTSNSecs)
        if usejava('jvm')
            tz = java.util.TimeZone.getDefault();
            % See http://java.sun.com/j2se/1.5.0/docs/api/java/util/TimeZone.html#getOffset(long)
            timeDiffToUTCInHours = tz.getOffset(epicsTSSecs*1000)/(60*60*1000);
        else
            timeDiffToUTCInHours = 0;
        end

        % Seconds between January 1st, 0000, which is when MATLAB time starts, and January 1st 1970,
        % which is when labCA time starts
        dOffsetInDays = datenum(1990, 01, 01, 0, 0, 0);
        dOffsetInSecs = dOffsetInDays * 24 * 60 * 60;


        matlabTSInSecs = dOffsetInSecs + epicsTSSecs + epicsTSNSecs / 10 ^ 9 + timeDiffToUTCInHours * 60 * 60;
        %in days
        matlabTS = matlabTSInSecs/(24 * 60 * 60);
    end

    function c = status_color(status)
        if bitand(status, 1)
            c = [52 114 53]/255; %green
        else
            c = [1 0 0]; %red
        end
    end
end
