function tutorialSignalsExperiment(t, events, params, visStim, inputs, outputs, audio)
%TUTORIALSIGNALSEXPERIMENT *Signals* Experiment Definition Tutorial
%% Notes:
% *Note: code files and commands to be executed that are mentioned in 
% comments in this file will be written within (not including) closed 
% angluar brackets (<...>). Highlight, right-click and select "Open" or 
% "Help on" to view these code files. Try it out here: <sig.Signal> 
%
% *Note 2: It is convenient and often necessary to use anonymous functions
% with some *signals* methods. If you are unfamiliar with using anonymous
% functions in MATLAB, run <doc Anonymous Functions> for a MATLAB primer.
% Similarly, it may also be helpful to understand the basics of 
% object-oriented programming. Run <doc Object-Oriented Programming> for a
% MATLAB primer.
%
% *Note 3: Along the way, you will encounter questions/assignments for you
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
% In this tutorial we will 1) define our experiment, and discuss the
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
%

%% Part 1: Define experiment: 
% For this experiment, we will imagine that we have a head-fixed rodent in 
% a four-wall enclosed rig. A visual stimulus will be presented to the
% rodent on the left wall, and the rodent will have to turn a wheel to the
% right to move the visual stimulus to the center to get a water reward
% from a reward valve. To see how we can create this experiment in a
% *signals* Exp Def, let's first go over the Exp Def input arguments.
%
% Just like in this file, Exp Defs are functions defined as 
% 'ExpDef(t, events, params, visStim, inputs, outputs, audio)'.
% Just as with any MATLAB function, these input arguments can be named
% anything, the only requirement is the order of the arguments (e.g. 
% 'events' could be named 'evts'). (In future, there may be support for
% name-value paired arguments).
%
% *Note: all input arguments are actually optional - the only arguments
% *signals* requires to run an Exp Def are 't' and 'events', which it
% provides itself. But of course, without defining the other input
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
% *Note: Remember, we are given the origin signals 'events.expStart',
% 'events.expStop', 'events.newTrial', and 'events.trialNum', so we will
% build all of our signals off of these origin signals. Additionally, we
% must create an 'events.endTrial' signal, which *signals* will use to
% start the next new trial, as soon is it takes a value to signify the end
% of the current trial.
%
% In general, a good way to build/format Exp Defs (as we'll see below) is 
% is in the following order:
% 1) Define 'inputs', 2) Lay-out the experiment and trial framework, 
% 3) Define 'visStim' 4) Define 'audio', 5) Define 'outputs', 6) Add to
% 'events', 7) (Optional) Add 'params'

% 1) Let's start this Exp Def by setting the 'inputs' (i.e. the wheel) and 
% an interactive phase for each trial (i.e. when the rodent will be allowed 
% to turn the wheel).
interactiveStart = events.newTrial.delay(0.5); % 0.5s after a new trial starts
wheel = inputs.wheel.skipRepeats; % signal for wheel (use 'skipRepeats' to only update when wheel moves)
wheel0 = wheel.at(interactiveStart); % signal that gets wheel value at onset of each trial
wheelScaled = (31*2*pi) / (2^10*4) * 5; % wheel resolution in mm for smallest wheel movement (31mm radius, 2^10*4 resolution per mm), scaled by a factor of 5
deltaWheel = wheelScaled * (wheel - wheel0); % signal for how much wheel has moved within a trial

% 2) Let's layout the experiment and trial framework:
% Let's link the visual stimulus' azimuth to the wheel's movement;
% Let's define a correct trial as azimuth=0 (when the visual stimulus is 
% exactly in center); 
% Let's define an incorrect trial when... 
% Let's define the end of a trial as either a) after a correct move, 
% b) after an incorrect move, or c) after some duration; 
% Let's define the experiment ending after some number of trials
azimuthDefault = -45 * events.newTrial.identity; % signal for azimuth at start of each new trial (use 'identity' to make sure it updates after 'newTrial')
azimuthWheel = deltaWheel; % signal to link azimuth to wheel
correctMove = (azimuthWheel + azimuthDefault) >= 0; % signal for correctly moving stim to center
reward = correctMove.skipRepeats; % signal to output reward for every correct move
totalReward = reward.scan(@plus, 0); % signal to track total reward
%incorrectMove = ...
trialTimeout = events.newTrial.delay(3); % signal for max time per trial (3 seconds)
endTrial = reward | trialTimeout; % signal to end trial when reward is given, or after 3 seconds
%endTrial = correctMove | incorrectMove | trialTimeout
expStop = events.trialNum == 10; % signal to end experiment (after 10 trials)

% 3) Let's create the visual stimulus and assign it in 'visStim'
% *Note, somewhat unintuitively, we have to do this *after* defining the
% azimuth for the visual stimulus (as we did above), since we first 
% needed to define the azimuth position for a correct move
firstVisStim = vis.grating(t); % signal as gabor patch grating (see <vis.grating> for more info)
firstVisStim.azimuth = azimuthWheel + azimuthDefault;
firstVisStim.show = interactiveStart.to(endTrial); % display the stimulus only during trial interactive phase
visStim.first = firstVisStim; % store this visual stimulus in our visStim StructRef (allowing for more than one visual stimulus per experiment)

% 4) Let's create auditory stimuli signifying trial onset, a correct trial,
% and an incorrect trial, and assign them in 'audio'.
audioDev = audio.Devices('default'); % assign computer's default audio device to the <audstream.Registry> object
onsetTone = events.newTrial * aud.pureTone(2000, 0.25,...
  audioDev.DefaultSampleRate, 0.1, audioDev.NrOutputChannels); % signal defining onset tone at each new trial, see <aud.pureTone> for more info
audio.default = onsetTone.at(interactiveStart); % signal that actually plays onsetTone at start of trial interactive phase

rewardTone = events.newTrial * aud.pureTone(3000, 0.1,...
   audioDev.DefaultSampleRate, 0.01, audioDev.NrOutputChannels);
audio.default = rewardTone.at(reward);

% incorrectTone = randn(audioDevice.NrOutputChannels, incorrectToneDur*...
%  audioDevice.DefaultSampleRate); % generate noise via 'randn'
% audio.default = inCorrrectTone.at

% 5) Let's set the 'outputs' (i.e. the reward valve).
outputs.reward = reward;

% 6) Let's add to the 'events' structure the signals that we want to save
events.endTrial = endTrial; % must ALWAYS define 'events.endTrial'
events.expStop = expStop;
events.interactiveStart = interactiveStart;
events.deltaWheel = deltaWheel;
events.reward = reward;
events.totalReward = totalReward;

% *Note: at this point, we have used all the input arguments in the Exp Def
% besides 'params'. This will be the case for the next two versions of the
% task we'll create, until we get to the final section of this tutorial.
%% Part 3: Second version of task
% Comment out all other sections and uncomment this section to run this 
% second version of the task.

%% Part 4: Third version of task
% Comment out all other sections and uncomment this section to run this
% third version of the task.

%% Part 5: Using parameters
% Comment out all other sections besides 'Part 4' and this section, to run
% the third version of the task with parameters.

end

