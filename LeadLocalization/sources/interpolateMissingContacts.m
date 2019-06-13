function handles=interpolateMissingContacts(numContacts)
%% handles=interpolateMissingContacts(numContacts)
%
%  Creates a GUI to allow for interpolating leads with missing contacts
%
%   Inputs:
%    - numContacts: Number of contacts in the lead. Used to scale the GUI
%
%   Outputs:
%    - handles: Struct contaning the handle to the GUI itself, as well as a nodes field
%       that contains the text/buttons for each contact
%
% Brandon Parks, 2019

if numContacts==0
    handles=[];
    return;
end

figWidth=330;
figHeight=numContacts*50;

handles.gui=figure('Name','Missing Contacts','NumberTitle','off');
handles.gui.Position=[300 150 figWidth figHeight];

distanceBetweenNodes=10;
nodeHeight=floor((figHeight-(numContacts+1)*distanceBetweenNodes)/numContacts);

currPosition=distanceBetweenNodes;
fontSize=round(nodeHeight/2.8);

for i=1:numContacts
    handles.node(i).text=uicontrol(handles.gui,'Style','pushbutton','String',sprintf('#%d',i),...
        'Units','Pixels','Position',[10 currPosition 40 nodeHeight],...
        'FontSize',fontSize,'BackgroundColor',[0.96 0.96 0.96]);
    handles.node(i).text.Enable='off';
    handles.node(i).set=uicontrol(handles.gui,'Style','pushbutton','String','Set',...
        'Units','Pixels','Position',[60 currPosition 50 nodeHeight],...
        'FontSize',fontSize);
    handles.node(i).posStr=uicontrol(handles.gui,'Style','text','String','[    0,    0,    0]',...
        'Units','Pixels','Position',[120 currPosition-7 130 nodeHeight],...
        'FontSize',3*(fontSize/4));
    handles.node(i).view=uicontrol(handles.gui,'Style','pushbutton','String','View',...
        'Units','Pixels','Position',[260 currPosition 60 nodeHeight],...
        'FontSize',fontSize);
    handles.node(i).pos=[];
    currPosition=currPosition+nodeHeight+distanceBetweenNodes;
end

handles.node(1).set.Enable='off';
handles.node(1).view.Enable='off';
handles.node(1).posStr.String='Distal';
handles.node(numContacts).set.Enable='off';
handles.node(numContacts).view.Enable='off';
handles.node(numContacts).posStr.String='Proximal';

end