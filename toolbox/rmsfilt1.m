function y = rmsfilt1(x,n,blksz,DIM)
%rmsFILT1  One dimensional std filter.
%   Y = rmsFILT1(X,N) returns the output of the order N, one dimensional
%   std filtering of X.  Y is the same size as X; for the edge points,
%   zeros are assumed to the left and right of X.  If X is a matrix,
%   then rmsFILT1 operates along the columns of X.
%
%   If you do not specify N, rmsFILT1 uses a default of N = 3.
%   For N odd, Y(k) is the std of X( k-(N-1)/2 : k+(N-1)/2 ).
%   For N even, Y(k) is the std of X( k-N/2 : k+N/2-1 ).
%
%   Y = rmsFILT1(X,N,BLKSZ) uses a for-loop to compute BLKSZ ("block size") 
%   output samples at a time.  Use this option with BLKSZ << LENGTH(X) if 
%   you are low on memory (rmsFILT1 uses a working matrix of size
%   N x BLKSZ).  By default, BLKSZ == LENGTH(X); this is the fastest
%   execution if you have the memory for it.
%
%   For matrices and N-D arrays, Y = rmsFILT1(X,N,[],DIM) or 
%   Y = rmsFILT1(X,N,BLKSZ,DIM) operates along the dimension DIM.
%
%   See also std, FILTER, SGOLAYFILT, and MEDFILT2 in the Image
%   Processing Toolbox.

% Copy from medfilt1.m

% Validate number of input arguments
error(nargchk(1,4,nargin));
if nargin < 2, n = []; end
if nargin < 3, blksz = []; end
if nargin < 4, DIM = []; end

% Check if the input arguments are valid
if isempty(n)
  n = 3;
end

if ~isempty(DIM) && DIM > ndims(x)
	error('Dimension specified exceeds the dimensions of X.')
end

% Reshape x into the right dimension.
if isempty(DIM)
	% Work along the first non-singleton dimension
	[x, nshifts] = shiftdim(x);
else
	% Put DIM in the first (row) dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [DIM,1:DIM-1,DIM+1:ndims(x)];
	x = permute(x,perm);
end

% Verify that the block size is valid.
siz = size(x);
if isempty(blksz),
	blksz = siz(1); % siz(1) is the number of rows of x (default)
else
	blksz = blksz(:);
end

% Initialize y with the correct dimension
y = zeros(siz); 

% Call rmsfilt1D (vector)
for i = 1:prod(siz(2:end)),
	y(:,i) = rmsfilt1D(x(:,i),n,blksz);
end

% Convert y to the original shape of x
if isempty(DIM)
	y = shiftdim(y, -nshifts);
else
	y = ipermute(y,perm);
end


%-------------------------------------------------------------------
%                       Local Function
%-------------------------------------------------------------------
function y = rmsfilt1D(x,n,blksz)
%rmsFILT1D  One dimensional std filter.
%
% Inputs:
%   x     - vector
%   n     - order of the filter
%   blksz - block size

nx = length(x);
if rem(n,2)~=1    % n even
    m = n/2;
else
    m = (n-1)/2;
end
X = [zeros(m,1); x; zeros(m,1)];
y = zeros(nx,1);

% Work in chunks to save memory
indr = (0:n-1)';
indc = 1:nx;
for i=1:blksz:nx
    ind = indc(ones(1,n),i:min(i+blksz-1,nx)) + ...
          indr(:,ones(1,min(i+blksz-1,nx)-i+1));
    xx = reshape(X(ind),n,min(i+blksz-1,nx)-i+1);
    y(i:min(i+blksz-1,nx)) = std(xx,1);
end
