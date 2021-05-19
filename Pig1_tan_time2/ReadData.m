%% Reads data from files
clear;
load AllResults_Control.mat
load AllResults_HD.mat
load AllResults_Dob.mat
%% Reading data / modeling / analysis based on Pzf data from John Tune:

SpecimenPairs = [2,2;
    3,1;
    4,3;
    5,4]; % First column Control, Second column Anemia and Anemia+Dobutamine case number.


Control = (Control);
Dob = (Dob);
Anemia = (HD);

i = 1;

%% Parameter initialization and estimation
names = {'Control','Anemia','Anemia+Dobutamine'};
SpecimenIDs = {'#10013','#10011','#10015','#10276'};
CPP = [40 ,60, 80, 100, 120, 140];

Control = Control{SpecimenPairs(i,1)};
Anemia = Anemia{SpecimenPairs(i,2)};
Dob = Dob{SpecimenPairs(i,2)};

BloodGasMeasurementReading;
CPP(end) = [];

Control =   Calculations(Control);

Anemia  =   Calculations(Anemia);

Dob     =   Calculations(Dob);

[Control, Anemia, Dob] = RepVessel(Control, Anemia, Dob);

RepVessel_Pcor(Control, Anemia, Dob);

Data_Ready = 1;
