function drgSummaryBatchCohCaMKII
%Analyzes the linear discriminant analysis performed by drgLFPDiscriminantBatch
%Takes as a in input the 'drgbDiscPar' file listing 'Discriminant_*.mat' output files
%from drgLFPDiscriminantBatch
%
%Performs summary analises for LDA and  PAC analysis performed with case 19
%of drgAnalysisBatchLFP

warning('off')

close all
clear all

%If you want statistics to be done with the value for each odor pair for
%each mouse make this variable 1
mouse_op=1;

bandwidth_names{1}='Theta';
bandwidth_names{2}='Beta';
bandwidth_names{3}='Low gamma';
bandwidth_names{4}='High gamma';

prof_naive_leg{1}='Proficient';
prof_naive_leg{2}='Naive';

group_legend{1}='WT';
group_legend{2}='Het';
group_legend{3}='KO';

evTypeLabels{1}='S+';
evTypeLabels{2}='S-';

peak_label{1}='Trough';
peak_label{2}='Peak';

%Location of files
% hippPathName='E:\CaMKIIpaper\datos sumarry\coherence\';
hippPathName='/Users/restrepd/Documents/Projects/CaMKII_analysis/Coherence new/';
% 
% %Files
% FileName{1}='CaMKIIacetocohe02012021_out.mat';
% FileName{2}='CaMKIIethylbenacetocohe2262021_out.mat';
% FileName{3}='CaMKIIPAEAcohe02082021_out.mat';
% FileName{4}='CaMKIIEAPAcohe2262021_out.mat';
% FileName{5}='CaMKIIpz1EAcohe02142021_out.mat';
% FileName{6}='CaMKIIPZ1PAEAcohe202102021_out.mat';
% FileName{7}='CaMKIIpzz1EAPAcohe02112021_out.mat';
% FileName{8}='CaMKIIpzz1propylacecohe02092021_out.mat';

%Note: For the correlation calculation it is very important to list 
%the odor pairs in the same order in the drgSummarizeCaMKIIbehavior
FileName{1}='CaMKIIacetocohe02012021_out80.mat';
FileName{2}='CaMKIIEAPAcohe2262021_out80.mat';
FileName{3}='CaMKIIethylbenacetocohe2262021_out80.mat';
FileName{4}='CaMKIIPAEAcohe02082021_out80.mat';
FileName{5}='CaMKIIpz1EAcohe02142021_out80.mat';
FileName{6}='CaMKIIPZ1PAEAcohe202102021_out80.mat';
FileName{7}='CaMKIIpzz1EAPAcohe02112021_out80.mat';
FileName{8}='CaMKIIpzz1propylacecohe02092021_out80.mat';


%Load data
all_files=[];

for ii=1:length(FileName)
    load([hippPathName FileName{ii}])
    all_files(ii).handles_out=handles_out;
end

handles_out=[];

figNo=0;

%Now plot the average PRP for each electrode calculated per mouse
%(including all sessions for each mouse)
edges=[-0.3:0.02:0.3];
rand_offset=0.5;


for bwii=[1 2 4]    %for amplitude bandwidths (beta, low gamma, high gamma)
    
    glm_coh=[];
    glm_ii=0;
    
    id_ii=0;
    input_data=[];
    
    %Plot the average
    figNo = figNo +1;
    
    try
        close(figNo)
    catch
    end
    hFig=figure(figNo);
    
    ax=gca;ax.LineWidth=3;
    
    set(hFig, 'units','normalized','position',[.1 .5 .7 .4])
    hold on
    
    bar_lab_loc=[];
    no_ev_labels=0;
    ii_gr_included=0;
    bar_offset = 0;
    
    for evNo=1:2
        
        for per_ii=2:-1:1
            
            for grNo=1:3
                bar_offset = bar_offset +1;
                
                %Get these MI values
                these_coh=[];
                ii_coh=0;
                for ii=1:length(FileName)
                    this_jj=[];
                    for jj=1:all_files(ii).handles_out.dcoh_ii
                        
                        if all_files(ii).handles_out.dcoh_values(jj).pacii==bwii
                            if all_files(ii).handles_out.dcoh_values(jj).evNo==evNo
                                if all_files(ii).handles_out.dcoh_values(jj).per_ii==per_ii
                                    
                                    
                                    if all_files(ii).handles_out.dcoh_values(jj).groupNo==grNo
                                        this_jj=jj;
                                    end
                                    
                                end
                                
                            end
                        end
                    end
                    if ~isempty(this_jj)
                        if mouse_op==1
                            these_coh(ii_coh+1:ii_coh+length(all_files(ii).handles_out.dcoh_values(this_jj).dcoh_per_mouse))=all_files(ii).handles_out.dcoh_values(this_jj).dcoh_per_mouse;
                            ii_coh=ii_coh+length(all_files(ii).handles_out.dcoh_values(this_jj).dcoh_per_mouse);
                        else
                            ii_coh=ii_coh+1;
                            these_coh(ii_coh)=all_files(ii).handles_out.dcoh_values(this_jj).dcoh;
                        end
                    end
                end
                
                switch grNo
                    case 1
                        bar(bar_offset,mean(these_coh),'g','LineWidth', 3,'EdgeColor','none')
                    case 2
                        bar(bar_offset,mean(these_coh),'b','LineWidth', 3,'EdgeColor','none')
                    case 3
                        bar(bar_offset,mean(these_coh),'y','LineWidth', 3,'EdgeColor','none')
                end
                
                
                %Violin plot
                
                [mean_out, CIout]=drgViolinPoint(these_coh,edges,bar_offset,rand_offset,'k','k',3);
%                 CI = bootci(1000, {@mean, these_coh},'type','cper');
%                 plot([bar_offset bar_offset],CI,'-k','LineWidth',3)
%                 plot(bar_offset*ones(1,length(these_coh)),these_coh,'o','MarkerFaceColor', [0.7 0.7 0.7],'MarkerEdgeColor',[0 0 0],'MarkerSize',5)
%                 
                
                %                                 %Save data for glm and ranksum
                
                glm_coh.data(glm_ii+1:glm_ii+length(these_coh))=these_coh;
                glm_coh.group(glm_ii+1:glm_ii+length(these_coh))=grNo*ones(1,length(these_coh));
                glm_coh.perCorr(glm_ii+1:glm_ii+length(these_coh))=per_ii*ones(1,length(these_coh));
                glm_coh.event(glm_ii+1:glm_ii+length(these_coh))=evNo*ones(1,length(these_coh));
                glm_ii=glm_ii+length(these_coh);
                
                id_ii=id_ii+1;
                input_data(id_ii).data=these_coh;
                input_data(id_ii).description=[group_legend{grNo} ' ' evTypeLabels{evNo} ' ' prof_naive_leg{per_ii}];
                
                
            end
            bar_offset = bar_offset + 1;
            
        end
        bar_offset = bar_offset + 1;
        
    end
    
    title(['Average delta coherence per odor pair per mouse for ' bandwidth_names{bwii}])
    
    
    
    xticks([1 2 3 5 6 7 10 11 12 14 15 16])
    xticklabels({'nwtS+', 'nHS+', 'nKOS+', 'pwtS+', 'pHS+', 'pKOS+', 'nwtS-', 'nHS-', 'nKOS-', 'pwtS-', 'pHS-', 'pKOS-'})
    
    ylim([-0.3 0.3])
    ylabel('delta coherence')
    
    
    %Perform the glm
    fprintf(1, ['glm for average coherence per odor pair per mouse for '  bandwidth_names{bwii} '\n'])
    
    fprintf(1, ['\n\nglm for PRP for' bandwidth_names{bwii} '\n'])
    tbl = table(glm_coh.data',glm_coh.group',glm_coh.perCorr',glm_coh.event',...
        'VariableNames',{'MI','group','perCorr','event'});
    mdl = fitglm(tbl,'MI~group+perCorr+event+perCorr*group*event'...
        ,'CategoricalVars',[2,3,4])
    
    
    %Do the ranksum/t-test
    fprintf(1, ['\n\nRanksum or t-test p values per odor pair per mouse for ' bandwidth_names{bwii} ' hippocampus\n'])
    [output_data] = drgMutiRanksumorTtest(input_data);
    
    
end


 
%Now plot the  AUC and save the data for the correlation code
%(including all sessions for each mouse)
edges=[-0.1:0.02:0.5];
rand_offset=0.5;


for bwii= [1 2 4]    %for amplitude bandwidths (beta, low gamma, high gamma)
    
    handles_out.bwii(bwii).auROC=[];
    handles_out.bwii(bwii).mouseNo=[];
    handles_out.bwii(bwii).odor_pairNo=[];
    handles_out.bwii(bwii).groupNo=[];
    
    glm_AUC=[];
    glm_ii=0;
    
    id_ii=0;
    input_data=[];
    
    %Plot the average
    figNo = figNo +1;
    
    try
        close(figNo)
    catch
    end
    hFig=figure(figNo);
    
    %             try
    %                 close(figNo+bwii)
    %             catch
    %             end
    %             hFig=figure(figNo+bwii);
    
    set(hFig, 'units','normalized','position',[.1 .5 .7 .4])
    hold on
    
    bar_lab_loc=[];
    no_ev_labels=0;
    ii_gr_included=0;
    bar_offset = 0;
    
    %     for evNo=1:2
    
    for per_ii=2:-1:1
        
        for grNo=1:3
            bar_offset = bar_offset +1;
            
            %                         if sum(eventType==3)>0
            %                             bar_offset=(grNo-1)*(3.5*length(eventType))+(2-(per_ii-1))+3*(2-evNo);
            %                         else
            %                             bar_offset=(grNo-1)*(3.5*length(eventType))+(2-(per_ii-1))+3*(length(eventType)-evNo);
            %                         end
            %
            %                         these_offsets(per_ii)=bar_offset;
            bar_offset = bar_offset + 1;
            
            %Get these MI values
            these_AUC=[];
            ii_AUC=0;
            for ii=1:length(FileName)
                this_jj=[];
                for jj=1:all_files(ii).handles_out.auc_ii
                    if all_files(ii).handles_out.auc_values(jj).pacii==bwii
                        if all_files(ii).handles_out.auc_values(jj).per_ii==per_ii
                            
                            if all_files(ii).handles_out.auc_values(jj).groupNo==grNo
                                this_jj=jj;
                            end
                            
                        end
                    end
                    
                end
                if ~isempty(this_jj)
                    if mouse_op==1
                        these_AUC(ii_AUC+1:ii_AUC+length(all_files(ii).handles_out.auc_values(this_jj).auROC_per_mouse))=all_files(ii).handles_out.auc_values(this_jj).auROC_per_mouse;
                        if per_ii==1
                            handles_out.bwii(bwii).auROC=[handles_out.bwii(bwii).auROC all_files(ii).handles_out.auc_values(this_jj).auROC_per_mouse];
                            handles_out.bwii(bwii).mouseNo=[handles_out.bwii(bwii).mouseNo all_files(ii).handles_out.auc_values(this_jj).mouseNo];
                            handles_out.bwii(bwii).odor_pairNo=[handles_out.bwii(bwii).odor_pairNo ii*ones(1, length(all_files(ii).handles_out.auc_values(this_jj).mouseNo))];
                            handles_out.bwii(bwii).groupNo=[handles_out.bwii(bwii).groupNo grNo*ones(1, length(all_files(ii).handles_out.auc_values(this_jj).mouseNo))];
                        end
                        ii_AUC=ii_AUC+length(all_files(ii).handles_out.auc_values(this_jj).auROC_per_mouse);
                    else
                        ii_AUC=ii_AUC+1;
                        these_AUC(ii_AUC)=all_files(ii).handles_out.auc_values(this_jj).auc_coh;
                    end
                end
            end
            
            switch grNo
                case 1
                    bar(bar_offset,mean(these_AUC),'g','LineWidth', 3,'EdgeColor','none')
                case 2
                    bar(bar_offset,mean(these_AUC),'b','LineWidth', 3,'EdgeColor','none')
                case 3
                    bar(bar_offset,mean(these_AUC),'y','LineWidth', 3,'EdgeColor','none')
            end
            
            
            %Violin plot
            
            [mean_out, CIout]=drgViolinPoint(these_AUC,edges,bar_offset,rand_offset,'k','k',3);
            %             CI = bootci(1000, {@mean, these_AUC},'type','cper');
            %             plot([bar_offset bar_offset],CI,'-k','LineWidth',3)
            %             plot(bar_offset*ones(1,length(these_AUC)),these_AUC,'o','MarkerFaceColor', [0.7 0.7 0.7],'MarkerEdgeColor',[0 0 0],'MarkerSize',5)
            %
            %                                 %Save data for glm and ranksum
            
            glm_AUC.data(glm_ii+1:glm_ii+length(these_AUC))=these_AUC;
            glm_AUC.group(glm_ii+1:glm_ii+length(these_AUC))=grNo*ones(1,length(these_AUC));
            glm_AUC.perCorr(glm_ii+1:glm_ii+length(these_AUC))=per_ii*ones(1,length(these_AUC));
            glm_AUC.event(glm_ii+1:glm_ii+length(these_AUC))=evNo*ones(1,length(these_AUC));
            glm_ii=glm_ii+length(these_AUC);
            
            id_ii=id_ii+1;
            input_data(id_ii).data=these_AUC;
            input_data(id_ii).description=[group_legend{grNo} ' ' evTypeLabels{evNo} ' ' prof_naive_leg{per_ii}];
            
            
        end
        bar_offset = bar_offset + 2;
        
    end
    bar_offset = bar_offset + 3;
    
    %     end
    
    title(['Average coherence auROC for each electrode calculated per mouse for ' bandwidth_names{bwii}])
    
    
    %Annotations identifying groups
    x_interval=0.8/ii_gr_included;
    for ii=1:ii_gr_included
        annotation('textbox',[0.7*x_interval+x_interval*(ii-1) 0.7 0.3 0.1],'String',handles_drgb.drgbchoices.group_no_names{ groups_included(ii)},'FitBoxToText','on');
    end
    
    %Proficient/Naive annotations
    annotation('textbox',[0.15 0.8 0.3 0.1],'String','Proficient','FitBoxToText','on','Color','r','LineStyle','none');
    annotation('textbox',[0.15 0.75 0.3 0.1],'String','Naive','FitBoxToText','on','Color','b','LineStyle','none');
    
    
    xticks([2 4 6 10 12 14 21 23 25 29 31 33])
    xticklabels({'nwtS+', 'nHS+', 'nKOS+', 'pwtS+', 'pHS+', 'pKOS+', 'nwtS-', 'nHS-', 'nKOS-', 'pwtS-', 'pHS-', 'pKOS-'})
    
    ylim([0 0.5])
    ylabel('auROC')
    
    %Perform the glm
    fprintf(1, ['glm for average coherence auROC for each electrode calculated per mouse for '  bandwidth_names{bwii} '\n'])
    
    fprintf(1, ['\n\nglm for auROC for Theta/' bandwidth_names{bwii} '\n'])
    tbl = table(glm_AUC.data',glm_AUC.group',glm_AUC.perCorr',glm_AUC.event',...
        'VariableNames',{'MI','group','perCorr','event'});
    mdl = fitglm(tbl,'MI~group+perCorr+event+perCorr*group*event'...
        ,'CategoricalVars',[2,3,4])
    
    
    %Do the ranksum/t-test
    fprintf(1, ['\n\nRanksum or t-test p values for average coherence auROC for each electrode calculated per mouse for ' bandwidth_names{bwii} '\n'])
    [output_data] = drgMutiRanksumorTtest(input_data);
    
    
end

 
%Plot the bounded lines
maxlP=-200000;
minlP=200000;

frequency=all_files(1).handles_out.frequency;

for evNo=1:2
    

    for per_ii=2:-1:1      %performance bins. blue = naive, red = proficient
        
        figNo = figNo + 1;
        try
            close(figNo)
        catch
        end
        hFig=figure(figNo);
        
        set(hFig, 'units','normalized','position',[.1 .5 .4 .4])
        
        set(gca,'FontName','Arial','FontSize',12,'FontWeight','Bold',  'LineWidth', 2)
        hold on
        
        
        for grNo=3:-1:1
            
            %Get the deltaCxy_af
            %Get these MI values
            these_deltaCxy_af=[];
            ii_coh=0;
            for ii=1:length(FileName)
                this_jj=[];
                for jj=1:all_files(ii).handles_out.dcohaf_ii
                    if all_files(ii).handles_out.dcohaf_values(jj).evNo==evNo
                        if all_files(ii).handles_out.dcohaf_values(jj).per_ii==per_ii
                            if all_files(ii).handles_out.dcohaf_values(jj).groupNo==grNo
                                this_jj=jj;
                            end
                        end
                    end
                end
                if (~isempty(this_jj))&(~isempty(all_files(ii).handles_out.dcohaf_values(this_jj).dcoh_per_mouse))
                    if mouse_op==1
                        sz_dcoh=size(all_files(ii).handles_out.dcohaf_values(this_jj).dcoh_per_mouse);
                        these_deltaCxy_af(ii_coh+1:ii_coh+sz_dcoh(1),1:sz_dcoh(2))=all_files(ii).handles_out.dcohaf_values(this_jj).dcoh_per_mouse;
                        ii_coh=ii_coh+length(all_files(ii).handles_out.dcohaf_values(this_jj).dcoh_per_mouse);
                    else
                        ii_coh=ii_coh+1;
                        these_deltaCxy_af(ii_coh,:)=all_files(ii).handles_out.dcohaf_values(this_jj).dcohaf;
                    end
                end
            end
            
            
            
            if ii_coh>=3
                
                mean_deltaCxy=[];
                mean_deltaCxy=mean(these_deltaCxy_af,1);
                
                CI=[];
                CI = bootci(1000, {@mean, these_deltaCxy_af})';
                maxlP=max([maxlP max(CI(:))]);
                minlP=min([minlP min(CI(:))]);
                CI(:,1)= mean_deltaCxy'-CI(:,1);
                CI(:,2)=CI(:,2)- mean_deltaCxy';
                
                
                switch grNo
                    case 1
                        [hlCR, hpCR] = boundedline(frequency',mean_deltaCxy', CI, 'g');
                    case 2
                        [hlCR, hpCR] = boundedline(frequency',mean_deltaCxy', CI, 'cmap',[0.3010 0.7450 0.9330]);
                    case 3
                        [hlCR, hpCR] = boundedline(frequency',mean_deltaCxy', CI, 'y');
                end
                 
            end
        end
        
        title(['delta coherence per odor pair per mouse ' prof_naive_leg{per_ii} ' ' evTypeLabels{evNo}])
        xlabel('Frequency (Hz')
        ylabel('delta coherence')
    end
    
end

%Set the same ylim for all figures
maxyl=maxlP+0.1*(maxlP-minlP);
minyl=minlP-0.1*(maxlP-minlP);

fNo=figNo-4;
for evNo=1:2
    for per_ii=2:-1:1
        fNo=fNo+1;
        hFig=figure(fNo);
        ylim([minyl maxyl])
    end
end


save([hippPathName 'drgSummaryBatchCohCaMKII_out.mat'],'handles_out')

pffft=1;