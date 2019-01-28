function axh = timeplot(varargin)
%SIG.TIMEPLOT Summary of this function goes here
%   TODO Document
%   TODO Vararg for axes name value args, e.g. LineWidth
%   TODO Deal with logging signals & registries & subscriptable signals
%   TODO Deal with strings, arrays, structures, cell arrays
%sigs, figh, mode, tWin

% set figure handle, 'figh', for plotting
[present, value, idx] = namedArg(varargin, 'parent');
if present
  figh = value;
  varargin(idx:idx+1) = [];
else
  figh = figure('Name', 'LivePlot', 'NumberTitle', 'off', 'Color', 'w');
end

% set the plotting mode, 'mode'
[present, value, idx] = namedArg(varargin, 'mode');
if present
  mode = value;
  varargin(idx:idx+1) = [];
else
  mode = 0;
end

% set the length of time to be displayed for the plotted signals, 'tWin'
[present, value, idx] = namedArg(varargin, 'tWin');
if present
  tWin = value;
  varargin(idx:idx+1) = [];
else
  tWin = 5;
end

clf(figh);

% Create cell array to store all signals and their names
signals = cell(length(varargin),1);
names = cell(length(varargin),1);

% for all our signals, get their names and values
for i = 1:length(varargin)
  s = varargin{i};
  % Get the name of the signal. If Name is empty, use the variable name
  name = iff(isempty(s.Name), inputname(i), s.Name);
  switch class(s)
    case {'sig.Registry', 'StructRef'}
      % For StructRef objects and their subclasses, extract their signals
      % and set the names to be the fieldnames of the signal
      %names{i} = strcat([name '.'], fieldnames(s));
      names{i} = fieldnames(s);
      signals{i} = struct2cell(s);
    case {'sig.Signal', 'sig.node.Signal', ...
        'sig.node.ScanningSignal', 'sig.node.OriginSignal'}
      names{i} = name;
      signals{i} = s;
    otherwise
      error('Unrecognized type')
  end
end

% Flatten cell arrays
signals = cellflat(signals);
names = cellflat(names);
names{1} = 't'; % the first signal will always be the 'time' signal

n = numel(names); % number of signals, including 'time signal'
tstart = [];
lastval = cell(n,1); % 'lastval' will hold all signals' preceding values before their next update 

% create a colormap for plotting
cmap = colormap(figh, 'hsv'); 
skipsInCmap = ceil(length(cmap) / n);
cmap = cmap(1:skipsInCmap:end, :);

args = {'linewidth' 2};

axh = matlab.graphics.axis.Axes.empty(n,0); % axes handles for the signal plots
x_t = cell(n,1); % 'x_t' will hold time-mapped signals to be plotted (instead of the actual signals)
fontsz = 9;

if numel(mode) == 1
  mode = repmat(mode, n, 1); % allow changing plot mode for each signal individually 
end

% create and prettify the subtightplots for all signals
listeners = TidyHandle.empty(n,0); % initialize listeners to the signals that will update the plots
for i = 1:n
  axh(i) = subtightplot(n,1,i,[0.02,0.2],0.05,0.05,'parent',figh);
  x_t{i} = signals{i}.map(...
    @(x)struct('x',{x},'t',{GetSecs}), '%s(t)');
  curTitle = title(axh(i), names{i}, 'interpreter', 'none');
  if i == n    
    xlabel(axh(i), 't (s)', 'fontsize',fontsz);
  else
    set(axh(i),'XTickLabel',[]);
  end
  % add listeners 
  listeners(i) = onValue(x_t{i}, @(v)new(i,v));
end

% set additional figure and axes properties
set(axh, 'NextPlot', 'add', 'fontsize', fontsz); % set plots to "hold on", set x axes
set(axh, 'Xlim', [0 tWin]);
set(axh,'ButtonDownFcn',@(s,~)cycleMode(s)); % 'cycleMode' is a local callback which changes plotting mode of signals
set(figh, 'DeleteFcn', @(~,~)delete(listeners)); % delete listeners upon figure deletion

% 'new' does the actual plotting of the new values of the signals upon update
  function new(idx, value)
    if isempty(tstart)
      tstart = GetSecs;
    end
    
    if ischar(value.x)
      str = value.x;
      value.x = iff(isempty(value.x),0,1);
      mode(idx) = 1;
      text(axh(idx), value.t-tstart, value.x+0.1, str,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'bottom');
      ylim(axh(idx), [0 1.5])
    elseif numel(value.x) > 1
      str = num2str(size(value.x));
      ylabel(axh(idx),'size')
      value.x = numel(value.x);
      mode(idx) = 1;
      text(axh(idx), value.t-tstart, value.x+0.1, str,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'bottom');
    end
    
    if isempty(lastval{idx})
      lastval{idx} = value;
    end
    
    switch mode(idx)
      case 0 % plot as a signal, but with change points shown
        xx = [lastval{idx}.x value.x];
        tt = [lastval{idx}.t value.t]-tstart;
        scatter(axh(idx), value.t-tstart, value.x, 'x', 'MarkerEdgeColor', cmap(idx,:), args{:});
        stairs(axh(idx), tt, xx, 'Color', cmap(idx,:), args{:});
      case 1 % plot as a stream of discrete events, no intevening values
        xx = [0 value.x];
        tt = [value.t value.t]-tstart;
        scatter(axh(idx), value.t-tstart, value.x, 'o', 'MarkerEdgeColor', cmap(idx,:), args{:});
        stairs(axh(idx), tt, xx, 'Color', cmap(idx,:), args{:});
      case 2 % plot as a signal, without showing change points, and interpolate
        xx = [lastval{idx}.x value.x];
        tt = [lastval{idx}.t value.t]-tstart;
        line(tt, xx, 'Parent', axh(idx), 'Color', cmap(idx,:), args{:});
    end
    lastval{idx} = value;
    set(axh, 'Xlim', [GetSecs-tstart-tWin GetSecs-tstart+0.1]);
  end

  function cycleMode(src)
    id = src==axh;
    if mode(id) == 2
      mode(id) = 0;
    else
      mode(id) = mode(id) + 1;
    end
  end
end

