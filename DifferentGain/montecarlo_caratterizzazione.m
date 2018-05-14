
%% Simulazioni Montecarlo
intruder_bheaviour=2; % 1: debug,segue la teoria dei giochi
                      % 2: intruso autonomo persegue il suo obbiettivo 

map=1000; %dimensione dell'ambiente quadrato in pixel.
%************************************SCENARIO******************************
%numero di giocatori variabile

repetitions=1;


speed_intruder= 5; %
speed_defensors_max= 15; %max speed
speed_defensors_min= speed_intruder;
formation_radius=30;

actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4

obstacle_factor=3000;   %    <-------------
barrier_factor=10;%
identification=[0,1]; %identification on,off
identification_buffer=100;% 

comunication_radius=1000;
detection_radius=1000;

%E' possibile aggiungere quante zone critiche si vuole

criticalAreas=[60,60; 500,400; 500,600 ];

criticalAreas=[60,60; 500,400; 500,600 ];
intruder_target=1; % selezionare quale tra le zone critiche elecante sopra 
                   % sia l'obbiettivo dell'intruso.

safeZone =[60,60; 900,500]; 
%safeZone =[60,60; 900,500];
obstacles=[10,0;900 900; 900,100]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...]

formation_extension=pi/3;

python_start='python Python/nashgambitNoOutput.py&';
python_stop='pkill -9 -f nashgambitNoOutput.py';
status = system(python_start);
%*****************************************************************************



for i=2:2 %caratt
    for rep=1:repetitions
                


    %creo l'intruso
    intruder1=intruder([50,500],0,detection_radius,intruder_bheaviour,actions,obstacle_factor,speed_intruder,intruder_target);
    posx=randi([map/2, map]);
    posy=randi([map/2, map]);
    robot1=defender([posx,posy],0,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification(i),identification_buffer);           
    posy=randi([0, map/2]);
    robot2=defender([posx,posy],0,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification(i),identification_buffer);
    agentsArray={intruder1,robot1,robot2};
    %Risolutore teoria dei giochi
    gambit=gambit(1);

    %creo e scelgo quali robot tra quelli creati devono essere presenti e li assegno
    %nell'ambiente.

            


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
    iterations(i,rep)=it;
    results(i,rep)=res;
    
    
    sprintf('stato simulazioni: %d/%d , %d/%d\n', i,2,rep,repetitions)
    pause(1);
    status = system(python_stop);
    status = system(python_start);
    pause(1);
    end


    save('simulation.mat','iterations','results');
end
