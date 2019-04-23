function [ output] = TimeNowToString( ct )

if nargin<1
    ct=clock;
end
%TIMETOSTRING Converts actual time in a nice string
output = [sprintf('%04u',ct(1)) '_' ... % year
    sprintf('%02u',ct(2)) '_' ... % month
    sprintf('%02u',ct(3)) '__' ... % day
    sprintf('%02u',ct(4)) '_' ... % hour
    sprintf('%02u',ct(5)) '_' ... % second
    sprintf('%02u',round(ct(6)))];

end

