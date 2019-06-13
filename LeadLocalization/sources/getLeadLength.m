function len=getLeadLength(leadType)
%% len=getLeadLength(leadType)
%
%  Given the name of the lead, return the reported lead length in millimeters. Note that
%  this is not the exact same number as the documentation, but is corrected for the length
%  from the center of the first contact to the center of the last contact. This makes the
%  length given 2 mm shorter than spec sheet states.
%
%   Inputs:
%    - leadType: String containing the name of the lead, same as the leadModel name
%
%   Outputs:
%    - len: Length of the lead in mm from center of the proximal contact to center of the
%       distal contact
%
%  Brandon Parks, 2019
%

switch leadType
    case 'UF_sEEG_8'
        len=24.5;
    case 'UF_sEEG_10'
        len=31.5;
    case 'UF_sEEG_12'
        len=38.5;
    case 'UF_sEEG_14'
        len=45.5;
    case 'UF_sEEG_16'
        len=66.5;
    case 'medtronic_3387'
        len=9;
    case 'medtronic_3389'
        len=6;
end

end