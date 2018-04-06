%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending during the first 15 minutes of an
%Age of Empires II game.

clc
clear

chromosome_size = 55; % If chromosome length changes must change mutation function with it
generation_size = 10; % MUST BE AN EVEN NUMBER!!!!!!!!!
M = 100; % Total Number of generations
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

%plot initial
figure(1), clf,
plot(current_gen-1,fitness(:,1),'k*')
hold on
% axis([0 M 0 2000])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LET THE HUNGER GAMES BEGIN!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%perform tournament selection for mother and father chromosomes
tournament_size = 5;
for master_counter=1:M
    
    for counter_3=1:2:generation_size-1 %GEN_SIZE MUST BE EVEN!!!!
        
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
        cross_prob = .5; % We can change
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
        child_1 = mutation(child_1, chromosome_size, M, current_gen, mut_prob);
        child_2 = mutation(child_2, chromosome_size, M, current_gen, mut_prob);

        %create next generation chromo matrix and fitness matrix
        next_gen_chromos(counter_3,:)=child_1;
        next_gen_fitness(counter_3,1)=AoEModel(child_1);
        next_gen_fitness(counter_3,2)=generation_size+counter_3;
        next_gen_chromos(counter_3+1,:)=child_2;
        next_gen_fitness(counter_3+1,1)=AoEModel(child_2);
        next_gen_fitness(counter_3+1,2)=1+generation_size+counter_3;
    end

    %%%elitism
    elitism_fitness = [fitness;next_gen_fitness];
    elitism_fitness = sortrows(elitism_fitness,1);

    for counter_4=generation_size+1:2*generation_size
        if elitism_fitness(counter_4,2)<generation_size+1
            generation_chromos(counter_4-generation_size,:)=...
                generation_chromos(elitism_fitness(counter_4,2),:);
            fitness(counter_4-generation_size,1)=fitness(elitism_fitness(counter_4,2),1);
        else
            generation_chromos(counter_4-generation_size,:)=...
                next_gen_chromos(elitism_fitness(counter_4,2)-generation_size,:);
            fitness(counter_4-generation_size,1)=...
                next_gen_fitness(elitism_fitness(counter_4,2)-generation_size,1);
        end
    end    
    
    current_gen = current_gen+1;
    plot(current_gen-1,fitness(:,1),'k*')
end

max_spend=max(fitness)
axis([0 M 0 max_spend(1)+100])

%I just put this in so you can run the optimal chromosome and see how many
%of each unit got trained, etc.
AoEModel(generation_chromos(end,:))