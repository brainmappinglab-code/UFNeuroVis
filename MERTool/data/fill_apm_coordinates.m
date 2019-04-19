function ApmDataTable = fill_apm_coordinates(CrwData,DbsData,ApmDataTable)
%{
FILL_APM_COORDINATES
    Fills columns 3,4,5 of ApmDataTable with x,y,z coordinates that
    correspond to the depths in column 1, using the trajectories
    defined in the CrwData. Then plots those x,y,z
ARGS
    CrwData: structure, created by extract_crw_data
    DbsData: structure, contains MER data
    ApmDataTable: structure, created by build_apm_table
    aH: handle of axes to plot 3D trajectory on
RETURNS
    ApmDataTable: structure, 
%}

%get number of passes
nPass = size(DbsData.trackinfo,1);

if (nPass ~= size(ApmDataTable,2))
    error("ERROR: when building ApmDataTable, number of passes in APM files and DBS files do not match.")
    %TODO escape GUI here
    return;
end

LtTargetPoint = zeros(nPass,1);
ApTargetPoint = zeros(nPass,1);
AxTargetPoint = zeros(nPass,1);

%calculate entry point coordinates from CRW and DBS data
%       CrwData.entrypoint(n) contains AP/LT/AX base coordinates
%       DbsData.trackinfo(i,n) indicates positive (2) or negative (3) adjustment
%       DbsData.trackinfo(i,n+1) contains adjustment distance
for i = 1:nPass
    if (DbsData.trackinfo(i,2) == 2)
        ApTargetPoint(i) = CrwData.functargpoint(1) + DbsData.trackinfo(i,3);
    elseif (DbsData.trackinfo(i,2) == 3)
        ApTargetPoint(i) = CrwData.functargpoint(1) - DbsData.trackinfo(i,3);
    end
    if (DbsData.trackinfo(i,4) == 2)
        LtTargetPoint(i) = CrwData.functargpoint(2) + DbsData.trackinfo(i,5);
    elseif (Dbs.trackinfo(i,4) == 3)
        LtTargetPoint(i) = CrwData.functargpoint(2) - DbsData.trackinfo(i,5);
    end
    AxTargetPoint(i) = CrwData.functargpoint(3);
end

%extract crw data for calculating xyz coordinates
CTR = CrwData.clineangle ;
ACPC = CrwData.acpcangle ;

for iPass = 1:nPass
    %extract T values (depths from ApmDataTable column 1)
    T = 30 - ApmDataTable{iPass}.depth;
    
    for iPoint = 1:size(T,1)
        ApmDataTable{iPass}.x(iPoint) = LtTargetPoint(iPass) + (T(iPoint) * sind(CTR));
        ApmDataTable{iPass}.y(iPoint) = ApTargetPoint(iPass) + (T(iPoint) * cosd(ACPC) * cosd(CTR)) ;
        ApmDataTable{iPass}.z(iPoint) = AxTargetPoint(iPass) + (T(iPoint) * sind(ACPC) * cosd(CTR));
    end
end
