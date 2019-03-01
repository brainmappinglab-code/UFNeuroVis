classdef intch_wc_reader < handle
	properties
        sr
        max_segments
        opened_file
        segmentLength
        open_file
        t0_segments
    end 
	methods 
        function obj = intch_wc_reader(par, raw_filename)
            
            load('intan_meta_data.mat','sr','lts','channels');
            obj.sr = sr;
            
            
            if strcmp(par.tmax,'all')
                initial_index = 0;
                obj.max_segments = ceil(lts/(par.segments_length  * sr * 60)); %number of segments in which data is cut
            else
                initial_index = floor(par.tmin * obj.sr);                   %min time to read (in micro-sec)
                tsmax = min(par.tsmax,lts/sr);
                obj.max_segments = ceil((tsmax - par.tsmin)/ ...
                    (par.segments_length *60));         %number of segments in which data is cutted
            end
            
            obj.opened_file = fopen(raw_filename,'r','l');
			fseek(obj.opened_file,initial_index*4,'bof');
            
            obj.segmentLength = floor (lts/obj.max_segments);
             
            obj.t0_segments = zeros(1,obj.max_segments);
            obj.t0_segments(1) = initial_index*obj.sr;
            for i = 2:obj.max_segments
            	obj.t0_segments(i) = obj.t0_segments(i-1) + obj.segmentLength/obj.sr*1000;
            end
        end     
        function [sr,max_segments,with_raw,with_spikes] = get_info(obj)
        	sr = obj.sr;
            max_segments = obj.max_segments;
            with_raw = true;
            with_spikes = false;
        end
        
        function index_ts = index2ts(obj,index,i)
            index_ts = (index)/obj.sr*1000 + obj.t0_segments(i);
        end
      
        function x = get_segment(obj,i)
            x=fread(obj.opened_file,obj.segmentLength,'single=>double')';
            if i == obj.max_segments
                fclose(obj.opened_file);
            end
        end   
        
    end
end