% Perform cosinor analysis on actigraphy data
% generates 5 Excel spreadsheets, one for whole recordings, one for weekdays
% one for weekends, one for work days and one for days off
% THE BRIGHAM AND 
% WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
% AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
% PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
% BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
% INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
% FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
% AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
% RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
% please report bugs and malfunctionings to sara.mariani7@gmail.com
% modified 11/14/18 to fix bugs related to rest and wear vectors and weekdays/weekends
% modified 5/17/20 corrected typo line 91
% modified 7/12/20 corrected typo line 54
clc
close all
clear all
warning('off')
scrsz = get(0,'ScreenSize');
PathName = uigetdir(pwd,'Select the folder containing your data files');
PathName2 = uigetdir(pwd,'Select the folder where you want to save your results');
addpath(PathName, PathName2)
datafiles=dir([PathName '\*.xlsx']);

titles=[{'Subject'};{'Numdays'};{'Mesor (log counts)'};{'Amplitude (log counts)'}; ...
    {'Acrophase (dec hours)'}; ];

xlswrite ([PathName2 '\Results.xlsx'],titles');
xlswrite ([PathName2 '\ResultsW.xlsx'],titles');
xlswrite ([PathName2 '\ResultsO.xlsx'],titles');
xlswrite ([PathName2 '\ResultsWD.xlsx'],titles');
xlswrite ([PathName2 '\ResultsWE.xlsx'],titles');

names=cell(length(datafiles),1);
data=NaN+zeros(length(datafiles),length(titles)-1); %here I store the results for all the days
dataW=NaN+zeros(length(datafiles),length(titles)-1); %here I store the results for workdays only
dataO=NaN+zeros(length(datafiles),length(titles)-1); %here I store the results for days off only
dataWD=NaN+zeros(length(datafiles),length(titles)-1); %here I store the results for work days only
dataWE=NaN+zeros(length(datafiles),length(titles)-1); %here I store the results for weekends only
%%
for j=1:length(datafiles)
    xlsxFn=datafiles(j).name;
    name=xlsxFn;
    display(name);
    names{j}=name;
    [~,~,tab]=xlsread([PathName '\' xlsxFn]);
    
    % there is an header in the Excel file: if it changes size, change this value
    numlineshea=4;
    tab(1:numlineshea,:)=[];
    
    % wear column could be 1/0 or w/nw
    wearvec=tab(:,11);
    if ischar(wearvec{1})
        wear=ones(size(wearvec));
        for jj=1:length(wearvec)
             if ~isempty(strfind(wearvec{jj},'n'))|| ...
                ~isempty(strfind(wearvec{jj},'N'))
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
        time=datevec(tab(:,3));
    end
    actigraphy = cell2mat(tab(:,4)); % I am using axis 1
    sleepvec=cell2mat(tab(:,10));
    weekdayvec=tab(:,13);
    
    work=[];
    
    % I need the rest vector to combine with the sleep/wake vector
    restvec=tab(:,14);
    rest=ones(size(restvec));
    for jj=1:length(restvec)
        if ~isempty(strfind(restvec{jj},'n'))|| ...
                    ~isempty(strfind(restvec{jj},'N'))
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
    
    % EMILY'S RULE: REST IS WEAR
    wear(rest>0)=1;
    
    % weekday/weekend could be 1/0 or day of the week
    if ischar(weekdayvec{1})
        weekday=ones(size(weekdayvec));
        for jj=1:length(weekdayvec)
            if ~isempty(strfind(weekdayvec{jj},'Sun')) || ~isempty(strfind(weekdayvec{jj},'Sat')) ...
                    || ~isempty(strfind(weekdayvec{jj},'SUN')) || ~isempty(strfind(weekdayvec{jj},'SAT')) ...
                    || ~isempty(strfind(weekdayvec{jj},'sun')) || ~isempty(strfind(weekdayvec{jj},'sat'))
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
    if numel(unique(y))>1
        m(m==m(end))=m(m==m(end))+12;
    end
    if numel(unique(m))>1 %we are recording between months
        uu=unique(m);
        for u=1:length(uu)-1
            dm=30; %default
            % check if February
            if uu(u)==2
                dm=28;
                % check if leap year
                if mod(y(1),4)==0
                    dm=29;
                end
            elseif any(uu(u)==[1,3,5,7,8,10,12])
                dm=31;
            end
            d(find(m>uu(u)))=d(find(m>uu(u)))+dm;
        end
    end
    y=y-y(1);
    m=m-m(1);
    d=d-d(1);
    timeInHours=d*24+time(:,1)+time(:,2)/60+time(:,3)/3600;
    timeInMinutes=timeInHours*60;
    % check that it makes sense
    if any(diff(round(timeInMinutes*1000))~=1000)
        
        % check for daylight saving time: are we missing one hour
        err=find(diff(round(timeInMinutes*1000))~=1000);
        if numel(err)==1 & time(err+1,1)-time(err,1)==1
            display(['Possibly Daylight Saving Time between ' num2str(time(err,1)) ' and ' ...
                num2str(time(err+1,1)) ' on ' num2str(date(err,2)) '/' num2str(date(err,3))])
            % or do we have a repeated hour?
        elseif numel(err)==1 & time(err+1,1)-time(err,1)==0 & time(err,2)-time(err+1,2)==59
            display(['Possibly Daylight Saving Time at ' num2str(time(err,1)) ' on ' ...
                num2str(date(err,2)) '/' num2str(date(err,3))])
        else
            error('Something wrong in the time/sampling')
            break
        end
    end
    %figure('Name', name, 'Position',...
    %[0.05*scrsz(3) 0.05*scrsz(4) 0.7*scrsz(3) 0.7*scrsz(4)],...
    %'Color',[1 1 1]);
    
    % SELECT DAYS I WANT TO USE
    % whole file
    display('Analysis for the whole file')
%     ax(1)=subplot(2,3,1);
    [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphy,sleep);
%     title('Whole recording                     ')
    data(j,1)=numdays;
    data(j,2)=cosinorStruct.Mesor;
    data(j,3)=cosinorStruct.Amp;
    data(j,4)=cosinorStruct.PhiHours;
    
    clear ('cosinorStruct','numdays')
    
    timeOfDay=mod(timeInHours,24);
    % weekdays/weekends
    % weekdays
    display('Analysis for the weekdays')
    inWE=find(weekday==0 & timeOfDay>=7); %weekend
    actigraphyWD=actigraphy;
    actigraphyWD(inWE)=NaN;
%     ax(2)=subplot(2,3,2);
    [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphyWD,sleep);
%     title('Weekdays                     ')
    dataWD(j,1)=numdays;
    dataWD(j,2)=cosinorStruct.Mesor;
    dataWD(j,3)=cosinorStruct.Amp;
    dataWD(j,4)=cosinorStruct.PhiHours;
    clear ('cosinorStruct','numdays')
    % weekends
    display('Analysis for the weekends')
    inWD=find(weekday & timeOfDay>=7); %weekday
    actigraphyWE=actigraphy;
    actigraphyWE(inWD)=NaN;
%     ax(3)=subplot(2,3,3);
    [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphyWE,sleep);
%     title('Weekends                     ')
    dataWE(j,1)=numdays;
    dataWE(j,2)=cosinorStruct.Mesor;
    dataWE(j,3)=cosinorStruct.Amp;
    dataWE(j,4)=cosinorStruct.PhiHours;
    
    clear ('cosinorStruct','numdays')
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
%         ax(4)=subplot(2,3,4);
        [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphyW,sleep);
%         title('Work Days                     ')
        dataW(j,1)=numdays;
        dataW(j,2)=cosinorStruct.Mesor;
        dataW(j,3)=cosinorStruct.Amp;
        dataW(j,4)=cosinorStruct.PhiHours;
        
        clear ('cosinorStruct','numdays')
        % days off
        display('Analysis for the days off')
        inW=find(work & timeOfDay>=7); %workdays
        actigraphyO=actigraphy;
        actigraphyO(inW)=NaN;
%         ax(5)=subplot(2,3,5);
        [cosinorStruct, numdays]=mainCosinorOctave(timeInHours,actigraphyO,sleep);
%         title('Days Off')
        dataO(j,1)=numdays;
        dataO(j,2)=cosinorStruct.Mesor;
        dataO(j,3)=cosinorStruct.Amp;
        dataO(j,4)=cosinorStruct.PhiHours;
        
        clear ('cosinorStruct','numdays')
        %save paramfile.mat names data dataWD dataWE dataW dataO
    end
end
xlswrite ([PathName2 '\Results.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\Results.xlsx'],data,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWD.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWD.xlsx'],dataWD,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWE.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsWE.xlsx'],dataWE,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsW.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsW.xlsx'],dataW,['B2:AZ', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsO.xlsx'],names,['A2:A', num2str(length(names)+1)]);
xlswrite ([PathName2 '\ResultsO.xlsx'],dataO,['B2:AZ', num2str(length(names)+1)]);
