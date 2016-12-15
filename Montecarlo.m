
% MAZZITELLI FEDERICO
% Game Theoretic Framework
%*************************************************
% V6

%% Dichiarazioni
map=1000;
critAreas=[60,60; 800,800]; %[lato1,lato2; xpos1,ypos1; xpos2,ypos2]
safeZone =[60,60; 800,300]; %[lato1,lato2; xpos,ypos]
obstacles=[10,0;500 200; 500 800]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...]
gambit_output=0; %voglio che gambit mi mostri gli equilibri e i payoff ad 
                 % ogni stadio del gioco.
intruder_bheaviour=2;
comunication_radius=200;
detection_radius=100;
speed_defensors=8; %max speed
speed_intruder= 5; % fixed speed
actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4
obstacle_factor=[ 2500 3000 3500 4000];

%% Simulazione
for i=1:length(obstacle_factor)
    for rep=1:10
        %creo i robot nelle loro posizioni iniziali.
        robot1=defender([300,850],pi,detection_radius,comunication_radius,actions,obstacle_factor(i),speed_defensors);
        robot2=defender([300,750],pi,detection_radius,comunication_radius,actions,obstacle_factor(i),speed_defensors);
        robot3=defender([300,700],pi,detection_radius,comunication_radius,actions,obstacle_factor(i),speed_defensors);

        intruder1=intruder([200,800],0,detection_radius,intruder_bheaviour,actions,obstacle_factor(i),speed_intruder);
        agentsArray={intruder1,robot1,robot2,robot3};
        
        %Chiamo le librerie di gambit tramite la casse addetta
        gambit=gambit(gambit_output);

        %creo l'oggetto mondo.
        world=enviroment(map,critAreas,safeZone,obstacles,agentsArray,gambit);
        %abilito il disegno
        %world.draw();
        %esecuzione della simulazione
        [iterations(i,rep) result(i,rep)]= world.start();

        switch result(i,rep)
            case 1
                disp('SUCCESSO: Intruso è stato scortato nella zona sicura');
            case -1
                disp('SIMULAZIONE FALLITA: Numero di cicli limite superato');
            case 0
                disp('SIMULAZIONE FALLITA: Intruso ha raggiunto la zona critica');
        end
        
        clearvars robot1  robot2  robot3 intruder1 agentsArray gambit world
        pause(1);
        save('SimulationData_variablecost.mat','result','iterations','rep','i');
        
    end
    

end