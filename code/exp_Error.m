function [  ] = exp_Error( errmess, type )
%EXP_ERROR Produces errors or warnings



switch errmess
	case 'filemissing'
		message = 'Input file missing.';
	case 'nofiles'
		message = 'Folder missing or no images inside.';
	case 'wronginputfile'
		message = 'Wrong input file.';
end

switch type
	case 'error'
		error(message)
		
	case 'warning'
		warning(message)
	case 'info'
		disp(message)
end
		



end

