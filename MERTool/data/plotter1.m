function ApmDataTable = plotter1(CrwData,DbsData,ApmDataTable,aH)
%{
PLOTTER1
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

%preallocate space for entry point arrays
LtEntryPoint = zeros(nPass,1);
ApEntryPoint = zeros(nPass,1);
AxEntryPoint = zeros(nPass,1);

%calculate entry point coordinates from CRW and DBS data
%       CrwData.entrypoint(n) contains AP/LT/AX base coordinates
%       DbsData.trackinfo(i,n) indicates positive (2) or negative (3) adjustment
%       DbsData.trackinfo(i,n+1) contains adjustment distance
for i = 1:nPass
    if (DbsData.trackinfo(i,2) == 2)
        ApEntryPoint(i) = CrwData.entrypoint(1) + DbsData.trackinfo(i,3);
    elseif (DbsData.trackinfo(i,2) == 3)
        ApEntryPoint(i) = CrwData.entrypoint(1) - DbsData.trackinfo(i,3);
    end
    if (DbsData.trackinfo(i,4) == 2)
        LtEntryPoint(i) = CrwData.entrypoint(2) + DbsData.trackinfo(i,5);
    elseif (Dbs.trackinfo(i,4) == 3)
        LtEntryPoint(i) = CrwData.entrypoint(2) - DbsData.trackinfo(i,5);
    end
    AxEntryPoint(i) = CrwData.entrypoint(3);
end

%extract crw data for calculating xyz coordinates
CTR = CrwData.clineangle ;
ACPC = CrwData.acpcangle ;

for iPass = 1:nPass
    x = [];
    y = [];
    z = [];
    
    %extract T values (depths from ApmDataTable column 1)
    T = [ApmDataTable{iPass}.depth];
    
    for iPoint = 1:size(T,1)
        % skip empty depths, don't break on empty entries
        % if isempty(ApmDataTable{iPass})
        %     continue % this was break, why?
        % end
        x(iPoint,1) = LtEntryPoint(iPass) -(T(iPoint) * sind(CTR));
        y(iPoint,1) = ApEntryPoint(iPass) - (T(iPoint) * cosd(ACPC) * cosd(CTR)) ;
        z(iPoint,1) = AxEntryPoint(iPass) - (T(iPoint) * sind(ACPC) * cosd(CTR));
        ApmDataTable{iPass}.x(iPoint) = x(iPoint,1);
        ApmDataTable{iPass}.y(iPoint) = y(iPoint,1);
        ApmDataTable{iPass}.z(iPoint) = z(iPoint,1);
    end
    
    %plot each x,y,z after calculating
    fprintf('plotting pass %d\n',iPass)
    lH = plot3(aH,x,y,z,'-s');
    set(lH,'hittest','off');
end
