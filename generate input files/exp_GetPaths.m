function [ RFMapIndexes, AllIndexes ] = exp_GetPaths( fid )
%EXP_GETPATHS Creates the first part of the input file: lists all videos
% in a specific folder.
%   The function also adds the keywords needed to load the videos in an
%   experiment.
%  It is called from exp_GenerateInputFile
% 
% fid = file index

pthAll = uigetdir;

if pthAll == 0  
    fprintf('Videos not listed.\n');
    return;
end

% outputfile = 'exp_List_of_videos.txt';
% fid = fopen(outputfile,'wt');

folders = dir(pthAll);
folders = {folders.name};% 3 because the first two are 'go back' folders


RFMapIndexes = [];
AllIndexes = [];

for i=1:length(folders) 
    entry = [pthAll filesep folders{i}];
    idx = str2num(folders{i}(1:min(4,length(folders{i}))));
    
    if isdir(entry) && ~isempty(idx)
        
        fprintf(fid,'load\tpath\t%s\tindex\t%u\n',entry,idx);
        
        AllIndexes(idx) = 1;
        if ~isempty(strfind(lower(folders{i}),'rfmap')) % folder that contain RFmap in their name are for receptive field
            RFMapIndexes(idx) = 1;
        end
    end
end
%fclose(fid);

% fprintf('Operation successful: folders listed in %s\n',outputfile);
% edit(outputfile);
end

