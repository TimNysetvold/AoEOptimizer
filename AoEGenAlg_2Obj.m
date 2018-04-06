%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending and villagers during the first 15 
%minutes of an Age of Empires II game.

clc
clear

chromosome_size = 55; % If chromosome length changes must change mutation function with it
generation_size = 20; % MUST BE AN EVEN NUMBER!!!!!!!!!
M = 100; % Total Number of generations
current_gen = 1; %Will need to keep track of the generaation we are on for mutation to work properly


generation_chromos = zeros(generation_size,chromosome_size);
next_gen_chromos = zeros(generation_size,chromosome_size);
obj_funcs = zeros(generation_size,3);
next_gen_obj_funcs = zeros(generation_size,3);

%populate first generation chromosomes and fitness values
%there are no external constraints, so the fitness values are simply the
%values of the objective functions, 'military_spend' and 'vils'
for counter_1=1:size(generation_chromos,1)
    chromosome = ChromosomeGenerator();
    generation_chromos(counter_1,:) = chromosome;
    [obj_funcs(counter_1,1),obj_funcs(counter_1,2)] = AoEModel_2Obj(chromosome);
    obj_funcs(counter_1,3) = counter_1;
end

%plot initial design points
figure(1),clf,
plot(obj_funcs(:,2),obj_funcs(:,1),'r*')
hold on

%calculate fitnesses
f1 = obj_funcs(:,1);
f2 = obj_funcs(:,2);

find_fitness = zeros(length(f1),length(f2));
fitness = zeros(length(f1),2);

for i=1:length(f1)
    for k=1:length(f2)
        find_fitness(i,k) = min(f1(i)-f1(k),f2(i)-f2(k));
    end

    if (max(find_fitness(i,find_fitness(i,:) ~=0)) <0 && length(find(find_fitness(i,:)==0,2,'first'))>1)
        fitness(i,1) = 0;
    else
        fitness(i,1) = max(find_fitness(i,find_fitness(i,:) ~=0));
    end
    fitness(i,2) = i;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LET THE HUNGER GAMES BEGIN!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%perform tournament selection for mother and father chromosomes
tournament_size = 0.5*generation_size;
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

        %create next generation chromo matrix
        next_gen_chromos(counter_3,:)=child_1;
        [next_gen_obj_funcs(counter_3,1),next_gen_obj_funcs(counter_3,2)] = AoEModel_2Obj(child_1);
        next_gen_obj_funcs(counter_3,3)=generation_size+counter_3;
        next_gen_chromos(counter_3+1,:)=child_2;
        [next_gen_obj_funcs(counter_3+1,1),next_gen_obj_funcs(counter_3+1,2)] = AoEModel_2Obj(child_2);
        next_gen_obj_funcs(counter_3+1,3)=1+generation_size+counter_3;
    end

    %create next generation fitnesses
    next_gen_f1 = next_gen_obj_funcs(:,1);
    next_gen_f2 = next_gen_obj_funcs(:,2);

    next_gen_find_fitness = zeros(length(next_gen_f1),length(next_gen_f2));
    next_gen_fitness = zeros(length(next_gen_f1),2);

    for i=1:length(next_gen_f1)
        for k=1:length(next_gen_f2)
            next_gen_find_fitness(i,k) = min(next_gen_f1(i)-next_gen_f1(k),next_gen_f2(i)-next_gen_f2(k));
        end
        if ~isempty(find(next_gen_find_fitness(i,:)~=0,2,'first'))
            if (max(next_gen_find_fitness(i,next_gen_find_fitness(i,:) ~=0)) <0 && length(find(next_gen_find_fitness(i,:)==0,2,'first'))>1)
                next_gen_fitness(i,1) = 0;
            else
                next_gen_fitness(i,1) = max(next_gen_find_fitness(i,next_gen_find_fitness(i,:) ~=0));
            end
        else
            next_gen_fitness(i,1)=0;
        end
        next_gen_fitness(i,2) = generation_size+i;
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
end

max(fitness);

final_f=zeros(generation_size,2);
    
%plot final design points
for final_counter=1:size(generation_chromos,1)
    [military_spend,vils]=AoEModel_2Obj(generation_chromos(final_counter,:));
    final_f(final_counter,1)=military_spend;
    final_f(final_counter,2)=vils;
end


plot(final_f(:,2),final_f(:,1),'k*')
axis([0 max(final_f(:,2))+5 0 max(final_f(:,1))+100])
%I just put this in so you can run the optimal chromosome and see how many
%of each unit got trained, etc.
[military_spend,vils]=AoEModel_2Obj(generation_chromos(end,:));

sortrows(final_f,1)