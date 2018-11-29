function [L5,M10,L5mid,M10mid,RA,logAmp]=amplitudes(varargin)
%[L5,M10,L5mid,M10mid,RA,logAmp]=amplitudes(t,y,numdays,mode)
% modified 2/16/17 --> added mode option
% mode=0 (default) computes L5 and M10 using moving average of signal
% mode=1 computes L5 and M10 using filtfilt, which filters twice (obtains
% smoother signal)
% modified 11/28/18 --> corrected a bug in case mode=1 that caused M10 to find the wrong number

if nargin<2
error('Not enough input arguments')
elseif nargin>4
error ('Too many input arguments')
end
t=varargin{1};
y=varargin{2};

tmin=t*60;
fs=1/(tmin(2)-tmin(1)); %samples per minute

if nargin==2
% I want an integer number of days
numdays=floor((t(end)-t(1)+1/60)/24);
else
numdays=varargin{3};
end

if nargin==4
    mode=varargin{4};
else
    mode=0;
end

tint=t(1:numdays*24*60*fs);
yint=y(1:numdays*24*60*fs);

% average corresponding intervals of different days
avg=reshape(yint,length(yint)/numdays,numdays);
avg=nanmean(avg,2);
% make it circular
avg=[avg;avg];
%tavg=tint(1:length(avg));
tavg=tint(1)+[0:length(avg)-1]/60;
%% L5 MIDPOINT
% find least active 5-hour period
w=ones(round(60*fs*5),1)./(60*fs*5); %average on 5 hours
% option 0:simple moving average
if mode==0
y5hours=nanfilter(w,1,avg);
y5hours(1:150)=[];
else % option 1:2-direction filter (smoother)
    y5hours=nanfiltfilt(w,1,avg);
end
y5hours(1:60*fs*5/2)=9999;
y5hours(end-60*fs*5/2:end)=9999;
[L5,i]=nanmin(y5hours);
L5mid=tavg(i);
% figure
% plot(tavg,avg)
% hold on
% plot(tavg(1:length(y5hours)),y5hours)
% plot(L5mid,L5,'*c')
if L5mid>24, L5mid=mod(L5mid,24); end
%% M10 MIDPOINT
% find most active 10-hour period
w=ones(round(60*fs*10),1)./(60*fs*10); %average on 5 hours
if mode==0
y10hours=nanfilter(w,1,avg);
y10hours(1:300)=[];
y10hours(1:60*fs*10/2)=0;
y10hours(end-60*fs*10/2:end)=0;
else
    y10hours=nanfiltfilt(w,1,avg);
    y10hours(1:60*fs*10)=0;
y10hours(end-60*fs*10:end)=0;
end
[M10,i]=nanmax(y10hours);
M10mid=tavg(i);

% plot(tavg(1:length(y10hours)),y10hours)
% plot(M10mid,M10,'*m')
if M10mid>24, M10mid=mod(M10mid,24); end
RA=(M10-L5)/(M10+L5);
logAmp=log(M10-L5);
