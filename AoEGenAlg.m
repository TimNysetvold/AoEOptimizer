%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending during the first 15 minutes of an
%Age of Empires II game.

clc
clear

chromosome_size = 49; % If chromosome length changes must change mutation function with it
generation_size = 10;
M = 1000; % Total Number of generations
current_gen = 1; %Will need to keep track of the generaation we are on for mutation to work properly


generation_chromos = zeros(generation_size,chromosome_size);
next_gen_chromos = zeros(generation_size,chromosome_size);
fitness = zeros(generation_size,2);
next_gen_fitness = zeros(generation_size,2);

%populate first generation chromosomes and fitness values
%there are no external constraints, so the fitness value is simply the
%value of the objective function, 'military_spend'
for counter_1=1:size(generation_chromos,1)
    chromosome = ChromosomeGenerator();
    generation_chromos(counter_1,:) = chromosome;
    fitness(counter_1,1) = AoEModel(chromosome);
    fitness(counter_1,2) = counter_1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LET THE HUNGER GAMES BEGIN!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%perform tournament selection for mother and father chromosomes
tournament_size = 3;
for master_counter=1:M
for counter_3=1:2:generation_size-1
    for counter_2=1:2
        %randomly select chromosomes
        rand_chromo_nums = randperm(generation_size,tournament_size);

        tournament_chromos = zeros(tournament_size,chromosome_size);
        tournament_fitnesses = zeros(tournament_size,1);
        for counter_1=1:tournament_size
            tournament_chromos(counter_1,:) = generation_chromos(rand_chromo_nums(counter_1),:);
            tournament_fitnesses(counter_1) = fitness(rand_chromo_nums(counter_1));
        end

        %determine champion chromosome
        highest_tournament_fitness = max(tournament_fitnesses);
        highest_fitness_chromos = [];

        for counter_1=1:tournament_size
            if tournament_fitnesses(counter_1)==highest_tournament_fitness
                highest_fitness_chromos=[highest_fitness_chromos,rand_chromo_nums(counter_1)];
            end
        end

        if length(highest_fitness_chromos)==1
            if counter_2==1
                mother_chromo = generation_chromos(highest_fitness_chromos(1),:);
            elseif counter_2==2
                father_chromo = generation_chromos(highest_fitness_chromos(1),:);
            end
        elseif length(highest_fitness_chromos)>1
            if counter_2==1
                mother_chromo = generation_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
            elseif counter_2==2
                father_chromo = generation_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
            end
        end
    end


    % Crossover

    cross_prob = .6; % We can change this, set high to test cross over
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
    mut_prob = .1; % We can change, set high to test
    % child_1_save = child_1; % Used to compare changes
    child_1 = mutation(child_1, chromosome_size, M, current_gen, mut_prob);
    % child_comp = [child_1_save;child_1]; % Used to compare changes
    child_2 = mutation(child_2, chromosome_size, M, current_gen, mut_prob);

    next_gen_chromos(counter_3,:)=child_1;
    next_gen_fitness(counter_3,1)=AoEModel(child_1);
    next_gen_fitness(counter_3,2)=10+counter_3;
    next_gen_chromos(counter_3+1,:)=child_2;
    next_gen_fitness(counter_3+1,1)=AoEModel(child_2);
    next_gen_fitness(counter_3+1,2)=11+counter_3;
end

%%%elitism
elitism_fitness = [fitness;next_gen_fitness];
elitism_fitness = sortrows(elitism_fitness,1);

for counter_4=11:20
    if elitism_fitness(counter_4,2)<11
        generation_chromos(counter_4-10,:)=generation_chromos(elitism_fitness(counter_4,2),:);
        fitness(counter_4-10,1)=fitness(elitism_fitness(counter_4,2),1);
    else
        generation_chromos(counter_4-10,:)=next_gen_chromos(elitism_fitness(counter_4,2)-10,:);
        fitness(counter_4-10,1)=next_gen_fitness(elitism_fitness(counter_4,2)-10,1);
    end
end

current_gen = current_gen+1;
end