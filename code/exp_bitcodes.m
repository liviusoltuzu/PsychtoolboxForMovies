function [ bcCoords, coverCoords ] = exp_bitcodes(  )
% Coordinates of the bitcode rectangles as copied (approximately) from MWorks
% The last lines convert these coordinates to pixels. MATLAB origin of the
% system of reference is in the top-left corner. Everything is calculated
% from that.
% 
% Note: For the size of a rectangle, (e.g. rectXsiz or CovXsiz) there is no 
% need of exp_mwptb.m, only of a simple multiplication by rapw as defined
% in exp_mwptb.m
%
% cover and photodiodes are arranged like this
% cover     --------------------------------
% 1st row  |                     P11 P10 P9 |
% 2nd row: | P1  P2  P3  P4  P5  P6  P7  P8 |
%           --------------------------------

rectXsize = 1.2;
rectYsize = 1.2;
rectXpos = -48; %-47.5
rectYpos = -32.2;
AnalogYOffset = 2.6; % 2.2
xPosOffset = 2.8; % 2.7

% cover 
CovXsize = 24;
CovYsize = 8;
CovXpos = -38;
CovYpos = -32;

Rects = zeros(11,6);
RectsPTB = Rects;

% second row of photodiodes
for i=1:8
    Rects(i,1) = rectXsize;
    Rects(i,2) = rectYsize;
    Rects(i,3) = rectXpos + xPosOffset * (i-1) - Rects(i,1)/2;
    Rects(i,4) = rectYpos + Rects(i,2)/2;
    Rects(i,5) = Rects(i,3) + Rects(i,1);
    Rects(i,6) = Rects(i,4) - Rects(i,2);
end

%first row of photodiodes
i=9;
Rects(i,1) = rectXsize;
Rects(i,2) = rectYsize;
Rects(i,3) = rectXpos + xPosOffset * 7 - Rects(i,1)/2;
Rects(i,4) = rectYpos + AnalogYOffset + Rects(i,2)/2;
Rects(i,5) = Rects(i,3) + Rects(i,1);
Rects(i,6) = Rects(i,4) - Rects(i,2);

i=10;
Rects(i,1) = rectXsize;
Rects(i,2) = rectYsize;
Rects(i,3) = rectXpos + xPosOffset * 6 - Rects(i,1)/2;
Rects(i,4) = rectYpos + AnalogYOffset + Rects(i,2)/2;
Rects(i,5) = Rects(i,3) + Rects(i,1);
Rects(i,6) = Rects(i,4) - Rects(i,2);

% timing rectangle, still first row
i=11;
Rects(i,1) = rectXsize;
Rects(i,2) = rectYsize;
Rects(i,3) = rectXpos + xPosOffset * 5 - Rects(i,1)/2;
Rects(i,4) = rectYpos + AnalogYOffset + Rects(i,2)/2;
Rects(i,5) = Rects(11,3) + Rects(11,1);
Rects(i,6) = Rects(11,4) - Rects(11,2);

% cover
Cover(1) = CovXsize;
Cover(2) = CovYsize;
Cover(3) = CovXpos - Cover(1)/2;
Cover(4) = CovYpos + Cover(2)/2;
Cover(5) = Cover(3) + Cover(1);
Cover(6) = Cover(4) - Cover(2);

% computes PTB coordinates

RectsPTB(1:end,[1 3 5]) = exp_mwptb(Rects(1:end,[1 3 5]), 1);
RectsPTB(1:end,[2 4 6]) = exp_mwptb(Rects(1:end,[2 4 6]), 2);

CoverPTB([1 3 5]) = exp_mwptb(Cover([1 3 5]), 1);
CoverPTB([2 4 6]) = exp_mwptb(Cover([2 4 6]), 2);

bcCoords = RectsPTB;
coverCoords = CoverPTB;