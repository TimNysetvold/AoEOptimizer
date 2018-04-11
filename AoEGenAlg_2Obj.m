%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending and villagers during the first 15 
%minutes of an Age of Empires II game.

clc
clear

size_chromo = ChromosomeGenerator();
num_buildings=8;
num_techs=8;
num_vil_divisions=4;

chromosome_size = length(size_chromo); 
generation_size = 20; % must be an even number
M = 200; % Total Number of generations
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
hold on

% prepare vectors to pass into 'findFitness' function
spend = obj_funcs(:,1);
vils = obj_funcs(:,2);

% find fitness of parent generation
parent_fitness=findFitness(spend,vils);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LET THE HUNGER GAMES BEGIN!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%perform tournament selection for mother and father chromosomes
tournament_size = floor(0.2*generation_size);
for master_counter=1:M
        
    %for counter_3=1:2:generation_size-1 %GEN_SIZE MUST BE EVEN!!!!
    while size(children_chromos,1)<generation_size
        for counter_2=1:2
            
            %randomly select chromosomes
            rand_chromo_nums = randperm(generation_size,tournament_size);

            tournament_chromos = zeros(tournament_size,chromosome_size);
            tournament_fitnesses = zeros(tournament_size,1);
            
            for counter_1=1:tournament_size
                tournament_chromos(counter_1,:) = parent_chromos(rand_chromo_nums(counter_1),:);
                tournament_fitnesses(counter_1) = parent_fitness(rand_chromo_nums(counter_1));
            end
            %determine champion chromosome
            highest_tournament_fitness = max(tournament_fitnesses);
            highest_fitness_chromos = [];

            
            for counter_1=1:tournament_size
                if tournament_fitnesses(counter_1)==highest_tournament_fitness
                    highest_fitness_chromos=[highest_fitness_chromos,rand_chromo_nums(counter_1)];
                end
            end

            % select mother/father chromosomes. If only one chromosome in 
            % the tournament has the max fitness, that chromosome becomes
            % one of the parents. If more than one tournament chromosome
            % has the highest fitness, one of those chromosomes is selected
            % randomly to be the parent.
            if length(highest_fitness_chromos)==1
                if counter_2==1
                    mother_chromo = parent_chromos(highest_fitness_chromos(1),:);
                elseif counter_2==2
                    father_chromo = parent_chromos(highest_fitness_chromos(1),:);
                end
            elseif length(highest_fitness_chromos)>1
                if counter_2==1
                    mother_chromo = parent_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
                elseif counter_2==2
                    father_chromo = parent_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
                end
            end
        end


        % Crossover
        cross_prob = .8; % We can change
        cross_rand = rand(1);
        if cross_rand < cross_prob
            cross_point = ceil(chromosome_size*rand(1));
            child_1 = [mother_chromo(1:cross_point),father_chromo(cross_point+1:end)];
            child_2 = [father_chromo(1:cross_point),mother_chromo(cross_point+1:end)];
        else
            child_1 = mother_chromo;
            child_2 = father_chromo;
        end

        % Mutation
        mut_prob = .05; % We can change
        child_1 = blockMutation2(child_1, chromosome_size, M, current_gen, mut_prob,num_buildings,num_techs,num_vil_divisions);
        child_2 = blockMutation2(child_2, chromosome_size, M, current_gen, mut_prob,num_buildings,num_techs,num_vil_divisions);

        %create next generation chromo matrix
        children_chromos(end+1,:)=child_1;
        children_chromos(end+1,:)=child_2;
        
%% eliminate true duplicates. Consider changing this to delete 
% all that have the same objective value.
%        children_chromos=unique(children_chromos,'rows');
    end

    
    for i=1:generation_size
        for j=i+1:generation_size
            if isequal(children_chromos(i,:),children_chromos(j,:))
                disp 'fial'
            end
        end
    end
    
    
    for i=1:generation_size
        [children_obj_funcs(i,1),children_obj_funcs(i,2)] = AoEModel(children_chromos(i,:));
    end
    
    %create next generation fitnesses
    children_spend = children_obj_funcs(:,1);
    children_vils = children_obj_funcs(:,2);
    
    children_fitness=findFitness(children_spend,children_vils);
    
    candidates_chromos = [parent_chromos;children_chromos];
    candidates_fitness = [parent_fitness;children_fitness];
    
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
    
    %renumber remaining chromosomes
    for i=1:size(candidates_chromos)
        candidates_fitness(i,2) = i;
    end

    elitism_fitness = sortrows(candidates_fitness,1);
    
    %% We need to sort chromosomes in the same way we've sorted rows at some
    %point
    
    parent_chromos=[];
    parent_fitness=[];
    for i=1:generation_size
        %Pulls off the fitness and index of the best available candidate,
        %adds them to the parent chromosome, and then deletes them from the
        %elitism matrix.
        parent_fitness(i,1)=elitism_fitness(end-generation_size+i,1);
        parent_fitness(i,2)=i;
        index=elitism_fitness(end-generation_size+i,2);
        parent_chromos(i,:)=candidates_chromos(index,:);
    end
    
%     for i=1:generation_size
%         for j=i+1:generation_size
%             if isequal(children_chromos(i,:),children_chromos(j,:))
%                 disp 'fial'
%             end
%         end
%     end
    
    %% What is this for?
    %This is supposed to select genes for the new parents.
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

%I just put this in so you can run the optimal chromosome and see how many
%of each unit got trained, etc.
[military_spend,vils]=AoEModel(parent_chromos(end,:));

sortrows(final_f,1)