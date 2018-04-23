function [ cellarr_out ] = txtfile2cellarr(file_path,txt_sep,line_lim, col_lim, is_num, charset_name)
%[ cellarr_out ] = txtfile2cellarr(file_path [,txt_sep, line_lim, col_lim, is_num)])
%   read a txt file and parse it in a cell array with the txt separator
%   specified (default is '\t' (TAB))
%   -line_lim: represents the range of lines to read (inclusive)
%   -col_lim : represents the range of lines to read (inclusive)
%   -is_num  : state to convert the read text to number. if they are all
%              numbers, it will be automatically formatted as normal array 
%              and not cell array
%   -charset_name: select one otherwise the machone default will be selected
%         US-ASCII	Seven-bit ASCII, a.k.a. ISO646-US, a.k.a. the Basic Latin block of the Unicode character set
%         ISO-8859-1  	ISO Latin Alphabet No. 1, a.k.a. ISO-LATIN-1
%         UTF-8	Eight-bit UCS Transformation Format
%         UTF-16BE	Sixteen-bit UCS Transformation Format, big-endian byte order
%         UTF-16LE	Sixteen-bit UCS Transformation Format, little-endian byte order
%         UTF-16	Sixteen-bit UCS Transformation Format, byte order identified by an optional byte-order mark

    if ~exist('txt_sep','var')
        txt_sep='\t';
    end
    
    if ~exist('line_lim','var')
        line_lim=[1 Inf];
    else
        %if only one element is included in line_lim, assume that the
        %number is the first line to cut from and add an infinite limit
        if isempty(line_lim)
            error('need to specify at least one limit for rows')
        end
        if length(line_lim)==1
            line_lim=[line_lim(1) Inf];
        end
    end
    
    if ~exist('col_lim','var')
        col_lim=[1 Inf];
    else
        %if only one element is included in line_lim, assume that the
        %number is the first line to cut from and add an infinite limit
        if isempty(col_lim)
            error('need to specify at least one limit for columns')
        end
        if length(col_lim)==1
            col_lim=[col_lim(1) Inf];
        end
    end
    
    if ~exist('is_num','var')
        is_num=false;
    end
    
    %open file
    if ~exist('charset_name','var')
        br = java.io.BufferedReader(java.io.FileReader(file_path));
    else
        br = java.io.BufferedReader(java.io.InputStreamReader(java.io.FileInputStream(file_path),java.nio.charset.Charset.forName(charset_name)));
    end
    A={}; 
    try
        line = java.lang.String;
        %line and row id are not always going parallel, this is because you
        %may be skipping lines and therefore the row_i is not increasing
        line_i=0;
        row_i=0;
        while ~is_null(line)
            if line_i>0 && ((line_i>=line_lim(1)) && (line_i<=line_lim(2)))
                row_i=row_i+1;
                fields_found=line.split(txt_sep, -1);
                A{row_i}=cell(fields_found);
            end
            
            %read a line
            line = br.readLine();
            line_i=line_i+1;
        end
    catch
        br.close();
        error('error while reading');
        return
    end
    
    br.close();

    max_cols=0;
    for i=1:length(A)
        if max_cols<length(A{i})
            max_cols=length(A{i});
        end
    end
    
    %check columns limits, substitute inf with real num
    if isinf(col_lim(2))
        col_lim(2)=max_cols;
    end
    
    num_cols=length(col_lim(1):col_lim(2));

    cellarr_out=cell(length(A),num_cols);
    
    for i=1:length(A)
        col_i=0;
        for j=1:length(A{i})
            if ((j>=col_lim(1)) && (j<=col_lim(2)))
                col_i=col_i+1;
                cellval1=A{i}{j};
                
                if isempty(cellval1)
                    cellval1=nan;
                end
                if is_num
                    cellarr_out{i,col_i}=str2double(cellval1);
                else
                    cellarr_out{i,col_i}=cellval1;
                end
            end
        end
    end
    
    %convert to number if it is necessary
    if is_num
    %    cellarr_out=cellfun(@str2num,cellarr_out);
        cellarr_out=cell2mat(cellarr_out);
    end
end

function flag=is_null(value)
    if isempty(value)
        if strcmp(value,'')
            flag=false;
        else
            flag=true;
        end
    else
        flag=false;
    end        
end
