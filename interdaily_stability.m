function [IS, ISm, IS60]=interdaily_stability(varargin)
% [IS, ISm, IS60]=interdaily_stability(t,y,numdays)
% INTERDAILY STABILITY - different intervals (new method: Goncalves et al)
% y is my activity time series
% t is the time vector, in hours
% numdays is the number of days we want the analysis for
% default is the max number of whole days in the file
% determine how many samples per minute
if nargin<2
error('Not enough input arguments')
elseif nargin>3
error ('Too many input arguments')
end
t=varargin{1};
y=varargin{2};
tmin=t*60;
fs=1/(tmin(2)-tmin(1)); %samples per minute

if nargin==2
% I want an integer number of days for IS
numdays=floor((t(end)-t(1)+1/60)/24);
else
numdays=varargin{3};
end

tint=t(1:numdays*24*60*fs);
yint=y(1:numdays*24*60*fs);
% use Goncalves method: compute IS for different divisors of 1440
% traditional IS is the one for interval=60 minutes
intervals=[1,2,3,4,5,6,8,9,10,12,15,16,18,20,24,30,32,36,40,45,48,60];
IS=zeros(size(intervals));
ii=1;
for k=intervals
% aggregate activity in bins of size=interval, discard NaNs in averages
avg=zeros(floor(length(yint)/k),1);
for j=1:length(avg)
    win=yint((j-1)*k+1:j*k);
    avg(j)=nanmean(win);
end
% average corresponding intervals of different days
avg3=reshape(avg,length(avg)/numdays,numdays);

avg3=nanmean(avg3,2);
% IS is the ratio between the variance of the average 24-hour pattern
% around the mean and the overall variance of the complete series of 
% individual hourly averages
IS(ii)=nanmean((avg3-nanmean(avg3)).^2)/nanmean((avg-nanmean(avg)).^2);
ii=ii+1;
end
ISm=mean(IS);
IS60=IS(end); %traditional IS (hour by hour)