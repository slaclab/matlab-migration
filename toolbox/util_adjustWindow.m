function varargout = util_adjustWindow ( functn, varargin )
% util_adjustWindow allows to properly change the length of the window
%       as well as its position on the screen.
%           
%       Usage:
%           position = util_adjustWindow ( 'getPosition',    hObject, units );
%                      util_adjustWindow ( 'setPosition',    hObject, units, position );
%                      util_adjustWindow ( 'resizeWindow',   hObject, units, dY );
%                      util_adjustWindow ( 'positionWindow', hObject, x_pct, y_pct );
%
%           hObject  : window handle
%           units    : string       => 'pixels', 'characters'
%           position : double array => [ x, y, with, height]
%           dY       : double       => requested window height change
%           x_pct    ; double       => new horizontal window position in percent of
%                                       available screen width.
%           y_pct    ; double       => new vertical window position in percent of
%                                       available screen width.
%
%   Last edited by Heinz-Dieter Nuhn 03/25/2008

callback        = str2func ( functn );
varargout { 1 } = NaN;

if ( nargout )
    switch nargin
        case 2
            varargout { 1 } = callback ( varargin { 1 } );
        case 3
            varargout { 1 } = callback ( varargin { 1 }, varargin { 2 } );
        case 4
            varargout { 1 } = callback ( varargin { 1 }, varargin { 2 }, varargin { 3 } );
    end
else
    switch nargin
        case 2
            callback ( varargin { 1 } );
        case 3
            callback ( varargin { 1 }, varargin { 2 } );
        case 4
            callback ( varargin { 1 }, varargin { 2 }, varargin { 3 } );
    end
end

end


function positionWindow ( hObject, x_pct, y_pct )
% positonObject moves the Object defined by handle hObject
%       relative the screen to location x_pct, y_pct.
%       The coordinates are defined as percentages of the avalailable
%       screen position area, i.e. by the extreme postions of the Windows
%       which still keeps the Title bar inside the screen area.

global Xwin32;

if ( Xwin32 )
    yTitleBar        =  18;
    xBorder          =   8;
    yBorder          =   8;
else
    yTitleBar        =   0;
    xBorder          =   4;
    yBorder          =  12;
end

x_pct            = min ( 100, max ( 0, x_pct ) );
y_pct            = min ( 100, max ( 0, y_pct ) );

screenSize       = get ( 0, 'ScreenSize' );
windowSize       = getPosition ( hObject, 'pixels' );

screenWidth      = screenSize ( 3 );
screenHeight     = screenSize ( 4 );

if ( Xwin32 )
    windowWidth      = windowSize ( 3 ) + xBorder;
    windowHeight     = windowSize ( 4 ) + yBorder;

    xLftCtr          =              + windowWidth  / 2 + xBorder;
    xRgtCtr          = screenWidth  - windowWidth  / 2 + xBorder + 1;
    yTopCtr          =              + windowHeight / 2 - 18;
    yBtmCtr          = screenHeight - windowHeight / 2 - 18 - yTitleBar - 1;
else
    windowWidth      = windowSize ( 3 ) + xBorder;
    windowHeight     = windowSize ( 4 ) + yBorder;

    xLftCtr          =                xBorder + windowWidth  / 2;
    xRgtCtr          = screenWidth  - xBorder - windowWidth  / 2;
    yTopCtr          =                yBorder + windowHeight / 2;
    yBtmCtr          = screenHeight - yBorder - windowHeight / 2;
end

xRgtCtr          = max ( xRgtCtr, xLftCtr );
yBtmCtr          = max ( yBtmCtr, yTopCtr );

xNewCtr          = ( xRgtCtr - xLftCtr ) * x_pct / 100 + xLftCtr;
yNewCtr          = ( yBtmCtr - yTopCtr ) * y_pct / 100 + yTopCtr;

if ( Xwin32 )
    newPos ( 1 )     = xNewCtr - windowWidth  / 2;
    newPos ( 2 )     = yNewCtr - windowHeight / 2;
else
    newPos ( 1 )     = xNewCtr - windowWidth  / 2;
    newPos ( 2 )     = yNewCtr - windowHeight / 2;
end

newPos ( 3 )     = windowSize ( 3 );
newPos ( 4 )     = windowSize ( 4 );

setPosition ( hObject, 'pixels', newPos );

end


function resizeWindow ( hObject, units, dY )
% resizeWindow changes the height of window hObject by dY up
%           to the available screen size and corrects the
%           positions of all objects that it contains.
%

global Xwin32;

if ( Xwin32 )
    yTitleBar        =  24;
else
    yTitleBar        =   0;
end

screenSize       = get ( 0, 'ScreenSize' );
curPosition      = getPosition ( hObject, units );
screenHeight     = screenSize  ( 4 );
windowHeight     = curPosition ( 4 );
%reqWindowHeight  = windowHeight + dY;
newHeight        = max ( 100, min ( screenHeight - yTitleBar, windowHeight + dY ) );
deltaY           = newHeight - windowHeight;

if ( deltaY ~= 0 )
    curPosition ( 4 ) = curPosition ( 4 ) + deltaY;
    setPosition ( hObject, units, curPosition );

    allObjects  = findobj ( hObject );
    nObjects    = length ( allObjects );

    for j = 1 : nObjects
        obj = allObjects ( j );
        
        if ( obj ~= hObject )
            curPosition       = getPosition ( obj, units );
%            fprintf ( 'obj #%d [%6.4f/%6.4f] Tag: "%s" y = %9.4f', j, hObject, obj, get ( obj, 'Tag' ), curPosition ( 2 ) );
            curPosition ( 2 ) = curPosition ( 2 ) + deltaY;
%            fprintf ( '; set to y = %9.4f\n', curPosition ( 2 ) );
            setPosition ( obj, units, curPosition );
        end
    end
end

end


function setPosition ( hObject, units, position )
    savedUnits = get ( hObject, 'Units' );
    set ( hObject, 'Units', units );
    set ( hObject, 'Position', position );
    set ( hObject, 'Units', savedUnits );
end


function position = getPosition ( hObject, units )
    savedUnits = get ( hObject, 'Units' );
    set ( hObject, 'Units', units );
    position = get ( hObject, 'Position' );
    set ( hObject, 'Units', savedUnits );
end


