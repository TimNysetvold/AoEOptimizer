%This script performs an optimizing real-value genetic algorithm seeking to 
%maximize the amount of military spending during the first 15 minutes of an
%Age of Empires II game.

clc
clear

chromosome_size = 49;
generation_size = 10;


generation_chromos = zeros(generation_size,chromosome_size);
fitness = zeros(generation_size,1);

%populate first generation chromosomes and fitness values
%there are no external constraints, so the fitness value is simply the
%value of the objective function, 'military_spend'
for i=1:size(generation_chromos,1)
    chromosome = ChromosomeGenerator();
    generation_chromos(i,:) = chromosome;
    fitness(i) = AoEModel(chromosome);
end

%perform tournament selection for mother and father chromosomes
tournament_size = 3;

for j=1:2
    %randomly select chromosomes
    rand_chromo_nums = randperm(generation_size,tournament_size);

    tournament_chromos = zeros(tournament_size,chromosome_size);
    tournament_fitnesses = zeros(tournament_size,1);
    for i=1:tournament_size
        tournament_chromos(i,:) = generation_chromos(rand_chromo_nums(i),:);
        tournament_fitnesses(i) = fitness(rand_chromo_nums(i));
    end

    %determine champion chromosome
    highest_tournament_fitness = max(tournament_fitnesses);
    highest_fitness_chromos = [];

    for i=1:tournament_size
        if tournament_fitnesses(i)==highest_tournament_fitness
            highest_fitness_chromos=[highest_fitness_chromos,rand_chromo_nums(i)];
        end
    end

    if length(highest_fitness_chromos)==1
        if j==1
            mother_chromo = generation_chromos(highest_fitness_chromos(1),:);
        elseif j==2
            father_chromo = generation_chromos(highest_fitness_chromos(1),:);
        end
    elseif length(highest_fitness_chromos)>1
        if j==1
            mother_chromo = generation_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
        elseif j==2
            father_chromo = generation_chromos(highest_fitness_chromos(randperm(length(highest_fitness_chromos),1)),:);
        end
    end
end
