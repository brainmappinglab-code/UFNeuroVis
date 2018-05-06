%function clear_persistent_vars()
%   CLEAR_PERSISTENT_VARS clear persistent variables (it needs to be a script,
%   to semplify interactions with base workspace)
    Vars0128139=whos;
    Vars0128139=Vars0128139([Vars0128139.persistent]);
    Vars0128139_names={Vars0128139.name};
    if ~isempty(Vars0128139_names)
        clear(Vars0128139_names{:});
    end
    
    clear Vars0128139
    clear Vars0128139_names
%end

