X=magic(10);

shmkey=12345; 
sharedmatrix('clone',shmkey,X); 
clear X; 
spmd(2) 
    X=sharedmatrix('attach',shmkey); 
    % do something with X 
    sharedmatrix('detach',shmkey,X); 
end 
sharedmatrix('free',shmkey);