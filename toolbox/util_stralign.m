function s = util_stralign ( t, w, m )
% UTIL_STRALIGN writeS string, t, to a string of width w.
%        The parameter m should be one of [ 'l', 'c', 'r' ]
%        and determines string alignment.
%        m = 'r' is assumed as default.
%
%        Examples:
%           s = util_stralign ( 'abc', 5, 'l' ) => s = 'abc  '
%          
%           s = util_stralign ( 'abc', 5, 'c' ) => s = ' abc '
%          
%           s = util_stralign ( 'abc', 5, 'r' ) => s = '  abc'
%          
%           s = util_stralign ( 'abc', 2, 'l' ) => s = 'ab'
%          
%           s = util_stralign ( 'abc', 1, 'l' ) => s = 'a'
%          
%           s = util_stralign ( 'abc', 1, 'c' ) => s = 'b'
%          
%           s = util_stralign ( 'abc', 1, 'r' ) => s = 'c'
%          
% Last Modified by HDN on 02-Feb-2008

s = ' ';
n = length ( t );

if ( n < 1 || w < 1 )
    return;
end

s = char ( zeros ( 1, w ) + 32 );
c = min ( w, n );
b = floor ( ( w - c ) / 2 );
d = floor ( ( n - c ) / 2 );

if ( m == 'l' )
    s1 = 1;
    s2 = c;
    t1 = 1;
    t2 = c;
elseif ( m == 'c' )
    s1 = b + 1;
    s2 = b + c;
    t1 = d + 1;
    t2 = d + c;
else
    s1 = w - c + 1;
    s2 = w;
    t1 = n - c + 1;
    t2 = n;
end

s ( s1 : s2 ) = t ( t1 : t2 );
%fprintf ( '"%s"\n', s );
end
