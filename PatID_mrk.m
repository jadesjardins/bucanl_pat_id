function EEG = PatID_mrk(EEG, EventLabel, AnchorType, PatType, DataType, SigLabel, varargin)

g = finputcheck(varargin, { 'pri_cell'         'cell'           {}        {};
                            'sec_proc'         'string'         ''        '';
                            'sec_cell'         'cell'           {}        {};
                            'conc_proc'        'string'         ''        '';
                            'conc_cell'        'cell'           {}        {};
                            });       

if ischar(g), error(g); end;

if strcmp(AnchorType, 'EventTime');
    
    if strcmp(PatType, 'Onset');
        
        %Interpret varargin.
        %from g.pri_cell
        pri.EventTypeCell=g.pri_cell{1};
        pri.ScanTime=g.pri_cell{2};
        pri.ThresholdUnits=g.pri_cell{3};
        pri.ThresholdValue=g.pri_cell{4};
        pri.ThresholdDur=g.pri_cell{5};
        pri.SampTime=g.pri_cell{6};
                
        % adjustments related to polarity of threshold value.
        if pri.ThresholdValue<0;
            Direction='neg';
        else
            Direction='pos';
        end
        
        pri.ThresholdValue=abs(pri.ThresholdValue);
                
        % create data vector for scan.
        if strcmp(DataType, 'EEG');
            pri.data=EEG.data(strmatch(SigLabel, {EEG.chanlocs.labels}),:,:);
        end
        if strcmp(DataType, 'IC');
            if ~isempty(EEG.icaact);
                pri.data = EEG.icaact(str2num(SigLabel),:,:);
            else
                tmpdata=[];
                tmpdata = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, length(EEG.icaweights(1,:)), EEG.trials*EEG.pnts);
                tmpdata = reshape( tmpdata, size(tmpdata,1), EEG.pnts, EEG.trials);
                pri.data=tmpdata(str2num(SigLabel),:,:);
            end;
        end
        if strcmp(DataType, 'PatID');
            pri.data=EEG.PatID.data(strmatch(SigLabel, {EEG.PatID.chanlocs.labels}),:,:);
        end
                
        % define relative time values around anchor.
        pri.ScanRelStartPnt=round(pri.ScanTime(1)*(EEG.srate/1000));
        pri.ScanRelEndPnt=round(pri.ScanTime(2)*(EEG.srate/1000));

        pri.SampRelStartPnt=round(pri.SampTime(1)*(EEG.srate/1000));
        pri.SampRelEndPnt=round(pri.SampTime(2)*(EEG.srate/1000));
        
        pri.ThresholdDurPnts=round(pri.ThresholdDur*(EEG.srate/1000));

        
        % Create Anchor.event structure for event scanning.
        j=0;
        for i=1:length(EEG.event);
            if ~isempty(strmatch(EEG.event(i).type, pri.EventTypeCell, 'exact'));
                j=j+1;
                Anchor.event(j)=EEG.event(i);
            end
        end

        
        % Loop through each event in Anchor structure and perform waveform scan.
        for a_ind=1:length(Anchor.event);
                
            
            % Create ScanData and SampleData vectors.
            CurAnchorPnt=Anchor.event(a_ind).latency;
            pri.ScanData=pri.data(CurAnchorPnt+pri.ScanRelStartPnt:CurAnchorPnt+pri.ScanRelEndPnt);
            pri.SampData=pri.data(CurAnchorPnt+pri.SampRelStartPnt:CurAnchorPnt+pri.SampRelEndPnt);
            
            
            % Adjust waveform polarity relative to threshold.
            if strcmp(Direction, 'neg');
                pri.ScanData=pri.ScanData*-1;
                pri.SampData=pri.SampData*-1;
            end
            
            
            % Create ThresholdScore value.
            if strcmp(pri.ThresholdUnits, 'SD from mean');
                pri.ThresholdScore=mean(pri.SampData)+(pri.ThresholdValue*std(pri.SampData));
            end
            if strcmp(pri.ThresholdUnits, '% of max');
                pri.ThresholdScore=max(pri.SampData)*(pri.ThresholdValue/100);
            end
            if strcmp(pri.ThresholdUnits, 'abs value');
                pri.ThresholdScore=pri.ThresholdValue;
            end

            
            % Run primary threshold scan.
            for pri_ind=1:length(pri.ScanData)-pri.ThresholdDurPnts;
                if all(pri.ScanData(pri_ind:pri_ind+pri.ThresholdDurPnts)>=pri.ThresholdScore);
                    
                    
                    % Run secondary scan if requested.
                    sec.ind=0;
                    
                    if strcmp(g.sec_proc, 'return to mean');
                        for sec_ind=1:pri_ind-1;
                            if pri.ScanData(pri_ind-sec_ind)<=mean(pri.SampData);
                                break
                            end
                        end
                    end
                    
                    if strcmp(g.sec_proc, 'following peak');
                        
                        
                        % Interpret varargin
                        % from g.sec_cell
                        sec.PeakDur=g.sec_cell{1};
                        sec.PeakDurPnts=round(sec.PeakDur*(EEG.srate/1000));
                        
                        sec.data=pri.ScanData(pri_ind:length(pri.ScanData));
                        
                        sec_ind=PeakScan(sec.data, sec.PeakDurPnts);
                    end

                    
                    % Run concurent criteria if requested.
                    conc.Crit=1;
                    if strcmp(g.conc_proc, 'area threshold');
                        
                        
                        % Interpret varargin
                        % from g.conc_cell
                        conc.DataType=g.conc_cell{1};
                        conc.SigLabel=g.conc_cell{2};
                        conc.ScanTime=g.conc_cell{3};
                        conc.SampTime=g.conc_cell{4};
                        conc.Stat=g.conc_cell{5};
                        
                        
                        % Define variables for concurrent criteria.
                        conc.ScanRelStartPnt=round(conc.ScanTime(1)*(EEG.srate/1000));
                        conc.ScanRelEndPnt=round(conc.ScanTime(2)*(EEG.srate/1000));

                        conc.SampleRelStartPnt=round(conc.SampTime(1)*(EEG.srate/1000));
                        conc.SampleRelEndPnt=round(conc.SampTime(2)*(EEG.srate/1000));

                        if strcmp(conc.DataType, 'PatID');
                            conc.Baseline=mean(EEG.PatID.data(strmatch(conc.SigLabel, {EEG.PatID.chanlocs.labels}),CurAnchorPnt+conc.SampleRelStartPnt:CurAnchorPnt+conc.SampleRelEndPnt));
                            conc.Area=mean(EEG.PatID.data(strmatch(conc.SigLabel, {EEG.PatID.chanlocs.labels}),CurAnchorPnt+pri.ScanRelStartPnt+pri_ind+sec_ind+conc.ScanRelStartPnt:CurAnchorPnt+pri.ScanRelStartPnt+pri_ind+sec_ind+conc.ScanRelEndPnt));
                            conc.Score=conc.Area-conc.Baseline;
                            conc.Exec=sprintf('%s%s%s', 'if conc.Score ', conc.Stat, ';conc.Crit=1;else;conc.Crit=0;end;');
                            eval(conc.Exec);
                        end
                    end

                    if conc.Crit==1;
                        CurOnsetPnt=CurAnchorPnt+pri.ScanRelStartPnt+pri_ind+sec_ind;
                        EEG=InsertEvent(EEG, EventLabel, CurOnsetPnt);
                        break
                    end;

                end
            end

        end

    end

end

%EEG = eeg_checkset(EEG, 'eventconsistency');

    
