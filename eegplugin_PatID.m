% eegplugin_PatID() - EEGLAB plugin for waveform pattern identification and event marking.
%
% Usage:
%   >> eegplugin_PatID(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
%
% Copyright (C) <2006> <James Desjardins> Brock University
%
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

% $Log: eegplugin_Segmentation.m



function eegplugin_PatID(fig,try_strings,catch_strings);


% find EEGLAB tools menu.
% ---------------------
toolsmenu=findobj(fig,'tag','tools');


% Create "pop_PatID" callback cmd.
%---------------------------------------
PatID_mrk_cmd='[EEG,LASTCOM] = pop_PatID_mrk(EEG);';
PatID_mrk_cmd=[PatID_mrk_cmd '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'];
finalPatID_mrk_cmd=[try_strings.no_check PatID_mrk_cmd catch_strings.new_and_hist];

PatID_chan_cmd='[EEG,LASTCOM] = pop_PatID_chan(EEG);';
PatID_chan_cmd=[PatID_chan_cmd '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'];
finalPatID_chan_cmd=[try_strings.no_check PatID_chan_cmd catch_strings.new_and_hist];

%PatID_edit_cmd='[EEG,LASTCOM] = pop_PatID_edit(EEG);';
%PatID_edit_cmd=[PatID_edit_cmd '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'];
%finalPatID_edit_cmd=[try_strings.no_check PatID_edit_cmd catch_strings.new_and_hist];


% add "patID" submenu to the "Tools" menu.
%--------------------------------------------------------------------
PatIDmenu=uimenu(toolsmenu, 'label', 'PatID');
uimenu(PatIDmenu, 'label', 'Mark waveform pattern.', 'callback', finalPatID_mrk_cmd);
uimenu(PatIDmenu, 'label', 'Create new PatID channel.', 'callback', finalPatID_chan_cmd);
%uimenu(PatIDmenu, 'label', 'Plot waveforms and events for editing.', 'callback', PatID_edit_cmd);
