function[IS, IV, L5,M10,L5mid,M10mid,RA,logAmp,numdays,days,nightsleep,nightrest]=mainNParametricOctave(timeInHours,actigraphy,sleep,rest);
% perform non-parametric analysis
% modified 12/23/15: I changed the criteria for discarding a day
% discard if less than 10 valid hours of wakefulness time
% discard if more than 1 hour nonvalid main sleep time (consider main sleep
% all sleep between 9 pm and 7 am)

% start at 7 am
s=mod(timeInHours,24);
ss=find(s==7);
ss=ss(1);
t = timeInHours(ss:end);
y = actigraphy(ss:end);

% count integer number of days
tmin=t*60;
fs=1/(tmin(2)-tmin(1)); %samples per minute
numdays=floor((t(end)-t(1)+1/60)/24);
tint=t(1:numdays*24*60*fs);
yint=y(1:numdays*24*60*fs);
sleepint=sleep(ss:end);
sleepint=sleepint(1:numdays*24*60*fs);

restint=rest(ss:end);
restint=restint(1:numdays*24*60*fs);

% handle non-wear times (part 3)
% discard days where there are too many NaNs
discard=zeros(size(yint));
disc=0;
days=ones(1,numdays);
nightsleep=zeros(1,length(numdays));
nightrest=zeros(1,length(numdays));
for jj=1:numdays
    sig=yint((jj-1)*24*60+1:jj*24*60);
    sigsleep=sleepint((jj-1)*24*60+1:jj*24*60);
    sigrest=restint((jj-1)*24*60+1:jj*24*60);
    tday=tint((jj-1)*24*60+1:jj*24*60);
    tday=mod(tday,24);
    daysig=sig(sigsleep==0); % activity during wakefulness
    nightsig=sig(find((sigsleep>0))); %activity during main sleep

    nightsleep(jj)=length(nightsig);
    nightrest(jj)=length(find(sigrest>0));
    %nightsig=sig(find(sigsleep));
    if (numel(find(~isnan(daysig)))<10*60 || numel(find(isnan(nightsig)))>60)
      % display(['Day ' num2str(jj) ' has too much non-wear time and will be discarded'])
       discard((jj-1)*24*60+1:jj*24*60)=1;
       disc=disc+1;
       days(jj)=0;
    end
end
display(['I discarded ' num2str(disc) ' days out of ' num2str(numdays)])
numdays=numdays-disc;

if numdays>0
yint_new=yint(discard==0);
tint_new=tint(discard==0);
%figure
%ax(1)=subplot(211);
%plot(tint_new,yint_new)
%xlabel('Time (hours)','fontsize',18)
%ylabel('Magnitude','fontsize',18)
%set(gca,'fontsize',18)

% stitch days together for following analysis
tint_stitch=tint_new(1)+[0:length(tint_new)-1]/60;
%ax(2)=subplot(212);
%plot(tint_stitch,yint_new)
%xlabel('Time (hours)','fontsize',18)
%ylabel('Magnitude','fontsize',18)
%set(gca,'fontsize',18)
%linkaxes(ax)

[IS, ISm, IS60]=interdaily_stability(tint_stitch,yint_new,numdays);
[IV, IVm, IV60]=intradaily_variability(tint_stitch,yint_new,numdays);
[L5,M10,L5mid,M10mid,RA,logAmp]=amplitudes(tint_stitch,yint_new,numdays);

else
IS=IV=L5=M10=L5mid=M10mid=RA=logAmp=NaN;
end

