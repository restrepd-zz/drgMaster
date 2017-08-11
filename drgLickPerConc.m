function handles=drgLickPerConc(handles)
%   Finds the percent lick in the 0.5 to 2.5 sec interval for all OdorOn events

%Enter LFP tetrode and event
sessionNo=handles.sessionNo;
lfpElectrode=19; %19 is the lick

userevTypeNo = handles.evTypeNo;
concx = 1;
plickvals = [];
concxline = [];
hitx = 1;
hitlinex = [];

if strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Hi Od1') || strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Hi Od2') || ...
        strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Hi Od3') || strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Lo Od4') || ...
        strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Lo Od5') || strcmp(handles.drg.draq_d.eventlabels{handles.evTypeNo},'Lo Od6')
    
    for evTypeNo = 16:21
        handles.evTypeNo = evTypeNo;
        
        %Enter trials
        firstTr=1;
        lastTr=handles.drg.session(sessionNo).events(handles.evTypeNo).noTimes;
        
        allnoEvs1=0;
        licks=[];
        
        for evNo=firstTr:lastTr
            %     excludeTrial=drgExcludeTrialLFP(handles.drg,handles.peakLFPNo,handles.drg.session(sessionNo).events(handles.evTypeNo).times(evNo),sessionNo);
            %     if excludeTrial==0
            thisLFP=[];
            [thisLFP, trialNo, can_read] = drgGetTrialLFPData(handles, lfpElectrode, evNo, handles.evTypeNo, handles.time_start, handles.time_end);
            allnoEvs1=allnoEvs1+1;
            if (can_read==1)
                licks(1:length(thisLFP),allnoEvs1)=thisLFP;
            else
                %             szLFP=size(licks);
                %             licks(szLFP(1),allnoEvs1)=zeros(szLFP(1),1);
            end
            %     end
        end
        
        %Now calculate percent lick
        szlicks=size(licks);
        
        skip_artifact_n=ceil(handles.time_pad*handles.drg.session(sessionNo).draq_p.ActualRate); %Need to skip a large jump at the start due to the filtering
        times=[1:(szlicks(1)-2*skip_artifact_n)+1]/handles.drg.session(sessionNo).draq_p.ActualRate;
        times=times+handles.time_start+handles.time_pad;
        thresholded_licks=zeros(szlicks(2),length(licks(skip_artifact_n:end-skip_artifact_n,1))');
        
        for noTr=1:szlicks(2)
            threshold=((prctile(licks(:,noTr),99.5)-prctile(licks(:,noTr),0.5))/2)+prctile(licks(:,noTr),0.5);
            thresholded_licks(noTr,:)=(licks(skip_artifact_n:end-skip_artifact_n,noTr)>=threshold)';
        end
        
        thresholded_licks=double(thresholded_licks);
        trials=1:szlicks(2);
        try
            close 1;
        catch
        end
        
        meanlicks = mean(thresholded_licks,2);
        totmeanlicks = mean(meanlicks);
        
        concxline = [concxline, concx];
        plickvals = [plickvals, totmeanlicks];
        
        figure(2);
        plot(concx,totmeanlicks,'-or');
        line(concxline,plickvals,'Color','blue');
        
        hold on;
        concx = concx+1;
        
        set(gca,'xtick',0:6);
        %     set(gca,'ytick',0.4:0.2:0.8);
        xlabel('Concentration');
        ylabel('Plick');
        title('Probability of licking vs odor conc');
    end
else
    for evTypeNo = [3 9]
        handles.evTypeNo = evTypeNo;
        
        
        %Enter trials
        firstTr=1;
        lastTr=handles.drg.session(sessionNo).events(handles.evTypeNo).noTimes;
        
        allnoEvs1=0;
        licks=[];
        
        for evNo=firstTr:lastTr
            %     excludeTrial=drgExcludeTrialLFP(handles.drg,handles.peakLFPNo,handles.drg.session(sessionNo).events(handles.evTypeNo).times(evNo),sessionNo);
            %     if excludeTrial==0
            thisLFP=[];
            [thisLFP, trialNo, can_read] = drgGetTrialLFPData(handles, lfpElectrode, evNo, handles.evTypeNo, handles.time_start, handles.time_end);
            allnoEvs1=allnoEvs1+1;
            if (can_read==1)
                licks(1:length(thisLFP),allnoEvs1)=thisLFP;
            else
                %             szLFP=size(licks);
                %             licks(szLFP(1),allnoEvs1)=zeros(szLFP(1),1);
            end
            %     end
        end
        
        %Now calculate percent lick
        szlicks=size(licks);
        
        skip_artifact_n=ceil(handles.time_pad*handles.drg.session(sessionNo).draq_p.ActualRate); %Need to skip a large jump at the start due to the filtering
        times=[1:(szlicks(1)-2*skip_artifact_n)+1]/handles.drg.session(sessionNo).draq_p.ActualRate;
        times=times+handles.time_start+handles.time_pad;
        thresholded_licks=zeros(szlicks(2),length(licks(skip_artifact_n:end-skip_artifact_n,1))');
        
        for noTr=1:szlicks(2)
            threshold=((prctile(licks(:,noTr),99.5)-prctile(licks(:,noTr),0.5))/2)+prctile(licks(:,noTr),0.5);
            thresholded_licks(noTr,:)=(licks(skip_artifact_n:end-skip_artifact_n,noTr)>=threshold)';
        end
        
        thresholded_licks=double(thresholded_licks);
        trials=1:szlicks(2);
        try
            close 1;
        catch
        end
        
        meanlicks = mean(thresholded_licks,2);
        totmeanlicks = mean(meanlicks);
        %         hitxline = [1 2];
        %         concxline = [concxline, concx];
        plickvals = [plickvals, totmeanlicks];
        hitlinex = [hitlinex, hitx];
        
        
        %         concxline = [concxline, concx];
        
        figure(2);
        plot(hitx,totmeanlicks,'-or');
        line(hitlinex,plickvals,'Color','blue');
        set(gca,'XTickLabel',handles.whichEvent.String);
        hold on
        hitx = hitx + 1;
        %
        %         hold on;
        % %       set(gca,'xtick',0:6);
        %   %     set(gca,'ytick',0.4:0.2:0.8);
        %         xlabel('Hit vs. CR');
        %         ylabel('Plick');
        title('Probability of licking vs choice');
        
        ylabel('Plick');
        set(gca,'xtick',0:2);
        JL = 1;
        
    end
    
    
    % line(concx,totmeanlicks,'Color','blue');
    
    % hFig1 = figure(1);
    % set(hFig1, 'units','normalized','position',[.05 .15 .85 .3])
    % drg_pcolor(repmat(times,szlicks(2),1),repmat(trials',1,length(times)),double(thresholded_licks))
    % colormap jet
    % shading flat
    % xlabel('Time (sec)')
    % ylabel('Trial No');
    % title(['Licks per trial ' handles.drg.session(1).draq_d.eventlabels{handles.evTypeNo}])
    % caxis([0 1]);
    handles.evTypeNo = userevTypeNo;
end
