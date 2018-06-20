LEADpath = 'C:\Users\eisinger\Documents\GoNoGo\Data and Analysis\Imaging\PD_Processed_Lauren\ID5\Processed\LEAD_Right_01.mat';
LEAD = load(LEADpath);
Proximal = LEAD.Proximal;
Distal = LEAD.Distal;
Distance = (Proximal - Distal) / 6;

LEAD.Contact0 = Distal;
LEAD.Contact10 = Distal+Distance;
LEAD.Contact1 = Distal+Distance*2;
LEAD.Contact12 = Distal+Distance*3;
LEAD.Contact2 = Distal+Distance*4;
LEAD.Contact23 = Distal+Distance*5;
LEAD.Contact3 = Distal+Distance*6;

LEAD
