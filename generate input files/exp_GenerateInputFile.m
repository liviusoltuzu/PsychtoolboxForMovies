% Generates the sequence of movies to be played randomly
% input:
% noBlocks = no of repetitions of the movies
% idxAll = indexes of the movies that will be played
% idxRFmap = indexes of the receptive fields movies that will be played
% waitBtwBlocks = pause between blocks [in seconds]
% waitBtwMovies = pause between two consecutive movies [in seconds]
% outputFilename = name for the input file
%
% If needed define particular parameters for some movies, like framerate,
% total duration or what interpolation to be used by Psychtoolbox (see Screen('DrawTexture') for help)


clear

% Loads constants
exp_constants




%% File that will be written
outputFilename = 'exp_input_test.txt';
[executionPath,~,~] = fileparts(mfilename('fullpath'));
outputFilename = [executionPath filesep outputFilename];

%% Retrieve list of movies
fid=fopen(outputFilename,'wt');
fprintf(fid,'%% videos\n');
[RFMapIndexes, AllIndexes] = exp_GetPaths(fid);
idxAll = find(AllIndexes);
idxRFmap = find(RFMapIndexes);
idxMovs = setxor(idxAll,idxRFmap);

% to write the protocol only with RFmaps
boolIgnoreMovies = 0;
if boolIgnoreMovies
	idxMovs = [];
end

%%       THIS VARIABLES TO MODIFY
noBlocks = 1; % blocks / trials
boolRandomize = 0; % 1 if movies have to be randomized inside each block

waitBtwBlocks = 0; % wait between blocks [seconds]
waitBtwMovies = 1 ; % wait between movies [seconds]

noRepsRFMapping = 0;

%% INITIALIZE


noIndices = max(idxAll); % the largest bcode present in the list

movInterpolation = cell(1,noIndices);
movFramerate = zeros(1,noIndices);
movDuration = zeros(1,noIndices);

% rfmap matrix of repetitions
if isempty(idxMovs)
    noRepsRFMapping = noBlocks; % used when the protocol is only made of rfmap
end
rfmapseq = repmat(idxRFmap, [1 noRepsRFMapping]);


%% FRAMERATE
movFramerate(1:noIndices) = 30; % sets framerate to all movies

% set different than default framerate
movFramerate(42) = 20; % white noise 42 is shown at 20 hz

%% INTERPOLATION
movInterpolation = {};
% default parameters
for i=1:noIndices
    movInterpolation{i} = 'nice'; % nice vs coarse
end

% which movies to play with special interpolation; for white noise
movInterpolation{42} = 'coarse';
movInterpolation{51} = 'coarse'; % 51 is phase scrambled
movInterpolation{52} = 'coarse'; % 52 is phase scrambled

%% DURATION
% set different than default duration
movDuration(42) = 20.05;



%% WRITING THE FILE

% number of movies
nmovs = length(idxMovs);

% playseq contains the random playing sequence of the movies

noRFsTaken = 0;
playseq=[];
for i=1:noBlocks
    % Adding movies in the sequence
    playseq(i,1:nmovs) = idxMovs(1:nmovs);
    
    % Adds rf maps in the sequence
    % an estimate of the number of bars to add ut to this block
    % but not more than the total number of rfs for this protocol: see min
    % below
    noRFsNeeded = min(ceil(length(rfmapseq) / noBlocks * i),length(rfmapseq));
    
    noRFsNew = noRFsNeeded - noRFsTaken; % rfs to add in this block
    
    % Concatenate the bitcodes of the rfs tot the bitcodes of movies
    playseq(i,nmovs+1 : nmovs + noRFsNew) = rfmapseq(noRFsTaken+1:noRFsTaken + noRFsNew);
    
    % Update no of RF taken up to this protocol
    noRFsTaken = noRFsNeeded;
    
    % Number of stimuli in this block
    stims = nmovs + noRFsNew;
    
    % If randomization needed in the block, randomize all
    if boolRandomize
        playseq(i,1:stims) = playseq(i,randperm(stims));
    else
        % no change
    end
end
if noRFsTaken <  length(rfmapseq)
    error('Check the code! Receptive field protocol incomplete.')
end



fprintf(fid,'\n%% sequence\n');

for j=1:size(playseq,1)
    
    % start of a new block
    fprintf(fid,'\nnewblock\t%u\n',j);
    
    for k=1:size(playseq,2)
        
        mIdx = playseq(j,k); % movie index
        if mIdx~=0
            
            switch mIdx
                
                case num2cell(idxRFmap) % rf mapping
                    fprintf(fid,'wait\tduration\t%5.3f\n',waitTimeForRFMap); % 'wait' before rfmap; constant value
                    fprintf(fid,'playrf\tindex\t%u',mIdx);
                    
                    
                case defaultBlankScreenCode % blank screen
                    % special case for blankscreen
                    fprintf(fid,'blankscreen');
                    
                case num2cell(idxMovs) % movies
                    % 'wait' between movies
                    if waitBtwMovies~=0
                        fprintf(fid,'wait\tduration\t%u\n',waitBtwMovies);
                    end
                    
                    fprintf(fid,'play\tindex\t%u',mIdx);
                    
                    % adds interpolation parameter if necessary
                    %if ~strcmp(interpolation{mIdx}, 'nice')
                    fprintf(fid,'\tinterpolation\t%s',movInterpolation{mIdx});
                    %end
                    
                    % adds framerate parameter if different from 0
                    if movFramerate(mIdx)~=0
                        fprintf(fid,'\tframerate\t%u',movFramerate(mIdx));
                    end
  
            end
            
            % adds duration parameter if different from 0
            if movDuration(mIdx)~=0
                fprintf(fid,'\tduration\t%u',movDuration(mIdx));
            end
            
            % ends line
            fprintf(fid,'\n');
        end
    end
    
    if waitBtwBlocks~=0
        fprintf(fid,'wait\t%u\n',waitBtwBlocks);
    end
    
end
fclose(fid);
fprintf('input file: %s\n',outputFilename);
edit(outputFilename)