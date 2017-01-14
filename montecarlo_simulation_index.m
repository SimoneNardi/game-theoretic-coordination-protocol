
%% Simulazioni Montecarlo
intruder_bheaviour=2; % 1: debug,segue la teoria dei giochi
                      % 2: intruso autonomo persegue il suo obbiettivo 

map=1000; %dimensione dell'ambiente quadrato in pixel.
%************************************SCENARIO******************************
%numero di giocatori variabile

repetitions=30;


speed_intruder= 5; %
speed_defensors_max= 10; %max speed
speed_defensor_min= [speed_intruder, speed_intruder+0.1, speed_intruder+0.3, speed_intruder+0.5]      %<-------------
formation_radius=30;

actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4

obstacle_factor=[2000 2500 3000 3500 4000];%          <-------------

identification_buffer=[2 10 50 100 200];%          <-------------

comunication_radius=300;
detection_radius=200;

%E' possibile aggiungere quante zone critiche si vuole
criticalAreas=[60,60; 500,900; 900 500]; %[lato1,lato2; xpos1,ypos1; xpos2,ypos2; ... ]
intruder_target=1; % selezionare quale tra le zone critiche elecante sopra 
                   % sia l'obbiettivo dell'intruso.

safeZone =[60,60; 900,900]; %[lato1,lato2; xpos,ypos] Safe zone è unica!

obstacles=[10,0;700 700]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...]

formation_extension=[pi/8 pi/6 pi/3 pi/2];%          <-------------

%*****************************************************************************

for p=1:4 %numbers of agents
    for of=1:length(obstacle_factor)
        for sp=1:length(speed_defensor_min)
            for fe=1:length(formation_extension)
                for rep=1:length(repetitions)

    %creo l'intruso
    intruder1=intruder([50,50],0,detection_radius,intruder_bheaviour,actions,obstacle_factor(of),speed_intruder(sp),intruder_target);

    %Risolutore teoria dei giochi
    gambit=gambit(1);

    %creo e scelgo quali robot tra quelli creati devono essere presenti e li assegno
    %nell'ambiente.
    switch p
        case 1
            robot1=defender([500,500],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            agentsArray={intruder1,robot1};
        case 2
            robot1=defender([500,500],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot2=defender([450,450],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            agentsArray={intruder1,robot1,robot2};
        case 3
            robot1=defender([500,500],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot2=defender([450,450],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot3=defender([550,450],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            agentsArray={intruder1,robot1,robot2,robot3};
        case 4
            robot1=defender([500,500],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot2=defender([450,450],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot3=defender([550,450],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            robot4=defender([450,550],pi,detection_radius,comunication_radius,actions,formation_extension(fe),obstacle_factor(of),speed_defensors_max,speed_defensors_min(sp),formation_radius,identification_buffer);
            agentsArray={intruder1,robot1,robot2,robot3,robot4};
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
    iterations(p,of,sp,fe,rep)=it;
    results(p,of,sp,fe,rep)=res;
    
    
    sprintf('stato simulazioni: %d/%d , %d/%d , %d/%d , %d/%d , %d/%d\n', p,4,of,length(obstacle_factor),sp,length(speed_intruder),fe,length(formation_extension),rep,length(repetitions))
    
                end
            end
        end
        save('simulation.mat','iterations','results')
    end
end
