classdef Signal < handle
  % SIG.SIGNAL: A mostly abstract class defining *signals* objects' 
  % interactions.
  %   This class contains the methods that define how a *signals* object
  %   can be manipulated. The principle subclass to this is
  %   SIG.NODE.SIGNAL, which inherhits these methods. All concrete methods 
  %   defined here effectively overload builtin MATLAB functions using
  %   CONTAINERS.MAP with a format spec to allow straightforward syntax.
  %
  %   Running Example: 
  %     create a *signals* network and three origin signals
  %     net = sig.Net;
  %     os1 = net.origin('os1'); 
  %     os2 = net.origin('os2'); 
  %     os3 = net.origin('os3'); 
  %       
  % See also SIG.NODE.SIGNAL
  %
  % *Note: when running the example code for the below methods, first
  % run the 'Running Example' code written above
  
  methods (Abstract)
    
    % 'th = s1.onValue(f)' returns a TidyHandle, 'th', that executes a
    % callback function 'f' whenever 's1' takes a value.
    %
    % Example:
    %  dispValLong = os1.onValue(@(x)... 
    %    fprintf('The value of this signal is %d\n',x));
    %  os1.post(5);
    
    h = onValue(this, fun)
    
    % 'th = s1.output' returns a TidyHandle object 'th' which displays the
    % output of the signal 's1' whenever it takes a value (equivalent to 
    % 'th = s1.onValue(@disp)').
    % 
    % Example:
    %   dispValShort = os1.output;
    %   os1.post(1); % 1 will be displayed
    
    h = output(this)
    
    % 'ds = s1.at(s2)' returns a dependent signal 'ds' that takes the
    % current value of 's1' whenever 's2' takes any "truthy" value
    % (that is, a value not false or zero).
    %
    % Example:
    %   ds1 = os1.at(os2);
    %   ds1Out = output(ds1);
    %   os2.post(0); % nothing will be displayed
    %   os2.post(2); % '1' will be displayed
    %   os2.post(false); % nothing will be displayed
    
    s = at(this, when)
    
    % 'ds = s1.keepWhen(s2)' returns a dependent signal 'ds' that takes
    % the value of 's1' whenever 's1' is updated, given that 's2' holds a
    % truthy value.
    %
    % Example:
    %   ds2 = os1.keepWhen(os2);
    %   ds2Out = output(ds2);
    %   os1.post(1); % nothing will be displayed
    %   os2.post(true); 
    %   os1.post(0); % '0' will be displayed
    
    s = keepWhen(what, when)
    
    % 'ds = s1.map(f, formatSpec)' returns a dependent signal 'ds' that
    % takes the value resulting from mapping function 'f' onto the value 
    % in 's1' (i.e. 'f(s1)') whenever 's1' is updated.
    %
    % Example:
    %   f = @(x) x.^2; % the function to be mapped
    %   ds3 = os1.map(f);
    %   ds3Out = output(ds3); 
    %   os1.post([1 2 3]); % '[1 4 9]' will be displayed
    
    m = map(this, f, varargin)
    
    % 'ds = s1.map2(s2, f, formatSpec)' returns a dependent signal 'ds'
    % that takes the value resulting from mapping function 'f' onto the
    % values in 's1' and 's2' (i.e. 'f(s1, s2)') whenever 's1' or 
    % 's2' is updated
    %
    % Example:
    %   f = @(x,y) x.*y + x; % the function to be mapped
    %   ds4 = os1.map2(os2, f);
    %   ds4Out = output(ds4);
    %   os2.post([4 5 6]);
    %   os1.post([1 2 3]); % '[5 12 21]' will be displayed
    
    m = map2(this, other, f, varargin)
    
    % 'ds = s1.mapn(s2..., sN, f, formatSpec)' is an extension of 'map2' 
    % that returns a dependent signal 'ds' which takes the value
    % resulting from mapping function 'f' onto the values of an 
    % arbitrary 'n' number of other signals (i.e. 'f(s2,..., sN)')
    % whenever any of 's1...sN' is updated.
    %
    % Example:
    %   f = @(x,y,z) x+y-z;
    %   ds5 = os1.map2(os2, os3, f);
    %   ds5Out = output(ds5);
    %   os1.post(1);
    %   os2.post(2);
    %   os3.post(3); % '0' will be displayed
    %
    % See also SIG.SIGNAL.MAP2
    
    m = mapn(this, varargin)

    % 'ds = s1.scan(f, init)' returns a dependent signal 'ds' that applies
    % an initial value 'init' to the first element in 's1' via the function 
    % 'f', and then applies each subsequent element in 's1' to the 
    % previous, again via the function 'f', resulting in a running total,
    % whenever 's1' is updated. If 'init' is a signal, it will overwrite
    % the current value of 'ds' whenever it updates.
    %
    % Example:
    %   f = @plus;
    %   ds6 = os1.scan(f, 5);
    %   ds6Out = output(ds6);
    %   os1.post([1 2 3]); % '[6 7 8]' will be displayed

    s = scan(this, f, seed)
    
    % 'ds = indexOfFirst(s1, ..., sN)' returns a dependent signal 'ds'
    % which takes as value the index of the first signal with a truthy
    % value in the input argument list of size 'N'. If no signal has a
    % truthy node value, then the node value of 'ds' = N+1.
    %
    % Example:
    %   ds7 = indexOfFirst(os1, os2, os3);
    %   ds7 = output(ds7);
    %   os1.post(0); % '4' will be displayed
    %   os3.post(1); % '3' will be displayed
    
    f = indexOfFirst(varargin)
    
    % 'ds = cond(pred1, val1, pred2, val2,...predN, valN)' returns a
    % dependent signal 'ds' that takes on the corresponding value, 'val',
    % for the first true predicate, 'pred', in the 'pred, val' pair list 
    % which 'cond' takes as arguments, whenever any signal in any predicate
    % in the predicate list updates ('pred1, val1' can be thought of 
    % as a typical MATLAB name-value pair).
    %
    % Example:
    %   ds8 = cond(os1>0, 1, os2>0, 2);
    %   ds8Out = output(ds8);
    %   os1.post(1); % '1' will be displayed
    %   os2.post(1); % '1' will be displayed again 
    %   os1.post(0); % '2' will be displayed
    
    c = cond(pred1, value1, varargin)
    
    % Returns the value of the input signal indexed by this
    % The resulting signal samples a new value if either the index signal
    % (this) or the indexed signal changes
    %
    % Example: 
    
    s = selectFrom(this, varargin)
    
    % 'ds = s1.bufferUpTo(n)' returns a dependent signal 'ds' which takes 
    % as value the last 'n' values 's1' took. When the number of updates
    % of 's1' is fewer than 'n', 'ds' takes as value all of those updates.
    % 
    % Example:
    %   ds10 = os1.bufferUpTo(3);
    %   ds10Out = output(ds10);
    %   os1.post(1); % '1' will be displayed
    %   os1.post(2); % '[1 2]' will be displayed
    %   os1.post(3); % '[1 2 3]' will be displayed
    %   os1.post(4); % '[2 3 4]' will be displayed
    % See also SIG.SIGNAL.BUFFER
    
    b = bufferUpTo(this, nSamples)
    
    % 'ds = s1.buffer(n)' returns a dependent signal 'ds' which takes as
    % value the last 'n' values 's1' updated to. When the number of
    % updates of 's1' is fewer than 'n', 'ds' takes no value.
    %
    % Example:
    %   ds11 = os1.buffer(3);
    %   ds11Out = output(ds11);
    %   os1.post(1); % nothing will be displayed
    %   os1.post(2); % nothing will be displayed
    %   os1.post(3); % '[1 2 3]' will be displayed
    %   os1.post(4); % '[2 3 4]' will be displayed
    
    b = buffer(this, nSamples)
    
    % 'ds = s1.merge(s2...sN)' returns a dependent signal 'ds' which takes
    % the value of the value of the last input signal to update.
    % *Note: if multiple signals update during the same transaction, 'ds'
    % will update to the signal which is earlier in the input argument list 
    %
    % Example:
    %   ds1 = os1.at(os3);
    %   ds12 = os1.merge(os2,ds1,os3);
    %   ds12Out = output(ds12);
    %   os1.post(1); % '1' will be displayed
    %   os2.post(2); % '2' will be displayed
    %   os3.post(3); % '1' will be displayed
    
    m = merge(this, varargin)
    
    % 'ds = to(s1,s2)' returns a dependent signal 'ds' which only initially
    % takes a value (of 1) when 's1' takes a truthy value. 'ds' then
    % alternates between updating to '0' the first time 's2' updates to a
    % truthy value after 's1' has updated to a truthy value, and updating 
    % to '1' the first time 's1' updates to a truthy value after 's2' has
    % updated to a truthy value.
    %
    % Example:
    %   ds13 = to(os1, os2);
    %   ds13Out = output(ds13);
    %   os1.post(1); % 1 will be displayed
    %   os1.post(2); % nothing will be displayed
    %   os2.post(1); % 0 will be displayed
    %   os1.post(0); % nothing will be displayed
    %   os1.post(1); % 1 will be displayed
    
    p = to(a, b)
    
    % 'ds = setTrigger(s1,s2)' returns a dependent signal 'ds' which can
    % only ever take a value of 1. 'ds' initially updates to 1 when s2 is
    % set to a truthy value, given that s1 has a truthy value. 
    % Additional updates of 'ds' take place whenever 's2' is set to a
    % truthy value, given that 's1' has been "reset" to a truthy value.
    % 
    % Example: 
    %   ds14 = setTrigger(os1,os2);
    %   ds14Out = output(ds14);
    %   os2.post(1); % nothing will be displayed
    %   os1.post(1); os2.post(2); % 1 will be displayed
    %   os2.post(3); % nothing will be displayed
    %   os1.post(2); os2.post(4); % 1 will be displayed
  
    tr = setTrigger(arm, release)
    
    % 'ds = s1.skipRepeats' returns a dependent signal 'ds' which takes the
    % value of 's1' only when 's1' updates to a value different from 
    % it's current value.
    %
    % Example: 
    %   ds15 = os1.skipRepeats;
    %   ds15Out = output(ds15);
    %   os1.post(1); % 1 will be displayed
    %   os1.post(1); % nothing will be displayed
    %   os1.post(2); % 2 will be displayed
    
    nr = skipRepeats(this)
    
    % 'ds = s1.delta' returns a dependent signal 'ds' which takes the value
    % of the difference between the current value of 's1' and its previous
    % value.
    %
    % Example:
    %   ds16 = os1.delta;
    %   ds16Out = output(ds17);
    %   os1.post(1);
    %   os1.post(10); % 9 will be displayed
    %   os1.post(5); % -5 will be displayed
    
    d = delta(this)
    
    % New signal that follows another, but is always n samples behind
    %
    % See also SIG.SIGNAL.DELAY
    d = lag(this, n)
    
    % New signal that follows another, but delayed in time
    %
    %
    d = delay(this, period)
    
    % Mathmematical identity function, i.e. output == input
    % 
    % When two signals update at the same time, the order is undefined.
    % Sometimes it is required that one signal updates first, in which case
    % the use of identity can help.
    % 
    % Example:
    %   endTrial = repeat.at(stimOff) 
    %   % endTrial and stimOff update during the same propagation through 
    %   % the network.  stimOff may update AFTER endTrial, which is
    %   % undesirable.
    %   endTrial = repeat.at(stimOff.identity())
    %   % Now endTrial is likely to update just after stimOff takes a value
    id = identity(this)
    
    % 'ds = s1.log' returns a dependent signal, 'ds' whose value is a
    % structure with two fields, 'time' and 'value'. Each element in 'time'
    % is the time of the last update of 's1' (in seconds, via the PTB
    % GETSECS function), and the corresponding element in 'value' is the
    % value of that update.
    % 
    % Example:
    %   ds20 = os1.log;
    %   ds20Out = output(ds20);
    %   os1.post(1); os1.post(2); os1.post(3); % a 1x3 struct array will be displayed
    l = log(this)
    
  end
  
  methods
    function b = floor(a)
      b = map(a, @floor, 'floor(%s)');
    end
    
    function a = abs(x)
      a = map(x, @abs, '|%s|');
    end
    
    function a = sign(x)
      a = map(x, @sign, 'sgn(%s)');
    end
    
    function c = sin(a)
      c = map(a, @sin, 'sin(%s)');
    end
    
    function c = cos(a)
      c = map(a, @cos, 'cos(%s)');
    end
    
    function c = uminus(a)
      c = map(a, @uminus, '-%s');
    end
    
    function c = not(a)
      c = map(a, @not, '~%s');
    end
    
    function c = plus(a, b)
      c = map2(a, b, @plus, '(%s + %s)');
    end
    
    function c = minus(a, b)
      c = map2(a, b, @minus, '(%s - %s)');
    end
    
    function c = mtimes(a, b)
      c = map2(a, b, @mtimes, '%s*%s');
    end
    
    function c = times(a, b)
      c = map2(a, b, @times, '%s.*%s');
    end
    
    function c = mrdivide(a, b)
      c = map2(a, b, @mrdivide, '%s/%s');
    end
    
    function c = rdivide(a, b)
      c = map2(a, b, @rdivide, '%s./%s');
    end
    
    function c = mpower(a, b)
      c = map2(a, b, @mpower, '%s^%s');
    end
    
    function c = power(a, b)
      c = map2(a, b, @power, '%s.^%s');
    end
    
    function c = mod(a, b)
      c = map2(a, b, @mod, '%s %% %s');
    end
    
    function y = vertcat(varargin)
      formatSpec = ['[' strJoin(repmat({'%s'}, 1, nargin), '; ') ']'];
      y = mapn(varargin{:}, @vertcat, formatSpec);
    end
    
    function y = horzcat(varargin)
      formatSpec = ['[' strJoin(repmat({'%s'}, 1, nargin), ' ') ']'];
      y = mapn(varargin{:}, @horzcat, formatSpec);
    end
    
    function c = eq(a, b, handleComparison)
      % New signal carrying the current equality (==) between signals
      
      if nargin < 3 || ~handleComparison
        c = map2(a, b, @eq, '%s == %s');
      else
        c = eq@handle(a, b);
      end
    end
    
    function c = ge(a, b)
      % New signal carrying the current inequality (>=) between signals
      
      c = map2(a, b, @ge, '%s >= %s');
    end
    
    function c = gt(a, b)
      % New signal carrying the current inequality (>) between signals
      
      c = map2(a, b, @gt, '%s > %s');
    end
    
    function c = le(a, b)
      % New signal carrying the current inequality (<=) between signals
      
      c = map2(a, b, @le, '%s <= %s');
    end
    
    function c = lt(a, b)
      % New signal carrying the current inequality (<) between signals
      
      c = map2(a, b, @lt, '%s < %s');
    end
    
    function c = ne(a, b, handleComparison)
      % New signal carrying the current non-equality (~=) between signals
      
      if nargin < 3 || ~handleComparison
        c = map2(a, b, @ne, '%s ~= %s');
      else
        c = ne@handle(a, b);
      end
    end
    
    function c = and(a, b)
      % New signal carrying the logical AND between signals
      
      c = map2(a, b, @and, '%s & %s');
    end
    
    function c = or(a, b)
      % New signal carrying the logical OR between signals
      
      c = map2(a, b, @or, '%s | %s');
    end
    
    function b = strcmp(s1, s2)
      % New signal carrying the result of string comparison
      b = map2(s1, s2, @strcmp, 'strcmp(%s, %s)');
    end
    
    function b = transpose(a)
      % New signal carrying the result of transposing source values
      b = map(a, @transpose, '%s''');
    end
    
    function x = str2num(strSig)
      x = map(strSig, @str2num, 'str2num(%s)');
    end
  end
  
end

