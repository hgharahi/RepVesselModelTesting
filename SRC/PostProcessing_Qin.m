function Results = PostProcessing_Qin(t,X,measurements,InFlow,P)

% INPUT


Q_in = interp1(InFlow.t,InFlow.Qclamped,t);
dQindT = interp1(InFlow.t,InFlow.dQclampeddt,t);
P_LV = interp1(measurements.t,measurements.PLV,t);

P_im1 = 1.2*0.167*P_LV;
P_im2 = 1.2*0.500*P_LV;
P_im3 = 1.2*0.833*P_LV;
P_RA = 0; % right atrial pressure (mmHg)

% STATE VARIABLES
Results.P_PA = X(:,1); % penetrating artery pressure
Results.P11  = X(:,2); 
Results.P21  = X(:,3);
Results.P12  = X(:,4); 
Results.P22  = X(:,5);
Results.P13  = X(:,6); 
Results.P23  = X(:,7);
Results.P_PV = X(:,8); % penetrating vein pressure

% PENETRATING ARTERY CALCULATIONS
Results.P_in = Results.P_PA + P.R_PA*Q_in + P.L_PA*dQindT;                  %Eq. (1)

% MYOCARDIAL CALCULATIONS 
V11 = P.cf1*((Results.P11 - P_im1)*P.C11+P.V01);
V11(V11<P.Vc) = P.Vc;

V21 = P.cf1*((Results.P21 - P_im1)*P.C2+P.V02);
R11 = P.rf1*P.R01*(P.V01./V11).^2;
R21 = P.rf1*P.R02*(P.V02./V21).^2;
Rm1 = P.R0m*(P.gamma*R11/P.R01 + (1-P.gamma)*R21/P.R02);
Results.Q11 = (Results.P_PA - Results.P11)./R11;                                 %Eq. (4)
Results.Qm1 = (Results.P11 - Results.P21)./Rm1;                                  %Eq. (10)
% Results.Q21 = (Results.P21 - Results.P_PV)./R21;                                 %Eq. (16)

V12 = P.cf2*((Results.P12 - P_im2)*P.C12+P.V01);
V12(V12<P.Vc) = P.Vc;

V22 = P.cf2*((Results.P22 - P_im2)*P.C2+P.V02);
R12 = P.rf2*P.R01*(P.V01./V12).^2;
R22 = P.rf2*P.R02*(P.V02./V22).^2;
Rm2 = P.R0m*(P.gamma*R12/P.R01 + (1-P.gamma)*R22/P.R02);
Results.Q12 = (Results.P_PA - Results.P12)./R12;                                 %Eq. (5)
Results.Qm2 = (Results.P12 - Results.P22)./Rm2;                                  %Eq. (11)
% Results.Q22 = (Results.P22 - Results.P_PV)./R22;                                 %Eq. (17)

V13 = (Results.P13 - P_im3)*P.C13+P.V01;
V13(V13<P.Vc) = P.Vc;

V23 = (Results.P23 - P_im3)*P.C2+P.V02;
R13 = P.R01*(P.V01./V13).^2;
R23 = P.R02*(P.V02./V23).^2;
Rm3 = P.R0m*(P.gamma*R13/P.R01 + (1-P.gamma)*R23/P.R02);
Results.Q13 = (Results.P_PA - Results.P13)./R13;                                 %Eq. (6)
Results.Qm3 = (Results.P13 - Results.P23)./Rm3;                                  %Eq. (12)
% Results.Q23 = (Results.P23 - Results.P_PV)./R23;                                 %Eq. (18)


for i = 1:length(Results.Qm2)
    
    A1 = [(R21(i)+P.R_PV/2), (P.R_PV/2), (P.R_PV/2)];
    A2 = [(P.R_PV/2), (R22(i)+P.R_PV/2), (P.R_PV/2)];
    A3 = [(P.R_PV/2), (P.R_PV/2), (R23(i)+P.R_PV/2)];
    
    A = [A1;A2;A3];
    B = [Results.P21(i)-Results.P_PV(i); Results.P22(i)-Results.P_PV(i); Results.P23(i)-Results.P_PV(i)];
    
    x = A\B;
    
    Results.Q21(i) = double(x(1));
    Results.Q22(i) = double(x(2));
    Results.Q23(i) = double(x(3));
    
    Results.Q21(i) = max(Results.Q21(i),0);
    Results.Q22(i) = max(Results.Q22(i),0);
    Results.Q23(i) = max(Results.Q23(i),0);
    
    Results.Q_ima(i) = Results.Q11(i) + Results.Q12(i) + Results.Q13(i);
    Results.Q_imv (i)= Results.Q21(i) + Results.Q22(i) + Results.Q23(i);
    
    Results.Q_out(i) = (Results.P_PV(i) - P_RA)/(P.R_PV/2);
end

