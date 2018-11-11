function create_headers()
%CREATE_HEADERS create Headers object and save as Headers.mat in the data folder

Headers.stimTrack = {
    'Stimulation Track #'                   '' '' '' '' '' '';
    'Anterior'                              '' '' '' '' '' '';
    'Medial'                                '' '' '' '' '' '';
    'Angle from the verticle line'          '' '' '' '' '' '';
    'Presence of heme prior to track'       '' '' '' '' '' '';
    'Depth to target (mm)'                  '' '' '' '' '' '';
    'Depth (mm)' '(-)' '(+)' 'Frequency' 'Amplitude' 'Pulse Width' 'Comments'
    };

Headers.recordingTrack = {
    'Recording Track #'                     '' '' '' '' '' '' '' '';
    'Anterior'                              '' '' '' '' '' '' '' '';
    'Medial'                                '' '' '' '' '' '' '' '';
    'Angle from the verticle line'          '' '' '' '' '' '' '' '';
    'Presence of heme prior to track'       '' '' '' '' '' '' '' '';
    'Depth to target (mm)'                  '' '' '' '' '' '' '' '';
    'Recording Grade' 'Site/Time' 'Depth (mm)' 'Cell Location' 'Cell Location Certain' 'Cell Type' 'Body Part Location' 'Body Part Movement' 'Comments'
    };

Headers.postRecordingStim = {
    'Depth (mm)' 'Stimulation Type' 'Current' 'Response' 'Description of Sensation'
    };

Headers.updrsHeaders = {
    %Patient Info
    'Last Name:'        '' '' '' '' '';
    'First Name:'       '' '' '' '' '';
    'Middle Name:'      '' '' '' '' '';
    'MRN:'              '' '' '' '' '';
    'Date of Birth:'    '' '' '' '' '';
    'Study Case:'       '' '' '' '' '';
    'Hemisphere:'       '' '' '' '' '';
    'Date of Service:'  '' '' '' '' '';
    'Surgery:'          '' '' '' '' '';
    ''                  '' '' '' '' '';
    ''                  'AP' 'Lt' 'Ax' '' '';
    'Set Target Point'  '' '' '' '' '';
    'Set Entry Point'   '' '' '' '' '';
    'Base Slider'       '' '' '' '' '';
    'Arc Slider'        '' '' '' '' '';
    'Axial Slider'      '' '' '' '' '';
    'Collar Angle'      '' '' '' '' '';
    'Arc Angle'         '' '' '' '' '';
    ''                  '' '' '' '' '';
    ''                  'AP' 'Lt' 'Ax' '' '';
    'Set AC Point'      '' '' '' '' '';
    'Set PC Point'      '' '' '' '' '';
    'Set Ctr Line Point' '' '' '' '' '';
    'Set Func Point'    '' '' '' '' '';
    'AC-PC Angle'       '' '' '' '' '';
    'Ctr Line Angle'    '' '' '' '' '';
    ''                  '' '' '' '' '';
    % Baseline
    'Baseline UPDRS'    '' '' '' '' '';
    'Speech'            '' '' '' '' '';
    'Facial'            '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Rigidity'          '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Action/Postural Tremor (UE)'       '' '' '' '' '';
    'Finger Taps (UE)'                  '' '' '' '' '';
    'Hand Movements (UE)'               '' '' '' '' '';
    'Rapid Alternating Movements (UE)'  '' '' '' '' '';
    'Abduction/Adduction (LE)'          '' '' '' '' '';
    'Plantarflexion/Dorsiflexion (LE)'  '' '' '' '' '';
    'Spiral'                            '' '' '' '' '';
    'Drink'                             '' '' '' '' '';
    'Dystonia Comments'                 '' '' '' '' '';
    'Dyskinesia Comments'               '' '' '' '' '';
    'General Comments'                  '' '' '' '' '';
    ''                                  '' '' '' '' '';
    % Post Electrode
    'Post Microelectrode UPDRS'         '' '' '' '' '';
    'Speech'                            '' '' '' '' '';
    'Facial'                            '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Rigidity'          '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Action/Postural Tremor (UE)'       '' '' '' '' '';
    'Finger Taps (UE)'                  '' '' '' '' '';
    'Hand Movements (UE)'               '' '' '' '' '';
    'Rapid Alternating Movements (UE)'  '' '' '' '' '';
    'Abduction/Adduction (LE)'          '' '' '' '' '';
    'Plantarflexion/Dorsiflexion (LE)'  '' '' '' '' '';
    'Spiral'                            '' '' '' '' '';
    'Drink'                             '' '' '' '' '';
    'Dystonia Comments'                 '' '' '' '' '';
    'Dyskinesia Comments'               '' '' '' '' '';
    'General Comments'                  '' '' '' '' '';
    ''                                  '' '' '' '' '';
    % Post Lead
    'Post Lead UPDRS'   '' '' '' '' '';
    'Speech'            '' '' '' '' '';
    'Facial'            '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Rigidity'          '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Action/Postural Tremor (UE)'       '' '' '' '' '';
    'Finger Taps (UE)'                  '' '' '' '' '';
    'Hand Movements (UE)'               '' '' '' '' '';
    'Rapid Alternating Movements (UE)'  '' '' '' '' '';
    'Abduction/Adduction (LE)'          '' '' '' '' '';
    'Plantarflexion/Dorsiflexion (LE)'  '' '' '' '' '';
    'Spiral'                            '' '' '' '' '';
    'Drink'                             '' '' '' '' '';
    'Dystonia Comments'                 '' '' '' '' '';
    'Dyskinesia Comments'               '' '' '' '' '';
    'General Comments'                  '' '' '' '' '';
    };

Headers.trsHeaders = {
    %Patient Info
    'Last Name:'        '' '' '' '' '';
    'First Name:'       '' '' '' '' '';
    'Middle Name:'      '' '' '' '' '';
    'MRN:'              '' '' '' '' '';
    'Date of Birth:'    '' '' '' '' '';
    'Study Case:'       '' '' '' '' '';
    'Hemisphere:'       '' '' '' '' '';
    'Date of Service:'  '' '' '' '' '';
    'Surgery:'          '' '' '' '' '';
    ''                  '' '' '' '' '';
    ''                  'AP' 'Lt' 'Ax' '' '';
    'Set Target Point'  '' '' '' '' '';
    'Set Entry Point'   '' '' '' '' '';
    'Base Slider'       '' '' '' '' '';
    'Arc Slider'        '' '' '' '' '';
    'Axial Slider'      '' '' '' '' '';
    'Collar Angle'      '' '' '' '' '';
    'Arc Angle'         '' '' '' '' '';
    ''                  '' '' '' '' '';
    ''                  'AP' 'Lt' 'Ax' '' '';
    'Set AC Point'      '' '' '' '' '';
    'Set PC Point'      '' '' '' '' '';
    'Set Ctr Line Point' '' '' '' '' '';
    'Set Func Point'    '' '' '' '' '';
    'AC-PC Angle'       '' '' '' '' '';
    'Ctr Line Angle'    '' '' '' '' '';
    ''                  '' '' '' '' '';
    % Baseline
    'Baseline TRS'      '' '' '' '' '';
    'Voice'             '' '' '' '' '';
    'Facial'            '' '' '' '' '';
    'Handwriting'       '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Postural Tremor'   '' '' '' '' '';
    'Action Tremor'     '' '' '' '' '';
    ''                  'Postural' 'Rest' '' '' '';
    'Tongue Tremor'     '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Spiral'               '' '' '' '' '';
    'Drink'                '' '' '' '' '';
    'Dystonia Comments'    '' '' '' '' '';
    'Dyskinesia Comments'  '' '' '' '' '';
    'General Comments'     '' '' '' '' '';
    ''                     '' '' '' '' '';
    % Post Electrode
    'Post Microelectrode TRS'      '' '' '' '' '';
    'Voice'             '' '' '' '' '';
    'Facial'            '' '' '' '' '';
    'Handwriting'       '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Postural Tremor'   '' '' '' '' '';
    'Action Tremor'     '' '' '' '' '';
    ''                  'Postural' 'Rest' '' '' '';
    'Tongue Tremor'     '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Spiral'               '' '' '' '' '';
    'Drink'                '' '' '' '' '';
    'Dystonia Comments'    '' '' '' '' '';
    'Dyskinesia Comments'  '' '' '' '' '';
    'General Comments'     '' '' '' '' '';
    ''                     '' '' '' '' '';
    % Post Lead
    'Post Lead TRS'      '' '' '' '' '';
    'Voice'             '' '' '' '' '';
    'Facial'            '' '' '' '' '';
    'Handwriting'       '' '' '' '' '';
    ''                  'Face' 'LUE' 'RUE' 'LLE' 'RLE';
    'Rest Tremor'       '' '' '' '' '';
    'Postural Tremor'   '' '' '' '' '';
    'Action Tremor'     '' '' '' '' '';
    ''                  'Postural' 'Rest' '' '' '';
    'Tongue Tremor'     '' '' '' '' '';
    ''                  'Left' 'Right' '' '' '';
    'Spiral'               '' '' '' '' '';
    'Drink'                '' '' '' '' '';
    'Dystonia Comments'    '' '' '' '' '';
    'Dyskinesia Comments'  '' '' '' '' '';
    'General Comments'     '' '' '' '' '';
    };

save('data\Headers.mat','Headers');

end

