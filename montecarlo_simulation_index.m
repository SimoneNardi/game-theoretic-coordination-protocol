
%% Simulazioni Montecarlo
intruder_bheaviour=2; % 1: debug,segue la teoria dei giochi
                      % 2: intruso autonomo persegue il suo obbiettivo 

map=1000; %dimensione dell'ambiente quadrato in pixel.
%************************************SCENARIO******************************
%numero di giocatori variabile

repetitions=30;


speed_intruder= 5; %
speed_defensors_max= 15; %max speed
speed_defensors_min= speed_intruder;
formation_radius=30;

actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4

obstacle_factor=[500 1000  3000 8000 10000];   %    <-------------
barrier_factor=[1 10 50 1000 3000 8000];%
identification=0; %identification on,off
identification_buffer=100;% 

comunication_radius=400;
detection_radius=300;

%E' possibile aggiungere quante zone critiche si vuole
%CONFIGURAZIONE SENZA IDENTIFICAZIONE:
criticalAreas=[60,60; 900,500]; %[lato1,lato2; xpos1,ypos1; xpos2,ypos2; ... ]

%CONFIGURAZIONE CON IDENTIFICAZIONE
%criticalAreas=[60,60; 900,300;900 700];

intruder_target=1; % selezionare quale tra le zone critiche elecante sopra 
                   % sia l'obbiettivo dell'intruso.

safeZone =[60,60; 600,900]; %[lato1,lato2; xpos,ypos] Safe zone è unica!

obstacles=[10,0;500 500]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...]

formation_extension=pi/3;

%*****************************************************************************

for p=1:3 %numbers of agents
    for of=1:length(obstacle_factor)
        for bar=1:length(barrier_factor)
            for rep=1:length(repetitions)

    %creo l'intruso
    intruder1=intruder([50,500],0,detection_radius,intruder_bheaviour,actions,obstacle_factor(of),speed_intruder,intruder_target);

    %Risolutore teoria dei giochi
    gambit=gambit(1);

    %creo e scelgo quali robot tra quelli creati devono essere presenti e li assegno
    %nell'ambiente.
    switch p
        case 1
            
            posx=randi([map/2, map]);
            posy=randi([floor(map/3), floor(map*2/3)]);
            robot1=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
            agentsArray={intruder1,robot1};
        case 2
            
            posx=randi([map/2, map]);
            posy=randi([map/2, map]);
            robot1=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);           
            posy=randi([0, map/2]);
            robot2=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
            agentsArray={intruder1,robot1,robot2};
        case 3
            
            posx=randi([map/2, map]);
            posy=randi([floor(map*2/3), map]);
            robot1=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);           
            posy=randi([floor(map/3), floor(map*2/3)]);
            robot2=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);            
            posy=randi([0, floor(map/3)]);
            robot3=defender([posx,posy],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor(of),barrier_factor(bar),speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
            agentsArray={intruder1,robot1,robot2,robot3};
    end
    world=enviroment(map,criticalAreas,safeZone,obstacles,agentsArray,gambit);

    %posso scegliere se abilitare o meno il disegno
    world.draw();

    %% esecuzione della simulazione


    [it, res]= world.start();
    
    switch res
        case 1   
            disp('SUCCESSO: Intruso è stato scortato nella zona sicura');
            
        case -1

            disp('SIMULAZIONE FALLITA: Numero di cicli limite superato');
        case 0

            disp('SIMULAZIONE FALLITA: Intruso ha raggiunto la zona critica');

    end
    iterations(p,of,rep)=it;
    results(p,of,rep)=res;
    
    
    sprintf('stato simulazioni: %d/%d , %d/%d , %d/%d, %d/%d\n', p,3,of,length(obstacle_factor),bar,length(barrier_factor),rep,repetitions)
    
            end
        end
    end
    save('simulation.mat','iterations','results');
end
