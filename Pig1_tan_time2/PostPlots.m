function PostPlots(Control, Anemia, Dob, layer, i, x, MetSignal)

clear pl;

y = x;

%% Autoregulation

[Control, Anemia, Dob] = TanModelHR_eval(y, Control, Anemia, Dob, layer,'normal', MetSignal);

h = figure;

pl(1) = plot(Control.Ptm, Control.Dmod/100,'-s','linewidth',1.5,'Color',[0    0.4470    0.7410]); hold on
pl(2) = plot(Control.Ptm, Control.Dexp/100,'o','linewidth',2.5,'Color',[0    0.4470    0.7410]);

pl(3) = plot(Anemia.Ptm, Anemia.Dmod/100,'-s','linewidth',1.5,'Color',[0.8500    0.3250    0.0980]);
pl(4) = plot(Anemia.Ptm, Anemia.Dexp/100,'o','linewidth',2.5,'Color',[0.8500    0.3250    0.0980]);

pl(5) = plot(Dob.Ptm(1:5), Dob.Dmod/100,'-s','linewidth',1.5,'Color',[0.9290    0.6940    0.1250]);
pl(6) = plot(Dob.Ptm(1:5), Dob.Dexp/100,'o','linewidth',2.5,'Color',[0.9290    0.6940    0.1250]);

xlabel('p_{tm} (mmHg)');
ylabel('$\bar{D}$ (-)','Interpreter','Latex');
box off;

%% Passive

[Pp, Dp, ~] = TanModelHR_eval(y, Control , Anemia, Dob, layer,'passive', MetSignal);


pl(7) = plot(Pp, Dp/100,'--k','linewidth',1.5); 

%% Fully active

[Pact, Dm, Pmax] = TanModelHR_eval(y, Control , Anemia, Dob, layer,'constricted', MetSignal);


pl(8) = plot(Pact, Dm/100,':k','linewidth',1.5); 

xlim([-50 100]);

saveas(h,['Dbar_ParamEst',layer,num2str(i),'.png']);

ax1 = gca;
hp = figure;

ax2 = copyobj(ax1,hp);
ax1Chil = ax1.Children; 
copyobj(ax1Chil, ax2)

legend('Control-Mod','Control-Exp','Anemia-Mod','Anemia-Exp','Dob+Anemia-Mod','Dob+Anemia-Exp','Passive','Active','Location','southeast','FontSize',14);
set(gcf,'Position',[0,0,1024,1024]);
legend_handle = legend('Orientation','vertical');
set(gcf,'Position',(get(legend_handle,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
set(legend_handle,'Position',[0,0,1,1]);
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);

saveas(hp,['Legend',layer,num2str(i),'.png']);
%% Activation and signal plots

h1 = figure; hold on;
plot(Control.Ptm,Control.Act,'-s','linewidth',1.5);
plot(Anemia.Ptm,Anemia.Act,'-s','linewidth',1.5);
plot(Dob.Ptm,Dob.Act,'-s','linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('p_{tm} (mmHg)');
ylabel('A (-)');

saveas(h1,['Act_ParamEst',layer,num2str(i),'.png']);


h2 = figure; hold on;
plot(Control.Ptm,Control.Smeta,'-s','linewidth',1.5);
plot(Anemia.Ptm,Anemia.Smeta,'-s','linewidth',1.5);
plot(Dob.Ptm,Dob.Smeta,'-s','linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('p_{tm} (mmHg)');
ylabel('S_{meta} (-)');
set(gca,'FontSize',12);

saveas(h2,['Smeta_ParamEst',layer,num2str(i),'.png']);

h3 = figure; hold on;
plot(Control.Ptm,Control.Smyo,'-s','linewidth',1.5);
plot(Anemia.Ptm,Anemia.Smyo,'-s','linewidth',1.5);
plot(Dob.Ptm,Dob.Smyo,'-s','linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('p_{tm} (mmHg)');
ylabel('S_{myo} (-)');
set(gca,'FontSize',12);

saveas(h3,['Smyo_ParamEst',layer,num2str(i),'.png']);

h4 = figure; hold on;
plot(Control.Ptm,Control.SHR,'-s','linewidth',1.5);
plot(Anemia.Ptm,Anemia.SHR,'-s','linewidth',1.5);
plot(Dob.Ptm,Dob.SHR,'-s','linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
xlabel('p_{tm} (mmHg)');
ylabel('S_{HR} (-)');
set(gca,'FontSize',12);

saveas(h4,['SHR_ParamEst',layer,num2str(i),'.png']);
% 
% h5 = figure; hold on;
% plot(Control.Ptm,eval(['Control.',layer,'.MVO2']),'linewidth',1.5);
% plot(Anemia.Ptm,eval(['Anemia.',layer,'.MVO2']),'linewidth',1.5);
% plot(Dob.Ptm,eval(['Dob.',layer,'.MVO2']),'linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
% xlabel('p_{tm} (mmHg)');
% ylabel('MVO2 ()');
% set(gca,'FontSize',12);
% 
% saveas(h5,['MVO2',layer,num2str(i),'.png']);
% 
% h6 = figure; hold on;
% plot(Control.Ptm,eval(['Control.',layer,'.Tv']),'linewidth',1.5);
% plot(Anemia.Ptm,eval(['Anemia.',layer,'.Tv']),'linewidth',1.5);
% plot(Dob.Ptm,eval(['Dob.',layer,'.Tv']),'linewidth',1.5);
% legend('Control','Anemia','Dob+Anemia','Location','best');
% xlabel('p_{tm} (mmHg)');
% ylabel('[ATP] ()');
% set(gca,'FontSize',12);
% 
% saveas(h6,['ATP',layer,num2str(i),'.png']);
%% Move files to Figs folder
movefile('*.png',['./Figs',MetSignal,'/']);


