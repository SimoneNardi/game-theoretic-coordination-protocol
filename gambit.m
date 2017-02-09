classdef gambit < handle
    %GAMBIT classe che si occupa di trovare gli equilibri di Nash
    %   Questa classe si occupa di caricare le librerie per l'esecuzione di
    %   gambit e poi invoca il metodo per trovare gli equilibri basandosi
    %   sulle informazioni attuali della classe enviroment.
    % V6
    

    
    properties
        verbose;
        solvedGame_time=1;
        solvedGame_players
        solvedGame_actions
        solvedGame_CritAreaHypothesis=[0,0];
    end
    
    methods       
        function obj=gambit(verboseOutput)
        
        if(verboseOutput)   
            
            obj.verbose=1;
        else
            
            obj.verbose=0;
        end
        end
        
        function equilibriums = TCP_IP_comm(obj,sendArray,numPlayers)
            

            string=num2str(numPlayers);
            string=strcat(string,';');
            for i=1:length(sendArray)
                num=num2str(sendArray(i));
                string= strcat(string,num);
                if i< length(sendArray)
                    string= strcat(string,',');
                end
            end
            string=strcat(string,'t');
            t = tcpip('localhost', 50000);
            t.OutputBufferSize = 25600;
            t.InputBufferSize = 25600;
            fopen(t);
            fwrite(t, string);

            while t.BytesAvailable == 0
                 pause(0.01)
            end
            data = fread(t, t.BytesAvailable);
            fclose(t);
            delete(t);
            clear t;

            outputstring=char(data)';
            
            if (outputstring == 'n')
                equilibriums=0;
                display('no equilibriums');
            
            elseif (outputstring == 'f')
                equilibriums=0;
                display('failed calculus');
                
            else
                char_cell=strsplit(outputstring,',');
                equilibriums= cellfun(@str2num,char_cell);                
            end
            
        end
        
        

        
%%         
        function [move,steer,intruder_mixed] = gamePayoff(obj,robot,intruder,defensors,world,critAreaHyp)
            
            %robot: l'indice che identifica quale robot all'interno dell'array players è il chiamante.
            %                  1: intruso
            %                  2: difensore

            
            %controllo che la richiesta attuale non sia già stata soddisfatta
            gameSolved=0;
                       
%             if (world.time == obj.solvedGame_time) && (length(obj.solvedGame_players)== length(defensors)) && (all(ismember(obj.solvedGame_players,defensors)) && isequal(critAreaHyp,obj.solvedGame_CritAreaHypothesis))
%                 gameSolved=1;
%         
%             end
            
            players={intruder};
            for i=1:length(defensors)
                players{i+1}=defensors(i); %cellarray dei giocatori
            end
            actions= intruder.actions;
            %% risolvo il gioco se non � gi� stato risolto            
            if not(gameSolved )
                
                
                numPlayers=length(players);

                numStrat= 3^numPlayers; %number of pure strategy permutations

                Sp = math.permn(actions,numPlayers);%matrix containing the players pure strategy 
                                  %permutations 1:forward 2:turn left 3:turn r
                %U=zeros(numStrat,numPlayers); %matrix containing the pay-offs to the players at various 
                                  %pure strategy permutations

                predictedPosition=zeros(numPlayers,2);

                

                for s = 1:numStrat

                %Aggiorno le posizioni previste degli altri giocatori secondo la strategia attuale

                    for p = 1:(numPlayers)

                    predictedPosition(p,:)=players{p}.currentPosition+players{p}.speed*[cos(players{p}.currentDirection+ Sp(s,p) ) sin(players{p}.currentDirection+ Sp(s,p))];

                    end 


                    for p = 1:numPlayers

                        l_dist_player_intruder= norm(predictedPosition(1,:) - predictedPosition(p,:));
                        [ l_min_dist_player_nearobs_otherplayer,~ ]=world.min_dist_player_nearobs_otherplayer(p,predictedPosition);
                        
                        l_dist_player_critic =norm(critAreaHyp - predictedPosition(p,:));   

                        [barrier_center_angle]=math.formation(predictedPosition(1,:),critAreaHyp,world.safeZone);
                        
                        %d è l'indice per scorrere l'array dei difensori.
                        if p==1
                            d=1;
                        else
                            d=p-1;
                        end
                        [l_dist_player_arc, ~, ~, ~, ~, ~, barrier_gain]=math.distance_point_arc(defensors(d).formationRadius,barrier_center_angle,defensors(d).formationHalfExtension,predictedPosition(1,:),predictedPosition(p,:));                

                        if p==1
                            I(p)= - l_dist_player_critic-defensors(p).obstacle_factor*(1/l_min_dist_player_nearobs_otherplayer);
                        else
                            I(p)= -defensors(p-1).obstacle_factor*(1/l_min_dist_player_nearobs_otherplayer)- l_dist_player_arc -defensors(p-1).barrier_factor*barrier_gain;
                        end

                        U(s,p)= I(p); 

                    end

               end 
        
            
 % ******************************************TROVO GLI EQUILIBRI*******************************           
            
               U_vector = fix(reshape(U',1,numStrat*numPlayers).*10^4);
               
               S=3*ones(1,numPlayers); %number of strategies of each player
                
            
               if obj.verbose

               else
                    
               end
               
               equilibriums=obj.TCP_IP_comm(U_vector,numPlayers);
               
               if equilibriums == 0

                 

                 A= 0.5 * ones(3,numPlayers);



               else
                   %I must select one of the equilibriums 
                   %equilibriums=double(equilibriums_python);

                   numEquilibriums = length(equilibriums)/(3*numPlayers);   
                   EqLen=numPlayers*3;
                   rank= zeros(1,numEquilibriums); %declaration


                       if numEquilibriums > 1


                            % in this case if there are more then one equilibrium        
                            for eq =1 : numEquilibriums
                                selEquilibrium= reshape(equilibriums(EqLen*(eq-1)+1 : EqLen*eq),3,numPlayers);
                                rank(eq) = math.equilibrium_value(selEquilibrium,numPlayers,3,U);
                            end

                            [~,maxRankIndex]=max(rank);
                            chosenEquilibrium=equilibriums(EqLen*(maxRankIndex-1)+1 : EqLen*maxRankIndex);

                       else

                            chosenEquilibrium=equilibriums;

                       end


                   %reshape the vector in to a matrix form
                   A = reshape(chosenEquilibrium,3,numPlayers);
               end
        
               % salvo il gioco

               obj.solvedGame_players=defensors;
               obj.solvedGame_actions=A;
               obj.solvedGame_time=world.time;
               obj.solvedGame_CritAreaHypothesis=critAreaHyp;
       
            end %end if not(gameSolved)
       
            %% assegno la posizione al chiamante sia nel caso di gioco risolto che nel caso di gioco non risolto
            
            %'robot' è l'indice che identifica quale robot all'interno dell'array players è il chiamante. 
            %'applicant' è l'indice che identifica il chiamante all'interno
            %dell'array delle soluzioni del gioco.
      
            if robot == 1          
               applicant=1;
            else             
               %cerco in quale posizione fosse il robot chiamante quando il
               % gioco è stato risolto in passato.
               logicalarray=(defensors(1)==obj.solvedGame_players);
               applicant=find(logicalarray)+1;
            end
                                    
           %fornisco in uscita la matrice delle strategie miste dell'intruso
           intruder_mixed=obj.solvedGame_actions(:,1);                 

            random = rand;
           %passo la posizione e l'angolo di sterzata

            if (random >0) && (random <= obj.solvedGame_actions(1,applicant))

                move=players{robot}.currentPosition+players{robot}.speed*[cos(players{robot}.currentDirection ) sin(players{robot}.currentDirection)]; 
                steer=players{robot}.currentDirection;
            end

            if (random >obj.solvedGame_actions(1,applicant)) && (random <= obj.solvedGame_actions(1,applicant)+obj.solvedGame_actions(2,applicant))
                move=players{robot}.currentPosition+players{robot}.speed*[cos(players{robot}.currentDirection+actions(2) ) sin(players{robot}.currentDirection+ actions(2))]; 
                steer=players{robot}.currentDirection +actions(2);


            end

            if (random > obj.solvedGame_actions(1,applicant)+obj.solvedGame_actions(2,applicant)) && (random <= 1)
                move=players{robot}.currentPosition+players{robot}.speed*[cos(players{robot}.currentDirection+ actions(3) ) sin(players{robot}.currentDirection+actions(3))]; 
                steer=players{robot}.currentDirection +actions(3);


            end

       
        end %function payoff
        

        
    end %end methods
    
end %end class

