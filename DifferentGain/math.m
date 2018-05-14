classdef math
    %MATH Summary of this class goes here
    %   Detailed explanation goes here
    %V6
    properties
    end
    
    methods (Static)
        function [M, I] = permn(V, N, K)
         % PERMN - permutations with repetition
        %   Using two input variables V and N, M = PERMN(V,N) returns all
        %   permutations of N elements taken from the vector V, with repetitions.
        %   V can be any type of array (numbers, cells etc.) and M will be of the
        %   same type as V.  If V is empty or N is 0, M will be empty.  M has the
        %   size numel(V).^N-by-N. 
        %
        %   When only a subset of these permutations is needed, you can call PERMN
        %   with 3 input variables: M = PERMN(V,N,K) returns only the K-ths
        %   permutations.  The output is the same as M = PERMN(V,N) ; M = M(K,:),
        %   but it avoids memory issues that may occur when there are too many
        %   combinations.  This is particulary useful when you only need a few
        %   permutations at a given time. If V or K is empty, or N is zero, M will
        %   be empty. M has the size numel(K)-by-N. 
        %
        %   [M, I] = PERMN(...) also returns an index matrix I so that M = V(I).
        %
        %   Examples:
        %     M = permn([1 2 3],2) % returns the 9-by-2 matrix:
        %              1     1
        %              1     2
        %              1     3
        %              2     1
        %              2     2
        %              2     3
        %              3     1
        %              3     2
        %              3     3
        %
        %     M = permn([99 7],4) % returns the 16-by-4 matrix:
        %              99     99    99    99
        %              99     99    99     7
        %              99     99     7    99
        %              99     99     7     7
        %              ...
        %               7      7     7    99
        %               7      7     7     7
        %
        %     M = permn({'hello!' 1:3},2) % returns the 4-by-2 cell array
        %             'hello!'        'hello!'
        %             'hello!'        [1x3 double]
        %             [1x3 double]    'hello!'
        %             [1x3 double]    [1x3 double]
        %
        %     V = 11:15, N = 3, K = [2 124 21 99]
        %     M = permn(V, N, K) % returns the 4-by-3 matrix:
        %     %        11  11  12
        %     %        15  15  14
        %     %        11  15  11
        %     %        14  15  14
        %     % which are the 2nd, 124th, 21st and 99th permutations
        %     % Check with PERMN using two inputs
        %     M2 = permn(V,N) ; isequal(M2(K,:),M)
        %     % Note that M2 is a 125-by-3 matrix
        %
        %     % PERMN can be used generate a binary table, as in
        %     B = permn([0 1],5)  
        %
        %   NB Matrix sizes increases exponentially at rate (n^N)*N.
        %
        %   See also PERMS, NCHOOSEK
        %            ALLCOMB, PERMPOS on the File Exchange

        % tested in Matlab 2016a
        % version 6.1 (may 2016)
        % (c) Jos van der Geest
        % Matlab File Exchange Author ID: 10584
        % email: samelinoa@gmail.com

        narginchk(2,3) ;

        if fix(N) ~= N || N < 0 || numel(N) ~= 1 ;
            error('permn:negativeN','Second argument should be a positive integer') ;
        end
        nV = numel(V) ;

        if nargin==2, % PERMN(V,N) - return all permutations

            if nV==0 || N == 0,
                M = zeros(nV,N) ;
                I = zeros(nV,N) ;

            elseif N == 1,
                % return column vectors
                M = V(:) ;
                I = (1:nV).' ;
            else
                % this is faster than the math trick used for the call with three
                % arguments.
                [Y{N:-1:1}] = ndgrid(1:nV) ;
                I = reshape(cat(N+1,Y{:}),[],N) ;
                M = V(I) ;
            end
        else % PERMN(V,N,K) - return a subset of all permutations
            nK = numel(K) ;
            if nV == 0 || N == 0 || nK == 0
                M = zeros(numel(K), N) ;
                I = zeros(numel(K), N) ;
            elseif nK < 1 || any(K<1) || any(K ~= fix(K))
                error('permn:InvalidIndex','Third argument should contain positive integers.') ;
            else

                V = reshape(V,1,[]) ; % v1.1 make input a row vector
                nV = numel(V) ;
                Npos = nV^N ;
                if any(K > Npos)
                    warning('permn:IndexOverflow', ...
                        'Values of K exceeding the total number of combinations are saturated.')
                    K = min(K, Npos) ;
                end

                % The engine is based on version 3.2 with the correction
                % suggested by Roger Stafford. This approach uses a single matrix
                % multiplication.
                B = nV.^(1-N:0) ;
                I = ((K(:)-.5) * B) ; % matrix multiplication
                I = rem(floor(I),nV) + 1 ;
                M = V(I) ;
            end
        end               
        end %function permn
        %********************************************************************
        
        function [ dist, LM1,LM2,LM3,LM4, LM5, w ] = distance_point_arc( d,alpha,beta,center,point )
        %Calcolo la distanza da un punto a un arco
        % d: raggio
        % alpha: angolo del versore che rappresenta il centro della barrira
        % beta: semi estensione della barrirea
        % center: centro barriera
        % point: punto da cui calcolare la distanza

        %controllo che alpha sia tra 0 e 2pi, nel caso non lo fosse lo riporto.

        if alpha < 0
            alpha = 2*pi+alpha;
        end

        if alpha > 2*pi
            alpha = alpha-2*pi;
        end

        %calcolo l'angolo del vettore distanza
        v= point-center;

        theta=atan2(v(2),v(1));
        if theta < 0
           theta = 2*pi+theta;
        end

        % calcolo il punto estremale della barriera e altri 4 per il disegno
        LM1angle=alpha-beta; 
        if LM1angle <0
            LM1angle=2*pi+LM1angle;
        end

        %gli altri 4 estremi non mi interessa in che forma siano espressi dato che
        %servono solo alla rappresentazione nella simulazione
        LM2angle=alpha-(beta/2);
        LM3angle=alpha;
        LM4angle=alpha+(beta/2);
        LM5angle=alpha+beta; 

        %restituisco i versori dei punti dei cinque punti della barriera
        LM1=center+[cos(LM1angle)*d, sin(LM1angle)*d];
        LM2=center+[cos(LM2angle)*d, sin(LM2angle)*d];
        LM3=center+[cos(LM3angle)*d, sin(LM3angle)*d];
        LM4=center+[cos(LM4angle)*d, sin(LM4angle)*d];
        LM5=center+[cos(LM5angle)*d, sin(LM5angle)*d];

        %riferisco tutti gli angoli a quello dell'estremo inferiore della barriera
        %LM1
        position_vector_angle=theta-LM1angle; 

        if position_vector_angle < 0
            position_vector_angle=theta+2*pi-LM1angle;
        end


        if position_vector_angle < 2*beta        
            dist= abs(norm(point-center)-d);
        else
            dist= min(norm(LM1-point),norm(LM5-point));
        end
        
        %calcolo la costante moltiplicativa della parte della funzione
        %costo adibita all'inseguimento della barriera, in modo tale che il
        %al centro della barriera si guadagni w_min=0, e agli
        %estremi si perda w_min=1. Si ricorda che gambit accetta funzioni
        %di guadagno, il fattore di guadagno sarà del tipo -K_2*w quindi
        %quando w=0 il guadagno è massimo, mentre quando w=1 il guadagno è
        %minimo.
        w_max=1;
        w_min=0;
        
        if  (position_vector_angle > 0) && (position_vector_angle <= beta) && (dist<=10)
            
            w = ((w_min-w_max)/beta)*position_vector_angle+w_max;
            
        elseif (position_vector_angle > beta) && (position_vector_angle < 2*beta) && (dist<=10)
            
            w = (w_max-w_min)*((position_vector_angle-beta)/beta)+w_min;
        else
            w = w_max;
        end
        
        

        if dist<=0.01
            dist=0.01;
        end
        end %function distance_point_arc
        
        
        
        function barrier_center_angle=formation(intruderPredictedPosition,critArea,safeZone)
            %% calcolo i punti della formazione

            l_dist_intruder_critic = norm(critArea - intruderPredictedPosition);  
            versore_C= [critArea-intruderPredictedPosition]/l_dist_intruder_critic;

            l_dist_intruder_safezone = norm(safeZone - intruderPredictedPosition);
            versore_S= [intruderPredictedPosition-safeZone]/l_dist_intruder_safezone;
            
            versore_C_angle=atan2(versore_C(2),versore_C(1));

            if versore_C_angle < 0
               versore_C_angle = 2*pi+versore_C_angle;
            end


            versore_S_angle=atan2(versore_S(2),versore_S(1));

            if versore_S_angle < 0
               versore_S_angle= 2*pi+versore_S_angle;
            end


            delta = versore_C_angle-versore_S_angle;


            while delta > pi
                delta= delta-2*pi;
            end

            while delta < -pi
                delta=delta+2*pi;
            end
            barrier_weight= l_dist_intruder_critic /(0.4*l_dist_intruder_safezone +l_dist_intruder_critic ); %0.4*
            barrier_center_angle= versore_S_angle*barrier_weight+(versore_S_angle+delta)*(1-barrier_weight);
            
            
            
            
            
            
            
        end
        
        function [ Value,Pr,temp ] = equilibrium_value(V,players,actions,U)
     %% error managment 
        if actions ~= size(V,1);
            error('equilibrium_value:mismatchInputDimensions','imput matrix must have numbers of row equals to the numbers of actions');
            else if players ~=size(V,2);
                error('equilibrium_value:mismatchInputDimensions','imput matrix must have numbers of colums equals to the numbers of players');
                end
        end


    %% Probability vector
       temp = zeros(actions^players,players) ; % declaration 
       for ii= 1:players
           cc=1;
           for jj=1:actions^(ii-1)
               for kk=1:actions
                   for mm=1: actions^(players-ii)
                       temp(cc, ii)= V(kk,ii);
                       cc=cc+1;
                   end
               end
           end
       end

    Pr =ones(actions^players,1);

    for i=1:players
        Pr= Pr.*temp(:,i);
    end 


    %% Equilibrium Value

    Z = Pr'* U;

    Value= sum(Z);

    end
        
    end %methods
    
end

