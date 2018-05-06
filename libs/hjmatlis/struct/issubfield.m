function [ is_subfield ] = issubfield( s, field_tag )
%[ is_subfield ] = issubfield( s, field_tag )
%   return true if the whole field_tag represent a rea tree of
%   substructures in the structure passed as input
    
    is_subfield=false;

    field_tree=strsplit(field_tag,'.');
    for i=1:length(field_tree)
        if isfield(s,field_tree{i})
            if i==length(field_tree)
                %if even the last field is field of the structure it means
                %that the whole field_tag represent a tree of subfields
                is_subfield=true;
            else
                %overwrite structure with substructure
                s=s.(field_tree{i});
            end
        end
    end

end

