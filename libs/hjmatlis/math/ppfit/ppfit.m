function pp = ppfit(varargin)
% ppfit            Fit a piecewise polynomal, i.e. ppform, to points (x,y)
%                  The points will be approximated by N polynomials, given in
% the pp-form (piecewise polynomial). ex: fnplt(pp); % to plot results
%
% pp = ppfit(x, y, breaks);
% pp = ppfit(x, y, breaks, ord, [], 'v');
% pp = ppfit(x, y, breaks, ord, cprop, fixval);
% pp = ppfit(x, y ,breaks, ord, cprop, fixval, 'p', 'v');
% pp = ppfit(x, y ,breaks, ord, cprop, fixval, 'p', 'v', weight);
%--------------------------------------------------------------------------
% arguments:
%   x        - the x values of which the function is given, size Lx1
%   y        - the function value for the corresponding x, size Lx1
%   breaks   - break sequence (knots), the start and end points for 
%              the N polynomials as a vector of length (N+1). 
%              Values of x should be within range of breaks: 
%              min(breaks) <= x(i) <= max(breaks)
%              A scalar N may be given to set the number of polynomials.
%   ord      - order of each polynomial, a vector of length N or a scalar 
%              1 (constant), 2 (linear), 3 (quadratic), 4 (cubic) (default)
%   cprop    - continuity properties, a vector of length (N-1) or N or a
%              scalar. Note that cprop(i) gives continuity at end of piece
%              i, at breaks(i+1). 
%                0 - no continuity for breaks(i+1)
%                1 - continuity (default), 
%                2 - also continuious first derivate, 
%                3 - also continuious second derivate.
%  argument 6 and onward may be in any order, they may be: 
%              fixval, numeric and size Kx3, gives fixed values for pp
%                fixval(k,1) is the x-value, must be within range of breaks.
%                fixval(k,2) the y-value (or the value of the derivate), and
%                fixval(k,3) is the type or derivate degree, i.e. 0 for value
%                1 for first derivate, 2 for second derivate.
%                if this variable is omitted no fixed values is assumed
%              weight, numeric and size Lx1
%                If this is given what is minimized is the weighted SSE;
%                i.e.    SSEw = sum( (weight.*error).^2 );
%                where   error = y - ppval(pp, x);
%              'p' for periodic, need cprop(N) > 0 to have any effect
%              'v' for verbose, default display only errors/warnings
%                  include fields 'input' and 'fitProp' in output struct
%--------------------------------------------------------------------------
% ex:  res = ppfit('test');   % special test (demo) examples 

%--------------------------------------------------------------------------
% Copyright (c) 2002-2015.  Karl Skretting.  All rights reserved.
% University of Stavanger, TekNat, IDE
% Mail:  karl.skretting@uis.no   Homepage:  http://www.uis.no/~karlsk/
% 
% HISTORY:  dd.mm.yyyy
% Ver. 1.0  15.01.2002  KS: function made as poly_inter_pol 
% Ver. 1.1  09.05.2008  KS: function still works, some modifications
% Ver. 1.2  01.09.2014  KS: function still works, add a try statement
% Ver. 2.0  27.04.2015  KS: changed name to ppfit, and rewritten parts
% Ver. 2.1  13.05.2015  KS: function works (partly)
% Ver. 2.2  07.09.2015  KS: made function simpler 
% Ver. 2.3  21.01.2016  KS: minor updates 
% Ver. 2.4  30.08.2016  KS: thisFirstge local function included 
% Ver. 2.5  06.12.2016  KS: a minor error corrected 
%--------------------------------------------------------------------------


if (nargin == 1) && ischar(varargin{1}) && strcmpi(varargin{1}, 'test')
    pp = thisTest();
    return;
end

if nargin < 3
    error([mfilename,': should at least have three input arguments, see help.']);
end

arg = thisArg(varargin{:});   % check and verify input arguments

if arg.verbose >= 1 
    disp([mfilename,': ',int2str(arg.L),' points (x,y) should be approximated by ',...
        int2str(arg.N),' polynomials.']);
    disp(['   order is in range ',int2str(min(arg.ord)),' to ',int2str(max(arg.ord)),'.']);
    t = ['   continuity properties is in range ',int2str(min(arg.cprop(1:(arg.N-1)))),...
             ' to ',int2str(max(arg.cprop(1:(arg.N-1)))),'.'];
    if arg.periodic
        t = [t,' Periodic continuity = ',int2str(arg.cprop(arg.N))];
    end
    disp(t);
    if (size(arg.fixval,1) > 0)
        disp(['   There are ',int2str(size(arg.fixval,1)), ' additional conditions.']);
    end
end

A = thisBuildA(arg.x, arg.breaks, arg.ord);

[B,c] = thisBuildBc(arg.breaks, arg.ord, arg.cprop, arg.fixval, arg.periodic);

if arg.verbose >= 2    % DEBUG
    disp([mfilename,': have made matrices: ']);
    disp(['   A (',int2str(size(A,1)),'x',int2str(size(A,2)),')', ...
          '   B (',int2str(size(B,1)),'x',int2str(size(B,2)),')', ...
          '   c (',int2str(size(c,1)),'x',int2str(size(c,2)),').']);
end

if (numel(arg.weight) == arg.L)
    u = thisLsq(repmat(arg.weight,1,size(A,2)).*A, arg.weight.*arg.y, B, c); 
else
    u = thisLsq(A, arg.y, B, c); 
end

% now use u to build the pp form
p = max(arg.ord);
N = arg.N;
ci = false(N, p);
for piece = 1:N
    ci(piece,(p - arg.ord(piece) + 1):p) = true;   % used variables
end
coefs = zeros(p,N);   % transposed
coefs(ci') = u;

% pp = ppmak(arg.breaks, coefs', 1);   % curvefit toolbox 
pp = mkpp(arg.breaks, coefs', 1);      % polyfun 'toolbox'

if arg.verbose >= 1
    disp(['   Number of parameters in polynomals is ',int2str(size(A,2))]);
    disp(['   Total number of conditions is ',int2str(size(B,1)), ...
          ' giving ',int2str(size(A,2)-size(B,1)),' free variables.']);
    pp.input = arg;
    pp.fitProp = thisPpFitProp(pp);
    disp([mfilename,': Used ',int2str(pp.pieces),' pieces,  final RMSE is ',num2str(pp.fitProp.rmse)]);
end

if (arg.verbose >= 2)   % DEBUG
    pp.A = A;
    pp.B = B;
    pp.c = c;
    pp.ci = ci;
    pp.u = u;
    % may check by
    % uM = lsqlin(pp.A,pp.input.y,[],[],pp.B,pp.c);
end

return;

%% ----------------------- subfunctions ----------------------
function arg = thisArg(varargin)
% returns struct 'arg' with verified input arguments
% pp = ppfit(x,y,breaks,ord,cprop,fixval);

arg = struct( 'x', [], ... % data x-locations (Lx1)
              'y', [], ... % data y-values (Lx1)
              'L', 0, ...  % number of data points
              'N', 0, ... % number of pieces, polynoms
              'breaks', [], ... %      Breaks (N+1)x1
              'ord', [], ... % Polynomial order, Nx1
              'cprop', [], ... %  Continuity properties, Nx1, last is 0 if not periodic
              'fixval', [], ... % Fixed values, Kx3
              'weight', [], ... % weight, empty or size Lx1 
              'periodic', false, ... %    true or false
              'verbose', 0 );  %  verbose level 0, 1 or 2

% Reshape x-data
x = varargin{1};
x = reshape(x,numel(x),1);
% Reshape y-data
y = varargin{2};
y = reshape(y,numel(y),1);

% Check data size
if numel(x) ~= numel(y)
    error([mfilename,': number of elements in x and y is not the same.']);
end

% Treat NaNs in x-data
xnan = find(isnan(x));
if ~isempty(xnan)
    x(xnan) = [];
    y(xnan) = [];
    warning([mfilename,': ignore NaN in x.']);
end

% Treat NaNs in y-data
ynan = find(isnan(y));
if ~isempty(ynan)
    x(ynan) = [];
    y(ynan) = [];
    warning([mfilename,': ignore NaN in y.']);
end

% Check number of data points
L = numel(x);
if L == 0
    error([mfilename,': no elements in x.']);
end

% Sort data
if any(diff(x) < 0)
    [x,isort] = sort(x);
    y = y(isort);
end

% Breaks
if isscalar(varargin{3})
    % Number of pieces
    N = varargin{3};
    if ~isreal(N) || ~isfinite(N) || (N < 1) || (fix(N) < N)
        error([mfilename,': breaks must be a vector or a positive integer.']);
    end
    %  we want (N+1) break points between x(1) and x(end), x is sorted
    %  distribute break points both uniform and random
    % ex: x = (1:0.1:10)'.^2; N = 10;
    L = numel(x);
    idxu = linspace(1, L, N+1);     % uniform indexes
    idxr = rand(1,N+1);             % some random numbers   
    idxr = 1+(sort(idxr)-min(idxr))*((L-1)/(max(idxr)-min(idxr)));    % range 1  to L
    % idx = 0.5*idxu + 0.5*idxr;      % a mix between uniform and random
    idx = 0.9*idxu + 0.1*idxr;      % uniform plus a little bit random 
    idx_int = floor(idx);           % N+1 elements
    idx_rem = (idx(1:N) - idx_int(1:N));   % the N first, not last element, first is zero
    breaks = [(1-idx_rem).*x(idx_int(1:N))' + idx_rem.*x(idx_int(2:(N+1)))', x(L)];
else
    % Vector of breaks
    breaks = varargin{3};
    N = numel(breaks) - 1;
    breaks = reshape(breaks,N+1,1);
end
% Sort breaks
if any(diff(breaks) < 0)
    breaks = sort(breaks);
end
% Unique breaks
if any(diff(breaks) <= 0)
    breaks = unique(breaks);
    N = numel(breaks)-1;
    disp([mfilename,': ignore duplicate breaks, use ',int2str(N+1),' breaks.']);
end
if isempty(breaks) || (min(breaks) == max(breaks))
    error([mfilename,': At least two unique breaks are required.']);
end

% ord of the polynomials
if (nargin < 4) || isempty(varargin{4})
    ord = 4*ones(N,1);
else
    if numel(varargin{4}) == N
        ord = reshape(floor(varargin{4}),N,1);
    else
        if numel(varargin{4}) > 1
            warning([mfilename,': use only first element of ord (argument 4)']);
        end
        ord = floor(varargin{4}(1))*ones(N,1);
    end
    if any(ord < 1)
        warning([mfilename,': set ord of ',int2str(nnz(ord < 1)),' polynomals to minimal value 1.']);
        ord(ord < 1) = 1;
    end
    if any(ord > 8)
        warning([mfilename,': set ord of ',int2str(nnz(ord > 8)),' polynomals to maximal value 8.']);
        ord(ord > 8) = 8;
    end
end
arg.ord = ord;

% continuity properties at breaks (except first, and perhaps last)
if (nargin < 5) || isempty(varargin{5})
    cprop = ones(N-1,1);
else
    if numel(varargin{5}) == N
        cprop = reshape(floor(varargin{5}),N,1);
    elseif numel(varargin{5}) == (N-1)
        cprop = [reshape(floor(varargin{5}),N-1,1); varargin{5}(end)]; 
    else
        if numel(varargin{5}) > 1
            warning([mfilename,': use only first element of cprop (argument 5)']);
        end
        cprop = floor(varargin{5}(1))*ones(N,1);
    end
    if any(cprop < 0)
        warning([mfilename,': set ',int2str(nnz(cprop < 0)),' neagtive ''cprop''-values to 0.']);
        cprop(cprop < 0) = 0;
    end
end
arg.cprop = cprop;

% Loop over optional arguments
for k = 6:nargin
    a = varargin{k};
    if ischar(a) && isscalar(a) && lower(a) == 'p'
        % Periodic conditions
        arg.periodic = true;
        if numel(cprop) == (N-1)
            arg.cprop = [cprop; cprop(end)];
        end
    elseif ischar(a) && strcmpi(a, 'v0')   % default
        arg.verbose = 0;
    elseif ischar(a) && (strcmpi(a, 'v') || strcmpi(a, 'v1'))
        arg.verbose = 1;
    elseif ischar(a) && strcmpi(a, 'v2')  % only for DEBUG
        arg.verbose = 2;
    elseif isreal(a) && (size(a,2) == 3)
        % fixval array,  
        arg.fixval = a;
    elseif isreal(a) && (size(a,2) == 1) && ((size(a,1) == L) || (size(a,1) == numel(varargin{1})))
        % weight vector,  
        if (size(a,1) ~= L)
            if ~isempty(xnan)
                a(xnan) = [];
            end
            if ~isempty(ynan)
                a(ynan) = [];
            end
        end
        if (size(a,1) == L)
            if exist('isort','var')
                arg.weight = a(isort);
                % warning([mfilename,': x and y and weights were sorted the same way to order x increasingly.']);
            else
                arg.weight = a;
            end
        else
            warning([mfilename,': ignore (weight?) argument ',int2str(k),'.']);
        end            
    else
        warning([mfilename,': ignore argument ',int2str(k),'.']);
    end
end

% chech fixval
if ~isempty(arg.fixval)
    F = arg.fixval;
    F(:,3) = max( floor(F(:,3)), 0);
    F = sortrows(F(:,[1,3,2]));
    if (F(1,1) < breaks(1)) || (F(end,1) > breaks(end))
        disp([mfilename,': ignore fixval-properties outside breaks range.']);
        F = F( (F(:,1) >= breaks(1)) & (F(:,1) <= breaks(end)), :);
    end
    if (size(F,1) >= 2)  % check for duplicates
        for i = 2:size(F,1)
            if (nnz(F(i,1:2) == F(i-1,1:2)) == 2)
                disp([mfilename,': ignore duplicate fixval-properties.']);
                F(i,:) = [];
            end
        end
    end
    arg.fixval = F(:,[1,3,2]);
end

if ~arg.periodic
    arg.cprop(N) = 0;
end

% Check if data are in expected range
h = diff(breaks);
xlim1 = breaks(1) - 0.01*h(1);
xlim2 = breaks(end) + 0.01*h(end);
if x(1) < xlim1 || x(end) > xlim2
    if arg.periodic
        % Move data inside domain
        P = breaks(end) - breaks(1);
        x = mod(x-breaks(1),P) + breaks(1);
        % Sort
        [x,isort] = sort(x);
        y = y(isort);
        if (size(arg.weight,1) == L)
            arg.weight = arg.weight(isort);
        end
    else
        warning([mfilename,': Some data points are outside the domain given by breaks.']);
    end
end

arg.x = x;
arg.y = y;
arg.L = numel(x);
arg.breaks = breaks;
arg.N = N;

return


function u = thisLsq(A,x,B,c)
% Solve   min ||Au - x||_2^2     s.t.  Bu = c
%
% using lsqlin is not quite as robust as wanted (and slower):
% tic; uM = lsqlin(A,x,[],[],B,c); toc
% disp(['Difference between two methods, ||uM - u|| = ',num2str(norm(uM-u))]);

% we supress:  'Warning: Rank deficient, rank =    '
warning('off', 'all');
if numel(B)
%     if issparse(B)
%         tol = 1000*eps; 
%         [Q,R] = qr(B'); 
%         R = abs(R);
%         jj = all(R < R(1)*tol, 2); 
%         Z = Q(:,jj);
%     else
%         Z = null(B);   % B*Z = 0
%     end
    Z = null(full(B));   % B*Z = 0

    % solve LS system
    if nnz(c)
        u0 = B\c;      % underdetermined system
        % rank test takes time (but avoid warnings)
        % Az = A*Z;
        % if rank(Az) < (size(A,2) - size(B,1))
        %     u = u0;        else
        v = (A*Z)\(x-A*u0);  % overdetermined system
        u = u0 + Z*v;
    else
        u = Z*((A*Z)\x); 
    end
else % B is empty;    Solve   min ||Au - x||_2^2 
    u = A\x;
end

warning('on', 'all');

return


function A = thisBuildA(x, breaks, ord)
% make matrix A to be used in LS, i.e. A in  min ||Au - y||_2^2
% where u are a vector of the (non-zero) elements in the coefs in pp-form

L = length(x);
N = numel(breaks)-1;    % number of pieces (polynoms)
p = max(ord);

if (N < 4)
    % make full matrix A
    A = zeros(L, N*p);
    for i=1:N
        idx = ((x >= breaks(i)) & (x < breaks(i+1))); 
        if (i == N) && (x(L) >= breaks(N+1))
            idx = (idx | (x == breaks(N+1)));  
        end
        if nnz(idx)
            t = x(idx) - breaks(i);
            col = ((i-1)*p+1):(i*p);
            A(idx,col(end)) = ones(numel(t),1);
            for cc = fliplr(col(1:(end-1)))
                % try
                A(idx,cc) = A(idx,cc+1).*t;
                % catch ME
                %     disp(ME.message);
                %     disp([i,size(x),size(breaks),-1,size(A),size(idx),cc,cc+1,size(t)]);
                %     disp(' ');
                % end
            end
        end
    end
else
    % make sparse matrix A
    I = thisFirstge(x, breaks);   % (N+1) breaks    
    if (I(end) <= L) && (x(I(end)) == breaks(end))
        % include this element in last polynom even if it strictly
        % belongs to next polynom
        I(end) = I(end)+1;
    end
    % build A matrix, as used in    min || A*u - y ||_2^2
    % where  u = reshape(coefs', M, 1);
    Ai = zeros(L*p,1);
    Aj = zeros(L*p,1);
    As = zeros(L*p,1);
    for i=1:N
        idx = I(i):(I(i+1)-1);  % indexes in x for this polynom, or rows in A
        ni = numel(idx);
        if ni
            % if (ni < ord(i))  
            %     disp([mfilename,' (521) Warning: ',...
            %         'Only ',int2str(ni),' points for polynom ',int2str(i),...
            %         ' of order ',int2str(ord(i)),' may cause problems.']);
            % end
            t = x(idx) - breaks(i);
            col = ((i-1)*p+1):(i*p);
            ii = (p*(I(i)-1)+1):(p*(I(i+1)-1));
            Ai(ii) = repmat(idx',p,1);
            Aj(ii) = reshape(repmat(col,ni,1),p*ni,1);
            tt = ones(ni,1);
            ii = (p*(I(i+1)-1)+1) - (ni:(-1):1);
            As(ii) = tt;
            for j=2:p
                tt = tt.*t;
                ii = ii - ni;
                As(ii) = tt;
            end
        end
    end
    A = sparse(Ai,Aj,As);
end

if (sum(ord) < N*p)     % some of the columns of A are not used
    ci = false(N, p);   % coefficient indicies
    for i = 1:N
        ci(i,(p-ord(i)+1):p) = true;   % used variables
    end
    A = A(:,reshape(ci',1,N*p));
end

return    % thisBuildA


function [B,c] = thisBuildBc(breaks, ord, cprop, fixval, periodic)
% make matrix B and vector c to be used as conditions in LS, i.e. Bu = c.
% where u are a vector of the (non-zero) elements in the coefs in pp-form

K = sum(cprop) + size(fixval,1);  % Number of continuity and fixval restrictions
if K
    N = numel(breaks)-1;    % number of pieces (polynoms)
    p = max(ord);
    pDesc = (p-1):(-1):0;
    facTab = [1 1 2 6 24 120 720 5040 40320 362880 3628800];
    if N < 4
        % make full matrix B
        B = zeros(K, p*N);
    else
        % make sparse matrix B
        B = sparse([],[],[], K, p*N, K*2*p);
    end
    c = zeros(K,1);
    
    k = 0;
    col = 1:(2*p);
    for i = 1:(N-1)
        % continuity at the end of polynom i,    breaks(i+1)
        t = breaks(i+1) - breaks(i);
        ft = (t*ones(1,p)).^pDesc;
        for count = 1:cprop(i)
            k = k+1;
            coeff = [ft, zeros(1,p)];
            coeff(2*p+1-count) = -facTab(count);
            B(k,col) = coeff;
            ft = [ft(2:end),0].*pDesc;
        end
        col = col + p;
    end
    if periodic             
        col((p+1):(p+p)) = 1:p;
        t = breaks(N+1) - breaks(N);
        ft = (t*ones(1,p)).^pDesc;
        for count = 1:cprop(N)
            k = k+1;
            coeff = [ft, zeros(1,p)];
            coeff(2*p+1-count) = -facTab(count);
            B(k,col) = coeff;
            ft = [ft(2:end),0].*pDesc;
        end
    end
    
    % and now fixval
    for i = 1:size(fixval,1)
        k = k + 1;
        c(k) = fixval(i,2);
        n = find(breaks > fixval(i,1), 1); % should give: n >= 2
        if isempty(n) % may happen if fixval(i,1) == breaks(end)
            n = N;
        else
            n = n-1;   % n is number for the polynom
        end
        col = ((n-1)*p + 1):(n*p);
        t = fixval(i,1) - breaks(n);
        ft = (t*ones(1,p)).^pDesc;
        for count = 1:fixval(i,3)
            ft = [ft(2:end),0].*pDesc;
        end
        B(k,col) = ft;
    end
    
    if (sum(ord) < N*p)
        % some of the columns of B are not used
        coefs = false(N, p);
        for i = 1:N
            coefs(i,(p-ord(i)+1):p) = true;   % used variables
        end
        B = B(:,reshape(coefs',1,N*p));
    end
else
    B = []; c = [];
end

return    % thisBuildBc


function s = thisPpFitProp(pp)
% makes a struct telling how well this pp fits points in x and y
N = pp.pieces;
x = pp.input.x;
yhat = ppval(pp, x);
sqErr = (pp.input.y - yhat).^2;  
nP = zeros(N, 1);     % number of points approximated by each polynom
sseP = zeros(N, 1);   % sum squared error for each polynom
n = 1;
for i = 1:numel(x);
    while (n < N) && (x(i) >= pp.breaks(n+1))
        n = n + 1;
    end
    nP(n) = nP(n) + 1;
    sseP(n) = sseP(n) + sqErr(i);
end
s = struct('n',nP, 'sse',sseP, 'rmse',sqrt(sum(sseP)/sum(nP)));
return


function res = thisTest()
res = struct([]);
disp(' ');
disp(['A test/demo of ppfit.m (by K. Skretting, ver: Jan. 21, 2016), ',datestr(now()),'.']);
disp(' ');
disp('1. a. Simple example: fit piecewise polynomal of three pieces to data points.');
disp('   b. also makes first derivative continuous.');
disp('2. a. Periodic quadratic example.');
disp('   b. Periodic cubic example, data as in example 2a.');
disp('3. a. Periodic cubic example and more break points.');
disp('   b. and compared to splinefit (if available).');
disp('4. Example using weights.');
disp(' ');
choice = input('Select example to run [1,2,3,4] : ');
disp(' ');

if choice == 1
    disp('1a. Simple example: fit piecewise polynomal of three pieces to data points.');
    x = linspace(1,6,50);
    disp('  make x by:  x = linspace(1,6,50);');
    y = sin(x) + 0.1*randn(size(x));
    disp('  and y by:  y = sin(x) + 0.1*randn(size(x));');
    breaks = [1, 3, 4, 6];
    disp(['  the break points are at: ',num2str(breaks),'.']);
    ord = [3, 2, 4];
    disp(['  the order of the ',int2str(numel(ord)),' pieces are: ',int2str(ord),...
        ', giving quadratic, linear and cubic curves.']);
    cprop = 1;
    disp('  the fifth argument set continuity properties at break points (between pieces),');
    disp('  here 1 (default) gives continuous values, but discontinuous derivative.');
    disp('  now find pp by:  pp = ppfit(x, y, breaks, ord, cprop, ''v'');');
    disp('  last argument ''v'' (verbose) make ppfit plot some results.');
    pp = ppfit(x, y, breaks, ord, cprop, 'v');
    disp('  finally plot results i figure 1.');
    xp = linspace(pp.breaks(1), pp.breaks(end), 400);   % x for plotting
    figure(1); clf;
    plot(x,y,'b.', xp,ppval(pp, xp),'r-', pp.breaks,ppval(pp, pp.breaks),'ro');
    title('ppfit: example 1a.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp-curve', 'break points');
    disp('  (press any key to continue)');
    res = struct('pp1a',pp, 'pp1b',[]);
    pause;
    
    disp(' ');
    disp('1b. As first example but makes also first derivative continuous.');
    cprop = 2;
    pp = ppfit(x, y, breaks, ord, cprop, 'v');
    disp('  plot results i figure 2.');
    figure(2); clf;
    plot(x,y,'b.', xp,ppval(pp, xp),'r-', pp.breaks,ppval(pp, pp.breaks),'ro');
    title('ppfit: example 1b.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp-curve', 'break points');
    res.pp1b = pp;
end

if choice == 2
    disp('2a. Periodic quadratic example.');
    x = linspace(0,2*pi,100);
    disp('  make x by:  x = linspace(0,2*pi,100);');
    y = sin(x) + 0.1*randn(size(x));
    disp('  and y by:  y = sin(x) + 0.1*randn(size(x));');
    breaks = [0, 4, 2*pi];
    disp('  and the break points by:  breaks = [0, 4, 2*pi];');
    ord = [3, 3];
    disp('  and the order by:  ord = [3, 3];');
    cprop = [1, 1];
    disp('  and cprop by:  cprop = [1, 1];');
    disp('  note that these are for second to last (periodic --> also first) break points.');
    disp('  find pp by:  pp = ppfit(x, y, breaks, ord, cprop, ''v'', ''p'');');
    pp = ppfit(x, y, breaks, ord, cprop, 'v', 'p');
    disp('  plot results i figure 1.');
    xp = linspace(pp.breaks(1), pp.breaks(end), 400);   % x for plotting
    figure(1); clf;
    plot(x,y,'b.', xp,ppval(pp, xp),'r-', pp.breaks,ppval(pp, pp.breaks),'ro');
    title('ppfit: example 2a.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp-curve', 'break points');
    disp('  (press any key to continue)');
    res = struct('pp2a',pp, 'pp2b',[]);
    pause;
    
    disp(' ');
    disp('2b. Periodic cubic example, data as in example 2a.');
    breaks = [0, pi, 2*pi];
    disp('  and the break points by:  breaks = [0, pi, 2*pi];');
    ord = [4, 4];
    disp('  and the order by:  ord = [4, 4];');
    cprop = [2, 2];
    disp('  and cprop by:  cprop = [2, 2];');
    pp = ppfit(x, y, breaks, ord, cprop, 'v', 'p');
    disp('  plot results i figure 2.');
    figure(2); clf;
    plot(x,y,'b.', xp,ppval(pp, xp),'r-', pp.breaks,ppval(pp, pp.breaks),'ro');
    title('ppfit: example 2b.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp-curve', 'break points');
    res.pp2b = pp;
end

if choice == 3
    disp('3a. Periodic cubic example and more break points.');
    x = linspace(0,2*pi,100);
    disp('  make x by:  x = linspace(0,2*pi,100);');
    y = sin(x) + 0.1*randn(size(x));
    disp('  and y by:  y = sin(x) + 0.1*randn(size(x));');
    breaks = [0:5, 2*pi];
    disp('  and the break points by:  breaks = [0:5, 2*pi];');
    ord = 4;
    disp('  and the order by:  ord = 4;  % will be expanded to correct length');
    cprop = 3;
    disp('  and cprop by:  cprop = 3;  % will be expanded to correct length');
    disp('  Constraints: y(pi) = 0,   y''(pi) = -1  given by :  fixval = [pi, 0, 0; pi, -1, 1];');
    fixval = [pi, 0, 0; pi, -1, 1];
    pp = ppfit(x, y, breaks, ord, cprop, fixval, 'v', 'p');
    disp('  plot results i figure 1.');
    xp = linspace(pp.breaks(1), pp.breaks(end), 400);   % x for plotting
    figure(1); clf;
    plot(x,y,'b.', xp,ppval(pp, xp),'r-', pp.breaks,ppval(pp, pp.breaks),'ro');
    title('ppfit: example 3a.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp-curve', 'break points');
    disp('  (press any key to continue)');
    res = struct('pp',pp, 'pps',[]);
    pause;
    
    if exist('splinefit','file')
        disp(' ');
        disp('3b. Compare this to splinefit (by J. Lundgren).');
        disp('  splinefit uses same order of all pieces and the continuity is maximal');
        disp('  in each break point (knot), i.e. cprop = order - 1.');
        disp('  splinefit has the possibility to do robust fitting which reduces influence from outlying data');
        disp('  and it also has some more flexibility in giving the constraints.');
        disp('  Constraints: y(pi) = 0,   y''(pi) = -1  are given by:');
        disp('  xc = [pi pi]; yc = [0 -1]; cc = [1 0; 0 1]; con = struct(''xc'',xc,''yc'',yc,''cc'',cc);');
        xc = [pi pi]; 
        yc = [0 -1]; 
        cc = [1 0; 0 1];    % one column for each condition ?
        con = struct('xc',xc, 'yc',yc, 'cc',cc);
        disp('  and spline is found by:   pps = splinefit(x,y,breaks,con,4,''p'');');
        pps = splinefit(x,y,breaks,con,4,'p');
        disp('  Compare coefficients to results from ppfit.')
        disp(['  ||pp.coefs - pps.coefs|| = ',num2str(norm(pp.coefs - pps.coefs))]);
        res.pps = pps;
    end
end

if choice == 4
    disp('4a.  Example using weights.');
    disp('  Here we do curve fitting in a loop, first loop without weights.');    
    disp('  In next iterations the weight function uses the errors (r) from previous iteration');
    disp('  to set the weights. We start by giving some examples of weight function.');
    disp('  In figure 1 the weight is in solid line and the contribution to SSEw in dotted line.');
    figure(1); clf;
    subplot(221);
    r = linspace(0,2,100);
    w = ones(size(r));
    plot(r,w,'b-', r,(r.*w).^2,'b:');
    title('w = 1'); xlabel('error');
    ylabel('------  weight');
    subplot(222);
    r = linspace(0,4,200);
    a = 1.2; 
    w = min(1,a./r);
    plot(r,w,'b-', r,(r.*w).^2,'b:');
    title(['w = min(1,a/r),  a=',num2str(a)]); xlabel('error r');
    subplot(223);
    a = 1.2; 
    r = linspace(0,4,400);
    w = exp(-r/a);
    plot(r,w,'b-', r,(r.*w).^2,'b:', [a,a],[0.1,0.8],'g-');
    text(a,0.8,' a');
    title(['w = exp( -r/a ), a=',num2str(a)]); xlabel('error r');
    ylabel('- - -  SSE contribution.');
    subplot(224);
    w = exp(-0.5*(r/a).^2);
    plot(r,w,'b-', r,(r.*w).^2,'b:', [a,a],[0.1,0.8],'g-');
    text(a,0.8,' a');
    title(['w = exp( -0.5*(r/a)^2 ), a=',num2str(a)]); xlabel('error r');
    disp('  This shows that constant (no) weight gives large SSE when the error is large.');
    disp('  Subplot 2 shows that SSE contribution is constant for error > a.');
    disp('  Subplot 3 and 4 shows that SSE contribution is maximal for error == a.');
    disp(' ');
    
    numLoops = 5;
    disp(['4b. Example doing ',int2str(numLoops),' loops where some y-values have large noise.']);
    x = linspace(0,2*pi,100);
    disp('  make x by:  x = linspace(0,2*pi,100);');
    y = sin(x) + 0.1*randn(size(x));
    idx = 5:10:numel(x);
    idxok = setdiff(1:numel(x), idx);
    y(idx) = sin(x(idx)) + rand(size(idx));
    disp('  make y by adding Gaussian noise, sigma = 0.1, to a sine,');
    disp('  for one tenth of y-values a random number between 0 and 1 is added.');
    disp('  These larger errors tends to lift the initial (no weights) curve up.');
    breaks = [0:5, 2*pi];
    disp('  Make the break points by:  breaks = [0:5, 2*pi];');
    ord = 4;
    disp('  and the order by:  ord = 4;');
    cprop = 3;
    disp('  and cprop by:  cprop = 3;');
    pp0 = ppfit(x, y, breaks, ord, cprop, 'v', 'p');
    r = abs(y - ppval(pp0, x));
    rr = r.^2;
    RMSE = sqrt(mean(rr));
    RMSEok = sqrt(mean(rr(idxok)));
    fprintf('  Initial results, SSE = %6.3f,  total RMSE = %6.4f,  ok RMSE = %6.4f \n',...
             sum(rr), RMSE, RMSEok );
    disp('  ok RMSE is RMSE for the points where only Gaussian noise was added.'); 
    disp(' ');
    disp('  Iterate to make better RMSE for the ones where only Gaussian noise was added, i.e. ok RMSE.'); 
    disp('  a is set as standard deviation of error r.');
    for loop = 1:numLoops
        a = std(r);
        w = exp(-r/a);
        fprintf('  Loop %2i  exponential weights, w = exp(-r/a);  a = %6.3f \n', loop, a);
        if loop == numLoops
            ppe = ppfit(x(:), y(:), breaks, ord, cprop, w(:), 'p', 'v');
        else
            ppe = ppfit(x(:), y(:), breaks, ord, cprop, w(:), 'p');
        end
        r = abs(y - ppval(ppe, x));
        rr = r.^2;
        RMSE = sqrt(mean(rr));
        RMSEok = sqrt(mean(rr(idxok)));
        fprintf('  Loop %2i results, SSE = %6.3f,  total RMSE = %6.4f,  ok RMSE = %6.4f \n',...
             loop, sum(rr), RMSE, RMSEok );
    end
    disp(' ');
    r = abs(y - ppval(pp0, x));
    for loop = 1:numLoops
        a = std(r);
        % w = exp(-r/a);
        % fprintf('  Loop %2i  exponential weights, w = exp(-r/a);  a = std(r) = %6.3f \n', loop, a);
        % disp([size(x), size(y), size(w)]);
        w = min(1,a./r);
        fprintf('  Loop %2i hyperbolic weights, w = min(1,a./r);  a = %6.3f  (%3i w(i)<1) \n', loop, a, nnz(w<1) );
        if loop == numLoops
            pph = ppfit(x(:), y(:), breaks, ord, cprop, w(:), 'p', 'v');
        else
            pph = ppfit(x(:), y(:), breaks, ord, cprop, w(:), 'p');
        end
        r = abs(y - ppval(pph, x));
        rr = r.^2;
        RMSE = sqrt(mean(rr));
        RMSEok = sqrt(mean(rr(idxok)));
        fprintf('  Loop %2i results, SSE = %6.3f,  total RMSE = %6.4f,  ok RMSE = %6.4f \n',...
             loop, sum(rr), RMSE, RMSEok );
    end
    
    % disp('  plot results i figure 2.');
    xp = linspace(pp0.breaks(1), pp0.breaks(end), 400);   % x for plotting
    figure(2); clf;
    plot(x,y,'b.', xp,ppval(pp0, xp),'g-', pp0.breaks,ppval(pp0, pp0.breaks),'go', ...
                   xp,ppval(ppe, xp),'r-', ppe.breaks,ppval(ppe, ppe.breaks),'ro');
    title('ppfit: example 4.');
    xlabel('x');
    ylabel('y');
    legend('Data points', 'pp0-curve', 'break points', 'ppe-curve', 'break points');
    
    res = struct('pp0',pp0, 'ppe',ppe, 'pph',pph);
end
    
disp(' ');

return


function I = thisFirstge(x,b)
% thisFirstge   Find first in x >= b(i) for each element of b
%               Both x and b should be sorted!
% It is like: I(j) = find(x >= b(j),1);  and if empty I(j) = numel(x)+1
%
% ex:  I = thisFirstge(x,b);
%      x = sort(rand(1000,1)); b = [0; sort(rand(5,1)); 1];
%      tic; I = thisFirstge(x,b); toc;

% in ..\srp\  this function is in its own m-file

I = zeros(size(b));
if (numel(b) < 20)
    for j = 1:numel(b)
        i = find(x >= b(j),1);
        if isempty(i);
            I(j) = numel(x)+1;
        else
            I(j) = i;
        end
    end
else
    i = 1; j = 1;
    while true
        if (x(i) >= b(j))
            I(j) = i;
            j = j + 1;
            if (j > numel(b)); break; end;
        else
            i = i + 1;
            if (i > numel(x)); break; end;
        end
    end
    if (j <= numel(b))
        I(j:end) = i;
    end
end

return
