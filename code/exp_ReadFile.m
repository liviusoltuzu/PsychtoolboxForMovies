function [ words ] = exp_ReadFile( filePath )
%EXP_READFILE Loads an input file
% This code segments the input file and creates a cell array in which
%   each cell is a line of the input file
% Each line is split into its keywords by the TAB separator

% reads input from input file
if ~exist(filePath,'file')
	disp(filePath)
	exp_Error('filemissing','error')
	
end

fid = fopen(filePath);

tline = fgets(fid);
newline = sprintf('\n');
% delimiter = sprintf('\t');

k = 0;
while ischar(tline)
    k = k+1;
    words(k) = textscan(tline,'%s','delimiter','\t');
    tline = fgets(fid);
end

fclose(fid);
end

