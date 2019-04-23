function [ result ] = exp_mwptb( angleDeg,wh )
%exp_mwptb Converts from angles to pixels
% Takes the coordinates used in MWorks and transpose to pixels, which are
% used by PTB
% Note. If the input is the size of a rectangle, then the function will
% provide a wrong result.
% For dimensions, only multiply the dimension [in degrees] with rapw.

% dimensions in mm of the screen
% w = 1038; % likely wrong
% h = 508;% likely wrong

% distance from the screen to the eye
% d = 300;
% d1 = sqrt(d^2+(w/2)^2);

% resolution of the screen
rw = 1920;
rh = 1080;

% subtended angle from the eye to the screen
uw = 119.9412; % degrees
uh = 67.9436; % degrees

rapw = rw/uw;
raph = rh/uh;

% angle = deg2rad(angleDeg);
angle = angleDeg;


if wh == 1 % ie it is a horizontal angle
    result = (angle + uw/2) * rapw;
elseif wh==2 % if vertical
    result = abs(angle - uh/2) * raph;
end
    
end

