function [IV, IVm, IV60]=intradaily_variability(varargin)
% [IV, IVm, IV60]=intradaily_variability(t,y,numdays)
% INTRADAILY VARIABILITY - different intervals (new method: Goncalves et al)
% y is my activity time series
% t is the time vector, in hours

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
%% INTRADAILY VARIABILITY - different intervals (new method: Goncalves et al)
intervals=[1,2,3,4,5,6,8,9,10,12,15,16,18,20,24,30,32,36,40,45,48,60];
IV=zeros(size(intervals));
ii=1;
for k=intervals
% aggregate activity in bins of size=interval, discard NaNs in the average
avg=zeros(floor(length(yint)/k),1);
for j=1:length(avg)
    win=y((j-1)*k+1:j*k);
    avg(j)=nanmean(win);
end
% compute derivative
d=diff(avg);
% IV is the ratio of the mean square of first derivative 
% and the overall variance of the complete series of individual
% hourly averages
IV(ii)=nanmean(d.^2)/nanvar(avg);
ii=ii+1;
end
IVm=mean(IV);
IV1=IV(1); %IV minute by minute
IV60=IV(end); %IV hour by hour
