function ER = TanModelHR_obj(x, Control, Anemia, Dob, layer, state, MetSignal)


%%%%%%%%%%%%%% Preparation
switch MetSignal
    
    case 'ATP'
        
        S0 = x(13);
        
    otherwise
        
        S0 = 0.037;
        
end

Control = ATPconcentration(Control, S0, MetSignal);

Anemia = ATPconcentration(Anemia, S0, MetSignal);

%%%%%%%%%%%%%% Control

eval(['DexpC = Control.',layer,'.D;']);
eval(['PexpC = Control.',layer,'.Ptm;']);
eval(['MetSignalC = Control.',layer,'.MetSignal;']);

Dc = DexpC(4);
Pc = PexpC(4);

[DmodC, AmodC , ~, ~, ~, ~, convC] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, state);

%%%%------Passive and Fully active diameters
[DpC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, 'passive');
[DcC, ~] = CarlsonModelTime(x, PexpC, DexpC, MetSignalC, Control.HR, Dc, Pc, 'constricted');

% %%%%%%%%%%%%%% Anemia

eval(['DexpA = Anemia.',layer,'.D;']);
eval(['PexpA = Anemia.',layer,'.Ptm;']);
eval(['MetSignalA = Anemia.',layer,'.MetSignal;']);

[DmodA, ~ , ~, ~, ~, ~, convA] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, state);

%%%%------Passive and Fully active diameters
[DpA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, 'passive');
[DcA, ~] = CarlsonModelTime(x, PexpA, DexpA, MetSignalA, Anemia.HR, Dc, Pc, 'constricted');

%%%%%%%%%%%%% Objective function
DMod = [DmodC,	DmodA];
DExp = [DexpC,	DexpA];


Dp = [DpC, DpA];
Dc = [DcC, DcA];
if sum(isnan(DMod)) || sum(convC+convA)|| sum([sum((Dp-DExp)<0),sum((DExp-Dc)<0)])
    ER = 1000;
else
    ER = norm((DExp - DMod)./DExp) + 0.1*abs(AmodC(4) - 0.5); % + 1000*(x(2)<x(3));
end

