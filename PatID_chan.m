function EEG = PatID_chan(EEG, ChanLabel, ChanMethod, varargin)

g = finputcheck(varargin,  { 'chanlabel'        'string'         ''        '';
                             'chanevalstr'      'string'         ''        '';
                             'datatype'         'string'         ''        '';
                             'siglabel'         'string'         ''        '';
                             'derchandeci'      'integer'        []        [];
                             'derchanlphz'      'integer'        []        [];
                             'derchangain'      'integer'        []        []});

if isstr(g), error(g); end;



%if strcmp(ChanMethod, 'eval string');
    
%    if ~isfield(EEG, 'PatID');
%        EEG.PatID.nbchan=0;
%    end
    
%    EEG.PatID.nbchan=EEG.PatID.nbchan+1;
%    EEG.PatID.chanlocs(EEG.PatID.nbchan).labels=ChanLabel;
%    eval(['EEG.PatID.data(EEG.PatID.nbchan,:)=' g.chanevalstr ';']);
        
%end


if strcmp(ChanMethod, 'eval string');
    
    EEG.nbchan=EEG.nbchan+1;
    EEG.chanlocs(EEG.nbchan).labels=ChanLabel;
    eval(['EEG.data(EEG.nbchan,:,:)=' g.chanevalstr ';']);
    EEG.chanlocs(EEG.nbchan).type='PatID';
    if isfield(EEG.chanlocs, 'badchan');
        EEG.chanlocs(EEG.nbchan).badchan=0;
    end

end

%if strcmp(ChanMethod, 'derivative');
    
%    if ~isfield(EEG, 'PatID');
%        EEG.PatID.nbchan=0;
%    end
    
%    EEG.PatID.nbchan=EEG.PatID.nbchan+1;
%    EEG.PatID.chanlocs(EEG.PatID.nbchan).labels=ChanLabel;
    
%    if strcmp(g.datatype, 'EEG');
%        data=EEG.data(strmatch(g.siglabel, {EEG.chanlocs.labels}),:,:);
%    end
%    if strcmp(g.datatype, 'PatID');
%        data=EEG.PatID.data(strmatch(g.siglabel, {EEG.PatID.chanlocs.labels}),:,:);
%    end


%    x=decimate(double(data),g.derchandeci);
%    y=interp(x,g.derchandeci);
    
%    [B,A]=butter(2,g.derchanlphz/(EEG.srate/2));
%    y=filtfilt(B,A,y);
    
%    t=[1:length(y)]*(1/EEG.srate);
    
%    DerData = diff(y)./diff(t);
    
%    dataRange=max(data)-min(data);
%    DerDataRange=max(DerData)-min(DerData);
    
%    RangeRatio=dataRange/DerDataRange;
    
%    DerData=DerData*RangeRatio*g.derchangain;
    
%    EEG.PatID.data(EEG.PatID.nbchan,1:length(DerData))=DerData;

%end


if strcmp(ChanMethod, 'derivative');
    
    EEG.nbchan=EEG.nbchan+1;
    EEG.chanlocs(EEG.nbchan).labels=ChanLabel;
    EEG.chanlocs(EEG.nbchan).type='PatID';
    if isfield(EEG.chanlocs, 'badchan');
        EEG.chanlocs(EEG.nbchan).badchan=0;
    end
    
    if strcmp(g.datatype, 'EEG');
        data=double(EEG.data(strmatch(g.siglabel, {EEG.chanlocs.labels}),:,:));
    end
    if strcmp(g.datatype, 'IC');
        if ~isempty(EEG.icaact);
            data = double(EEG.icaact(str2num(g.siglabel),:,:));
        else
            tmpdata=[];
            tmpdata = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, length(EEG.icaweights(1,:)), EEG.trials*EEG.pnts);
            tmpdata = reshape( tmpdata, size(tmpdata,1), EEG.pnts, EEG.trials);
            data=double(tmpdata(str2num(g.siglabel),:,:));
        end;
    end


    x=decimate(data,g.derchandeci);
    y=interp(x,g.derchandeci);
    
    [B,A]=butter(2,g.derchanlphz/(EEG.srate/2));
    y=filtfilt(B,A,y);
    
    t=[1:length(y)].*(1/EEG.srate);
    
    DerData = diff(y)./diff(t);
    
    dataRange=max(max(data))-min(min(data));
    DerDataRange=max(max(DerData))-min(min(DerData));
    
    RangeRatio=dataRange/DerDataRange;

    size(DerData)
    size(RangeRatio)
    size(g.derchangain)
    DerData=DerData*RangeRatio*g.derchangain;

    EEG.data(EEG.nbchan,:)=zeros(1,length(EEG.data(1,:)));
    if length(DerData)>length(EEG.data(1,:));
        DerData=DerData(1:length(EEG.data(1,:)));
    end
    
    EEG.data(EEG.nbchan,1:length(DerData))=DerData;

end
