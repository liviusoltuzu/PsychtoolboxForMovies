function [ playseq ] = exp_GenerateSequence( protocol )
%EXP_PLAYSEQUENCE Takes the input file and defines the sequence of events
% that will be interpreted during the execution of experiment.m
%
% Example events: play movie, wait time, clear screen
% New events could be added here when needed
% Called from experiment.m. 

% OUTPUT
% playseq is a cell array, each line is an event, each column the
% properties and instructions for that event
% see constants in exp_constants.m to see what each column contains

% Loads constants
exp_constants


firstPositionRfMap = 0;
kPlay = 0;
for i = 1:length(protocol)
    if ~isempty(protocol{i}) && (protocol{i}{1}(1) ~= '%')
        switch lower(protocol{i}{1})
            % CODE THAT INDICATES BEGINNING OF NEW BLOCK. CONSTANT
            case 'newblock'
                                
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'wait'; %#ok<*AGROW>
                playseq{kPlay, colPlaySeqDuration} = defaultDurAfterSeparator; % seconds
                
                kPlay = kPlay + 1;
                playseq{kPlay, colPlaySeqKeyword} = 'newblock';
                playseq{kPlay, colPlaySeqIndex} = newBlockBitcode;
                playseq{kPlay, colPlaySeqNumber} = str2num(protocol{i}{2});
                playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'wait';
                playseq{kPlay, colPlaySeqDuration} = defaultDurAfterSeparator; % seconds
                % loads folders
            case 'load'
                
                noParams = (length(protocol{i})-1)/2;
                for j=1:noParams
                    switch lower(protocol{i}{j*2})
                        case 'index'
                            idxLoad = str2num(protocol{i}{j*2+1});
                        case 'path'
                            pathLoad = protocol{i}{j*2+1};
                    end
                end
                movies{idxLoad} = pathLoad;
                
                % loads instructions for playing videos
            case {'play', 'playrf'}
                
                
                
                % LOAD
                kPlay = kPlay+1;
                
                % -1 to remove first word and then /2 because each
                % parameter also has a certain value (i.e. there are 2 words)
                noParams = (length(protocol{i})-1)/2;
                for j=1:noParams
                    switch lower(protocol{i}{j*2})
                        case 'index'
							moviecode = str2num(protocol{i}{j*2+1});
                            pathPlay = movies{moviecode};
							if isempty(pathPlay), disp(['Line ' num2str(i)]),exp_Error('wronginputfile','error'),end
                            % invert wait with load to take advantage of
                            % the loading time; then 'wait' event is shortened
							% swapWL is one 1 when there is a 'wait' before 'load'
							swapWL = 0; 
                            if kPlay>1 && strcmp(playseq{kPlay-1, colPlaySeqKeyword},'wait')
								swapWL = 1;
                                tempplayseq = playseq(kPlay - 1*swapWL,:);
                                playseq(kPlay - 1*swapWL,:) = [];
                                
                                playseq{kPlay - 1*swapWL, colPlaySeqKeyword} = 'load';
								playseq{kPlay - 1*swapWL, colPlaySeqIndex} = moviecode;
                                playseq{kPlay - 1*swapWL, colPlaySeqPath} = pathPlay;
                                playseq(kPlay,:) = tempplayseq;
                            else
								playseq{kPlay, colPlaySeqKeyword} = 'load';
								playseq{kPlay, colPlaySeqIndex} = moviecode;
								playseq{kPlay, colPlaySeqPath} = pathPlay;
							end
						case 'framerate'
							playseq{kPlay - 1*swapWL, colPlaySeqFramerate} = str2num(protocol{i}{j*2+1});
						case 'interpolation'
							playseq{kPlay - 1*swapWL, colPlaySeqInterpolation} = protocol{i}{j*2+1};
						case 'duration'
							playseq{kPlay - 1*swapWL, colPlaySeqDuration} = str2num(protocol{i}{j*2+1});
					end
                end
                
                
                switch lower(protocol{i}{1}) %second inner if
                    case 'play'
                        % CODE THAT INDICATES BEGINNING OF NEW MOVIE. CONSTANT
                        kPlay = kPlay + 1;
                        playseq{kPlay, colPlaySeqKeyword} = 'newmovie';
                        playseq{kPlay, colPlaySeqIndex} = newMovieBitcode;
                        playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                        
                        % WAIT pause between the moviecode and the movie
                        kPlay = kPlay+1;
                        playseq{kPlay, colPlaySeqKeyword} = 'wait';
                        playseq{kPlay, colPlaySeqDuration} = defaultDurAfterSeparator; % seconds
                        
                        % MOVIECODE
                        kPlay = kPlay+1;
                        playseq{kPlay, colPlaySeqKeyword} = 'moviecode';
                        playseq{kPlay, colPlaySeqIndex} = moviecode;
                        playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                        
                        % WAIT pause between the moviecode and the movie
                        kPlay = kPlay+1;
                        playseq{kPlay, colPlaySeqKeyword} = 'wait';
                        playseq{kPlay, colPlaySeqDuration} = defaultDurAfterSeparator; % seconds
                        
                        % I put this here because I want a new 'newmovie'
                        % separator every time a series of rfmaps start
                        % after a regular movie
                        
                        firstPositionRfMap = 0;
                    case 'playrf'
                        
                        if ~firstPositionRfMap
                            %CODE THAT INDICATES BEGINNING OF NEW MOVIE. CONSTANT
                            kPlay = kPlay + 1;
                            playseq{kPlay, colPlaySeqKeyword} = 'newmovie';
                            playseq{kPlay, colPlaySeqIndex} = newMovieBitcode;
                            playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                            % it's on when already the first movie in the
                            % receptive field mapping protocol has been put in the sequence
                            firstPositionRfMap = 1;
                            
                            kPlay = kPlay+1;
                            playseq{kPlay, colPlaySeqKeyword} = 'wait';
                            playseq{kPlay, colPlaySeqDuration} = defaultDurAfterSeparator; % seconds
                        end
                end
                
                % PLAY
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'play';
                
                % loads instruction for waiting [values in seconds]
            case 'wait'
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'wait';
                playseq{kPlay, colPlaySeqDuration} = str2num(protocol{i}{3});
                
            case 'blankscreen'
                
                kPlay = kPlay + 1;
                playseq{kPlay, colPlaySeqKeyword} = 'newmovie';
                playseq{kPlay, colPlaySeqIndex} = newMovieBitcode;
				playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'moviecode';
                playseq{kPlay, colPlaySeqIndex} = defaultBlankScreenCode;
				playseq{kPlay, colPlaySeqDuration} = defaultSeparatorDuration;
                
                kPlay = kPlay+1;
                playseq{kPlay, colPlaySeqKeyword} = 'blankscreen';
                playseq{kPlay, colPlaySeqDuration} = str2num(protocol{i}{3});
                
            otherwise
                fprintf('Line %u skipped \n',i)
        end
    end
    
end

% closes the protocol = makes sure that the screen is cleared at the end
kPlay = kPlay+1;
playseq{kPlay,colPlaySeqKeyword} = 'clear';
end

