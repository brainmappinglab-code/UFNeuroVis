function [ TRS_table ] = dbsdata_parse_TRS( trsdata1 )
%[ TRS_table ] = dbsdata_parse_TRS( trsdata1 )
%   parse data as stored by DBSdata program from Bova Lab

TRS_struct= struct( ...
 'intQ1', trsdata1(2,1),... %face tremor
 'intQ2rest', trsdata1(7,2),... % tongue tremor
 'intQ2post', trsdata1(7,1),... % tongue tremor
 'intQ3', trsdata1(1,1),... % voice tremor
 'intQ4rest', trsdata1(4,1),...% executed only rest head tremor (ask to be sure)
 'intQ4post', nan,...%not executed head tremor
 'intQ5rest', trsdata1(4,3),...%RUE tremor (right upper extremity)
 'intQ5post', trsdata1(5,2),...%RUE tremor (right upper extremity)
 'intQ5act', trsdata1(6,2),...%RUE tremor (right upper extremity)
 'intQ6rest', trsdata1(4,2),...
 'intQ6post', trsdata1(5,1),...
 'intQ6act', trsdata1(6,1),...
 'intQ7rest', nan,... %trunk, not executed
 'intQ7post', nan,... %trunk, not executed
 'intQ8rest', trsdata1(4,5),...%RLE tremor (right lower extremity)
 'intQ8post', trsdata1(5,4),...%RLE tremor (right lower extremity)
 'intQ8act', trsdata1(6,4),...%RLE tremor (right lower extremity)
 'intQ9rest', trsdata1(4,4),...
 'intQ9post', trsdata1(5,3),...
 'intQ9act', trsdata1(6,3),...
 'intQ10', trsdata1(3,1),... %handwriting
 'intQ11R', trsdata1(8,2),... %we consider the spiral as only drawing A (being large)
 'intQ11L', trsdata1(8,1),... %we consider the spiral as only drawing A (being large)
 'intQ12R', nan,...
 'intQ12L', nan,...
 'intQ13R', nan,...
 'intQ13L', nan,...
 'intQ14R', trsdata1(9,2),... %it is bringing cup to mount, considering as "pouring" with kind of a stretch
 'intQ14L', trsdata1(9,1)... %it is bringing cup to mount, considering as "pouring" with kind of a stretch
);

TRS_table=struct2table(TRS_struct);
end

