function [Control, Anemia, Dob] = TanModelHR_eval(x, Control, Anemia, Dob, layer, state, MetSignal)

Ap = x(2);
Bp = x(3);

switch state
    case 'normal'
        
        
        %%%%%%%%%%%%%% Preparation
        switch MetSignal
            
            case 'ATP'
                
                S0 = x(14);
                
            otherwise
                
                S0 = 0.037;
                
        end
        
        Control = ATPconcentration(Control, S0, MetSignal);
        
        Anemia = ATPconcentration(Anemia, S0, MetSignal);
        
        %%%%%%%%%%%%%% Control
        
        eval(['Control.Dexp = Control.',layer,'.D;']);
        eval(['Control.Ptm = Control.',layer,'.Ptm;']);
        eval(['MetSignalC = Control.',layer,'.MetSignal;']);
        CAT = 0; %Existence of extrinsic catecholamine (dobutamine)

        Dc = Control.Dexp(4);
        Pc = Control.Ptm(4);
        
        [Control.Dmod, Control.Act, Control.Smyo, Control.Smeta, Control.SHR, ~] = CarlsonModelTime(x, Control.Ptm, Control.Dexp, MetSignalC, Control.HR, Dc, Pc, CAT, state);
        
        % %%%%%%%%%%%%%% Anemia
        
        eval(['Anemia.Dexp  = Anemia.',layer,'.D;']);
        eval(['Anemia.Ptm = Anemia.',layer,'.Ptm;']);
        eval(['MetSignalA = Anemia.',layer,'.MetSignal;']);
        CAT = 0; %Existence of extrinsic catecholamine (dobutamine)

        [Anemia.Dmod, Anemia.Act, Anemia.Smyo, Anemia.Smeta, Anemia.SHR, ~] = CarlsonModelTime(x, Anemia.Ptm, Anemia.Dexp, MetSignalA, Anemia.HR, Dc, Pc, CAT, state);
        
        % %%%%%%%%%%%%%% Dob+Anemia
        
    case 'passive'
        
        R = (Bp+1):0.1:(Ap-1);
        D = R*2;
        
        [T_pass, ~] = Tension(R, x);
        
        Control = T_pass./R;
        Anemia = D;
        
    case 'constricted'
        
        R = (Bp+1):0.1:(Ap-1);
        D = R*2;
        
        [T_pass, T_act] = Tension(R, x);
        
        Control = (T_pass + T_act)./R;
        Anemia = D;
        Dob = T_act./R;
        
end
