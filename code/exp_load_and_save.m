function [matfiles] = exp_load_and_save( allStimsPaths, allStimsFrames, forceRewrite)
%EXP_LOAD Loads into a single file (and save it at .mat) all frames in folders given as input
% Each mat file is named like this: im_matrix_#frames.mat, where #frames is
% the number of frames included in the .mat file, starting from frame #1
% eg: im_matrix_600.mat will be of this size [H, W, 600]
%
% forceRewrite = recreates all mat files, no matter if they exist
% Called from experiment.m

exp_constants

if nargin<3
	forceRewrite = 0;
end

matfiles ={};
allStimsNo = length(allStimsPaths);
fprintf('\nLoading %u stimuli:\n',allStimsNo);

for jj = 1:allStimsNo
	
	folderPath = allStimsPaths{jj}; % get path
    [~,foldername,~] = fileparts(folderPath);	
    
	% filters in the current folder only images, as defined by img_filters
	all_files = [];
	for kk = 1:size(acceptedImgTypes,2)
		folder_path_filter = dir([folderPath filesep acceptedImgTypes{kk}]);
		all_files = [all_files; folder_path_filter];
	end
	
	no_files = size(all_files,1);
	no_files = min(no_files,allStimsFrames(jj));
	
	% gets the size of the image
	tempimg = imread([folderPath filesep all_files(1).name]);
	if length(size(tempimg)) > 2
		error('Images should be on 8 bits! Execution aborted.')
	end
	[imH, imW]= size(tempimg);
	
	matpath = [allStimsPaths{jj} filesep 'im_matrix_' num2str(no_files) '.mat'];
    matfiles{jj} = matpath;
    [~,matname,~] = fileparts(matpath);
	
	if ~exist(matpath,'file') || forceRewrite
		im_matrix = zeros(no_files,imH,imW,'uint8');
		for i=1:no_files
			im_matrix(i,:,:) = imread([folderPath filesep all_files(i).name]);
		end
		save(matpath,'im_matrix','-v6');        
		fprintf(' %u (created %s)\n',jj,[foldername filesep matname]);
	else
		fprintf(' %u (exists %s)\n',jj,[foldername filesep matname]);
	end
	
end
end