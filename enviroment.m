classdef enviroment < handle
    %ENVIROMENT Classe che gestisce la simulazione e il disegno 
    %   tramite la classe enviroment si gestiscono tutti gli aspetti della
    %   simulazione, inoltre si occupa della rappresentazione grafica e
    %   e dell'aggiornamento di tutti gli elementi.
    %V6
    
    properties
        
        %graphic objects
        map; 
        critAreas;
        safeZone;
        critArea_dim;
        safeZone_dim;
        obstacles;
        obstaclesRadius;
        colors;
        
        % agents
        defenders; %array con tutti i difensori
        intruder; %intruso
        
        %varies
        draw_enviroment=0;
        game_theory_solver;
        intruderDetected;

        time %tempo di simulazione
        
    end
    
    methods
        
        
        function obj=enviroment(map_pixels,crit,safe,obstacles_array,agentsArray,solver)
            %% costruttore
            
            obj.map=map_pixels;
            obj.colors=['m','c','r','y',];
            obj.critArea_dim=crit(1,1:2);            
            obj.critAreas=crit(2:end,:);
            obj.safeZone=safe(2:end,:);
            
            obj.safeZone_dim=safe(1,1:2);
            obj.intruder=agentsArray{1};
            
            for i=1:(size(agentsArray,2)-1)
                
            temp(i)=agentsArray{i+1};
            obj.defenders=temp;
            end
            
            obj.time=1;

            obj.obstacles=obstacles_array(2:end,:);
            obj.obstaclesRadius=obstacles_array(1,1);
            obj.game_theory_solver=solver;
            obj.intruderDetected=0;
            
        end
        
       
        
        function draw(obj)
            %% disegno
            
            %setto lo stato "disegno" "true"
            if obj.draw_enviroment==0
                intruder_handler=obj.intruder;
                fig = figure('keypressfcn',@intruder_handler.key_pressed);
                axis square 
                rectangle('position',[3 3 obj.map-3 obj.map-3],'edgecolor','y', 'LineWidth',2) %drawing map borders
                
                
                if obj.intruder.behaviour ==3
                    disp('inserire comando di direzione:');
                    disp('freccia su: avanza lungo la direzione attuale')                
                    disp('freccia sinistra: svolta a sinistra e avanza')
                    disp('freccia destra: svolta a destra e avanza')
                    rectangle('position',[obj.critAreas(obj.intruder.target,:)-obj.critArea_dim/2 obj.critArea_dim],'FaceColor',obj.colors(obj.intruder.target))%drawing target area
                    text(obj.critAreas(obj.intruder.target,1),obj.critAreas(obj.intruder.target,2),'C');
                else
                    for d=1:size(obj.critAreas,1)
                        rectangle('position',[obj.critAreas(d,:)-obj.critArea_dim/2 obj.critArea_dim],'FaceColor',obj.colors(d))%drawing target area
                        text(obj.critAreas(d,1),obj.critAreas(d,2),'C'),
                    end                   
                    rectangle('position',[obj.safeZone-obj.critArea_dim/2 obj.safeZone_dim],'FaceColor','g')%drawing target area
                    text(obj.safeZone(1),obj.safeZone(2),'S')                    
                end
             
                for i = 1:size(obj.obstacles,1)
                    rectangle('position',[obj.obstacles(i,:)-obj.obstaclesRadius, 2*obj.obstaclesRadius*ones(1,2)],'Curvature',[1 1],'FaceColor','k') % drawing obstacles
                end

                hold on;

                obj.draw_enviroment=1;
             
            end %if
            
            for i=1:length(obj.defenders)
                if obj.defenders(i).graphicalHandler==-1
                    %se non inizializzato l'oggetto grafico, viene
                    %inizializzato qui.
                    obj.defenders(i).graphicalHandler=fill([0; 0; 0; 0; 0; 0 ],[0; 0; 0; 0; 0; 0 ], 'b');
                    obj.defenders(i).comunicationHandler=rectangle('position',[obj.defenders(i).currentPosition-obj.defenders(i).comunicationRadius, obj.defenders(i).comunicationRadius*ones(1,2)*2 ],'Curvature',[1 1],'edgecolor','k','LineStyle',':');
                    obj.defenders(i).detectionHandler=rectangle('position',[obj.defenders(i).currentPosition-obj.defenders(i).detectionRadius, obj.defenders(i).detectionRadius*ones(1,2)*2 ],'Curvature',[1 1],'edgecolor','r','LineStyle',':');
                    obj.defenders(i).arcFormationHandler = line([0; 0; 0; 0; 0 ],[0; 0; 0; 0; 0 ], 'color', 'black','LineWidth',1);
                end
            obj.defenders(i).draw(obj);
            end
            
            
            if obj.intruder.graphicalHandler==-1
                %se non inizializzato l'oggetto grafico, viene
                %inizializzato qui. 
                obj.intruder.graphicalHandler=fill([0; 0; 0; 0; 0; 0 ],[0; 0; 0; 0; 0; 0 ], 'r');
                if obj.intruder.behaviour ==3
                   obj.intruder.criticalHandler=rectangle('position',[obj.intruder.currentPosition-obj.intruder.criticalRadius, obj.intruder.criticalRadius*ones(1,2)*2 ],'Curvature',[1 1],'edgecolor','r','LineStyle','-.');
                end
                hold on;
            end
            
            obj.intruder.draw();
            

                      
            drawnow;
            
        end %function draw
               
       function [ l_min_dist_player_nearobs_otherplayer,lindex ] = min_dist_player_nearobs_otherplayer(obj, agentIndex,positionsMatrix )
           %% calcolo la distanza dall'oggetto o robot più vicino.
            %positionMatrix = contiene tutte le posizioni degli agenti da
            %                cui voglio calcolare la distanza
            %agentIndex = definise quale è il robot di riferimento da cui voglio calcolare le distanze. 
            
            
            
            %distance from circular obstacles
            
            for o = 1:size(obj.obstacles,1)
                l_dist_player_nearobs(o)=norm(obj.obstacles(o,:)-positionsMatrix(agentIndex,:))-obj.obstaclesRadius; 
            end


            %distance from other player, the defenders do not consider the
            %distance from the intruder.
            
            count=1;
            for b = 1:size(positionsMatrix,1)

              if(b == 1) %la prima posizione è sempre l'intruso
                  continue;
              end

              if (b ~= agentIndex)                 
                l_dist_between_player(count)=norm(positionsMatrix(b,:)-positionsMatrix(agentIndex,:));
                count=count+1;
              end
            end


            if (size(positionsMatrix,1) == 2) && (agentIndex == 2) || (size(positionsMatrix,1)==1)
              [l_min_dist_player_nearobs_otherplayer, lindex] = min([l_dist_player_nearobs ]);
            else
              [l_min_dist_player_nearobs_otherplayer, lindex] = min([l_dist_player_nearobs ,l_dist_between_player ]);
            end

            if l_min_dist_player_nearobs_otherplayer<=0.01
                l_min_dist_player_nearobs_otherplayer=0.01;
            end
            
       end
       
       
       function exitStatus=exitConditions(obj,t)
       %% condizioni di uscita della simulazione
        exitStatus=[]; %standard exit
        

        l_dist_intruder_critic = norm(obj.critAreas(obj.intruder.target,:) - obj.intruder.currentPosition);
        l_dist_intruder_safezone = norm(obj.safeZone - obj.intruder.currentPosition);
        if t>= 10000
            close all;
            exitStatus=-1;
        end

        if l_dist_intruder_critic < obj.critArea_dim(1)/2
            
            exitStatus=0;
            close all;
            return
        end
        if l_dist_intruder_safezone < obj.safeZone_dim(1)/2
            if obj.intruder.behaviour==3
               rectangle('position',[obj.safeZone-obj.critArea_dim/2 obj.safeZone_dim],'FaceColor','g')%drawing target area
               text(obj.safeZone(1),obj.safeZone(2),'S') 
               pause(2);
               close all;
            end
            exitStatus=1;
            close all;
            return
        end    
       
       
       end
       
       
                 
        function [t, exitStatus]=start(obj)
            %% metodo principale della classe, si occupa dell'esecuzione del
            % gioco e restituisce il risultato della simulazione.    

            while 1
                
                obj.intruder.start(obj,obj.game_theory_solver);
                for i=1:length(obj.defenders)
                    obj.defenders(i).start(obj,obj.game_theory_solver);
                end
                
                obj.intruder.move();
                for i=1:length(obj.defenders)
                    obj.defenders(i).move();
                end
                
            if obj.draw_enviroment
                obj.draw();
            end 
            
            obj.time=obj.time+1;
            
            exitStatus=obj.exitConditions(obj.time);
               
            if not(isempty(exitStatus))
              t=obj.time;  
              return 
            end
            

            end   %end while         
        end %end function start
        
        
        
    end %metods
    
end %class

