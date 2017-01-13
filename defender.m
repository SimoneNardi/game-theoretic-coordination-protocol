classdef defender < handle
    %DEFENDER Oggetto che rappresenta gli agenti difensori
    %   E' una classe "Handler" le cui proprietà sono la
    %   posizione,l'orientazione e la dimensione del robot, oltre che una
    %   variabile contenente l'oggetto grafico se inizializzato dalla
    %   funzione enviroment.draw().
    %V6

    
    properties (SetAccess = public, GetAccess = public)
      
        %state
      currentPosition
      nextPosition
      currentDirection
      nextDirection
      speed
      speedMax;
      actions
      
        %graphics
      graphicalHandler
      detectionHandler
      comunicationHandler
      arcFormationHandler
      halfDiagonalDistance
      barrierLandmarks;  
      
        %varius
      detectionRadius
      comunicationRadius
      intruderDetected
      intruderFound %intruso, quando identificato
      defendersFound %array di tutti gli inseguitori dell'intruso
      DefendersNotFound %compagni ancora non trovati
      obstacle_factor
      safeZone
      formationRadius;
      formationHalfExtension;
      
        %identification
      occurrences
      hypothesis % quale zona critica sospetto sia quella che l'intruso ha 
                 % come target
      hypothesis_index
      intruderPreviousDirection      
      GTintruderPredictedMove
      predictedPositions
      predictedDirections
      buffer

      


    end
    methods

        function obj = defender(init_pos, init_dir, detect, comm,act,extension,obstacle,sp,radius,buffer)
            obj.currentPosition=init_pos;
            obj.nextPosition=init_pos;
            obj.currentDirection=init_dir;
            obj.nextDirection=init_dir;
            obj.graphicalHandler=-1;
            obj.halfDiagonalDistance=7;%  <----dimension robot
            obj.detectionRadius=detect;
            obj.comunicationRadius=comm;
            obj.speed=sp;
            obj.speedMax=sp;
            obj.intruderDetected=0;
            obj.defendersFound=defender.empty;
            obj.actions=act;
            obj.obstacle_factor=obstacle;
            obj.formationHalfExtension=extension;
            obj.formationRadius=radius;
            obj.hypothesis_index=1;
            obj.barrierLandmarks=[0 0 0 0 0 ; 0 0 0 0 0];
            obj.buffer=buffer;
        end
        
        function draw(obj,world)
            
            % plot robot with specified configuration
            corner1=obj.currentPosition+5/3*obj.halfDiagonalDistance*[ cos(obj.currentDirection) sin(obj.currentDirection)];
            corner2=obj.currentPosition+obj.halfDiagonalDistance*[ cos(obj.currentDirection+(2/3*pi)) sin(obj.currentDirection+(2/3*pi))];
            corner3=obj.currentPosition+obj.halfDiagonalDistance*[ cos(obj.currentDirection-(2/3*pi)) sin(obj.currentDirection-(2/3*pi))];

            % updating position of the robot 

            set(obj.graphicalHandler,{'XData'},{[corner1(1) corner2(1) corner3(1)  corner1(1)]},{'YData'},{[corner1(2);corner2(2);corner3(2);corner1(2)]});
            set(obj.graphicalHandler,'FaceColor',world.colors(obj.hypothesis_index));
            drawnow;
            
            set(obj.comunicationHandler,{'Position'},{[obj.currentPosition-obj.comunicationRadius, obj.comunicationRadius*ones(1,2)*2 ]});
            set(obj.detectionHandler,{'Position'},{[obj.currentPosition-obj.detectionRadius, obj.detectionRadius*ones(1,2)*2 ]});
            
            % updating barrier if intruder detected.
            if ( obj.intruderDetected  )
            
                set(obj.arcFormationHandler,{'XData'},{obj.barrierLandmarks(1,:)},{'YData'},{obj.barrierLandmarks(2,:)});
            
            end
        end
        
        function searchIntruderDefenders(obj,world)
        
        %cerco l'intruso    
        if  not(obj.intruderDetected) 
           if norm(obj.currentPosition-world.intruder.currentPosition)<= obj.detectionRadius
               obj.intruderDetected=1;
               obj.intruderFound=world.intruder;
           end
        
        end   
        %cerco i miei compagni 
       remove=[]; 
       if not(isempty(obj.DefendersNotFound))
           for s=1:length(obj.DefendersNotFound)
               if obj==obj.DefendersNotFound(s)
                   remove=[remove,obj];
                   continue

               end
               if norm(obj.currentPosition-obj.DefendersNotFound(s).currentPosition)<= obj.comunicationRadius
                   obj.defendersFound(length(obj.defendersFound)+1)=obj.DefendersNotFound(s);
                   remove=[remove,obj.DefendersNotFound(s)];

               end
           end
           
           obj.DefendersNotFound = setdiff(obj.DefendersNotFound,remove);

           
       end
            
        end
        
        function setSpeed(obj)
            barrier_center_angle=math.formation(obj.intruderFound.currentPosition,obj.hypothesis,obj.safeZone); 
            [l_dist_player_arc, LM1, LM2, LM3, LM4, LM5, ~]=math.distance_point_arc(obj.formationRadius,barrier_center_angle,obj.formationHalfExtension,obj.intruderFound.currentPosition,obj.currentPosition);
            obj.barrierLandmarks=[LM1(1) LM2(1) LM3(1)  LM4(1) LM5(1); LM1(2) LM2(2) LM3(2)  LM4(2) LM5(2)];
            
            if (l_dist_player_arc >=0) && (l_dist_player_arc <= (obj.detectionRadius/4))
            obj.speed=((obj.speedMax-obj.intruderFound.speed)/(obj.detectionRadius/4))*l_dist_player_arc+obj.intruderFound.speed;
            else 
               obj.speed=obj.speedMax; 
            end
    
            
        end
        
        function chooseNextMove(obj,world,game_theory_solver)
        
            if not(isempty(obj.intruderPreviousDirection ))
                % A partire dal confronto della posizione precedente
                % dell'intruso e di quella attuale deduco la sua mossa attuale.

                if (obj.intruderFound.currentDirection == obj.intruderPreviousDirection )
                     intrudermove=1;
                elseif (obj.intruderFound.currentDirection == obj.intruderPreviousDirection+obj.actions(2))
                     intrudermove=2;   
                else 
                     intrudermove=3;
                end

                % Confronto la sua mossa attuale con quella fornita da gambit
                % all'iterazione precedente, in questo modo posso aggiornare il
                % mio grado di fiducia sull'ipotesi attule.
                
                
                tot_occur=size(obj.occurrences,2);
                new_occur=tot_occur+1;
                for z=1:size(obj.GTintruderPredictedMove,2)
                    obj.occurrences(z,new_occur)=obj.GTintruderPredictedMove(intrudermove,z);
                end
                if tot_occur+1 > obj.buffer
                    window=obj.occurrences(:,tot_occur+2-obj.buffer:end);
                else
                    window= obj.occurrences;
                end                
                [confidence_percent,obj.hypothesis_index]=max(mean(window,2));
                


            end
            

            
            % richiamo gambit per ogni zona critica            
            if isempty(obj.defendersFound)
                defesorsPlayers=obj;
            else
                defesorsPlayers=[obj,obj.defendersFound];
            end
            
            for c=1:size(world.critAreas,1)
                [obj.predictedPositions(c,:),obj.predictedDirections(c,:),obj.GTintruderPredictedMove(:,c)]=game_theory_solver.gamePayoff(2,obj.intruderFound,defesorsPlayers,world,world.critAreas(c,:));
            end
            
            %assegno la mia mossa successiva in base al mio grado di fiducia 
            obj.nextPosition=obj.predictedPositions(obj.hypothesis_index,:);
            obj.nextDirection=obj.predictedDirections(obj.hypothesis_index);

           %salvo la posizione attuale dell'intruso per utilizzarla
           %l'iterazione successiva.
           obj.intruderPreviousDirection=obj.intruderFound.currentDirection;
           obj.hypothesis=world.critAreas(obj.hypothesis_index,:);
           
        end
        
        
        function move(obj)                             
            obj.currentPosition=obj.nextPosition;
            obj.currentDirection=obj.nextDirection;
            
            %setto la velocità  
            if ( obj.intruderDetected  )
              
                obj.setSpeed(); 
                
            end
        end
            
        function start(obj,world,game_theory_solver)
            
            if world.time==1
                %inizializzazione robot all'istante iniziale
                
                obj.DefendersNotFound=world.defenders;
                obj.safeZone=world.safeZone;
                
                %setto l'ipotesi iniziale
                obj.occurrences=zeros(size(world.critAreas,1),1);
                for i=1:size(world.critAreas,1) 
                    criticAreaDistance(i)=norm(obj.currentPosition-world.critAreas(i,:));  
                end
 
                [~,obj.hypothesis_index]=min(criticAreaDistance);
                obj.hypothesis=world.critAreas(obj.hypothesis_index,:);
               

            end
            
            
            
            obj.searchIntruderDefenders(world);
            
            if ( obj.intruderDetected  )
                
                obj.chooseNextMove(world,game_theory_solver);
      
            end

        end %end start    
            
            
            
        
        
    end
    
end
