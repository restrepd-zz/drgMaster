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
        if evTypeNo == 3
            A{1} = 'Hit';
        elseif evTypeNo == 9
            A{2} = 'CR';
        else
            set(gca,'XTickLabel','evTypeNo unknown');
        end
        
        plickvals = [plickvals, totmeanlicks];
        hitlinex = [hitlinex, hitx];
           
        figure(2);
        plot(hitx,totmeanlicks,'-or');
        line(hitlinex,plickvals,'Color','blue');
%         set(gca,'XTickLabel',handles.whichEvent.String);
        hold on
        hitx = hitx + 1;
        %
        %         hold on;
        % %       set(gca,'xtick',0:6);
        %   %     set(gca,'ytick',0.4:0.2:0.8);
        %         xlabel('Hit vs. CR');
        %         ylabel('Plick');
        title('Probability of licking vs choice');
        xlabel('Event');
%         set(axes1,'XTick',[-1 0 1 2 3],'XTickLabel',{'Hit','CR'});
%         set(gca,'Xtick',[-1 0 1 2 3]);
        NumTicks = 2;
        xlim([0.75 2.25]);
        xmarks = [0.25, 1];        
        set(gca,'XTick',linspace(xmarks(1),xmarks(2),NumTicks))        
        JL = 1;
        
    end
    set(gca,'XTickLabel',A);
    ylabel('Plick');
    handles.evTypeNo = userevTypeNo;
end
