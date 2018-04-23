%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Name:    hjanalyze_custom_macro1.m
% 
% Desc:    sets useful macro for the matlab workspace and editor.
%          In addition it supports the experimental @hjmeta parser
% 
% Created: 01-Mar-2017 03:26:25
% 
% Author:  Enrico Opri
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hjanalyze_custom_macro1()
    EditorMacro('Alt-Control-shift-h', @createHeaderComment2);
    EditorMacro('Alt-Control-h', @createHeaderComment1);
    
    %setting the <Ctrl-E> combination to a macro moving to the end-of-line (unix-style – equivalent to <End> on Windows), 
    %and <Ctrl-Shift-E> to a similar macro doing the same while also selecting the text (like <Shift-End> on Windows).
    EditorMacro('ctrl-e',@EOL_Macro,'run');
    EditorMacro('ctrl-shift-e',@EOL_Macro,'run')
    
    
    EditorMacro('ctrl-shift-l',@metacontent_autoparser_Macro,'run')
    
    
    %display instructions (it is nice to remember them)
    fprintf('Editor Macro additions\n\n');
    
    fprintf('ctrl-shift L : metacontent_autoparser_Macro:\n')
    fprintf('write @hjmeta: and type of metadata to be parsed. \n');
    fprintf('Types are : web, onenote.');
    fprintf('e.g. @hjmeta: web: https://www.google.com\n');
    
end

function comment = createHeaderComment1(hDocument, eventData)
  timestamp = datestr(now);
  username = 'Enrico Opri';%getenv('username');
  %computer = getenv('computername');  % unused
  lineStr = repmat('%',1,75);
  try
    tabName=hjmathandl.editor.getActiveTabName();
  catch
    tabName='enter a name for the function';
  end
  
  comment = sprintf(...
      ['%s\n' ...
       '%% \n' ...
       '%% Name:    %s\n' ...
       '%% \n' ...
       '%% Desc:    enter description here\n' ...
       '%% \n' ...
       '%% Author:  %s\n' ...
       '%% \n' ...
       '%s\n'], ...
       lineStr, tabName, username, lineStr);
end  % createHeaderComment

function comment = createHeaderComment2(hDocument, eventData)
  timestamp = datestr(now);
  username = 'Enrico Opri';%getenv('username');
  %computer = getenv('computername');  % unused
  lineStr = repmat('%',1,75);
  try
    tabName=hjmathandl.editor.getActiveTabName();
  catch
    tabName='enter a name for the function';
  end
  
  comment = sprintf(...
      ['%s\n' ...
       '%% \n' ...
       '%% Name:    %s\n' ...
       '%% \n' ...
       '%% Desc:    enter description here\n' ...
       '%% \n' ...
       '%% Inputs:  enter inputs here\n' ...
       '%% \n' ...
       '%% Outputs: enter outputs here\n' ...
       '%% \n' ...
       '%% Created: %s\n' ...
       '%% \n' ...
       '%% Author:  %s\n' ...
       '%% \n' ...
       '%s\n'], ...
       lineStr, tabName, timestamp, username, lineStr);
end  % createHeaderComment

function EOL_Macro(hDocument,eventData)
 
  % Find the position of the next EOL mark
  currentPos = hDocument.getCaretPosition;
  docLength = hDocument.getLength;
  textToEOF = char(hDocument.getTextStartEnd(currentPos,docLength));
  nextEOLPos = currentPos+find(textToEOF<=13,1)-1;  % next CR/LF pos
  if isempty(nextEOLPos)
      % no EOL found (=> move to end-of-file)
      nextEOLPos = docLength;
  end
 
  % Do action based on whether <Shift> was pressed or not
  %get(eventData);
  if eventData.isShiftDown
      % Select to EOL
      hDocument.moveCaretPosition(nextEOLPos);
  else
      % Move to EOL (without selection)
      hDocument.setCaretPosition(nextEOLPos);
  end
 
end  % EOL_Macro


function metacontent_autoparser_Macro(hDocument,eventData)
 
  % Find the position of the next EOL mark
  currentPos = hDocument.getCaretPosition;
  docLength = hDocument.getLength;

  textToEOF = char(hDocument.getTextStartEnd(currentPos,docLength));
  %get current End of Line (EOL)
  currentEOLPos = currentPos+find(textToEOF<=13,1)-1;  % next CR/LF pos
  clear textToEOF
  
  textFromBOF = char(hDocument.getTextStartEnd(0,currentPos));
  %get current Beginning of Line (BOL)
  currentBOLPos = find(textFromBOF<=13,1,'last');  % prev CR/LF pos
  clear textFromBOF
  
  if isempty(currentEOLPos)
      % no EOL found (=> move to end-of-file)
      currentEOLPos = docLength;
  end
  
  if isempty(currentBOLPos)
      %no BOL found (=> move to start-of-file)
      currentBOLPos=0;
  end
  
  %trim away any comment symbol or spaces at the beginning
  %while(strcmp(lineText1(1),'%') || strcmp(lineText1(1),' '))
  %  lineText1(1)=[];
  %end
  lineText1 = strtrim(char(hDocument.getTextStartEnd(currentBOLPos,currentEOLPos)));
  %if length(lineText1)>8 && strcmp(lineText1(1:8),'@hjmeta:')
  pos_metatag1=strfind(lineText1,'@hjmeta:');
  if ~isempty(pos_metatag1)
      %get meta type
      %metaText1=strtrim(lineText1(9:end));
      metaText1=strtrim(lineText1(pos_metatag1+8:end));
      %find meta type separator (which is ':')
      meta_sep1=find(metaText1==':',1,'first');
      metaType=strtrim(metaText1(1:(meta_sep1-1)));
      metaContent1=strtrim(metaText1((meta_sep1+1):end));
      
      switch (metaType)
          case 'web'
              web(metaContent1,'-browser');
          case 'onenote'
              web(metaText1,'-browser');
          case 'open'
              open(metaContent1);
      end
 
  end
 
end  % EOL_Macro