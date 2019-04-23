function [  ] = exp_Log( fid,what,content )
%EXP_LOG Creates a log of the sequence of events, movies and frames

fprintf(fid, '%u-%u-%u %u:%u:%02.0f\t',clock);
% 1 at the beginning: that line is important in the analysis; 
% 0 - not important

switch what
    case 'settings'
        fprintf(fid,'0\tsettings %s\n',content);
    case 'load'
        fprintf(fid,'0\tload %s\n',content);
    case 'played'
        fprintf(fid,'0\tplay finished %s\n',content); % not executed anymore
    case 'wait'
        fprintf(fid,'0\twait\t%s\n',content);
	case 'blankscreen'
        fprintf(fid,'0\tblankscreen\t%s\n',content);
    case 'clear'
        fprintf(fid,'0\tcleared screen \n');
    case 'timestamp'
		% movie_bitcode frame_name frame_i bitcode(i) VBLTimestamp(i) StimulusOnsetTime(i) FlipTimestamp(i) Missed(i) Beampos(i)
        fprintf(fid,'1\t%u\t%s\t%u\t%u\t%10.10f\t%10.10f\t%10.10f\t%10.10f\t%u\n',content{1:end});
    case 'no files'
        fprintf(fid,'0\tNo files in the specified folder. Nothing played.\n');
end


end

