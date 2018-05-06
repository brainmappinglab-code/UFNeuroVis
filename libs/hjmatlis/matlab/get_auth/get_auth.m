function [username,password]=get_auth(defaultuser)
%get_auth prompts a username and password from a user and hides the
% password input by *****
%
%   [user,password] = get_auth;
%   [user,password] = get_auth(defaultuser);
%
% arguments:
%   defaultuser - string for default name
%
% results:
%   username - string for the username
%   password - password as a string

persistent cache_username

if isempty(cache_username)
    cache_username='';
end

is_cached=false;
if nargin==0
    defaultuser='';
elseif nargin==1
    if isemptyvect(defaultuser) || isequal(defaultuser,true)
        is_cached=true;
        %reload cached user
        defaultuser=cache_username;
    end
else
    error('too many inputs');
end
  
h_auth=struct();

h_auth.fig = figure('Menubar','none','Units','normalized','Resize','off','NumberTitle','off', ...
                   'Name','Authentication','Position',[0.4 0.4 0.2 0.2],'WindowStyle','normal');

uicontrol('Parent',h_auth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0 0 1 1], ...
          'FontSize',12);

%create label for Username
uicontrol('Parent',h_auth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0.1 0.8 0.8 0.1], ...
                      'FontSize',12,'String','Username:','HorizontalAlignment','left');
                  
                 
h_auth.h_user = uicontrol('Parent',h_auth.fig,'Style','edit','Tag','username','Units','normalized','Position',[0.1 0.675 0.8 0.125], ...
                       'FontSize',12,'String',defaultuser,'BackGroundColor','white','HorizontalAlignment','left');
                
%create label for Password
uicontrol('Parent',h_auth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0.1 0.5 0.8 0.1], ...
          'FontSize',12,'String','Password:','HorizontalAlignment','left');
   
is_java_pwd=false;
try
    jPasswordField = javax.swing.JPasswordField('');  % default password arg is optional
    jPasswordField = javaObjectEDT(jPasswordField);  % javaObjectEDT is optional but recommended to avoid timing-related GUI issues
    
    %init java pwd field (set it in a random position, it will be adjusted later
    [jButton, hButton] = javacomponent(jPasswordField, [10,10,70,20], h_auth.fig);
    set(hButton,'units','norm', 'position',[0.1 0.375 0.8 0.125]);
    h_auth.h_pwd = hButton;
    h_auth.j_pwd = jButton;
    is_java_pwd=true;
catch
    h_auth.h_pwd = uicontrol('Parent',h_auth.fig,'Style','edit', 'Enable', 'off','Tag','password','Units','normalized','Position',[0.1 0.375 0.8 0.125], ...
                            'FontSize',12,'String','','BackGroundColor','white','HorizontalAlignment','left');
    set(h_auth.h_pwd,'KeypressFcn',@keypress_password)
end

h_auth.is_java_pwd=is_java_pwd;
h_auth.val_user='';%this is where the pwd val gets stored
         
%if press OK then execute uiresume and end the script
uicontrol('Parent',h_auth.fig,'Style','pushbutton','Tag','OK','Units','normalized','Position',[0.1 0.05 0.35 0.2], ...
                            'FontSize',12,'String','OK','Callback',@click_ok);                   
                        
uicontrol('Parent',h_auth.fig,'Style','pushbutton','Tag','Cancel','Units','normalized','Position',[0.55 0.05 0.35 0.2], ...
                            'FontSize',12,'String','Cancel','Callback',@event_abort_auth);                                           

set(h_auth.fig,'CloseRequestFcn',@event_abort_auth)

setappdata(0,'h_auth',h_auth);
uicontrol(h_auth.h_user);

%block function based on UI interaction (uiresume will continue the
%execution of the function)
uiwait;

%by now it should be updated
h_auth = getappdata(0,'h_auth');
username = get(h_auth.h_user,'String');
password = h_auth.val_user;
%password = get(h_auth.h_pwd,'UserData');
delete(h_auth.fig);

cache_username=username;

end

function keypress_password(hObject,event)
    h_auth = getappdata(0,'h_auth');
    
    password = get(h_auth.h_pwd,'UserData');
    switch event.Key
       case 'backspace'
          password = password(1:end-1);
       case 'return'
          uiresume;
          return;
       otherwise
          password = [password event.Character];
    end
    h_auth.val_user=char('*'*ones(size(password)));
    %set(h_auth.h_pwd,'String',char('*'*ones(size(password))));
    set(h_auth.h_pwd,'UserData',password)
end
    
function click_ok(hObject,event)
    h_auth = getappdata(0,'h_auth');
    if h_auth.is_java_pwd
        %set(h_auth.h_pwd,'UserData',h_auth.h_pwd.Text);
        h_auth.val_user=char(h_auth.j_pwd.Text);
        uiresume;
    else
        uiresume;
    end
    setappdata(0,'h_auth',h_auth);
end

function event_abort_auth(hObject,event)
    h_auth = getappdata(0,'h_auth');
    set(h_auth.h_user,'String','');
    %set(h_auth.h_pwd,'UserData','');
    h_auth.val_user='';
    uiresume;
end