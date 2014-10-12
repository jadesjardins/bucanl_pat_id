function EEG = InsertEvent(EEG, EventLabel, LatPnt)

% Create new event.
if isempty(EEG.event);
    EEG.event(1).latency=LatPnt;
else
    EEG.event(length(EEG.event)+1).latency=LatPnt;
end

nevents=length(EEG.event);

EEG.event(nevents).type=EventLabel;
EEG.event(nevents).code='Comment';
EEG.event(nevents).duration=1;
EEG.event(nevents).channel=0;
EEG.event(nevents).bvtime=[];
EEG.event(nevents).urevent=[];
if EEG.trials==1;
    EEG.event(nevents).epoch=1;
else
    EEG.event(nevents).epoch=ceil(LatPnt/EEG.pnts);
end


% Sort events.

for i=1:length(EEG.event);
    latencies(i,1)=EEG.event(i).latency;
    latencies(i,2)=i;
end

latenciesSort=sortrows(latencies,1);

if exist('SortedEvents');
    clear SortedEvents;
end

for i=1:length(EEG.event);
    SortedEvents(i)=EEG.event(latenciesSort(i,2));
end

EEG=rmfield(EEG,'event');

EEG.event=SortedEvents;
clear latenciesSort latencies SortedEvents;

