function drgRunBatchBehavior

%Ask user for the m file that contains information on what the user wants the analysis to be
%This file has all the information on what the user wants done, which files
%to process, what groups they fall into, etc
%
% An example of this file: drgbChoicesDanielPrelim
%
%

close all
clear all

%
% % which_display=1 used to show first and last behavior
% % For Daniel's new Fig. 1
% % drgbChoicesDanielAPEBfirstandlastBeh11618.m
% % drgbChoicesDanielEAPAfirstandlastBeh11418.m
% % drgbChoicesDanielIAMOirstandlastBeh11618.m
% which_display=1;
% trial_window=30;

% which_display=2 is used to show behavior for per and post laser for Fig.
% 6 of Daniel's paper
% drgbChoicesDanielAPEBexperimentalBeh02012018
which_display=1;
trial_window=20;

which_file=1; %1=.m   2=.mat

if which_file==1
    [choiceFileName,choiceBatchPathName] = uigetfile({'drgbChoices*.m'},'Select the .m file with all the choices for analysis');
    addpath(choiceBatchPathName)
    eval(['handles=' choiceFileName(1:end-2) ';'])
    handles.choiceFileName=choiceFileName;
    handles.choiceBatchPathName=choiceBatchPathName;
    
    new_no_files=length(handles.drgbchoices.PathName);
    choicePathName=handles.drgbchoices.PathName;
    choiceFileName=handles.drgbchoices.FileName;
    
    %Do batch processing for each file
    for filNum=1:length(handles.drgbchoices.FileName)
        file_no=filNum
        
        this_file=handles.drgbchoices.FileName{filNum};
        
        if strcmp(this_file(1:3),'jt_')
            %read the jt_times files
            handles.jtfullName=[handles.drgbchoices.PathName,handles.drgbchoices.FileName{filNum}];
            handles.jtFileName=handles.drgbchoices.FileName{filNum};
            handles.jtPathName=handles.drgbchoices.PathName;
            
            
            drgRead_jt_times(handles.jtPathName,handles.jtFileName);
            
            FileName=[handles.jtFileName(10:end-4) '_drg.mat'];
            handles.fullName=[handles.jtPathName,FileName];
            handles.FileName=FileName;
            handles.PathName=handles.jtPathName;
            
            load(handles.fullName);
            handles.drg=drg;
            
            if handles.read_entire_file==1
                handles=drgReadAllDraOrDg(handles);
            end
            
            switch handles.drg.session(handles.sessionNo).draq_p.dgordra
                case 1
                case 2
                    handles.drg.drta_p.fullName=[handles.jtPathName handles.jtFileName(10:end-4) '.dg'];
                case 3
                    handles.drg.drta_p.fullName=[handles.jtPathName handles.jtFileName(10:end-4) '.rhd'];
            end
            
            
            
            %Set the last trial to the last trial in the session
            handles.lastTrialNo=handles.drg.session(handles.sessionNo).events(2).noTimes;
            
            %Save information for this file
            handles.drgb.filNum=filNum;
            handles.drgb.file(filNum).FileName=handles.FileName;
            handles.drgb.file(filNum).PathName=handles.PathName;
            
            [handles.drgb.file(filNum).perCorr, handles.drgb.file(filNum).encoding_trials, handles.drgb.file(filNum).retrieval_trials, encoding_this_evTypeNo,retrieval_this_evTypeNo]=drgFindEncRetr(handles);
            
        else
            %Read dropc .mat file
            handles.dropc_hand=drg_dropc_load([handles.drgbchoices.PathName,handles.drgbchoices.FileName{filNum}]);
            
            
            %Compute percent correct in a 20 trial window
            sliding_window=20; %Trials for determination of behavioral performance
            
            
            no_trials=length(handles.dropc_hand.dropcData.trialTime);
            score=~(handles.dropc_hand.dropcData.trialScore==(handles.dropc_hand.dropcData.odorType-1));
            
            for ii=1:length(handles.dropc_hand.dropcData.trialTime)-sliding_window+1
                first_time=handles.dropc_hand.dropcData.trialTime(ii);
                last_time=handles.dropc_hand.dropcData.trialTime(ii+sliding_window-1);
                handles.drgb.file(filNum).perCorr(ii+(sliding_window/2))=100*sum(score(ii:ii+sliding_window-1))/sliding_window;
                
                if ii==1
                    handles.drgb.file(filNum).perCorr(ii:(sliding_window/2))=handles.drgb.file(filNum).perCorr(ii+(sliding_window/2));
                end
                if ii==length(handles.dropc_hand.dropcData.trialTime)-sliding_window+1
                    handles.drgb.file(filNum).perCorr(ii+(sliding_window/2)+1:length(handles.dropc_hand.dropcData.trialTime))=handles.drgb.file(filNum).perCorr(ii+(sliding_window/2));
                end
            end
            
            handles.drgb.file(filNum).encoding_trials=handles.drgb.file(filNum).perCorr<=65;
            handles.drgb.file(filNum).retrieval_trials=handles.drgb.file(filNum).perCorr>=80;
            
        end
        
        
    end
    
    %Save the data
    save([handles.choiceBatchPathName handles.choiceFileName(1:end-2) '.mat'],'handles')
    
else
    [matFileName,matBatchPathName] = uigetfile({'drgbChoices*.mat'},'Select the .mat file with all the choices for analysis');
    load([matBatchPathName matFileName])
end


%Plot percent correct
try
    close 1
catch
end

hFig1 = figure(1);
set(hFig1, 'units','normalized','position',[.02 .02 .95 .95])

max_session=max(handles.drgbchoices.session_no);
max_mouse=max(handles.drgbchoices.mouse_no);

for filNum=1:length(handles.drgbchoices.FileName)
    subplot(max_mouse,max_session,max_session*(handles.drgbchoices.mouse_no(filNum)-1)+handles.drgbchoices.session_no(filNum))
    set(gca,'FontName','Arial','FontSize',12,'FontWeight','Bold',  'LineWidth', 2)
    % subplot(3,1,1)
    trials=1:length(handles.drgb.file(filNum).perCorr);
    
    %Plot in different colors
    plot(trials,handles.drgb.file(filNum).perCorr,'o','MarkerEdgeColor',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7])
    hold on
    plot(trials(handles.drgb.file(filNum).encoding_trials),handles.drgb.file(filNum).perCorr(handles.drgb.file(filNum).encoding_trials),'ob')
    plot(trials(handles.drgb.file(filNum).retrieval_trials),handles.drgb.file(filNum).perCorr(handles.drgb.file(filNum).retrieval_trials),'or')
    
    ylim([0 110]);
%     title([handles.drgbchoices.group_no_names{handles.drgbchoices.group_no(filNum)} ':' handles.drgbchoices.epoch_names{handles.drgbchoices.epoch(filNum)}])
    
    remainder = rem((max_session*(handles.drgbchoices.mouse_no(filNum)-1)+handles.drgbchoices.session_no(filNum))-1,max_session);
    if  remainder==0
        ylabel(handles.drgbchoices.MouseName(handles.drgbchoices.mouse_no(filNum)))
    end
end