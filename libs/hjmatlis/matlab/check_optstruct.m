function [opts] = check_optstruct(opts, def_opts)
%[opts] = check_optstruct(opts, def_opts)
%parse until two level struct to declare options in a function
%INPUT
%   -opts: options struct to be filled (if necessary)
%   -def_opts: default options to be used to fill the options struct passed
%OUTPUT
%   -opts: filled options struct
%
%EXAMPLE CODE:
% 
% function foo(var1 var2, opts)
%     def_opts = struct(...
%         'discard_first_n_scans',false,...%as default do not discard any volume
%         'file_wildcard', 'f*.nii',...
%         'opts_norm', struct(...
%             'is_direct', true,...
%             'bbtype', 0, ...
%             'new_voxel_mmdim', [2 2 2], ...
%             'seg_regtype', 'mni' ...
%         ),...
%         'smoothFilter', 6, ...%default 6mm
%         'force_rewrite', false, ...%default false (it will overwrite the normalized images anyway
%     );
%     if ~exist('opts','var')
%         %if opts struct is not passed, fill with default
%         opts = def_opts;
%     else
%         %fill opts struct with default values if necessary
%         [opts] = check_optstruct(opts, def_opts);
%     end
    

    fnms = fieldnames(def_opts);
    for i=1:length(fnms)
        if ~isfield(opts,fnms{i})
            opts.(fnms{i}) = def_opts.(fnms{i});
        elseif isstruct(opts.(fnms{i}))
            sub_fnms = fieldnames(def_opts.(fnms{i}));
            for i2=1:length(sub_fnms)
                if ~isfield(opts.(fnms{i}),sub_fnms{i2})
                    opts.(fnms{i}).(sub_fnms{i2})=def_opts.(fnms{i}).(sub_fnms{i2});
                end
            end
        end
    end
end

