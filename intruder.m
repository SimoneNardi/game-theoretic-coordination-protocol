classdef intruder < handle
    %DEFENDER Oggetto che rappresenta gli agenti difensori
    %   E' una classe "Handler" le cui proprietà sono la
    %   posizione,l'orientazione e la dimensione del robot, oltre che una
    %   variabile contenente l'oggetto grafico se inizializzato dalla
    %   funzione enviroment.draw().
    %V6
    
    properties (SetAccess = public, GetAccess = public)
      currentPosition
      nextPosition
      currentDirection
      nextDirection
      graphicalHandler
      criticalHandler
      criticalRadius
      
      defendersFound;
      halfDiagonalDistance
      behaviour %1 nash, 2 greedy, 3 Player.
      speed
      detectionRadius
      actions
      obstacle_factor
      target
      key

    end
    methods

        function obj = intruder(init_pos, init_dir,detect,behav,act,obstacle,sp,target)
            obj.currentPosition=init_pos;
            obj.nextPosition=init_pos;
            obj.currentDirection=init_dir;
            obj.nextDirection=init_dir;
            obj.graphicalHandler=-1;
            obj.halfDiagonalDistance=7;
            obj.speed=3;
            obj.behaviour=behav;
            obj.defendersFound=defender.empty;
            obj.detectionRadius=detect;
            obj.actions=act;
            obj.obstacle_factor=obstacle;
            obj.speed=sp;
            obj.target=target;
            obj.criticalRadius=30;
        end
        
        function draw(obj)
            
            % plot robot with specified configuration
            corner1=obj.currentPosition+(obj.halfDiagonalDistance*5/3)*[ cos(obj.currentDirection) sin(obj.currentDirection)];
            corner2=obj.currentPosition+obj.halfDiagonalDistance*[ cos(obj.currentDirection+(2/3*pi)) sin(obj.currentDirection+(2/3*pi))];
            corner3=obj.currentPosition+obj.halfDiagonalDistance*[ cos(obj.currentDirection-(2/3*pi)) sin(obj.currentDirection-(2/3*pi))];

            % updating position of the robot 

            set(obj.graphicalHandler,{'XData'},{[corner1(1) corner2(1) corner3(1)  corner1(1)]},{'YData'},{[corner1(2);corner2(2);corner3(2);corner1(2)]});
            set(obj.criticalHandler,{'Position'},{[obj.currentPosition-obj.criticalRadius, obj.criticalRadius*ones(1,2)*2 ]});            
        end
        
        function greedyMove(obj,world)
            %% gestisco il movimento dell'intruso, senza usare teoria dei giochi
            actions = obj.actions;
            
            
            predictedPosition=[0,0];
            for p=1:length(obj.defendersFound)
                predictedPosition(p+1,:)= obj.defendersFound(p).currentPosition;
            end
            
            
           for y = 1:size(actions,2)
               predictedPosition(1,:)=obj.currentPosition+obj.speed*[cos(obj.currentDirection+ actions(y) ) sin(obj.currentDirection+ actions(y))];    
               [l_min_dist_player_nearobs_otherplayer_NoNash,~]=world.min_dist_player_nearobs_otherplayer(1,predictedPosition);    
               l_dist_player_critic =norm(world.critAreas(obj.target,:) - predictedPosition(1,:));                      
               I_noNash (y)= -l_dist_player_critic -obj.obstacle_factor*(1/l_min_dist_player_nearobs_otherplayer_NoNash);
          
           end

           [~,noNash_action_index] = max(I_noNash(:)); 
           
           obj.nextPosition=obj.currentPosition+obj.speed*[cos(obj.currentDirection+actions(noNash_action_index) ) sin(obj.currentDirection+actions(noNash_action_index))];
           obj.nextDirection=obj.currentDirection +actions(noNash_action_index);
            
            
        end    
        
        
        function searchDefenders(obj,world)
            count=1;
            for i=1:length(world.defenders)
                
                if(norm(world.defenders(i).currentPosition-obj.currentPosition) <= obj.detectionRadius)
                    obj.defendersFound(count)=world.defenders(i);
                    count=count+1;
                end
                
            end
            
     
        end
        function key_pressed(obj,varargin)
              %funzione callback per quando viene premuto un tasto
              key=varargin{2}.Key;
              switch key
                  case 'rightarrow'
                      disp('svolta a destra')
                      obj.key=3;
                  case 'leftarrow'
                      disp('svolta a sinistra')
                      obj.key=2;
                  case 'uparrow'
                      disp ('prosegui')
                      obj.key=1;
              end
        end
        
        
        function move(obj)
                             
                obj.currentPosition=obj.nextPosition;
                obj.currentDirection=obj.nextDirection;
                
        end
        function start(obj,world,game_theory_solver)
            
            obj.searchDefenders(world);
            
            if ( (not(isempty(obj.defendersFound)) && obj.behaviour==1) )
                
                %richiedo al solver della teoria dei giochi di calcolare i
                %payoff dei giocatori e di scegliere la mossa da fare.
 
                 [obj.nextPosition,obj.nextDirection,~]=game_theory_solver.gamePayoff(1,obj,obj.defendersFound,world,world.critAreas(obj.target,:));

                
            end
            
            if (isempty(obj.defendersFound) && obj.behaviour==1)  || (obj.behaviour==2)
                %scelgo la mossa da fare in base agli agenti che vedo e
                %agli ostacoli.
                obj.greedyMove(world);
                
            end
            
            if obj.behaviour==3
              % controllo dell'utente.              
                obj.key=0;
              %attendo che venga premuto un tasto
                while not(obj.key)
                    pause(0.3);
                end
              %lo assegno per la mossa successiva
              obj.nextPosition=obj.currentPosition+obj.speed*[cos(obj.currentDirection+obj.actions(obj.key) ) sin(obj.currentDirection+ obj.actions(obj.key))]; 
              obj.nextDirection=obj.currentDirection +obj.actions(obj.key);
              
            end
            
        end %end start

    end
    
end