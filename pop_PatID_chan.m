% pop_CalcNewCh() - Calculate new channel from current dataset .
%
% Usage: 
%   >>  EEG = CalcNewCh( EEG, CalcExpression, CalcChLabel );
%
% Inputs:
%   EEG             - input EEG dataset
%   CalcExpression  - Calculation expression for new channel.
%   CalcChLabel     - Label of ne calculated channel.
%    
% Outputs:
%   EEG     - output dataset.
%   com     - current command.
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

function [EEG com]=pop_PatID_chan(EEG, ChanLabel, ChanMethod, varargin);

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_CalcNewCh;
	return;
end;	

ChanMethodList =           {'eval string', 'derivative'};

% pop up window
% -------------
if nargin < 3

    results=inputgui( ...
    {[1] [1] [3 2] [1] [3 2] [1]}, ...
    {...
        {'Style', 'text', 'string', 'Enter new PatID channel parameters.', 'FontWeight', 'bold'}, ...
        {}, ...
        {'Style', 'text', 'string', 'Label of the new channel'}, ...
        {'Style', 'edit', 'string', 'CalcCh'}, ...
        {}, ...
        {'Style', 'text', 'string', 'New channel calculation method:'}, ...
        {'Style', 'popupmenu', 'string', ChanMethodList}, ...
        {}, ...
    }, ...
    'pophelp(''pop_CalcNewCh'');', 'Calculate new channel -- pop_CalcNewCh()' ...
    );

    ChanLabel   	= results{1};
    ChanMethod      = ChanMethodList{results{2}};

end;

if strcmp(ChanMethod,'eval string');
    
    results=inputgui( ...
    {[2 1] [1] [1] [1] [1]}, ...
    {...
        ...1
        {'Style', 'text', 'string', 'Enter PatID channel eval string parameters.', 'FontWeight', 'bold'}, ...
        {}, ...
        ...2
        {}, ...
        ...3
        {'Style', 'text', 'string', 'eval string (eg. to invert channel #1 "EEG.data(1,:)*-1"):'}, ...
        ...4
        {'Style', 'edit', 'tag', 'PatIDChanEvalStrEdit'}, ...
        ...5
        {}, ...
     }, ...
     'pophelp(''pop_EXGmrk'');', 'Select EXG marking parameters -- pop_EXGmrkEp()' ...
     );
     ChanEvalStr=results{1};

end

if strcmp(ChanMethod,'derivative');
    
    DataTypeList =         {'EEG', 'IC', 'PatID'};
    SigLabelList =         {EEG.chanlocs.labels};
    
    results=inputgui( ...
    {[1 1] [1] [2 1 1] [1] [2 1 1] [2 1 1] [2 1 1] [1]}, ...
    {...
        ...1
        {'Style', 'text', 'string', 'Enter PatID channel eval string calculation.', 'FontWeight', 'bold'}, ...
        {}, ...
        ...2
        {}, ...
        ...3
        {'Style', 'text', 'string', 'Channel from which to calculate derivative:'}, ...
        {'Style', 'popupmenu', 'tag', 'PatIDDataTypeBox', 'string', DataTypeList, ...
         'callback', ['if get(findobj(gcbf, ''tag'', ''PatIDDataTypeBox''),''Value'')==1;'...
                      '    SigLabelList = {EEG.chanlocs.labels};' ...
                      'end;' ...
                      'if get(findobj(gcbf, ''tag'', ''PatIDDataTypeBox''),''Value'')==2;'...
                      '    SigLabelList = {EEG.icachansind};' ...
                      'end;' ...
                      'set(findobj(gcbf, ''tag'', ''PatIDSigLabelBox''), ''string'', SigLabelList);' ...
                      ]}, ...
        {'Style', 'popupmenu', 'tag', 'PatIDSigLabelBox', 'string', SigLabelList}, ...
        ...4
        {}, ...
        ...5
        {'Style', 'text', 'string', 'Derivative channel decimation factor:'}, ...
        {'Style', 'edit', 'tag', 'DerChanDeciFactEdit'}, ...
        {}, ...
        ...6
        {'Style', 'text', 'string', 'Derivative channel Lowpass frequency (Hz):'}, ...
        {'Style', 'edit', 'tag', 'DerChanLPHzEdit'}, ...
        {}, ...
        ...7
        {'Style', 'text', 'string', 'Derivative channel relative gain factor:'}, ...
        {'Style', 'edit', 'tag', 'DerChanGainFactEdit'}, ...
        {}, ...
        ...8
        {}, ...
     }, ...
     'pophelp(''pop_EXGmrk'');', 'Select EXG marking parameters -- pop_EXGmrkEp()' ...
     );
     DataType=DataTypeList{results{1}};
%     if strcmp(DataType, 'EEG');
%         SigLabelList={EEG.chanlocs.labels};
%     end
%     if strcmp(DataType, 'IC');
%         SigLabelList={EEG.icachansind};
%     end
%     if strcmp(DataType, 'PatID');
%         SigLabelList={EEG.PatID.chanlocs.labels};
%     end
    
     SigLabel=SigLabelList{results{2}};
     DerChanDeci=results{3};
     DerChanLPHz=results{4};
     DerChanGain=results{5};

end


% create tmparg string.

tmparg=sprintf('''%s'', ''%s''', 'chanlabel', ChanLabel);

if exist('ChanEvalStr');
    tmparg=sprintf('%s, ''%s'', ''%s'' ', tmparg, 'chanevalstr', ChanEvalStr);
end
if exist('DataType');
    tmparg=sprintf('%s, ''%s'', ''%s'' ', tmparg, 'datatype', DataType);
end
if exist('SigLabel');
    tmparg=sprintf('%s, ''%s'', ''%s'' ', tmparg, 'siglabel', SigLabel);
end
if exist('DerChanDeci');
    tmparg=sprintf('%s, ''%s'', %s ', tmparg, 'derchandeci', DerChanDeci);
end
if exist('DerChanLPHz');
    tmparg=sprintf('%s, ''%s'', %s ', tmparg, 'derchanlphz', DerChanLPHz);
end
if exist('DerChanGain');
    tmparg=sprintf('%s, ''%s'', %s ', tmparg, 'derchangain', DerChanGain);
end

% return command
% -------------------------
com=sprintf('EEG = pop_PatID_chan( %s, %s, %s, %s);', inputname(1), vararg2str(ChanLabel), vararg2str(ChanMethod), tmparg)

% call command
% ------------
exec=sprintf('EEG = PatID_chan( %s, %s, %s, %s);', inputname(1), vararg2str(ChanLabel), vararg2str(ChanMethod), tmparg);
eval(exec);

return;
