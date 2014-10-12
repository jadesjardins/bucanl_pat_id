function ind = PeakScan(data, peakdur)

ind=0;
for i=1:length(data)-peakdur;
    x(i)=data(i+peakdur)-data(i);
    if i==3
        if all(x)>0
            slopedir='pos';
        elseif all(x)<0
            slopedir='neg';
        end
    elseif i>3
        if strcmp(slopedir, 'pos') && x(i)<0;
            ind=i+find(data(i:i+peakdur)==max(data(i:i+peakdur)),1)-3;
            break
        elseif strcmp(slopedir, 'neg') && x(i)>0;
            ind=i+find(data(i:i+peakdur)==min(data(i:i+peakdur)),1)-3;
            break
        end        
    end
end
    

