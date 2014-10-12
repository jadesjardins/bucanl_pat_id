% pop_PatID_mrk() - Obtain initial PatID information.
%
% Usage: 
%   >>  EEG = pop_PatID( EEG, Anchor, PatType, DataType);
%
%   Anchor       - Scan waveform time points relative to anchor (event type, or segment time).
%   PatType      - Pattern type for which to scan (peak, trough, onset).
%   DataType     - Data in which to perform pattern scan (EEG, IC, other computed waveforms).
%    
% Outputs:
%   EEG  - output dataset
%
% See also:
%   EEGLAB 

% Copyright (C) <2006>  <James Desjardins> Brock University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG,com]=pop_PatID_mrk(EEG, NewEventLabel, AnchorType, PatType, DataType, SigLabel, varargin);

% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
          % display help if not enough arguments
% ------------------------------------

if nargin < 1
	help pop_PatID_mrk;
	return;
end;	

% Check varargin content
if ~isempty(varargin)
    
        g = finputcheck(varargin, { 'pri_cell'             'cell'           {}        {};
                                'sec_proc'             'string'         ''        '';
                                'conc_proc'            'string'         ''        '';
                                'conc_datatype'        'string'         ''        '';
                                'conc_siglabel'        'string'         ''        '';
                                'conc_scantime'        'integer'        []        [];
                                'conc_samptime'        'integer'        []        [];
                                'conc_stat'            'string'         ''        '' });       
                            
    if ischar(g), error(g); end;
    
else
    g=[];
end

% If primary scan paramiters are not present in call to pop_PatID_mrk run
% GUI window.
if nargin < 6
    
    %Create AnchorTypeCell.
    AnchorTypeCell={};
    AnchorTypeCell{length(AnchorTypeCell)+1}='Continuous';
    if ~isempty(EEG.event);
        AnchorTypeCell{length(AnchorTypeCell)+1}='EventTime';
    end
    if EEG.trials>1;
        AnchorTypeCell{length(AnchorTypeCell)+1}='EpochTime';
    end

    %Create PatTypeCell.
    PatTypeCell = {'Onset', 'Peak'};
    
    %Create DataTypeCell.
    DataTypeCell={};
    DataTypeCell{length(DataTypeCell)+1}='EEG';
    if ~isempty(EEG.icasphere);
        DataTypeCell{length(DataTypeCell)+1}='IC';
    end
    if isfield(EEG, 'PatID');
        if ~isempty(EEG.PatID.data);
            DataTypeCell{length(DataTypeCell)+1}='PatID';
        end
    end

    %Create SigLabelCell.
    if strcmp(DataTypeCell{1}, 'EEG');
        SigLabelCell = {EEG.chanlocs.labels};
    end
    if strcmp(DataTypeCell{1}, 'IC');
        SigLabelCell = {EEG.icachansind};
    end
    if strcmp(DataTypeCell{1}, 'PatID');
        SigLabelCell = {EEG.PatID.chanlocs.labels};
    end

    
    % Run GUI for primary scan parameters. 
    results=inputgui( ...
    {[1] [1] [2 1 1] [2 1 1] [2 1 1] [2 1 1] [1]}, ...
    {...
        ...1
        {'Style', 'text', 'string', 'Enter parameters for primary PatID scan.', 'FontWeight', 'bold'}, ...
        ...2
        {}, ...
        ...3
        {'Style', 'text', 'string', 'Label of new event markers:'}, ...
        {'Style', 'edit', 'tag', 'NewEventLabelEdit', 'string', 'PatID'}, ...
        {}, ...
        ...4
        {'Style', 'text', 'string', 'Identify patterns relative to:'}, ...
        {'Style', 'popupmenu', 'tag', 'AnchorTypePopup', 'string', AnchorTypeCell}, ...
        {}, ...
        ...5
        {'Style', 'text', 'string', 'Type of pattern to identify:'}, ...
        {'Style', 'popupmenu', 'tag', 'PatTypePopup', 'string', PatTypeCell}, ...
        {}, ...
        ...6
        {'Style', 'text', 'string', 'Waveform in which to identify patterns:'}, ...
        {'Style', 'popupmenu', 'tag', 'DataTypePopup', 'string', DataTypeCell, ...
         'callback', ['DataTypeIndex=get(findobj(gcbf, ''tag'', ''DataTypePopup''),''Value'');' ...
                      'DataTypeCell=get(findobj(gcbf, ''tag'', ''DataTypePopup''),''string'');' ...
                      'if strcmp(DataTypeCell{DataTypeIndex}, ''EEG'');'...
                      '    SigLabelCell = {EEG.chanlocs.labels};' ...
                      'end;' ...
                      'if strcmp(DataTypeCell{DataTypeIndex}, ''IC'');'...
                      '    SigLabelCell = {EEG.icachansind};' ...
                      'end;' ...
                      'if strcmp(DataTypeCell{DataTypeIndex}, ''PatID'');'...
                      '    SigLabelCell = {EEG.PatID.chanlocs.labels};' ...
                      'end;' ...
                      'set(findobj(gcbf, ''tag'', ''SigLabelPopup''), ''string'', SigLabelCell);' ...
                      ]}, ...
        {'Style', 'popupmenu', 'tag', 'SigLabelPopup', 'string', SigLabelCell}, ...
        ...7
        {}, ...
     }, ...
     'pophelp(''pop_PatID_mrk'');', 'Select pattern identification parameters -- pop_PatID_mrk()' ...
     );
     
 
     % Create PatID variables.
     NewEventLabel=results{1};
     AnchorType=AnchorTypeCell{results{2}};
     PatType=PatTypeCell{results{3}};
     DataType=DataTypeCell{results{4}};
     if strcmp(DataType, 'EEG');
         SigLabelCell={EEG.chanlocs.labels};
     end
     if strcmp(DataType, 'IC');
         for i=1:length(EEG.icaweights(:,1));
             SigLabelCell{i}=num2str(i);
         end
     end
     if strcmp(DataType, 'PatID');
         SigLabelCell={EEG.PatID.chanlocs.labels};
     end
     SigLabel=SigLabelCell{results{5}};
     
end



% Collect input variables for primary scan.
if strcmp(AnchorType,'EventTime') && strcmp(PatType,'Onset');
    
    if ~isfield(g, 'pri_cell');
        
        pri_ThresholdUnitCell = {'SD from mean', '% of max', 'abs value'};
        sec_ProcCell =          {'none', 'return to mean', 'preceeding peak', 'following peak'};
        conc_ProcCell =         {'none', 'area threshold'};
        
        results=inputgui( ...
            {[1] [1] [5 1 4] [3 2] [3 2] [3 2] [3 2] [3 2] [3 2] [3 2]}, ...
            {...
            ...1
            {'Style', 'text', 'string', 'Enter parameters for Onset identification relative to current event times.', 'FontWeight', 'bold'}, ...
            ...2
            {}, ...
            ...3
            {'Style', 'text', 'string', 'Event(s) around which to perform primary scan:'}, ...
            {'Style', 'pushbutton', 'string', '...', ... 
             'callback', ['[EventTypeIndex,EventTypeStr,EventTypeCell]=pop_chansel(unique({EEG.event.type}));' ...
                          'set(findobj(gcbf, ''tag'', ''pri_EventTypeEdit''), ''string'', vararg2str(EventTypeCell))']}, ...
            {'Style', 'edit', 'tag', 'pri_EventTypeEdit'}, ...
            ...4
            {'Style', 'text', 'string', 'Time limits of primary scan (ms relative to anchor event):'}, ...
            {'Style', 'edit', 'tag', 'pri_ScanTimeEdit'}, ...
            ...5
            {'Style', 'text', 'string', 'Select units for threshold:'}, ...
            {'Style', 'popupmenu', 'tag', 'pri_ThresholdUnitsPopup', 'string', pri_ThresholdUnitCell}, ...
            ...6
            {'Style', 'text', 'string', 'Threshold value for onset detection:'}, ...
            {'Style', 'edit', 'tag', 'pri_ThresholdEdit'}, ...
            ...7
            {'Style', 'text', 'string', 'Required duration above threshold (ms):'}, ...
            {'Style', 'edit', 'tag', 'pri_ThresholdDurEdit'}, ...
            ...8
            {'Style', 'text', 'string', 'Time limits of sample scan (for baseline calculation or max scan):'}, ...
            {'Style', 'edit', 'tag', 'pri_SampTimeEdit'}, ...
            ...9
            {'Style', 'text', 'string', 'Secondary scan procedure:'}, ...
            {'Style', 'popupmenu', 'tag', 'sec_ProcPopup', 'string', sec_ProcCell}, ...
            ...10
            {'Style', 'text', 'string', 'Concurrent criteria procedure:'}, ...
            {'Style', 'popupmenu', 'tag', 'conc_ProcPopup', 'string', conc_ProcCell} ...        
        }, ...
        'pophelp(''pop_EXGmrk'');', 'Select EXG marking parameters -- pop_EXGmrkEp()' ...
        );
    
        % Create primary scan variables.
        eval(['pri_EventTypeCell={' results{1} '};']);
        pri_ScanTime=str2num(results{2});
        pri_ThresholdUnits=pri_ThresholdUnitCell{results{3}};
        pri_ThresholdValue=str2num(results{4});
        pri_ThresholdDur=str2num(results{5});
        pri_SampTime=str2num(results{6});
        sec_Proc=sec_ProcCell{results{7}};
        conc_Proc=conc_ProcCell{results{8}};
        
        pri_Cell={pri_EventTypeCell, pri_ScanTime, pri_ThresholdUnits, pri_ThresholdValue, pri_ThresholdDur, pri_SampTime};

    end
    
end






% Collect input variables for secondary scan. 
if exist('sec_Proc')
    if strcmp(sec_Proc,'following peak');
        
        if ~isfield(g, 'sec_cell');
            
            results=inputgui( ...
                {[1] [1] [3 1] [1]}, ...
                {...
                ...1
                {'Style', 'text', 'string', 'Enter secondary scan parameters.', 'FontWeight', 'bold'}, ...
                ...2
                {}, ...
                ...3
                {'Style', 'text', 'string', 'Minimum peak width (ms):'}, ...
                {'Style', 'edit', 'tag', 'sec_PeakDurEdit'}, ...
                ...4
                {}, ...
                }, ...
                'pophelp(''pop_EXGmrk'');', 'Select secondary scan parameters -- pop_PatID_mrk()' ...
                );
            sec_PeakDur=str2num(results{1});
            
            sec_Cell={sec_PeakDur};
            
        end
    end
end





% Collect input variables for concurrent criteria.
if exist('conc_Proc')
    if strcmp(conc_Proc, 'area threshold');
        
        
        %Create DataTypeCell.
        DataTypeCell={};
        DataTypeCell{length(DataTypeCell)+1}='EEG';
        if ~isempty(EEG.icasphere);
            DataTypeCell{length(DataTypeCell)+1}='IC';
        end
        if isfield(EEG, 'PatID');
            if ~isempty(EEG.PatID.data);
                DataTypeCell{length(DataTypeCell)+1}='PatID';
            end
        end
        
        
        %Create SigLabelCell.
        if strcmp(DataTypeCell{1}, 'EEG');
            SigLabelCell = {EEG.chanlocs.labels};
        end
        if strcmp(DataTypeCell{1}, 'IC');
            SigLabelCell = {EEG.icachansind};
        end
        %    if strcmp(DataTypeCell{1}, 'PatID');
        %        SigLabelCell = {EEG.PatID.chanlocs.labels};
        %    end
        
        
        % Run GUI for concurrent criteria parameters.
        results=inputgui( ...
            {[1] [1] [2 1 1] [2 1 1] [2 1 1] [2 1 1] [1]}, ...
            {...
            ...1
            {'Style', 'text', 'string', 'Enter concurent scan area threshold parameters.', 'FontWeight', 'bold'}, ...
            ...2
            {}, ...
            ...3
            {'Style', 'text', 'string', 'Waveform in which to perform concurent scan:'}, ...
            {'Style', 'popupmenu', 'tag', 'conc_DataTypePopup', 'string', DataTypeCell, ...
            'callback', ['DataTypeIndex=get(findobj(gcbf, ''tag'', ''conc_DataTypePopup''),''Value'');' ...
            'DataTypeCell=get(findobj(gcbf, ''tag'', ''conc_DataTypePopup''),''string'');' ...
            'if strcmp(DataTypeCell{DataTypeIndex}, ''EEG'');'...
            '    SigLabelCell = {EEG.chanlocs.labels};' ...
            'end;' ...
            'if strcmp(DataTypeCell{DataTypeIndex}, ''IC'');'...
            '    SigLabelCell = {EEG.icachansind};' ...
            'end;' ...
            'if strcmp(DataTypeCell{DataTypeIndex}, ''PatID'');'...
            '    SigLabelCell = {EEG.PatID.chanlocs.labels};' ...
            'end;' ...
            'set(findobj(gcbf, ''tag'', ''conc_SigLabelPopup''), ''string'', SigLabelCell);' ...
            ]}, ...
            {'Style', 'popupmenu', 'tag', 'conc_SigLabelPopup', 'string', SigLabelCell}, ...
            ...4
            {'Style', 'text', 'string', 'Time limits of concurent criteria scan (ms relative to primary pattern detection):'}, ...
            {'Style', 'edit', 'tag', 'conc_ScanTimeEdit'}, ...
            {} ...
            ...5
            {'Style', 'text', 'string', 'Time limits of sample scan (ms relative to anchor event):'}, ...
            {'Style', 'edit', 'tag', 'conc_SampTimeEdit'}, ...
            {} ...
            ...6
            {'Style', 'text', 'string', 'Concurent criteria statement (eg. >=0):'}, ...
            {'Style', 'edit', 'tag', 'conc_StatEdit'}, ...
            {} ...
            ...7
            {}, ...
            }, ...
            'pophelp(''pop_EXGmrk'');', 'Select EXG marking parameters -- pop_EXGmrkEp()' ...
            );
        
        
        % Create concurrent criteria variables.
        conc_DataType=DataTypeCell{results{1}};
        if strcmp(conc_DataType, 'EEG');
            SigLabelCell={EEG.chanlocs.labels};
        end
        if strcmp(conc_DataType, 'IC');
            SigLabelCell={EEG.icachansind};
        end
        %     if strcmp(conc_DataType, 'PatID');
        %         SigLabelCell={EEG.PatID.chanlocs.labels};
        %     end
        conc_SigLabel=SigLabelCell{results{2}};
        conc_ScanTime=str2num(results{3});
        conc_SampTime=str2num(results{4});
        conc_Stat=results{5};
        
        conc_Cell={conc_DataType, conc_SigLabel, conc_ScanTime, conc_SampTime, conc_Stat};
    end
     
end


% create tmparg string.
if exist('pri_Cell');
    if exist('tmparg');
        tmparg=sprintf('%s, ''%s'', {%s} ', tmparg, 'pri_cell', pri_Cell);
    else
        tmparg=sprintf('''%s'', {%s} ', 'pri_cell', vararg2str(pri_Cell));
    end
end
if exist('sec_Proc')
    if ~strcmp(sec_Proc,'none');
        if exist('tmparg');
            tmparg=sprintf('%s, ''%s'', ''%s'', ''%s'', {%s} ', tmparg, 'sec_proc', sec_Proc, 'sec_cell', vararg2str(sec_Cell));
        else
            tmparg=sprintf('''%s'', ''%s'', ''%s'', {%s} ', 'sec_proc', sec_Proc, 'sec_cell', vararg2str(sec_Cell));
        end
    end
end
if exist('conc_Proc')
    if ~strcmp(conc_Proc,'none');
        if exist('tmparg');
            tmparg=sprintf('%s, ''%s'', ''%s'', ''%s'', {%s} ', tmparg, 'conc_proc', conc_Proc, 'conc_cell', vararg2str(conc_Cell));
        else
            tmparg=sprintf('''%s'', ''%s'', ''%s'', {%s} ', 'conc_proc', conc_Proc, 'conc_cell', vararg2str(conc_Cell));
        end
    end
end





% return command
% -------------------------
if exist('tmparg');
    com=sprintf('EEG = pop_PatID_mrk( %s, %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(NewEventLabel), vararg2str(AnchorType), vararg2str(PatType), vararg2str(DataType), vararg2str(SigLabel), tmparg);
else
    com=sprintf('EEG = pop_PatID_mrk( %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(NewEventLabel), vararg2str(AnchorType), vararg2str(PatType), vararg2str(DataType), vararg2str(SigLabel));
end

% call command
% ------------
if exist('tmparg');
    exec=sprintf('EEG = PatID_mrk( %s, %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(NewEventLabel), vararg2str(AnchorType), vararg2str(PatType), vararg2str(DataType), vararg2str(SigLabel), tmparg);
    eval(exec);
else
    exec=sprintf('EEG = PatID_mrk( %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(NewEventLabel), vararg2str(AnchorType), vararg2str(PatType), vararg2str(DataType), vararg2str(SigLabel))
    eval(exec);
end    
return;
