function display_match(aH,match,iPass)
%{
DISPLAY_MATCH
    updates text displays with DBS data from closest match to selected point
ARGS
    aH: handle of axes to plot 3D trajectory on
    match: row-index of matching DBS entry
    iPass: depth-index of matching DBS entry
RETURNS
    None
%}

f = ancestor(aH,'figure');
DbsData = getappdata(f,'DbsData');

m_pass_disp = findobj(f,'Tag','m_pass_disp');
m_depth_disp = findobj(f,'Tag','m_depth_disp');
m_location_disp = findobj(f,'Tag','m_location_disp');
m_cert_disp = findobj(f,'Tag','m_cert_disp');
m_type_disp = findobj(f,'Tag','m_type_disp');
m_body_disp = findobj(f,'Tag','m_body_disp');
m_mvmt_disp = findobj(f,'Tag','m_mvmt_disp');

if (match == 0)
    set(m_pass_disp,'String','');
    set(m_depth_disp,'String','');
    set(m_location_disp,'String','');
    set(m_cert_disp,'String','');
    set(m_type_disp,'String','');
    set(m_body_disp,'String','');
    set(m_mvmt_disp,'String','');
else
    set(m_pass_disp,'String',num2str(iPass));
    set(m_depth_disp,'String',[num2str(DbsData.data1{match,2,iPass}) ' mm']);

    switch DbsData.data1{match,3,iPass}
        case '1'
            set(m_location_disp,'String','Thal');
        case '2'
            set(m_location_disp,'String','Str');
        case '3'
            set(m_location_disp,'String','STN');
        case '4'
            set(m_location_disp,'String','SNr');
        case '5'
            set(m_location_disp,'String','GPE');
        case '6'
            set(m_location_disp,'String','GPi');
        case '7'
            set(m_location_disp,'String','Voa');
        case '8'
            set(m_location_disp,'String','Vop');
        case '9'
            set(m_location_disp,'String','Vim');
        case '10'
            set(m_location_disp,'String','Vc');
        case '11'
            set(m_location_disp,'String','IC');
        case '12'
            set(m_location_disp,'String','OT');
        case '13'
            set(m_location_disp,'String','Zl');
        case '14'
            set(m_location_disp,'String','Bord');
        case '15'
            set(m_location_disp,'String','Ansa');
        case '16'
            set(m_location_disp,'String','Nucl');
        case '17'
            set(m_location_disp,'String','Qui.');
        case '18'
            set(m_location_disp,'String','Oth.');
        case '19'
            set(m_location_disp,'String','Fib.');
        case '20'
            set(m_location_disp,'String','Top');
        case '21'
            set(m_location_disp,'String','Bot.');
        otherwise
            set(m_location_disp,'String','');
    end

    switch DbsData.data1{match,5,iPass}
        case '1'
            set(m_cert_disp,'String','Certain');
        case '2'
            set(m_cert_disp,'String','Uncertain');
        otherwise
            set(m_cert_disp,'String','');
    end

    switch DbsData.data1{match,6,iPass}
        case '1'
            set(m_type_disp,'String','Injury');
        case '2'
            set(m_type_disp,'String','Popcorn');
        case '3'
            set(m_type_disp,'String','Bursting');
        case '4'
            set(m_type_disp,'String','Pausing');
        case '5'
            set(m_type_disp,'String','Chugging');
        case '6'
            set(m_type_disp,'String','HFD-P');
        case '7'
            set(m_type_disp,'String','LFD-P');
        case '8'
            set(m_type_disp,'String','Tactile');
        case '9'
            set(m_type_disp,'String','L. Touch');
        case '10'
            set(m_type_disp,'String','Rhythmic');
        case '11'
            set(m_type_disp,'String','Pro. Act');
        case '12'
            set(m_type_disp,'String','Pro. Pas');
        case '13'
            set(m_type_disp,'String','Tonic');
        case '14'
            set(m_type_disp,'String','Neg');
        case '15'
            set(m_type_disp,'String','Tremor');
        case '16'
            set(m_type_disp,'String','Low Amp.');
        case '17'
            set(m_type_disp,'String','High Amp.');
        case '18'
            set(m_type_disp,'String','Oscilla');
        case '19'
            set(m_type_disp,'String','Bg. Up');
        case '20'
            set(m_type_disp,'String','Bg. Down');
        case '21'
            set(m_type_disp,'String','Other');
        otherwise
            set(m_type_disp,'String','');
    end

    switch DbsData.data1{match,7,iPass}
        case '1'
            set(m_body_disp,'String','Face');
        case '2'
            set(m_body_disp,'String','Cheek');
        case '3'
            set(m_body_disp,'String','In. Mouth');
        case '4'
            set(m_body_disp,'String','Tongue');
        case '5'
            set(m_body_disp,'String','Jaw');
        case '6'
            set(m_body_disp,'String','Chin');
        case '7'
            set(m_body_disp,'String','Neck');
        case '8'
            set(m_body_disp,'String','Shoulder');
        case '9'
            set(m_body_disp,'String','Elbow');
        case '10'
            set(m_body_disp,'String','Arm');
        case '11'
            set(m_body_disp,'String','Hand');
        case '12'
            set(m_body_disp,'String','Wrist');
        case '13'
            set(m_body_disp,'String','Fingers');
        case '14'
            set(m_body_disp,'String','Hip');
        case '15'
            set(m_body_disp,'String','Leg');
        case '16'
            set(m_body_disp,'String','Knee');
        case '17'
            set(m_body_disp,'String','Ankle');
        case '18'
            set(m_body_disp,'String','Foot');
        case '19'
            set(m_body_disp,'String','Toes');
        otherwise
            set(m_body_disp,'String','');
    end

    switch DbsData.data1{match,8,iPass}
        case '10000000'
            set(m_mvmt_disp,'String','Ab');
        case '01000000'
            set(m_mvmt_disp,'String','Ad');
        case '00100000'
            set(m_mvmt_disp,'String','Ex');
        case '00010000'
            set(m_mvmt_disp,'String','FI');
        case '00001000'
            set(m_mvmt_disp,'String','IR');
        case '00000100'
            set(m_mvmt_disp,'String','ER');
        case '00000010'
            set(m_mvmt_disp,'String','Df');
        case '00000001'
            set(m_mvmt_disp,'String','Pf');
        otherwise
            set(m_mvmt_disp,'String','');
    end
end

end

