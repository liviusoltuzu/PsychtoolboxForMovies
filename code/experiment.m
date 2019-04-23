% This file runs a full experiment.
%
% How to use:
%
% Define input file in the %%Input section
% Input file can be written manually (the separator is TAB, not spaces)
%	or can be generated with exp_GenerateInputFile
% 
% Edit settings in the %%Settings section 
%
% Based on the input file, exp_PlaySequence creates a sequence of events
%   that will be run during the experiment: such as: load a video, play a
%   video, show the bitcode for a movie, wait x seconds.
% Other events could be easily defined (hopefully) in exp_GenerateSequence
%   and then experiment.m (this file)
%
% Last updated 10th July 2015


clear
clc

%% Input
% defines path of the input file
[runningFolder, ~, ~] = fileparts(mfilename('fullpath'));

inputfile = fullfile(runningFolder, 'example_input_file.txt');


protocol = exp_ReadFile(inputfile);
disp('Input file read.');

% Sequence of events
playseq = exp_GenerateSequence( protocol );
disp('Sequence generated.');


%% Diary
diary off
[pthofexperiment, ~ , ~] = fileparts(which(mfilename));
chdir(pthofexperiment)
tempdiary = 'temporary_diary.txt';
if exist(tempdiary,'file')==2, 	delete(tempdiary), end;
diary (tempdiary)

%% Constants
% Loads constants
exp_constants

if ~forceReloadAllStimuli
	fprintf('\nStimuli NOT to be recreated if they exist!\n\n');
end


%% Output

% prefix for the output file
ct = clock;
fileroot = [pwd filesep 'exp_' TimeNowToString(ct)]; % this is basically a timestamp

copyfile(inputfile,[fileroot '_input.txt']); % one copy of the input file

% creates output file
outputfile = [fileroot '_output.txt'];
fid = fopen(outputfile,'at');
fprintf('\nOutput file: %s\n\n',outputfile);

%% Duration of the protocol and number of images
% number of events/stimuli in the sequence, as read from the input file
noEvents = size(playseq,1);

totalDuration = 0;

mapEventToStim = zeros(noEvents,1); % a map that matches events in the playseq with allStims arrays
allStimsNo = 0;     % number of stimuli
allStims_Paths = {};
allStims_Indices = [];
allStims_NoFrames = []; % number of frames for each stim
allStims_Framerate = []; % framerate for each stim
allStims_imH = [];
allStims_imW = [];
allStims_Duration = [];

% see exp_PlaySequence for what i in playseq{kEvent,i} means
for kEvent = 1:noEvents
	duration = 0;
	switch playseq{kEvent,1}
		case 'load'
			
			folderPath = playseq{kEvent,colPlaySeqPath}; % gets path
			
			
			% checks if this stimulus has been already saved
			alreadySaved = 0;
			for jj = 1:size(allStims_Paths,1)
				if strcmpi(allStims_Paths{jj},playseq{kEvent,colPlaySeqPath})
					alreadySaved = 1;
					mapEventToStim(kEvent) = jj;
					tempStimNo = jj; % it is remembered here so that the next 'play' takes this one
					break
				end
			end
			
			if alreadySaved
				duration = allStims_Duration(tempStimNo);
			else
				
				
				all_files = []; % files in current folder
				for kk = 1:size(acceptedImgTypes,2)
					folder_path_filter = dir([folderPath filesep acceptedImgTypes{kk}]);
					all_files = [all_files; folder_path_filter];
				end
				
				
				no_frames = size(all_files,1);
				if no_frames == 0
					disp(folderPath)
					exp_Error('nofiles','warning')
					return
				end
				
				im_matrixt = imread([folderPath filesep all_files(1).name]);
				
				% takes the framerate and makes sure it is not zero by comparing
				% with the default framerate
				framerate = defaultFramerate;
				if size(playseq,2)>=colPlaySeqFramerate && ~isempty(playseq{kEvent,colPlaySeqFramerate})
					framerate = playseq{kEvent,colPlaySeqFramerate};
				end
				
				% gets duration from playseq, if it exists
				duration = defaultDuration;
				if size(playseq,2)>=colPlaySeqDuration && ~isempty(playseq{kEvent,colPlaySeqDuration})
					duration = playseq{kEvent,colPlaySeqDuration};
				end
				
				no_frames = floor(min(no_frames,duration*framerate));
				
				% duration is determined by the number of files and framerate
				duration = min(duration,no_frames/framerate);
				
				
				% save details for each stimulus (once for each stim)
				allStimsNo = allStimsNo + 1;
				allStims_Paths{allStimsNo} = playseq{kEvent,colPlaySeqPath};
				allStims_NoFrames(allStimsNo) = min(no_frames,duration*framerate);
				allStims_Framerate(allStimsNo) = framerate;
				[allStims_imH(allStimsNo), allStims_imW(allStimsNo)]= size(im_matrixt);
				allStims_Duration(allStimsNo) = duration;
				
				clear im_matrixt
				
				% create a map btw event and stimulus
				mapEventToStim(kEvent) = allStimsNo;
				
				% remembers current stim to use for next events related to
				% this: eg. remembers for 'load' to use it at a later 'play'
				tempStimNo = allStimsNo; % it is remembered here so that the next 'play' takes this one
				
			end
			
		case {'moviecode', 'newmovie'}
			duration = defaultSeparatorDuration;
			if playseq{kEvent,colPlaySeqPath} ~= defaultBlankScreenCode
				% takes the value from load event
				mapEventToStim(kEvent) = tempStimNo;
			end
		case 'blankscreen'
			duration = playseq{kEvent,colPlaySeqDuration};
		case 'newblock'
			duration = defaultSeparatorDuration;
		case 'wait'
			duration = playseq{kEvent,colPlaySeqDuration};
		case 'play'
			% duration for this event is added in the load event above
			mapEventToStim(kEvent) = tempStimNo; % takes the value from load event
	end
	
	totalDuration = totalDuration + duration;
	% 	disp(num2str([duration totalDuration]))
	
	
	% flip vectors to be columns
	if allStimsNo == 2
		allStims_Paths = allStims_Paths';
		allStims_NoFrames = allStims_NoFrames'; % number of frames for each stim
		allStims_Framerate = allStims_Framerate'; % framerate for each stim
		allStims_imH = allStims_imH';
		allStims_imW = allStims_imW';
		allStims_Duration = allStims_Duration';
	end
end

%% Creating mat files for all stimuli
if LoadAtTheBeginning
	tic
	
	% builds matrices from individual frames
	exp_load_and_save(allStims_Paths, allStims_NoFrames, forceReloadAllStimuli);
	
	loading_time = toc;
	fprintf('Stimuli loaded (%.3f sec).\n', loading_time)
end

save([fileroot '_variables.mat']);

fprintf('\nTotal duration: %u'' %u''''\n\n',fix(totalDuration/60),fix(mod(totalDuration,60)));


%diary off; fclose(fid); return

%% Initializes PTB and other settings

% Set skipPTBTests to 1 if this runs in Windows. 
% It will prevent Psychtoolbox from crashing at the beginning
if skipPTBTests
	Screen('Preference', 'SkipSyncTests', 1);
end

sca;
oldLevelVisual = Screen('Preference', 'VisualDebugLevel', 3);
oldLevelVerbosity = Screen('Preference','verbosity',0);

AssertOpenGL;

KbName('UnifyKeyNames');

kcEsc = KbName('ESCAPE');
kcSecondName = 'leftshift';
kcSecondDelay = 2;
kcSecondEsc = KbName(kcSecondName);


PsychDefaultSetup(2);
if skipPTBTests
	% reverts changes to default
	Screen('Preference', 'SkipSyncTests', 0);
end

screens = Screen('Screens');
scrNo = max(screens);

[window, windowRect] = Screen(scrNo,'OpenWindow', [0, 0, 0]);
[widthWindow, heightWindow] = Screen('WindowSize', window);
if hideMouse == 1
	HideCursor(scrNo);
end

Screen('TextFont',window,'Arial');
Screen('TextSize',window,20);

% Screen('GetFlipInterval', window)


% gets the REFRESH RATE of the monitor
[FRmonitorFlipInterval, FRnrValidSamples, FRstddev] = Screen('GetFlipInterval',window);
nominalFR = round(1/FRmonitorFlipInterval);

% sets priority
maxPriorityLevel = MaxPriority(window);
Priority(maxPriorityLevel);


%% Start of the presentation
if showText
	Screen('DrawText',window,'Press any key to start',0,heightWindow/2,[255 0 0]);
	Screen('Flip',window);
end

% waits for user input to start
fprintf('\nPress any key to start.\n\n')
KbStrokeWait;
boolEscPressed = 0; % used to stop running; To stop press Esc and then leftshift
EscPressedTime = 0;
boolEndConfirmed = 0;
Screen('Flip',window);

loadEventOn =0;

kEvent = 0;
while kEvent < noEvents
	kEvent = kEvent+1;
	
	% Skips to the last event if, during the play event, it has been requested
	% to stop the execution
	if boolEndConfirmed
		kEvent = noEvents;
	end
	
	switch playseq{kEvent,1}
		
		%% event load
		
		case 'load'
			Screen('Flip', window);
			loadEventOn = 1;
			fprintf('event %u / %u: ',kEvent,noEvents);
			tic
			% extracts the properties of this event
			
			folderPath = playseq{kEvent,colPlaySeqPath};
			[~, folderName,~] = fileparts(folderPath);
			moviecode = playseq{kEvent,colPlaySeqIndex};
			
			RFMappingShowing = 0; % boolean that imposes different run when stim is receptive field mapping
			if ~isempty(strfind(lower(folderName),'rfmap'))
				RFMappingShowing = 1;
			end
			
			
			% takes the framerate and makes sure it is not zero by comparing
			% with the default framerate
			% this is the requested framerate
			framerate = allStims_Framerate(mapEventToStim(kEvent));
			
			% interpolation
			interpolation = defaultInterpolation;
			if size(playseq,2)>=colPlaySeqInterpolation && ~isempty(playseq{kEvent,colPlaySeqInterpolation})
				interpolation = playseq{kEvent,colPlaySeqInterpolation};
			end
			
			% duration
			duration = allStims_Duration(mapEventToStim(kEvent));
			
			% logs the event
			fprintf('   load %s ',folderName) % in command window
			
			% let's assume that in that folder there are only pictures
			folder_path_filter_tif = [folderPath filesep '*.tif'];
			folder_path_filter_png = [folderPath filesep '*.png'];
			all_files = [dir(folder_path_filter_png); dir(folder_path_filter_tif)]; % files in current folder
			
			% number of files
			no_frames = allStims_NoFrames(mapEventToStim(kEvent));
			
			if no_frames > 0
				% only playing a certain number of frames from the total
				% no_files = min(duration*framerate,no_files);
				
				% reads the first file and assumes all other files are the same
				% im_matrixt = imread([folderPath filesep all_files(1).name]);
				
				% gets the size of the image
				imH = allStims_imH(mapEventToStim(kEvent));
				imW = allStims_imW(mapEventToStim(kEvent));
				% clear im_matrixt
				
				% calculates the aspect ratio of the screen
				ratioW = widthWindow/imW;
				ratioH = heightWindow/imH;
				ratioMin = min([ratioW,ratioH]);
				
				% shifts the image to the right with shiftX if image has
				% different aspect ratio
				shiftX = 0;
				if shiftBool
					shiftX = widthWindow-imW*ratioMin;
				end
				TextureRectangle = [shiftX, 0, imW*ratioMin+shiftX, imH*ratioMin];
				%TextureRectangle = [0, 0, widthWindow, heightWindow];
				
				% resets frame timestamps % bc
				VBLTimestamp = zeros(1,no_frames);
				StimulusOnsetTime = zeros(1,no_frames);
				FlipTimestamp = zeros(1,no_frames);
				Missed = zeros(1,no_frames);
				Beampos = zeros(1,no_frames);
				
				% BITCODE for each frame reinitializes to 1 at 1020 (in maxBCode)
				bc = zeros(1,no_frames);
				bcBinary = zeros(no_frames,noBits);
				for i=1:no_frames
					if ~RFMappingShowing
						% if it's a regular movie with bitcodes for each frame
						bc(i) = 1 + mod(i-1,maxBCode);
					else
						% if receptive field mapping then one bitcode identical for all frames i.e moviebitcode
						bc(i) = moviecode;
					end
					bcBinary(i,:) = fliplr(dec2bin(bc(i),noBits)-'0');
				end
				
				
				% TIMING
				tocs = zeros(1,no_frames);
				realFPS = framerate;
				
				% screen refreshes per frame; usually 1 per 60fps, 2 for 30fps,
				% 3 for 20fps etc
				refperframe = fix(nominalFR/framerate);
				
				
				% loads frames into memory
				% matname = preexistent .mat file that contains no_frames frames
				matname = [folderPath filesep 'im_matrix_' num2str(no_frames) '.mat'];
				
				if LoadAtTheBeginning & exist(matname,'file')==2
					% clear im_matrix
					load(matname);
					
					% logs the event
					exp_Log(fid,'load',matname) % in file
				else
					% if the file doesn't exist or the presentation is 'on the fly'
					% then recreate the data
					clear im_matrix
					im_matrix = zeros(no_frames,imH,imW,'uint8');
					
					for i=1:no_frames
						im_matrix(i,:,:) = imread([folderPath filesep all_files(i).name]);
					end
					
					% logs the event
					exp_Log(fid,'load',folderPath) % in file
				end
				
				loading_time = toc;
				fprintf('(%.3f sec)\n',loading_time);
			end
			
			%% event play
		case 'play'
			
			% logs the event
			% exp_Log(fid,'play',folderPath) % in file
			fprintf('event %u / %u: ',kEvent,noEvents);
			fprintf('play %.3f sec\n',allStims_Duration(mapEventToStim(kEvent))) % in command window
			
			
			% boolean that tells if the WHILE below has been completed
			framesPlayed = 0;
			
			i = 1;
			currentRefresh = 0;
			
			while i <= no_frames
				
				t1 = GetSecs;
				
				currentRefresh = currentRefresh + 1;
				
				% SCANS FOR KEYBOARD INPUT
				[keyIsDown, keyDuration, keyCode] = KbCheck;
				if keyIsDown
					if keyCode(kcEsc) && ~boolEscPressed
						boolEscPressed = 1;
						EscPressedTime = GetSecs;
						fprintf('\nEsc pressed. Press %s within %u sec if you want to stop.\n\n',kcSecondName,kcSecondDelay);
					end
					
					if (keyCode(kcSecondEsc)) && boolEscPressed
						boolEscPressed = 0;
						boolEndConfirmed = 1;
						fprintf('\n%s pressed. Protocol will stop at the end of this event.\n\n',kcSecondName);
						%break;
					end
				end
				% if the delay btw Esc and SecondKey is >2 secs (given by kcSecondDelay) cancel stop procedure
				if GetSecs-EscPressedTime>kcSecondDelay && boolEscPressed
					boolEscPressed = 0;
					fprintf('\nEsc not active anymore.\n\n');
				end
				
				
				% creates and draws the texture
				texture = Screen('MakeTexture',window, squeeze(im_matrix(i,:,:)) );
				switch interpolation
					case 'nice'
						Screen('DrawTexture', window, texture,[], TextureRectangle);
					case 'coarse' % especially for white noise
						Screen('DrawTexture', window, texture,[], TextureRectangle,0,0);
				end
				Screen('Close',texture);
				
				% SHOWS FRAMERATE ON SCREEN
				if showText
					if (i>1)
						realFPS = 1/tocs(i-1);
						Screen('DrawText', window, ['Path: ' folderPath],40,10);
						Screen('DrawText', window, ['Movie framerate: ' num2str(framerate) ' fps'],40, 35);
						Screen('DrawText', window, ['Showing frame ' num2str(i) '/' num2str(no_frames) ...
							' at ' num2str(round(realFPS*100)/100) ' fps'],40, 60);
					end
				end
				
				% BITCODE cover
				Screen(window,'FillRect', [0 0 0], shape_pos_cover);
				
				% BITCODE 10 rectangles
				for j=1:noBits
					% white or black
					bcValue = bcBinary(i,j);
					
					shape_pos_rect =  bcR(j,3:6) ;
					Screen(window,'FillRect', repmat(bcValue*255,[1 3]), shape_pos_rect);
				end
				
				% BITCODE timing rectangle
				bcValue = 0;
				if RFMappingShowing % for RF mapping it stays online for all refreshes
					bcValue = 1;
				else % for frames it goes on and off
					if currentRefresh == 1
						% mod(i,2) means that is on for odd frames and off for even frames
						bcValue = mod(i,2);
						
						% other value is simply 1, which is that goes bitcode
						% is on one refresh every time the frame changes
					end
				end
				shape_pos_rect =  bcR(noBits+1,3:6); %bcNo+1 because this one does not encode stim identity
				Screen(window,'FillRect', repmat(bcValue*255,[1 3]), shape_pos_rect);
				
				% ACTUAL PRESENTATION OF THE FRAME: FLIPS the screen
				[VBLTimestamp(i), StimulusOnsetTime(i), FlipTimestamp(i), Missed(i), Beampos(i)] = Screen('Flip', window);
				
				% TIMING and WAITING
				t2 = GetSecs;
				
				% plays next frame or just maintains for another refresh
				if refperframe == currentRefresh
					framesPlayed = framesPlayed + 1;
					currentRefresh = 0;
					i = i + 1;
				end
				
				% used to compute the real fps
				tocs(i) = GetSecs - t1;
			end
			
			Screen('Flip', window);
			
			% logging play
			if no_frames>0
				% exp_Log(fid,'played',playseq{kEvent,2})
				for i=1:framesPlayed
					exp_Log(fid,'timestamp',{moviecode all_files(i).name, i, bc(i), ...
						VBLTimestamp(i), StimulusOnsetTime(i), FlipTimestamp(i), ...
						Missed(i), Beampos(i)});
				end
			else
				fprintf('not played\n');
				exp_Log(fid,'no files',[]);
			end
			
			%% event separator: moviecode newmovie newblock
			
		case {'moviecode' , 'newmovie' , 'newblock'}
			Screen('Flip', window);
			if strcmp(playseq{kEvent,colPlaySeqKeyword},'newblock')
				fprintf('\n')
			end
			
			% outpus log in command window, extra param for newblock
			fprintf('event %u / %u: ',kEvent,noEvents);
			switch playseq{kEvent,colPlaySeqKeyword}
				case 'newblock'
					fprintf('separator %s %u\n', playseq{kEvent,colPlaySeqKeyword}, playseq{kEvent,colPlaySeqNumber});
				case 'newmovie'
					fprintf('separator %s for %.3f sec\n', playseq{kEvent,colPlaySeqKeyword}, defaultSeparatorDuration);
				case 'moviecode'
					fprintf('%s %u\n', playseq{kEvent,colPlaySeqKeyword}, playseq{kEvent,colPlaySeqIndex});
			end
			
			moviecode = playseq{kEvent,colPlaySeqIndex};
			bcBinary_moviecode = fliplr(dec2bin(moviecode,noBits)-'0');
			Screen(window,'FillRect', [0 0 0], shape_pos_cover);
			
			% 10 rectangles
			for j=1:noBits
				% white or black
				bcValue = bcBinary_moviecode(j);
				
				shape_pos_rect =  bcR(j,3:6);
				Screen(window,'FillRect', repmat(bcValue*255,[1 3]), shape_pos_rect);
			end
			
			% timing rectangle
			bcValue = 1;
			shape_pos_rect =  bcR(noBits+1,3:6); %bcNo+1 because this one does not encode stim identity
			Screen(window,'FillRect', repmat(bcValue*255,[1 3]), shape_pos_rect);
			
			waitTime = defaultSeparatorDuration - FRmonitorFlipInterval;
			Screen('Flip', window);
			WaitSecs(waitTime);
			Screen('Flip', window);
			
			%% event wait
		case 'wait'
			
			% executes a 'wait' event
			fprintf('event %u / %u: ',kEvent,noEvents);
			
			exp_Log(fid,'wait',num2str(playseq{kEvent,colPlaySeqDuration}));
			waitTime = playseq{kEvent,colPlaySeqDuration};
			
			waitTimeToDiscount = 0;
			if exist('loadEventOn','var') && loadEventOn
				waitTimeToDiscount = loading_time;
				loadEventOn = 0;
			end
			
			BlackScreenRefreshes = floor((waitTime-waitTimeToDiscount)/FRmonitorFlipInterval);
			BlackScreenRefreshes = max(BlackScreenRefreshes,0);
			
            fprintf('wait %.3f sec (requested %.3f)\n',BlackScreenRefreshes*FRmonitorFlipInterval,playseq{kEvent,colPlaySeqDuration});
			for i = 1:BlackScreenRefreshes
				Screen('Flip', window);
				
                % wait time cannot be stopped with Esc 
			end
			
			
			%% even blankscreen
			
		case 'blankscreen'
			% similar to moviecode and wait
			fprintf('event %u / %u: ',kEvent,noEvents);
			fprintf('blankscreen for %.3f sec\n',playseq{kEvent,colPlaySeqDuration});
			exp_Log(fid,'blankscreen',num2str(playseq{kEvent,colPlaySeqDuration}));
			durationblank = playseq{kEvent,colPlaySeqDuration};
			
			tic
			while toc<durationblank
				% SCANS FOR KEYBOARD INPUT
				[keyIsDown, keyDuration, keyCode] = KbCheck;
				if keyIsDown
					if (keyCode(kcEsc))
						% Exit
						% break;
					end;
				end
			end
			
			
		case 'clear'
			% clears screen; usually at the end of the experiment
			Screen('Flip', window);
			if showText
				Screen('DrawText',window,'Press any key to clear the screen',0,heightWindow/2,[255 0 0]);
				Screen('Flip',window);
			end
			fprintf('\nPress any key to clear the screen.\n\n')
			KbStrokeWait;
			sca;
			fprintf('event %u / %u: ',kEvent,noEvents);
			fprintf('clear\n')
			exp_Log(fid,'clear','');
			ShowCursor(scrNo);
	end
	
end

%% End
Screen('Preference', 'VisualDebugLevel', oldLevelVisual);
Screen('Preference','verbosity',oldLevelVerbosity);
sca
fclose(fid);

% saves diary
diary off

% renames temporary diary
finaldiary = [fileroot '_diary.txt'];
copyfile(tempdiary, finaldiary);
delete(tempdiary);
fprintf('\nLog file: %s\n\n',finaldiary);