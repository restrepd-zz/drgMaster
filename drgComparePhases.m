function handles=drgComparePhases(handles)

anglethetaLFP = [];
anglesniff = [];

%Generates a trial per trial phase histogram
sessionNo=handles.sessionNo;
Fs=handles.drg.session(sessionNo).draq_p.ActualRate;
lowF1=handles.peakLowF;
lowF2=handles.peakHighF;
highF1=handles.burstLowF;
highF2=handles.burstHighF;
pad_time=handles.time_pad;
n_phase_bins=handles.n_phase_bins;

%Enter trials
firstTr=handles.trialNo;
lastTr=handles.lastTrialNo;


[perCorr, encoding_trials, retrieval_trials, encoding_this_evTypeNo,retrieval_this_evTypeNo]=drgFindEncRetr(handles);
%handles=drgPercentLickPerTrial(handles);

if handles.displayData==1
    try
        close 1
    catch
    end
    
    hFig1 = figure(1);
    set(hFig1, 'units','normalized','position',[.55 .27 .35 .15])
end


%Now get the phase of gamma bursts witin theta
no_encoding_trials=0;
no_retrieval_trials=0;
no_trials=0;
enc_phase_histo=[];
retr_phase_histo=[];
all_phase_histo=[];
all_theta_wave=[];
MI_enc=[];
MI_retr=[];
which_event=[];

for trNo=firstTr:lastTr
    
    if handles.displayData==1
        trial_no=trNo
    end
    
    evNo = drgFindEvNo(handles,trNo,sessionNo);
    if evNo~=-1
        excludeTrial=drgExcludeTrialLFP(handles.drg,handles.peakLFPNo,handles.drg.session(sessionNo).events(handles.evTypeNo).times(evNo),sessionNo);
        
        if excludeTrial==0
            handles.peakLFPNo==18
            [LFPlow, trialNo, can_read1] = drgGetTrialLFPData(handles, handles.peakLFPNo, evNo, handles.evTypeNo, handles.time_start, handles.time_end);
            thispeakLFP = handles.peakLFPNo;
            handles.peakLFPNo = 18;
            [LFPsniff, trialNo, can_read2] = drgGetTrialLFPData(handles, handles.burstLFPNo, evNo, handles.evTypeNo, handles.time_start, handles.time_end);
            handles.peakLFPNo = thispeakLFP;
            
            if (can_read1==1)&(can_read2==1)
                no_trials=no_trials+1;
                time(no_trials)=handles.drg.session(sessionNo).trial_start(trialNo);
                which_trial(no_trials)=1;
                perCorr_per_histo(no_trials)=50;
                
                bpFilttheta = designfilt('bandpassiir','FilterOrder',20, ...
                    'HalfPowerFrequency1',lowF1,'HalfPowerFrequency2',lowF2, ...
                    'SampleRate',Fs);
                filtLFPtheta = filtfilt(bpFilttheta,LFPsniff);
                LFPgenv = abs(hilbert(filtLFPtheta)); %theta envelope
                
                thfiltLFPgenv=filtfilt(bpFilttheta,LFPgenv);
                
                
                
                thfiltLFP=filtfilt(bpFilttheta,LFPlow);
                thisanglethetaLFP = angle(hilbert(thfiltLFP)); % phase modulation of amplitude
                anglethetaLFP = [anglethetaLFP thisanglethetaLFP];
                sniffFilt=filtfilt(bpFilttheta,LFPsniff);
                thisanglesniff = angle(hilbert(sniffFilt)); % phase modulation of amplitude
                anglesniff = [anglesniff thisanglesniff];
            end
        end
    end
    
    %end %if eventstamps...
end %for evNo

if handles.displayData==1
    try
        close 2
    catch
    end
    
    hFig2 = figure(2);
    set(hFig2, 'units','normalized','position',[.25 .1 .23 .8])
    
    %Plot the modulation index as a function of trial number
    %     subplot(4,1,1)
    %     trials=1:no_trials;
    %     plot(trials,mod_indx,'o-')
    %     xlabel('Trial No')
    %     ylabel('Modulation index')
    %     title('Modulation index vs trial number')
    plot(anglesniff,anglethetaLFP,'.r');
    hold on
    %     plot(
    
    
    % figure(11)
    % plot(trials,mod_indx,'o-k','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',7,'LineWidth',2)
    % xlabel('Trial No')
    % ylabel('Modulation index')
    % title('Modulation index vs trial number')
    % ylim([0 0.07])
    % set(gca,'FontSize',20,'LineWidth',1.25)
    
    
    
%     Now plot the mean theta waveform
    subplot(4,1,2)
    shadedErrorBar(phase,mean(all_theta_wave,1),std(all_theta_wave,0,1),'-b')
    xlim([0 360])
    title('Mean low frequency waveform')
    xlabel('Degrees')
    
    %Now plot the encoding theta phase histogram for gamma
    subplot(4,1,3)
    shadedErrorBar(phase,mean(enc_phase_histo,1),std(enc_phase_histo,0,1),'-b')
    xlim([0 360])
    title('Phase-amplitude coupling')
    ylabel('Probability')
    xlabel('Phase for low freq oscillation (deg)')
    yl_enc=ylim;
    text(20,yl_enc(1)+0.9*(yl_enc(2)-yl_enc(1)),['MI= ' num2str(mean_MI_enc)])
    
    
    
    try
        close 3
    catch
    end
    
    hFig3 = figure(3);
    set(hFig3, 'units','normalized','position',[.01 .1 .23 .8])
    
    min_prob=prctile(all_phase_histo(:),5);
    max_prob=prctile(all_phase_histo(:),95);
    
    trials=1:no_trials;
    %pcolor(repmat(phase,length(trials),1),repmat(trials',1,length(phase)),all_phase_histo)
    drg_pcolor(repmat(phase,length(trials),1),repmat(trials',1,length(phase)),all_phase_histo)
    colormap jet
    shading flat
    % min_prob=0.0113;
    % max_prob=0.0314;
    caxis([min_prob    max_prob])
    xlabel('Phase for low freq oscillation (deg)')
    ylabel('Trial No');
    title(['Phase-amplitude coupling per trial' handles.drg.session(1).draq_d.eventlabels{handles.evTypeNo}])
    
    try
        close 4
    catch
    end
    
    hFig4 = figure(4);
    set(hFig4, 'units','normalized','position',[.49 .1 .05 .3])
    
    
    prain=[min_prob:(max_prob-min_prob)/99:max_prob];
    pcolor(repmat([1:10],100,1)',repmat(prain,10,1),repmat(prain,10,1))
    colormap jet
    shading interp
    ax=gca;
    set(ax,'XTickLabel','')
    
    try
        close 5
    catch
    end
    
    hFig5 = figure(5);
    set(hFig5, 'units','normalized','position',[.49 .05 .35 .35])
    
    if no_encoding_trials>0
        rose(pi*meanVectorAngle/180,12)
        title('Mean phase')
    end
end

% %Save the data if requested by drgb
% if handles.save_drgb==1
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).no_trials=no_trials;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).which_trial=which_trial;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).meanVectorLength=meanVectorLength;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).meanVectorAngle=meanVectorAngle;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).peakAngle=peakAngle';
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).mod_indx=mod_indx;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).all_phase_histo=all_phase_histo;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).perCorr_per_histo=perCorr_per_histo;
%     handles.drgb.lfpevpair(handles.drgb.lfpevpair_no).which_event=which_event;
%     handles.drgb.phase=phase;
% end





