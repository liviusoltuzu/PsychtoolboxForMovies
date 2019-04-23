% Constants to be used throughout the code

waitTimeForRFMap = 0.2; % seconds

%% for playseq
colPlaySeqKeyword = 1;			% instruction: load, play, wait etc
colPlaySeqPath = 2;				% path
colPlaySeqIndex = 3;			% bitcode
colPlaySeqNumber = 4;			% order number, for newblock, not transformed in bitcode
colPlaySeqFramerate = 5;		% framerate
colPlaySeqInterpolation = 6;	% type of interpolation
colPlaySeqDuration = 7;			% duration of the event;
								% 'play' doesn't have one, because it depends
								% on the number of frames found in the folder


								
%% default playing
acceptedImgTypes = {'*.tif' '*.png' '*.bmp'};
defaultDuration = 30; % [seconds]
defaultFramerate = 30; % [fps]
defaultInterpolation = 'nice'; % 'nice' is Bilinear filtering; 'coarse' is Nearest neighbour filtering

%% separators
newBlockBitcode = 1023; % reserved bitcode % default 1023
newMovieBitcode = 1022; % reserved bitcode % default 1022
defaultBlankScreenCode = 1021; % unique index for blankscreen
defaultSeparatorDuration = 0.1; % duration of the separator bitcode: moviecode, newmovie, newblock [sec] default 0.1
defaultDurAfterSeparator = 0.1; % default 0.1

%% bitcodes
noBits = 10; % no of bits
maxBCode = 1010; % less than 1023 because a few are reserved, see above

% Retrieves coordinates of photodiodes position
[bcR, bcC] = exp_bitcodes;

% cover coordinates
shape_pos_cover =  bcC(3:6);

%% PTB

skipPTBTests = 0; % default 0; set 1 if it crashes in Windows OS

% show text over frames (with fps and current movie) [default 0]
% [1 in testing mode]
showText = 1; 

% hide mouse cursor [default 0]
hideMouse = 0;

% shift the movie to the right of the screen (useful for recording from the
% right eye) if the image is smaller than the screen
shiftBool = 0;


% LoadAtTheBeginning
% 1=load stimuli before running from .mat file; [default 1]
% 0=load frames on the fly, i.e. create im_matrix in memory in the load event
LoadAtTheBeginning = 1;

% forceReloadAllStimuli: to be set to 1 only if input file changed
% 1 = recreates all .mat files with frames all over again
forceReloadAllStimuli = 0; 