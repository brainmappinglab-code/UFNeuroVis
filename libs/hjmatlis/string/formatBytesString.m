function outstr=formatBytesString(bytesValue, precision)
    if ~exist('precision','var')
        precision=2;
    end
    unitFormats = {'B', 'KB', 'MB', 'GB', 'TB', 'PB'}; 
    %if it is a negative number throw error
    if bytesValue<0
        error('bytes values have to be a non negative value');
    elseif bytesValue==0%handle the case when bytes value is 0
        outstr='0B';
        return
    end
    powval = floor(log(bytesValue) / log(1024)); 
    %set last label as limit (well if you go over petabytes.. that is a nice amount fo data
    powval = min([powval, length(unitFormats)-1]);

    outstr=strcat(num2str(round_with_prec(bytesValue/(1024^powval), precision)),unitFormats{powval+1}); 