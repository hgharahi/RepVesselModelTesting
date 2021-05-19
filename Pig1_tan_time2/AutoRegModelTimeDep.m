clc;close all;

%%% IMPORTANT NOTE:
% This pig does not have blood gas measurement data for CPP 140 mmHg case.

% Created Sep 16 by HG

addpath('../SRC');

rng('shuffle');

if exist('Data_Ready','var')==1
else
    
    ReadData;
    
end

%% What is the Metabolic Signal?

MetOptions = {'QM','ATP','VariableSV','Generic','MVO2','QdS','Q','M2'};
for k = 1:1
    
    MetSignal = MetOptions{k};
    
    
    BPmax = min([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D,Dob.endo.D,Dob.mid.D,Dob.epi.D])/2;
    Apmin = max([Control.endo.D,Control.mid.D,Control.epi.D,Anemia.endo.D,Anemia.mid.D,Anemia.epi.D,Dob.endo.D,Dob.mid.D,Dob.epi.D])/2;
    
    %     Cp,     Ap,     Bp,                phi_p,      phi_m,      Cm,    rho         C_myo,      C_met,   C_HR,     C0       C_CAT   HR0
    xl = [.50      Apmin     0.1*BPmax       -20          100      10     1.00e2       0.1          0      0.001     -10.0     0     50 ];
    xu = [40.0      1.5*Apmin    BPmax        30          200     200    4.50e2       100          1      0.1      10.0       10      100];
    
    switch MetSignal
        
        case 'ATP'
            
            % y = [Cp, Ap, Bp, phi_p, phi_m, Cm, rho_m, C_myo, C_met, C_HR, C0, S0];
            
            xl(14) = 0.01; %S00
            xu(14) = 0.04;  %So
            xendo0(14) = 0.03;
            xmid0(14) = 0.03;
            xepi0(14) = 0.03;
            nvar = 14;
            
        otherwise
            
            nvar = 13;
            
    end
    
    %% Genetic Algorithm
    objfun_mid = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'mid','normal',MetSignal);
    objfun_endo = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'endo','normal',MetSignal);
    objfun_epi = @(x) TanModelHR_obj(x, Control, Anemia, Dob, 'epi','normal',MetSignal);
    
%    options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
%    warning('off','all')
%    warning
%    gs = GlobalSearch;
%    ms = MultiStart;

    p = gcp('nocreate'); % If no pool, do not create new one.
    if isempty( p )==1
    parpool(36);
    end

    pctRunOnAll warning('off', 'all'); 


    gaoptions = GA_setup();
    
    xendo = ga(objfun_endo, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'endo', i, xendo, MetSignal);

    xmid = ga(objfun_mid, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'mid', i, xmid, MetSignal);

    xepi = ga(objfun_epi, nvar, [], [], [], [], xl, xu, [], gaoptions);
    PostPlots(Control, Anemia, Dob, 'epi', i, xepi, MetSignal);


     fileID = ['Params_',num2str(i),'_',MetSignal,'.txt'];
     fid = fopen(fileID,'w');
    formatSpec = ['xendo = [',repmat('%12.8f ',1,length(xendo)),'];\n',...
         'xmid  = [',repmat('%12.8f ',1,length(xmid)),'];\n',...
         'xepi  = [',repmat('%12.8f ',1,length(xepi)),'];\n'];
     fprintf(fid,formatSpec,xendo,xmid,xepi);
     fclose('all');

end
