function bool = keyInterpreter(hObject, eventdata)
switch eventdata.Key
    case 'q'
        delete(hObject);
        bool = false;
    case 'z'
        zoom;
        bool = true;
    case 'x'
        pan;
        bool = true;
    case 'r'
        rotate3d;
        bool = true;
    case 't'
        campan;
        bool = true;
    case 'e'
        camzoom;
        bool = true;
    case 'f'
        zoom off;
        rotate3d off;
        bool = false;
    otherwise
        bool = false;
end
