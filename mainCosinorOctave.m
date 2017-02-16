function [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphy,sleep)
% performs cosinor analysis
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
% handle non-wear times (part 3)
% discard days where there are too many NaNs
discard=zeros(size(yint));
disc=0;
for jj=1:numdays
    sig=yint((jj-1)*24*60+1:jj*24*60);
    sigsleep=sleepint((jj-1)*24*60+1:jj*24*60);
    tday=tint((jj-1)*24*60+1:jj*24*60);
    tday=mod(tday,24);
    daysig=sig(sigsleep==0); % activity during wakefulness
    nightsig=sig(find((sigsleep>0))); %activity during main sleep
    %nightsig=sig(find(sigsleep));
    if (numel(find(~isnan(daysig)))<10*60 || numel(find(isnan(nightsig)))>60)
      % display(['Day ' num2str(jj) ' has too much non-wear time and will be discarded'])
       discard((jj-1)*24*60+1:jj*24*60)=1;
       disc=disc+1;
    end
end
display(['I discarded ' num2str(disc) ' days out of ' num2str(numdays)])
numdays=numdays-disc;

if numdays>0
yint_new=yint(discard==0);
tint_new=tint(discard==0);
figure
ax(1)=subplot(211);

% stitch days together for following analysis
%tint_stitch=tint_new(1)+[0:length(tint_new)-1]/60;
ylog=log(yint_new);

infIndex = find(ylog == -Inf);
ylog(infIndex) = 0;

plot(tint_new,ylog)
xlabel('Time (hours)','fontsize',18)
set(gca,'fontsize',18)

tint_new=tint_new(~isnan(ylog));
ylog(isnan(ylog))=[];
st=tint_new(1);

w = 2*pi/24; %2pi/T T=1 day
alpha = 0.05;
tint_new=tint_new-st+1/60;
cosinorStruct = cosinor(tint_new,ylog,w,alpha);
tint_new=tint_new+st-1/60;
acrophase_hours=tint_new(cosinorStruct.f==max(cosinorStruct.f));
acrophase_hours=mod(acrophase_hours,24);
cosinorStruct.PhiHours=acrophase_hours(1);

%----------- Plotting ----------------------------
hold on
plot(tint_new, cosinorStruct.f,'r',...
   'LineWidth', 2);

legend('Actigraphy','Cosinor model')
set(gca,'fontsize',18)

else
cosinorStruct.Mesor=NaN;
cosinorStruct.PhiHours=NaN;
cosinorStruct.Amp=NaN;
end
