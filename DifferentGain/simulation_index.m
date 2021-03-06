clear all;clc;
%V6

%% Dichiarazioni
python_start='python Python/nashgambitNoOutput.py&';
python_stop='pkill -9 -f nashgambitNoOutput.py';


intruder_bheaviour=2; % 1: DEBUG (intruso aderisce strategie Nash)
                      % 2: intruso autonomo persegue il suo obbiettivo 
                      % 3: intruso controllato da un giocatore

%% Configurazione da gioco


if intruder_bheaviour ==3
    
map=500; %dimensione dell'ambiente quadrato in pixel.
    
formation_radius=40;

gambit_output=0; %voglio che gambit mi mostri li equilibri e i payoff ad 
                 % ogni stadio del gioco.
speed_intruder= 10; %fixed speed                 
speed_defensors_max=15; %max speed
speed_defensors_min=speed_intruder;


actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4

obstacle_factor=2000;
barrier_factor=5;

identification=1; %0 off 1 on   
identification_buffer=10;
comunication_radius=200;
detection_radius=150;
formation_extension=pi/4;

%E' possibile aggiungere quante zone critiche si vuole
criticalAreas=[400,400]; %[lato1,lato2; xpos1,ypos1; xpos2,ypos2; ... ]
intruder_target=1; % selezionare quale tra le zone critiche elecante sopra 
                   % sia l'obbiettivo dell'intruso.

safeZone =[60,60; 300,100]; %[lato1,lato2; xpos,ypos] Safe zone è unica!

obstacles=[10,0;200 200; 400 250]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...]
robot1=defender([150,150],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
robot2=defender([300,250],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);


%creo l'intruso
intruder1=intruder([30,30],0,detection_radius,intruder_bheaviour,actions,obstacle_factor,speed_intruder,intruder_target);

%Chiamo le librerie di gambit
gambit=gambit(gambit_output);

%scelgo quali robot tra quelli creati devono essere presenti e li assegno
%nell'ambiente.
agentsArray={intruder1,robot1,robot2};
world=enviroment(map,criticalAreas,safeZone,obstacles,agentsArray,gambit);

%posso scegliere se abilitare o meno il disegno
world.draw();

else
%% Configurazione per la simulazione classica 

map=800; %dimensione dell'ambiente quadrato in pixel.
speed_intruder= 5; %fixed speed
speed_defensors_max= 10; %max speed
speed_defensors_min=speed_intruder;
formation_radius=30;

actions = [0 pi/4 -pi/4]; %standard: pi/4, -pi/4

obstacle_factor_intruder=2500;
obstacle_factor=2500; %1500
obstacle_factor2=2500;

barrier_factor=20; %20
barrier_factor2=20;

target_factor=1;%0.8
target_factor2=1;
target_factor_intruder=1;

identification=0; %0 off 1 on
identification_buffer=100;

comunication_radius=500;%300
detection_radius=300;%200

gambit_output=0; %voglio che gambit mi mostri li equilibri e i payoff ad 
                 % ogni stadio del gioco.

%E' possibile aggiungere quante zone critiche si vuole
criticalAreas=[90,90; 700 700]; %[lato1,lato2; xpos1,ypos1; xpos2,ypos2; ... ]
intruder_target=1; % selezionare quale tra le zone critiche elecante sopra 
                   % sia l'obbiettivo dell'intruso.

safeZone =[90,90; 200,700;]; %[lato1,lato2; xpos,ypos] Safe zone è unica!

obstacles=[10,0;200 400;]; %[raggio,0; xpos1,ypos1; xpos2,ypos2 ...] 

formation_extension=pi/3;%
 
%creo i robot difensori nelle loro posizioni iniziali.
robot1=defender([600,500],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,target_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
robot2=defender([600,300],-pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor2,barrier_factor2,target_factor2,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
%robot3=defender([600,300],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
%robot4=defender([500,500],pi,detection_radius,comunication_radius,actions,formation_extension,obstacle_factor,barrier_factor,speed_defensors_max,speed_defensors_min,formation_radius,identification,identification_buffer);
%creo l'intruso
intruder1=intruder([200,200],0,detection_radius,intruder_bheaviour,actions,obstacle_factor_intruder,target_factor_intruder,speed_intruder,intruder_target);

%Risolutore teoria dei giochi
gambit=gambit(gambit_output);

%scelgo quali robot tra quelli creati devono essere presenti e li assegno
%nell'ambiente.
agentsArray={intruder1,robot1,robot2};
world=enviroment(map,criticalAreas,safeZone,obstacles,agentsArray,gambit);
world.draw();

end

%% esecuzione della simulazione
status = system(python_start);
pause(0.1);

    [iterations, result]= world.start();
    switch result
        case 1
            if intruder_bheaviour==3
                h = msgbox('mi dispiace, HAI PERSO!: sei stato scortato nella zona sicura');
            end    
            disp('SUCCESSO: Intruso è stato scortato nella zona sicura');
        case -1
            if intruder_bheaviour==3
                h = msgbox('mi dispiace, HAI PERSO!: ci hai messo troppo tempo');
            end 
            disp('SIMULAZIONE FALLITA: Numero di cicli limite superato');
        case 0
            if intruder_bheaviour==3
                h = msgbox('HAI VINTO: Hai raggiunto la zona critica');
            end 
            disp('SIMULAZIONE FALLITA: Intruso ha raggiunto la zona critica');
        case 2
            h = msgbox('HAI PERSO: Hai urtato un difensore');

    end
status = system(python_stop);
