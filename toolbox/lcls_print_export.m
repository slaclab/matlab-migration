%
% lcls_print_export(fig,print_gui,title_string)
%
%    The function opens a modal print/export dialog in which the user
%    can choose between several types of output. If the user presses OK,
%    an output file will be generated or the given figure will be printed,
%    respectively.
%
%    The function is platform-aware and will automatically use the UNIX
%    or Windows printing system.
%
%    Currently the following output formats are supported:
%    - EPS file
%    - TIFF file
%    - LCLS logbook
%    - printer
%
% PARAMETERS
%   fig          - Handle of the Matlab figure to be printed;
%                  if no handle is given, the current figure is printed.
%   print_gui    - (optional) If this parameter is given and true, GUI
%                  elements like buttons will be included in the output.
%                  Otherwise, they are discarded.
%   title_string - (optional) A title that will appear in the headline of
%                  a logbook entry, or on the cover sheet of a printout.
%
% EXAMPLES
%   lcls_print_export                - Print/export the current figure.
%   lcls_print_export(fig)           - Print/export the figure specified by
%                                     the handle fig.
%   lcls_print_export(fig,true)      - Print/export the figure specified by
%                                     the handle fig, including GUI elements
%                                     like buttons etc.
%   lcls_print_export(fig,'abc')     - Print/export fig with the title 'abc'.
%   lcls_print_export(fig,true,'ab') - Print/export fig with the title 'ab',
%                                     including GUI.
%
function varargout = lcls_print_export(varargin)
   global lcls_print_export_cf;

   % Before we build our own (dialog) window: Determine the
   % current figure in case the user does not give us another
   % figure handle.
   lcls_print_export_cf = get(0, 'CurrentFigure');


   % Begin initialization code - DO NOT EDIT
   gui_Singleton = 1;
   gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @lcls_print_export_OpeningFcn, ...
                       'gui_OutputFcn',  @lcls_print_export_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
	if nargin && isstr(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
	end
	
	if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
        gui_mainfcn(gui_State, varargin{:});
	end
	% End initialization code - DO NOT EDIT

return






% A dummy.
function lcls_print_export_OutputFcn(hObject, eventdata, handles, varargin)
return


%%%%%
% Executes just before lcls_print_export is made visible.
%%%%%
function lcls_print_export_OpeningFcn(hObject, eventdata, handles, varargin)
   global default_printer;
   global lcls_print_export_selection;
   global lcls_print_gui lcls_title_string;
   global lcls_print_export_cf;


   if (length(varargin)<1)                    % If no parameter given,
      target_figure = lcls_print_export_cf;   %   use the current figure,
      if (isempty(lcls_print_export_cf))      %   if there is one.
         disp('lcls_print_export: Found no figure to print.');
         close(hObject);
         return;
      end
   else
	  target_figure = varargin(1);
   end

	if (iscell(target_figure))
		target_figure = cell2mat(target_figure);
	end

	if (~ishandle(target_figure))
		disp('lcls_print_export: This is not a valid figure handle.');
		delete(hObject);
		return;
	end

   % Check whether to include GUI elements in the output.
	if (length(varargin) >= 2)
   	lcls_print_gui = false;
      for i = 2:length(varargin)
   		if (islogical(varargin{i}) || isnumeric(varargin{i}))
   			if (varargin{i})
			   	lcls_print_gui = true;
               break;
			end
   		end
      end
      
      % Look if there is a title for the printout
      lcls_title_string = 'lcls print/export output';
      for i = 2:length(varargin)
		if (ischar(varargin{i}))
            lcls_title_string = varargin{i};
            break;
		end
      end
   end
      
	% Store our handles structure and the handle of the figure we are
	% to print/export within the figure's data space.
	handles.target_figure = target_figure;
	guidata(hObject, handles);

	% If no default printer has been set so far, try to get it from the environment.
	if (isempty(default_printer))
		default_printer = getenv('PRINTER');
	end
	
	% if that didn't work, use the elogbook
	if (isempty(default_printer))
		default_printer = 'lclslog';
	elseif (default_printer(end) == '=')
		% I've sometimes seen a '=' at the end of the environment variable,
		% and as I don't know where this comes from and suspect that it
		% doesn't do any good, I remove it...
		default_printer = default_printer(1:end-1);
	end

	% Make sure the print/export dialog shows only options the current platform supports.
	% The dialog is pre-configured for the Windows printing environment,
	% so we just need to change anything if we are running under UNIX.
	if (isunix)
		set(handles.radioLCLSlog, 'Enable', 'on');
		set(handles.editPrinter, 'String', default_printer);
      
      % If there is no other user preference and the default printer is
      % 'lclslog', select the appropriate radio button.
      if (isempty(lcls_print_export_selection) ...
          && strcmp(default_printer, 'lclslog'))
         lcls_print_export_selection = 3;
      end
	end

	% If this function has been used previously and there is a hint
	% which button should be pre-selected, make it so.
	preselected_button = id2handle(handles, lcls_print_export_selection);
   % If there is no other preselection, select lclslog on UNIX and Printer on Win
   if (preselected_button == -1)
      if (isunix)
   		preselected_button = handles.radioLCLSlog;
      else
         preselected_button = handles.radioPrinter;
      end
   end
   set(preselected_button, 'Value', 1);
   
   % Simulate a click on the preselected button
   radio_Callback(preselected_button, [], handles);
   

	% Determine the position of the dialog - centered on the callback figure
	% if available, else, centered on the screen
	FigPos=get(0,'DefaultFigurePosition');
	OldUnits = get(hObject, 'Units');
	set(hObject, 'Units', 'pixels');
	OldPos = get(hObject,'Position');
	FigWidth = OldPos(3);
	FigHeight = OldPos(4);
	if isempty(gcbf)
		ScreenUnits=get(0,'Units');
		set(0,'Units','pixels');
		ScreenSize=get(0,'ScreenSize');
		set(0,'Units',ScreenUnits);

		FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
		FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
	else
		GCBFOldUnits = get(gcbf,'Units');
		set(gcbf,'Units','pixels');
		GCBFPos = get(gcbf,'Position');
		set(gcbf,'Units',GCBFOldUnits);
		FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
							(GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
	end
	FigPos(3:4)=[FigWidth FigHeight];
	set(hObject, 'Position', FigPos);
	set(hObject, 'Units', OldUnits);

	% Make the GUI modal
	set(handles.figurePrintExport,'WindowStyle','modal')

	% UIWAIT makes lcls_print_export wait for user response
	uiwait(handles.figurePrintExport);
return




%%%%%
% A key has been pressed.
%%%%%
function figurePrintExport_KeyPressFcn(hObject, eventdata, handles)
	key = get(handles.figurePrintExport, 'CurrentCharacter');

	switch (key)
		case 27		% ESC -> Abort
			abort_Callback(hObject,eventdata,handles);
		case 13		% Return -> OK
			OK_Callback(hObject,eventdata,handles);
	end
return


%%%%%
% The user has clicked OK, so let's go ahead and print or export the figure.
%%%%%
function OK_Callback(hObject, eventdata, handles)
	global default_printer;
	global lcls_print_export_path;
	global lcls_print_export_selection;
	global lcls_print_gui lcls_title_string;
	
	% Determine which button has been selected
	sel = get_selected_radiobuttons(handles);
	if (length(sel) ~= 1)
		disp('Selection error.');
		return;
	else
		sel_handle = sel(1);
		lcls_print_export_selection = handle2id(handles, sel_handle);
   end

   fig_status = show_status_window(handles);
   
	% If it's not a real printer, let's set the paper size to
    % the size of the figure and say "landscape orientation"
	if (sel_handle ~= handles.radioPrinter)
      old_units = get(handles.target_figure, 'Units');
      old_figure_size = get(handles.target_figure, 'Position');
      
      set(handles.target_figure, 'Units', 'centimeters');
      figure_size = get(handles.target_figure, 'Position');
      set(handles.target_figure, 'Units', old_units);
      figure_size(1) = 1;
      figure_size(2) = 1;

      set(handles.target_figure, 'PaperPositionMode', 'manual', ...
                                 'PaperUnits', 'centimeters', ...	
                                 'PaperSize', [figure_size(3), figure_size(4)], ...
                                 'PaperOrientation', 'landscape', ...
                                 'PaperPosition', figure_size);
    end

	% Should we print GUI elements?
	if (lcls_print_gui)
		uiparam = '';
		refresh(handles.target_figure);	% Remove trash from our dialog box.
	else
		uiparam = '-noui';
	end

	% Print / export
	switch (sel_handle)
		
		case handles.radioEPS
			
			if (isempty(lcls_print_export_path))
				lcls_print_export_path = '.';
			end

			% Let's display a file selector...
			old_dir = pwd;
			cd(lcls_print_export_path);
			[filename,pathname] = uiputfile({'*.eps', 'Encapsulated Postscript (*.eps)'}, ...
														'Save plot as');
			cd(old_dir);

			% Not aborted?
			if (filename ~= 0)
				lcls_print_export_path = pathname;
                filename = fullfile(pathname, filename);

                print(handles.target_figure, uiparam, '-depsc2', filename);	% Save it.
            end

		case handles.radioTIFF
			
			if (isempty(lcls_print_export_path))
				lcls_print_export_path = '.';
			end

			% Let's display a file selector...
			old_dir = pwd;
			cd(lcls_print_export_path);
			[filename,pathname] = uiputfile({'*.tiff;*.tif', 'Tagged Image File Format (*.tiff,*.tif)'}, ...
											 'Save plot as');
			cd(old_dir);

			% Not aborted?
			if (filename ~= 0)
				lcls_print_export_path = pathname;
                filename = fullfile(pathname, filename);

                print(handles.target_figure, uiparam, '-dtiff', '-r90', filename);	% Save it.
            end

		case handles.radioLCLSlog

            print_with_title(handles.target_figure, 'lclslog', lcls_title_string, uiparam);
			
		case handles.radioPrinter

			if (isunix)																	% UNIX?
				printer = cutstr(get(handles.editPrinter, 'String'));		% ... check for a valid printer name.
				if (~isempty(printer))
					default_printer = printer;
				else
			      uiwait(msgbox('Please specify a valid printer name.', ...
              			        'No printer selected', 'warn', 'modal'));
					set(handles.editPrinter, 'String', default_printer);
					return;
				end
			end

			% We just trust the user has made the right decision on
			% PaperPosition etc., so now we can print :-)
			if (ispc)
				print(handles.target_figure, uiparam, '-dwinc');
            else
                print_with_title(handles.target_figure, printer, lcls_title_string, uiparam);
			end

	end	% switch ...

	% After printing, reset the figure to its default behaviour.
	set(handles.target_figure, 'PaperPositionMode', 'auto');

	% After successful printing, remove the status and the dialog box.
    if (ishandle(fig_status)),                delete(fig_status);                 end
	if (ishandle(handles.figurePrintExport)), delete(handles.figurePrintExport);  end
return


%%%%%
% The user has clicked Abort, pressed ESC or closed the dialog window.
%%%%%
function abort_Callback(hObject, eventdata, handles)
	delete(handles.figurePrintExport);
return


%%%%%
% Handle the radio buttons
%%%%%
function radio_Callback(handle_new_sel, eventdata, handles)
	%%%
	% Deselect the previously selected buttons.
	%%%
	for handle = get_selected_radiobuttons(handles)
		set(handle, 'Value', 0);
		% The "Printer" selection needs to disable some buttons and edit fields.
		if (handle == handles.radioPrinter)
			set(handles.buttonPrinterSetup, 'Enable', 'off');
            set(handles.buttonPageSetup, 'Enable', 'off');
            set(handles.editPrinter, 'Enable', 'off');
        end
	end
	
	%%%
	% Now select the new button.
	%%%
	set(handle_new_sel, 'Value', 1);
	
	% The "Printer" selection also needs to enable some buttons and edit fields.
	if (handle_new_sel == handles.radioPrinter)
      set(handles.buttonPageSetup, 'Enable', 'on');
      if (ispc)
   		set(handles.buttonPrinterSetup, 'Enable', 'on');
      end
		if (isunix)
			set(handles.editPrinter, 'Enable', 'on');
		end
	end
return


%%%%%
% Retrieve the handles of the currently selected radiobuttons.
% If none selected, [] is returned.
%%%%%
function ret_handles = get_selected_radiobuttons(handles)
	ret_handles = [];
	for handle = [handles.radioEPS, handles.radioTIFF, ...
				handles.radioLCLSlog, ...
				handles.radioPrinter]
		if (get(handle, 'Value') ~= 0)
			ret_handles = [ret_handles handle];
		end
	end
return


%%%%%
% Invoke a printer setup dialog. Let Matlab decide whether to use Windows'
% built-in dialog or the cross-platform Matlab one.
%%%%%
function buttonPrinterSetup_Callback(hObject, eventdata, handles)
	printdlg('-setup', handles.target_figure);
return


%%%%%
% Executes on button press in buttonPageSetup.
function buttonPageSetup_Callback(hObject, eventdata, handles)
   pagesetupdlg(handles.target_figure);
return


%%%%%
% Function to convert a Matlab radiobutton handle to an internal ID.
% Returns -1 on failure.
%%%%%
function id = handle2id(handles, radiobutton_handle)
	if (nargin~=2 || ~isstruct(handles) || length(radiobutton_handle)~=1 || ~ishandle(radiobutton_handle))
		id = -1;
		return;
	end

	switch (radiobutton_handle)
		case handles.radioEPS
			id = 1;			
		case handles.radioTIFF
			id = 2;
		case handles.radioLCLSlog
			id = 3;
		case handles.radioPrinter
			id = 5;
		otherwise
			id = -1;
			fprintf('lcls_print_export: Invalid radio button handle %f .\n', radiobutton_handle);
	end
return


%%%%%
% Function to convert an internal ID to a Matlab radiobutton handle.
% Returns -1 on failure.
%%%%%
function radiobutton_handle = id2handle(handles, id)
	if (nargin~=2 || ~isstruct(handles) || length(id)~=1 || ~isnumeric(id))
		radiobutton_handle = -1;
		return;
	end
	
	switch (id)
		case 1
			radiobutton_handle = handles.radioEPS;
		case 2
			radiobutton_handle = handles.radioTIFF;
		case 3
			radiobutton_handle = handles.radioLCLSlog;
		case 5
			radiobutton_handle = handles.radioPrinter;
		otherwise
			radiobutton_handle = -1;
			fprintf('lcls_print_export: Invalid radio button ID %d .\n', id);
	end
return


%%%%%
% cut off leading & trailing spaces from a string
%%%%%
function str = cutstr(str)
	str = deblank(str);		% removes trailing spaces
	while (~isempty(str) && str(1)==' ')
		str(1) = [];
	end
return


%%%%%
% Print a given figure to a given printer using a given title.
%%%%%
function print_with_title(fig, printer_name, title_string, uiparam)
   if (isunix)
      tmpfile = [ '/tmp/' datestr(now,'yyyy-mm-dd-HHMMSS') '-lcls_print_export-tmp.eps' ];
      try
		 print(fig, uiparam, '-depsc2', '-loose', tmpfile);
         if (isempty(title_string))
            title_string = 'no title';
         end
         unix(['lp -c -t ''' title_string ''' -d ' printer_name ' ' tmpfile]);
         delete(tmpfile);
      end
   else
      print(fig, uiparam, '-dwinc');
   end
return


%%%%%
% Hide the Print/Export figure and show a status
% window instead.
%%%%%
function fig_status = show_status_window(handles)
   set(handles.figurePrintExport, 'Visible', 'off');
   units = get(handles.figurePrintExport, 'Units');
   set(handles.figurePrintExport, 'Units', 'characters');
   pos = get(handles.figurePrintExport, 'Position');
   set(handles.figurePrintExport, 'Units', units);
   % Open a new status window and center it within the Print/Export figure
   pos = [ pos(1) + (pos(3) - 35) / 2, ...
           pos(2) + (pos(4) - 3) / 2, ...
           35, 3 ];
   fig_status = figure( 'NumberTitle', 'off', 'Name', 'Print/Export', ...
                        'Units', 'characters', 'Position', pos, ...
                        'MenuBar', 'none', 'Resize', 'off', ...
                        'ToolBar', 'none', 'WindowStyle', 'modal', ...
                        'Color', get(0, 'DefaultUIcontrolBackgroundColor'));
   uicontrol('Style', 'text', 'Units', 'characters', 'Position', [0, 1, pos(3), 1], ...
                        'String', 'Printing/saving...', 'HorizontalAlignment', 'center', ...
                        'FontWeight', 'bold');
   pause(0.01);
return
