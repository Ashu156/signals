function tutorialSignalsExperiment(t, events, params, visStim, inputs, outputs, audio)
%TUTORIALSIGNALSEXPERIMENT *Signals* Experiment Definition Tutorial
%% Notes:
% *Note 1: Before beginning, please make sure this entire 'tutorials'
% folder is added to your MATLAB path. 
%
% *Note 2: Code files that are mentioned in this file will be written 
% within (not including) closed angluar brackets (<...>). Highlight, 
% right-click and select "Open" or "Help on" to view these code files. 
% Try it out here: <sig.Signal> 
%
% *Note 3: When installing Rigbox, you should have installed all required
% dependencies, so at this time make sure you have the latest versions of
% Psychtoolbox (psychtoolbox.org/download) and GUI layout toolbox
% (mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox) 
% installed.
%
% *Note 4: It is convenient and sometimes necessary to use anonymous
% functions with some *signals* methods. If you are unfamiliar with using 
% anonymous functions in MATLAB, run 'doc Anonymous Functions' for a MATLAB 
% primer. Similarly, it may also be helpful to understand the basics of 
% object-oriented programming. Run 'doc Object-Oriented Programming' for a
% MATLAB primer.
%
% *Note 5: Along the way, you will encounter questions/assignments for you
% to solve, marked by closed double dashes (--...--). Answers to these 
% questions can be found in the <tutorialSignalsExperimentAnswers> file.
%
% -- 1) Who created *signals*? --

%% Intro:
% Welcome to this tutorial on running a *Signals* Experiment Definition
% (also referred to as an "Exp Def" or "*Signals* Protocol") within Rigbox. 
% For an introduction to *Signals* before running an experiment, open 
% <Getting_Started_with_Signals>. In this tutorial, we will go step-by-step
% to create a version of the "Burgess Steering Wheel Task" the CortexLab 
% uses to probe rodent behaviour and decision-making. (See 
% 1) https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5603732/pdf/main.pdf and
% 2) https://www.ucl.ac.uk/cortexlab/tools/wheel for more information on
% this task). 
%
% In this tutorial we will 1) define our experiment and discuss the
% *Signals* Exp Def input arguments; 2) create our first version of the
% task, where a visual stimulus will appear on the left, and will have to
% be moved (via virtual link to a steering wheel) to center to result in a 
% reward; 3) create our second version of the task where the stimuli can 
% now appear on either left or right, and will have to be moved to center 
% to result in a reward; 4) create our third version of the task where
% two stimuli will appear on both left and right simultaneously, and 
% certain properties of the stimuli will dictate which one has to be moved
% to center to result in a reward; 5) create task parameters that we can
% change in real-time during the experiment.

%% Part 1: Define experiment: 
% For this experiment, we will imagine that we have a head-fixed rodent in 
% a four-wall enclosed rig. A visual stimulus will be presented to the
% rodent, and the rodent will have to turn a wheel to move the visual 
% stimulus to the center to get a water reward from a reward valve. To see 
% how we can create this experiment in a *signals* Exp Def, let's first go
% over the Exp Def input arguments.
%
% Just like in this file, Exp Defs are functions defined as 
% 'ExpDef(t, events, params, visStim, inputs, outputs, audio)'.
% Just as with any MATLAB function, these input arguments can be named
% anything, the only requirement is the order of the arguments (e.g. 
% 'events' could be named 'evts'). (In future, there may be support for
% name-value paired arguments).
%
% *Note: all input arguments are actually optional - the only non-empty 
% arguments *signals* requires to run an Exp Def are 't' and 'events', 
% which it provides itself. But of course, without defining the other input
% arguments within a protocol, the experiment is largely meaningless. 
%
% 't' - This is the origin signal ( <sig.Net/origin> / 
% <sig.node.OriginSignal> ) that will track time during the experiment.
% *Signals* will create this (along with a few other initial origin 
% signals) at experiment onset.
%
% 'events' - This is a <sig.Registry> object (which is a subclass of 
% <sig.StructRef>, essentially a MATLAB 'struct' for signals) containing
% the signals to be saved when the experiment ends. It contains by default 
% the origin signals *Signals* creates at experiment onset (these are
% 'events.expStart', 'events.expStop', 'events.newTrial', and 
% 'events.trialNum' -the roles of these signals should be obvious by name-) 
% plus new signals added to it by the experimenter (e.g. 
% 'events.corectTrial').
%
% 'params' - This is a 'struct' containing experimenter defined parameters
% as signals, which will be used during the experiment. These parameters 
% will be given a default value, but can be changed by the experimenter in 
% real-time during the experiment.
%
% 'visStim' - This is a <sig.StructRef> object containining fields as
% signals that define the visual stimuli that will be presented during
% the experiment. 
%
% 'inputs' - This is a <sig.Registry> object containing hardware inputs as 
% signals. It contains by default the wheel as 'inputs.wheel'.
%
% 'outputs' - This is a <sig.Registry> object containing hardware outputs
% as signals. It contains by default the reward valve as 'outputs.reward'.
%
% 'audio' - This is an <audstream.Registry> object (similar to
% <sig.Registry> but specifically for audio stimuli) containing fields as
% signals that define the audio stimuli that will be presented during the
% experiment. This object also contains a field, 'Devices', which contains
% information about the actual audio device(s) that emit the audio stimuli.
%
% *Note: 'events', 'params', 'inputs', and 'outputs' are all saved by
% default in a 'block.mat' file when the experiment ends.

%% Part 2: First version of task
% % *Note: Remember, we are given the origin signals 'events.expStart',
% % 'events.expStop', 'events.newTrial', and 'events.trialNum', so we will
% % build all of our signals off of these origin signals. Additionally, we
% % must create an 'events.endTrial' signal, which *signals* will use to
% % start the next new trial, as soon as 'events.endTrial' takes a value to 
% % signify the end of the current trial.
% %
% % In general, a rough format for building Exp Defs is in the following
% % order:
% % 1) Define 'inputs', 2) Lay-out the experiment and trial framework, 
% % 3) Define 'visStim' 4) Define 'audio', 5) Define 'outputs', 6) Add to
% % 'events', 7) (Optional) Add 'params'
% %
% % We'll take this general approach as we go through this tutorial.
% 
% % 1) Let's start this Exp Def by setting the 'inputs' (i.e. the wheel) and 
% % an interactive phase for each trial (i.e. when the rodent will be allowed 
% % to turn the wheel).
% interactiveStart = events.newTrial.delay(0.5); % 0.5s after a new trial starts
% wheel = inputs.wheel.skipRepeats; % signal for wheel (use 'skipRepeats' to only update when wheel moves)
% wheel0 = wheel.at(interactiveStart); % signal that gets wheel value at onset of each trial
% deltaWheel = (wheel - wheel0); % signal for how much wheel has moved within a trial, scaled by a factor of 5 
% 
% % 2) Let's layout the experiment and trial framework:
% % Let's define the defaul azimuth for the visual stimulus at trial onset
% % and define a correct trial as azimuth=0 (when the visual stimulus is 
% % moved to the center) 
% azimuthDefault = -45 * events.newTrial; % signal for azimuth at start of each new trial
% correctMove = (deltaWheel + azimuthDefault) >= 0; % signal for correctly moving stim to center
% reward = correctMove.skipRepeats; % signal to output reward for every correct move
% totalReward = reward.scan(@plus, 0); % signal to track total reward
% endTrial = interactiveStart.setTrigger(reward); % signal to end trial when reward is given, but only after each new interactive trial phase
% expStop = events.trialNum > 10; % signal to end experiment (after 10 trials)
% 
% % 3) Let's create the visual stimulus, link its azimuth to the wheel,
% % and assign it to 'visStim'.
% % *Note, somewhat unintuitively, we have to do this *after* defining the
% % azimuth for the visual stimulus (as we did above), since we first 
% % needed to define the azimuth position for a correct trial
% firstVisStim = vis.grating(t); % signal as gabor patch grating (see <vis.grating> for more info)
% firstVisStim.azimuth = deltaWheel + azimuthDefault; % signal to link azimuth to wheel 
% firstVisStim.show = interactiveStart.to(endTrial); % signal to display the stimulus only during trial interactive phase
% visStim.first = firstVisStim; % store this visual stimulus in our visStim StructRef
% 
% % 4) Let's create an auditory stimulus that will signify the trial 
% % interactive phase
% audioDev = audio.Devices('default'); % assign computer's default audio device to the <audstream.Registry> object
%  % signal defining onset tone, use 'iff' statement to initialize 'onsetTone' 
%  % as a signal, see <aud.pureTone> for more info
% onsetTone = iff(events.expStart, aud.pureTone(2000, 0.25,... 
%   audioDev.DefaultSampleRate, 0.1, audioDev.NrOutputChannels), 0);
% audio.default = onsetTone.at(interactiveStart); % signal that actually plays onsetTone at start of trial interactive phase
% 
% % 5) Let's set the 'outputs' (i.e. the reward valve).
% outputs.reward = reward;
% 
% % 6) Let's add to the 'events' structure the signals that we want to plot
% % and save
% events.endTrial = endTrial; % must ALWAYS define 'events.endTrial'
% events.expStop = expStop;
% events.interactiveStart = interactiveStart;
% events.deltaWheel = deltaWheel;
% events.reward = reward;
% events.totalReward = totalReward;

% % *Note: at this point, we have used all the input arguments in the Exp Def
% % besides 'params'. This will remain the case for the next two versions of
% % the task we'll create, until we get to the final section of this
% % tutorial.
% %
% % To run this Exp Def, run 'expTestPanel' and select this file when the
% % file explorer appears. Then in the GUI, click the 'Apply Parameters'
% % button, followed by the 'Start Experiment' button. After the experiment
% % starts, you will be able to "move the wheel" by moving the mouse cursor.
% % You can right-click over the 'expTestPanel' figure to set/unset the mouse
% % cursor as wheel input emulator.

%% Part 3: Second version of task
% Comment out all other sections and uncomment this section.

% In this section, we'll build off of our first version of the task, and
% create a second version in which the stimuli can now appear on either
% left or right side, and will have to be moved appropriately to center.
%
% We'll also define incorrect trials, and a punishment (a separate auditory
% stimuli) for incorrect trials.
% 

% 1) The inputs will be the same as in the previous section
interactiveStart = events.newTrial.delay(0.5); 
wheel = inputs.wheel.skipRepeats; 
wheel0 = wheel.at(interactiveStart); 
deltaWheel = 5 * (wheel - wheel0); 

% 2) Let's repeat some of our experiment and trial framework from the
% previous section, but now define an incorrect trial when the wheel moves
% a small amount in the incorrect direction, and define the end of a trial 
% as either a) after a correct move, b) after an incorrect move, or c) 
% after some duration. 

%'defaultSide' is a signal that gets updated every new trial, and signifies
% the side that the stimulus will appear on: 1 for left, 2 for right
defaultSide = randi(2)*events.newTrial;
azimuthDefault = iff(defaultSide==1, -45*events.newTrial, 45*events.newTrial); 
correctMove = abs(deltaWheel) >= abs(azimuthDefault); % signal for correctMove now considers either azimuthDefault
reward = correctMove.skipRepeats;
totalReward = reward.scan(@plus, 0);
incorrectMove = abs(deltaWheel + azimuthDefault) >= 55; % signal for incorrect move for moving 10 degrees in wrong direction 
trialTimeout = events.newTrial.delay(3); % signal for max time per trial (3 seconds)
endTrial = interactiveStart.setTrigger(reward) | ...
  interactiveStart.setTrigger(incorrectMove) | ...
  interactiveStart.setTrigger(trialTimeout); % signal to end trial for any of 3 conditions
expStop = events.trialNum > 10; % signal to end experiment (after 10 trials)

% 3) The visual stimuli will be defined similarly to the previous section
secondVisStim = vis.grating(t);
secondVisStim.azimuth = deltaWheel + azimuthDefault;
secondVisStim.show = interactiveStart.to(endTrial);
visStim.second = secondVisStim;

% -- Another (albeit superfluous) way to create the visual stimuli for this 
% task would be to assign two separate stimuli to 'visStim'. How could this
% be done? --

% 4) Let's add auditory stimuli signifying correct and incorrect trials

% The 'onsetTone' is the same as in the previous section
audioDev = audio.Devices('default');
onsetTone = iff(events.expStart, aud.pureTone(2000, 0.25,... 
  audioDev.DefaultSampleRate, 0.1, audioDev.NrOutputChannels), 0);
audio.default = onsetTone.at(interactiveStart);

% The 'rewardTone' has a higher pitch than the 'onsetTone' and is shorter
% in duration
rewardTone = iff(events.expStart, aud.pureTone(3000, 0.1,... 
  audioDev.DefaultSampleRate, 0.01, audioDev.NrOutputChannels), 0);
audio.default = rewardTone.at(reward);

% The 'incorrectTone' will be low pitch a noise burst and 2x as long in
% duration as 'rewardTone'
incorrectTone = iff(events.expStart, randn(audioDev.NrOutputChannels, ...
  0.2 * audioDev.DefaultSampleRate), 0); % generate noise burst via 'randn'
audio.default = incorrectTone.at(incorrectMove);

% 5) The 'outputs' remain the same as in the previous section
outputs.reward = reward;

% 6) Let's add to the 'events' structure the signals that we want to save
events.endTrial = endTrial; % must ALWAYS define 'events.endTrial'
events.expStop = expStop;
events.interactiveStart = interactiveStart;
events.defaultSide = defaultSide; % add 'defaultSide' to 'events'
events.deltaWheel = deltaWheel;
events.reward = reward;
events.totalReward = totalReward; 
events.incorrectMove = incorrectMove; % add 'incorrectMove' to 'events'

%% Part 4: Third version of task
% Comment out all other sections and uncomment this section.

%% Part 5: Using parameters
% Comment out all other sections besides 'Part 4', and uncomment this 
% section.

end

