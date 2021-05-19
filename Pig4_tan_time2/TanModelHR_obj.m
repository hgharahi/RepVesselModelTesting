function ER = TanModelHR_obj(x, Control, Anemia, Dob, layer, state, MetSignal)


%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(14);
        
    otherwise
        
        S0 = 0.037;
        
end

Control = ATPconcentration(Control, S0, MetSignal);

Anemia = ATPconcentration(Anemia, S0, MetSignal);

Dob = ATPconcentration(Dob, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['DexpC = Control.',layer,'.D;']);
eval(['PexpC = Control.',layer,'.Ptm;']);
eval(['MetSignalC = Control.',layer,'.MetSignal;']);

Dc = DexpC(4);
Pc = PexpC(4);
CAT = 0; %Existence of extrinsic catecholamine (dobutamine)

[DmodC, AmodC , ~, ~, ~, ~, convC] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, CAT, state);

%%%%------Passive and Fully active diameters
[DpC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, CAT, 'passive');
[DcC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, CAT, 'constricted');

% %%%%%%%%%%%%%% Anemia

eval(['DexpA = Anemia.',layer,'.D;']);
eval(['PexpA = Anemia.',layer,'.Ptm;']);
eval(['MetSignalA = Anemia.',layer,'.MetSignal;']);
CAT = 0; %Existence of extrinsic catecholamine (dobutamine)

[DmodA, ~ , ~, ~, ~, ~, convA] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, CAT, state);

%%%%------Passive and Fully active diameters
[DpA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, CAT, 'passive');
[DcA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, CAT, 'constricted');

% %%%%%%%%%%%%%% Dob+Anemia

eval(['DexpD = Dob.',layer,'.D;']);
eval(['PexpD = Dob.',layer,'.Ptm;']);
eval(['MetSignalD = Dob.',layer,'.MetSignal;']);
CAT = 1; %Existence of extrinsic catecholamine (dobutamine)

[DmodD, ~ , ~, ~, ~, ~, convD] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc, CAT, state);

%%%%------Passive and Fully active diameters
[DpD, ~] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc, CAT, 'passive');
[DcD, ~] = CarlsonModelTime(x, PexpD, DexpD, MetSignalD, Dob.HR, Dc, Pc, CAT, 'constricted');

%%%%%%%%%%%%% Objective function
DMod = [DmodC,	DmodA,  DmodD];
DExp = [DexpC,	DexpA,	DexpD];

Dp = [DpC, DpA, DpD];
Dc = [DcC, DcA, DcD];
if sum(isnan(DMod)) || sum(convC+convA+convD)|| sum([sum((Dp-DExp)<0),sum((DExp-Dc)<0)])
    ER = 1000;
else
    ER = norm((DExp - DMod)/100); % + 1000*(x(2)<x(3));
end
