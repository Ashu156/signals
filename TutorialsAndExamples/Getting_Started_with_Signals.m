%% N.B.
% *Note: code files mentioned in this file will be written within
% (not including) closed double asterisks. Highlight, right-click and 
% select "Open" to view these code files. Try it out here to open the
% "sig.Signal" class: **sig.Signal** 
%
% *Note 2: It is convenient and often necessary to use anonymous functions
% with some *signals* methods. If you are unfamiliar with using anonymous
% functions in MATLAB, execute <doc Anonymous Functions> in the command
% window for a MATLAB primer on using anonymous functions.

%% Intro:
% *Signals* was originally developed in order to create and run simple,
% elegant and flexible stimulus presentation for neurophysiological
% experiments. Principally, *signals* allows for monitoring and 
% manipulating stimuli (and other experimental parameters) over time. This 
% is done by representing each parameter of interest as a signal!
%
% When creating an experiment that will use *signals*, a *signals* network 
% - **sig.Net** - must first be created. Every signal belongs to a 
% *signals* network, and is identifiable in the network by its ID. There
% are two major types of signals: 1) origin signals (**sig.Net.origin** /
% **sig.node.OriginSignal**), which are created directly in/by the
% *signals* network, and upon which all other signals depend, and 
% 2) dependent signals (**sig.Signal** / **sig.node.Signal**), which are 
% created from other signals (first-order dependent signals are created 
% from origin signals).
%
% In this tutorial you will get started with *signals*. You will 1) create 
% signals within a *signals* network; 2) use common arithmetic and
% signals-specific functions to manipulate signals; 3) plot signals to 
% visualise their changes over time; 4) create simple visual stimuli using
% signals. 
%
% Along the way, you will encounter questions/assignments for you to solve,
% marked by closed double-dashes. Answers to these questions can be found
% in the **Getting_Started_with_Signals_Answers** file.
% -- 1) Who created *signals*? --

%% Create signals in a *signals* network

% Let's create a signals network and three origin signals:
clear all; %#ok<CLALL> clear all workspace, hidden & global vars that might interfere with *signals* 
net = sig.Net;
os1 = net.origin('os1');
os2 = net.origin('os2');
os3 = net.origin('os3');

% let's create **TidyHandle** variables so we can display the output of
% our signals in the command window whenever they get updated
os1Out = os1.output;
os2Out = os2.output;
os3Out = os3.output;

% origin signals initialize with empty values, so let's post to them 
os1.post(1); % our signals can hold single values,
os2.post([0 1 2]); % vectors,
os3.post([1 2 3; 4 5 6; 7 8 9]); % and even arrays

% -- 2) Create a 4th origin signal, 'os4'. Post "Hello, *signals*" to this
% signal, and make sure its output is displayed --

%% Create (and manipulate) dependent signals from our origin signals

% Let's use some common MATLAB functions to create new signals from our
% origin signals:
dsAdd = os1 + 1; dsPlusOut = dsAdd.output;
dsMult = os3 * os3'; dsMultOut = dsMult.output;
dsNot = not(os2); dsNotOut = dsNot.output;
dsAnd = os2 & os2'; dsAndOut = dsAnd.output; %*note, the short-circuit '&&' and '||' operators do not work on signals
dsGE = os3*-1+10 >= os3; dsGEOut = dsGE.output;

% These dependent signals will also initialize with empty values and do not
% update until the signals they depend on update, so let's help them out by
% re-posting to our origin signals: 
os1.post(1); % first value displayed is 'os1', second is 'dsAdd'
os2.post([0 1 2]); % first value displayed is 'os2', second is 'dsNot', third is 'dsAnd'
os3.post([1 2 3; 4 5 6; 7 8 9]); % first value displayed is 'os3', second is 'dsMult', third is 'dsGE'

% -- 3) Use MATLAB's 'horzcat' function to create a new dependent signal, 
% 'dsStr' from 'os4' to append ", I am a signal" to the value of 'os4'.
% Re-post "Hello, *signals*" to os4, and make sure the output of 'dsStr' is
% displayed. --

% Now let's use some common signal-specific methods to create new signals:
% Let's first clear all our old output signals for clarity's sake, so the
% only display in the command line will be from the new dependent signals
% we will create
clear dsPlusOut dsMultOut dsNotOut dsAndOut dsGEOut os1Out os2Out os3Out

% 'at': 'ds = s1.at(s2)' returns a dependent signal 'ds' which takes the
% current value of 's1' whenever 's2' takes any "truthy" value
% (that is, a value not false or zero).
dsAt = os1.at(os2); ds1At2Out = dsAt.output;
os1.post(1);
os2.post(0); % nothing will be displayed
os2.post(2); % '1' will be displayed
os2.post(false); % nothing will be displayed (but value of 'ds1' remains 1)
clear ds1At2Out

% 'to': 'ds = to(s1,s2)' returns a dependent signal 'ds' which can only
% ever take a value of 1 or 0. 'ds' initially takes a value of 1 when 's1'
% takes a truthy value. 'ds' then alternates between updating to '0'
% the first time 's2' updates to a truthy value after 's1' has updated
% to a truthy value, and updating to '1' the first time 's1' updates
% to a truthy value after 's2' has updated to a truthy value.
dsTo = to(os1, os2); dsToOut = dsTo.output;
os1.post(1); % '1' will be displayed
os1.post(2); % nothing will be displayed
os2.post(1); % '0' will be displayed
os1.post(0); % nothing will be displayed
os1.post(1); % '1' will be displayed
clear dsToOut

% 'map': 'ds = s1.map(f, formatSpec)' returns a dependent signal 'ds' that
% takes the value resulting from mapping function 'f' onto the value
% in 's1' (i.e. 'f(s1)') whenever 's1' takes a value.
f = @(x) x.^2 + x; % the function to be mapped
dsMap = os1.map2(os2, f); dsMapOut = output(dsMap);
os1.post([1 2 3]); % '[2 6 12]' will be displayed
clear dsMapOut

% 'scan': 'ds = s1.scan(f, init)' returns a dependent signal 'ds' which
% applies an initial value 'init' to the first element in 's1' via the
% function 'f', and then applies each subsequent element in 's1' to the
% previous element, again via the function 'f', resulting in a running
% total, whenever 's1' takes a value. If 'init' is a signal, it will
% overwrite the current value of 'ds' whenever it updates.
f = @plus;
dsScan = os1.scan(f, 5); dsScanOut = output(dsScan);
os1.post([1 2 3]); % '[6 7 8]' will be displayed
clear dsScanOut

% 'delay': 'ds = s1.delay(n)' returns a dependent signal 'ds' which takes
% as value the value of 's1' after a delay of 'n' seconds AND after
% SIG.NET.RUNSCHEDULE has been run, whenever 's1' updates.
dsDelay = os1.delay(2); dsDelayOut = output(dsDelay);
% **sig.Net.runSchedule** is a method that checks for and applies
% updates to signals that are to be updated after a delay.
os1.post(1); pause(2); net.runSchedule; % '1' will be displayed
clear dsDelayOut

% -- 4) 
%      a) Create origin signals, 'expStart', which will signify the start
% of your experiment, and 'newTrial', which will signify the start of each 
% new trial. 
%      b) Create a dependent signal, 'endTrial', which will signify 
% the end of each trial. Make 'endTrial' update to '2' 3 seconds after 
% every 'newTrial'. 
%      c) Create dependent signals 'trialNum', which will signify the 
% current trial number (i.e. update to a new value every time there is a 
% new trial), and 'trialNumFunc', which will return the value of the 
% trial number cubed - 1, each time there is a new trial. 
%      d) Create signals 'trialRunning', a dependent signal which will 
% update to '1' at the start of each new trial and update to '0' at the 
% end of each new trial, an origin signal 'trialStr', whose value will be 
% the string "Trial is Running", and 'dispTrialStr', a dependent signal 
% which will update to 'trialStr' whenever 'trialRunning' updates to '1'.
%      e) Create (TidyHandle) variables that will display the output for 
% all of these signals whenever they get updated.
%
%    Hints: 
%      a) Just create these signals, don't post any values to them.
%      b) Use 'delay' to create 'endTrial' from 'newTrial'.
%      c) Use 'scan' to crerate 'trialNum' from 'newTrial', and use 'map'
% to create 'trialNumFunc' from 'trialNum'
%      d) Use 'to' to create 'trialRunning' from 'newTrial' and 'endTrial'.
% Post the appropriate string to the origin signal 'trialStr' after
% creating it. Use 'at' to create 'dispTrialStr' from 'trialStr' and
% 'trialRunning'.
%      e) use 'output' to create the variables that will display the
% signals' values. --

%% Plot signals and visualise their changes over time

%% Create simple visual stimuli using signals

