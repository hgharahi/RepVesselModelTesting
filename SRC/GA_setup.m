function [gaoptions] = GA_setup()


gaoptions = optimoptions('ga','MaxGenerations',100,'Display','iter','CreationFcn','gacreationlinearfeasible','MutationFcn', ... 
@mutationadaptfeasible);
    gaoptions = optimoptions(gaoptions,'UseParallel',true);
    gaoptions = optimoptions(gaoptions,'PopulationSize',50);
    gaoptions = optimoptions(gaoptions,'FunctionTolerance',1e-8);
    gaoptions = optimoptions(gaoptions,'OutputFcn',@GA_DISP);
