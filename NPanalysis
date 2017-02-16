% Perform non parametric analysis 
% please report bugs and malfunctionings to sara.mariani7@gmail.com
% generates 5 Excel spreadsheets, one for whole recordings, one for weekdays
% one for weekends, one for work days and one for days off
clc
close all
clear all
warning('off')
scrsz = get(0,'ScreenSize');
PathName = uigetdir(pwd,'Select the folder containing your data files');
PathName2 = uigetdir(pwd,'Select the folder where you want to save your results');
addpath(PathName, PathName2)

datafiles=dir([PathName '\*.xlsx']);

titles=[{'Subject'};{'Numdays'};{'Amplitude (log counts)'};{'RA'};{'L5 midpoint (dec hours)'}; ...
    {'M10 midpoint (dec hours)'}; {'L5 (counts)'}; {'M10 (counts)'};...
    {'IS1'};{'IS2'};{'IS3'};{'IS4'};{'IS5'};{'IS6'};{'IS8'};{'IS9'}; ...
    {'IS10'};{'IS12'};{'IS15'};{'IS16'};{'IS18'};{'IS20'};{'IS24'};{'IS30'};...
    {'IS32'};{'IS36'};{'IS40'};{'IS45'};{'IS48'};{'IS60'};{'IV1'};{'IV2'};...
    {'IV3'};{'IV4'};{'IV5'};{'IV6'};{'IV8'};{'IV9'};{'IV10'};{'IV12'};...
    {'IV15'};{'IV16'};{'IV18'};{'IV20'};{'IV24'};{'IV30'};{'IV32'};{'IV36'};...
    {'IV40'};{'IV45'};{'IV48'};{'IV60'};{'Valid Days'};{'TST (min)'};{'TIB (min)'};{'SE (%)'}];
    
xlswrite ([PathName2 '\Results.xlsx'],titles');
xlswrite ([PathName2 '\ResultsW.xlsx'],titles');
xlswrite ([PathName2 '\ResultsO.xlsx'],titles');
xlswrite ([PathName2 '\ResultsWD.xlsx'],titles');
xlswrite ([PathName2 '\ResultsWE.xlsx'],titles');

names=cell(length(datafiles),1);
data=NaN+zeros(length(datafiles),length(titles)-5); %here I store the results for all the days
dataW=NaN+zeros(length(datafiles),length(titles)-5); %here I store the results for workdays only
dataO=NaN+zeros(length(datafiles),length(titles)-5); %here I store the results for days off only
dataWD=NaN+zeros(length(datafiles),length(titles)-5); %here I store the results for work days only
dataWE=NaN+zeros(length(datafiles),length(titles)-5); %here I store the results for weekends only
D={};
TST={};
TIB={};
SE={};
tic
%%
for j=1:length(datafiles)
    xlsxFn=datafiles(j).name;
    name=xlsxFn;
    display(name);
    names{j}=name;
    [~,~,tab]=xlsread([PathName '\' xlsxFn]);   
    
        % there is an header in the Excel file: if it changes size, change this value
    numlineshea=1;
    tab(1:numlineshea,:)=[];
    
    % wear column could be 1/0 or w/nw
    wearvec=tab(:,12);
    if ischar(wearvec{1})
    wear=ones(size(wearvec));
    for jj=1:length(wearvec)
        if (strfind(wearvec{jj},'n')==1 | strfind(wearvec{jj},'N')==1)
            wear(jj)=0;
        end
    end
    else
    wear=cell2mat(wearvec);
    end
    
    % HANDLE NON-WEAR TIME (PART1)
    % eliminate non-wear times at beginning and end
    w=1;
    while wear(w)==0
      w=w+1;
    end

    ww=length(wear);
    while wear(ww)==0
      ww=ww-1;
    end
    tab=tab(w:ww,:);
    wear=wear(w:ww,:);
    
    numEntries = size(tab,1);
    
    % assign columns to variables
    try
    date=datevec(cell2mat(tab(:,2)));
    catch
    date=datevec(tab(:,2));
    end
    try
    time=datevec(cell2mat(tab(:,3)));
    catch
    date=datevec(tab(:,3));
    end
    actigraphy = cell2mat(tab(:,4)); % I am using axis 1
    sleepvec=cell2mat(tab(:,10));    
    weekdayvec=tab(:,13);
   
    work=[];
    
    % I need the rest vector to combine with the sleep/wake vector
    restvec=tab(:,14);
    rest=ones(size(restvec));
    for jj=1:length(restvec)
        if (strfind(restvec{jj},'n')==1 | strfind(restvec{jj},'N')==1)
            rest(jj)=0;
        end
    end
    
    % sleep column could be 0/1 or W/S
    if ischar(sleepvec(1))
    sleep=zeros(size(sleepvec));
    sleep(strfind(sleepvec','s'))=1;
    sleep(strfind(sleepvec','S'))=1;
    else
    sleep=sleepvec;
    end
    
    sleep=sleep.*rest;
    
    % REST IS WEAR
    wear(rest>0)=1;
    
    % weekday/weekend could be 1/0 or day of the week
    if ischar(weekdayvec{1})
    weekday=ones(size(weekdayvec));
    for jj=1:length(weekdayvec)
    if (strfind(weekdayvec{jj},'Sun') | strfind(weekdayvec{jj},'Sat') ...
    | strfind(weekdayvec{jj},'SUN') | strfind(weekdayvec{jj},'SAT') ...
    | strfind(weekdayvec{jj},'sun') | strfind(weekdayvec{jj},'sat'))
    weekday(jj)=0;
    end
    end
    else
    weekday=cell2mat(weekdayvec);
    end
    
    % HANDLE NON-WEAR TIME (PART2)
    % replace non-wear with NaN
    actigraphy(wear==0)=NaN;
    timeInHours=zeros(numEntries,1);
    
    % COMPUTE TIME IN HOURS
    date=date(:,1:3);
    time=time(:,4:6);
    d=date(:,3);
    m=date(:,2);
    y=date(:,1);
    dy=365; %default
    dm=30; %default
    if numel(unique(m))>1 %we are recording between months
      % check if February
      if m(1)==2
      dm=28;
      % check if leap year
                if mod(y(1),4)==0
                    dm=29;
                end
      elseif any(m(1)==[1,3,5,7,8,10,12])
      dm=31;
      end
      d(find(m==m(end)))=d(find(m==m(end)))+dm;
    end
    
    y=y-y(1);
    m=m-m(1);
    d=d-d(1);
    timeInHours=d*24+time(:,1)+time(:,2)/60+time(:,3)/3600;
    timeInMinutes=timeInHours*60;
    % check that it makes sense
    if any(diff(round(timeInMinutes*1000))~=1000)
    error('Something wrong in the time/sampling')
    break
    end
    
    %figure('Name', name, 'Position',...
    %[0.05*scrsz(3) 0.05*scrsz(4) 0.7*scrsz(3) 0.7*scrsz(4)],...
    %'Color',[1 1 1]);
    
    % SELECT DAYS I WANT TO USE
    % whole file
    display('Analysis for the whole file')
    %ax(1)=subplot(2,3,1);
    [IS, IV, L5, M10, L5mid, M10mid,RA,Amp,numdays,days,nightsleep,nightrest]=mainNParametricMatlab(timeInHours,actigraphy,sleep,rest);
    %title('Whole recording')
    data(j,1)=numdays;
    data(j,2)=Amp;
    data(j,3)=RA;
    data(j,4)=L5mid;
    data(j,5)=M10mid;
    data(j,6)=L5;
    data(j,7)=M10;
    data(j,8:29)=IS;
    data(j,30:end)=IV;
    clear ('IS', 'IV', 'L5', 'M10', 'L5mid', 'M10mid','RA','Amp','numdays')
    D{j,1}=num2str(find(days));
    TST{j,1}=num2str(nightsleep);
    TIB{j,1}=num2str(nightrest);
    SE{j,1}=num2str(nightsleep./nightrest*100);
    timeOfDay=mod(timeInHours,24);
    % weekdays/weekends 
    % weekdays
    display('Analysis for the weekdays')
    inWE=find(weekday==0 & timeOfDay>=7); %weekend
    actigraphyWD=actigraphy;
    actigraphyWD(inWE)=NaN;
    %ax(2)=subplot(2,3,2);
    [IS, IV, L5, M10, L5mid, M10mid,RA,Amp,numdays]=mainNParametricMatlab(timeInHours,actigraphyWD,sleep,rest);
    %title('Weekdays')
    dataWD(j,1)=numdays;
    dataWD(j,2)=Amp;
    dataWD(j,3)=RA;
    dataWD(j,4)=L5mid;
    dataWD(j,5)=M10mid;
    dataWD(j,6)=L5;
    dataWD(j,7)=M10;
    dataWD(j,8:29)=IS;
    dataWD(j,30:end)=IV;
    clear ('IS', 'IV', 'L5', 'M10', 'L5mid', 'M10mid','RA','Amp','numdays')
    % weekends
    display('Analysis for the weekends')
    inWD=find(weekday & timeOfDay>=7); %weekday
    actigraphyWE=actigraphy;
    actigraphyWE(inWD)=NaN;
    %ax(3)=subplot(2,3,3);
    [IS, IV, L5, M10, L5mid, M10mid,RA,Amp,numdays]=mainNParametricMatlab(timeInHours,actigraphyWE,sleep,rest);
    %title('Weekends')
    dataWE(j,1)=numdays;
    dataWE(j,2)=Amp;
    dataWE(j,3)=RA;
    dataWE(j,4)=L5mid;
    dataWE(j,5)=M10mid;
    dataWE(j,6)=L5;
    dataWE(j,7)=M10;
    dataWE(j,8:29)=IS;
    dataWE(j,30:end)=IV;
    clear ('IS', 'IV', 'L5', 'M10', 'L5mid', 'M10mid','RA','Amp','numdays')
    % work/off
    if isempty(work)
    display('No record of workdays and days off present: I will skip this analysis')
    dataW(j,:)=NaN;
    else
    % workdays
    display('Analysis for the workdays')
    inO=find(work==0 & timeOfDay>=7); %days off
    actigraphyW=actigraphy;
    actigraphyW(inO)=NaN;
    ax(4)=subplot(2,3,4);
    [IS, IV, L5, M10, L5mid, M10mid,RA,Amp,numdays]=mainNParametricMatlab(timeInHours,actigraphyW,sleep);
    title('Work Days')
    dataW(j,1)=numdays;
    dataW(j,2)=Amp;
    dataW(j,3)=RA;
    dataW(j,4)=L5mid;
    dataW(j,5)=M10mid;
    dataW(j,6)=L5;
    dataW(j,7)=M10;
    dataW(j,8:29)=IS;
    dataW(j,30:end)=IV;
     clear ('IS', 'IV', 'L5', 'M10', 'L5mid', 'M10mid','RA','Amp','numdays')
    % days off
    display('Analysis for the days off')
    inW=find(work & timeOfDay>=7); %workdays
    actigraphyO=actigraphy;
    actigraphyO(inW)=NaN;
    ax(5)=subplot(2,3,5);
    [IS, IV, L5, M10, L5mid, M10mid,RA,Amp,numdays]=mainNParametricMatlab(timeInHours,actigraphyO,sleep);
    title('Days Off')
    dataO(j,1)=numdays;
    dataO(j,2)=Amp;
    dataO(j,3)=RA;
    dataO(j,4)=L5mid;
    dataO(j,5)=M10mid;
    dataO(j,6)=L5;
    dataO(j,7)=M10;
    dataO(j,8:29)=IS;
    dataO(j,30:end)=IV;
    clear ('IS', 'IV', 'L5', 'M10', 'L5mid', 'M10mid','RA','Amp','numdays')
    %save paramfile.mat names data dataWD dataWE dataW dataO
    end
end
xlswrite ([PathName2 '\Results.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],data,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],D,['BA2:BA', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],TST,['BB2:BB', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],TIB,['BC2:BC', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],SE,['BD2:BD', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWD.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWD.xlsx'],dataWD,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWE.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWE.xlsx'],dataWE,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsW.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsW.xlsx'],dataW,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsO.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsO.xlsx'],dataO,['B2:AZ', num2str(length(names)+1)]);
toc
