%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending and villagers during the first 15 
%minutes of an Age of Empires II game.

clc
clear all
close all

size_chromo = ChromosomeGenerator();
num_buildings=8;
num_techs=8;
num_vil_divisions=4;

block_mut_prob=.05;
mut_prob = .1;
cross_prob = .4;        %Max value is 0.5. Above that, loses meaning
tournament_size = 3;

moving_average_vils=[];
moving_average_spend=[];

chromosome_size = length(size_chromo); 
generation_size = 14; % must be an even number
M = 1200; % Total Number of generations
current_gen = 1;

parent_chromos = zeros(generation_size,chromosome_size);
children_chromos = [];
obj_funcs = zeros(generation_size,3);
children_obj_funcs = zeros(generation_size,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% populate first generation chromosomes and fitness values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first find values of 2 objective functions of parent chromosomes
% 'obj_funcs' is a matrix with 'generation_size' rows and 3 columns-
% Column 1- Military Spending
% Column 2- Number of Villagers
% Column 3- Index of Chromosome
for i=1:size(parent_chromos,1)
    chromosome = ChromosomeGenerator();
    parent_chromos(i,:) = chromosome;
    [obj_funcs(i,1),obj_funcs(i,2)] = AoEModel(chromosome);
    obj_funcs(i,3) = i;
end

% save starting chromosomes for later comparison
starting_chromos = parent_chromos; 

% plot initial design points, Number of Villagers vs. Military Spending
figure(1),clf,
plot(obj_funcs(:,2),obj_funcs(:,1),'r*')
xlabel('Number of Villagers')
ylabel('Military Spending')
legend('Starting Designs')

figure(2),clf,
plot(obj_funcs(:,2),obj_funcs(:,1),'r*')
xlabel('Number of Villagers')
ylabel('Military Spending')
legend('Starting Designs')
hold on



% prepare vectors to pass into 'findFitness' function
spend = obj_funcs(:,1);
vils = obj_funcs(:,2);

% find fitness of parent generation
parent_fitness=findFitness(spend,vils);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LET THE HUNGER GAMES BEGIN!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for master_counter=1:M
        
    %for counter_3=1:2:generation_size-1 %GEN_SIZE MUST BE EVEN!!!!
    while size(children_chromos,1)<generation_size
        
        for child_counter=1:2
            % In this loop, we create two children. The loop is run twice 
            
            %% We will perform tournament selection for mother and father chromosomes            
            %Randomly select chromosomes. Instatiate an empty tournament
            %fitness matrix.
            rand_chromo_nums = randperm(generation_size,tournament_size);
            tournament_chromos = zeros(tournament_size,chromosome_size);
            tournament_fitnesses = zeros(tournament_size,1);
            
            for counter_1=1:tournament_size
                tournament_chromos(counter_1,:) = parent_chromos(rand_chromo_nums(counter_1),:);
                tournament_fitnesses(counter_1) = parent_fitness(rand_chromo_nums(counter_1));
            end
            
            %Determine champion chromosome
            highest_tournament_fitness = max(tournament_fitnesses);
            highest_fitness_chromos = [];

            %If there is a tie for best, list all chromosomes involved.
            for counter_1=1:tournament_size
                if tournament_fitnesses(counter_1)==highest_tournament_fitness
                    highest_fitness_chromos=[highest_fitness_chromos,rand_chromo_nums(counter_1)];
                end
            end
            
            if length(highest_fitness_chromos)==1
                %If no tie exists, create the mother or father with the
                %best available chromosome.
                if child_counter==1
                    mother_chromo = parent_chromos(highest_fitness_chromos(1),:);
                elseif child_counter==2
                    father_chromo = parent_chromos(highest_fitness_chromos(1),:);
                end
            elseif length(highest_fitness_chromos)>1
                %Break the tie, if it exists, with a random number generator.
                if child_counter==1
                    mother_chromo = parent_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
                elseif child_counter==2
                    father_chromo = parent_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
                end
            end
            
        end

        %% Crossover section.
        [child_1,child_2]=uni_cross(cross_prob,mother_chromo,father_chromo);
        
        if length(child_1)>172||length(child_2)>172
            disp 'bad'
        end
        
        %% Mutation section.
        child_1 = blockMutation2(child_1, chromosome_size, M, current_gen, block_mut_prob,num_buildings,num_techs,num_vil_divisions);
        child_2 = blockMutation2(child_2, chromosome_size, M, current_gen, block_mut_prob,num_buildings,num_techs,num_vil_divisions);
        
        if length(child_1)>172||length(child_2)>172
            disp 'bad'
        end
        
        child_1 = mutation(child_1, chromosome_size, M, current_gen, mut_prob,num_buildings,num_techs);
        child_2 = mutation(child_2, chromosome_size, M, current_gen, mut_prob,num_buildings,num_techs);
        
        
        if length(child_1)>172||length(child_2)>172
            disp 'bad'
        end
        %% Save children to matrix that will be used in elitism function.       
        
        try children_chromos(end+1,:)=child_1;
            
        catch oop
            oop=1
        end
        
        try children_chromos(end+1,:)=child_2;
            
        catch oop
            oop=1
        end
        
        %% Eliminate true duplicates. Currently unused; not necessary.
        % children_chromos=unique(children_chromos,'rows');
        
    end
    
    %% Find the function values of each child.
    for i=1:generation_size
        [children_obj_funcs(i,1),children_obj_funcs(i,2)] = AoEModel(children_chromos(i,:));
    end
    
    %% Create next generation fitnesses.
    children_spend = children_obj_funcs(:,1);
    children_vils = children_obj_funcs(:,2);
    children_fitness=findFitness(children_spend,children_vils);
    
    %% Create the total list of candidates for elitism.
    candidates_chromos = [parent_chromos;children_chromos];
    candidates_fitness = [parent_fitness;children_fitness];
    
    %% Delete duplicate designs from elitist matrix.
    indexes=[];
    for i=1:size(candidates_chromos,1)
        for j=i+1:size(candidates_chromos,1)
            if isequal(candidates_chromos(i,:),candidates_chromos(j,:))
                indexes=[indexes,j];
            end
        end
    end
    candidates_chromos(indexes,:)=[];
    candidates_fitness(indexes,:)=[];
    
    %% Renumber remaining chromosomes.
    for i=1:size(candidates_chromos)
        candidates_fitness(i,2) = i;
    end

    %% Sort candidates by fitness. Select the most fit designs for use in
    % the next generation.
    parent_chromos=[];
    parent_fitness=[];
    elitism_fitness = sortrows(candidates_fitness,1);
    
    for i=1:generation_size
        parent_fitness(i,1)=elitism_fitness(end-generation_size+i,1);
        parent_fitness(i,2)=i;
        index=elitism_fitness(end-generation_size+i,2);
        parent_chromos(i,:)=candidates_chromos(index,:);
    end
    
    %% Clean house.
    for i=1:generation_size
        [parent_spend(i),parent_vils(i)]=AoEModel(parent_chromos(i,:));
    end
    
    moving_average_spend(master_counter)=sum(parent_spend)/generation_size;
    moving_average_vils(master_counter)=sum(parent_vils)/generation_size;
    
    children_chromos=[];
    candidates_chromos=[];
    current_gen = current_gen+1;
end



%% Ending materials

final_f=zeros(generation_size,5);
    
%plot final design points
for final_counter=1:size(parent_chromos,1)
    [military_spend,vils]=AoEModel(parent_chromos(final_counter,:));
    final_f(final_counter,1)=military_spend;
    final_f(final_counter,2)=vils;
    final_f(final_counter,3)=final_counter;
end
     final_f(:,5:6)=findFitness(final_f(:,1),final_f(:,2))

figure(2)
plot(final_f(:,2),final_f(:,1),'k*')
axis([0 max(final_f(:,2))+5 0 max(final_f(:,1))+100])
xlabel('Number of Villagers')
ylabel('Military Spending')
legend('Starting Designs','Ending Designs')

figure(3)
plot(final_f(:,2),final_f(:,1),'k*')
axis([0 max(final_f(:,2))+5 0 max(final_f(:,1))+100])
xlabel('Number of Villagers')
ylabel('Military Spending')
legend('Ending Designs')

%%Debug code. (You can run the optimal chromosome and see how many
%of each unit got trained, etc.)
[military_spend,vils]=AoEModel(parent_chromos(end,:));

time_vector=1:M;
figure(4)
scatter(time_vector,moving_average_vils)
title('Moving Average of Number of Villagers in Pareto Frontier')
xlabel('Iteration')
ylabel('Number of Villagers')

figure(5)
scatter(time_vector,moving_average_spend)
title('Moving Average of Military Spending in Pareto Frontier')
xlabel('Iteration')
ylabel('Military Spending')

sortrows(final_f,1)