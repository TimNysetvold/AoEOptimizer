function [military_spend,vils] = AoEModel_2Obj(chromosome)
%Rationale: In AoE, it is widely accepted that during the first 15 minutes
%of the game, a player should create villagers constantly. How these
%villagers are distributed determines the total amount of resources that
%can be spent on military units, which is how the game is won. In this
%optimization, we determine which villagers should be allocated to which
%activities to maximize military production.



max_Vils=39; %One vil is created every 25 seconds of game time.
%in 15 minutes, this works out to 36 vils, plus three starting vils.
%However, we will research wheelbarrow (75 sec; -3 vils) and Feudal age
%(130 sec, ~-5 vils), so we should probably actually have a total of 31 vils.
num_buildings=8; %Currently, 8 buildings are implemented
num_techs=2;    %Currently, 2 techs are implemented

vil_assignments=chromosome(1:max_Vils);
build_times=chromosome(max_Vils+1:max_Vils+num_buildings);
tech_times=chromosome(max_Vils+num_buildings+1:max_Vils+num_buildings+num_techs);


%% start static model
total_time=15*60;
tc_occupied=1; %town center is not allowed to produce a villager the first
%round; it must have the first 25 seconds to build the first villager
pop_cap=0;
vils=3;

%Resource stockpiles
food_stockpile=300;
wood_stockpile=200;
gold_stockpile=200;
stone_stockpile=200;
build_stockpile=0;

free_food_gen_total=0;
farm_food_gen_total=0;

%general interest:
house_turns=[];

%Villager gather rates per 25 seconds
free_food_gather=.32*25;
farm_gather=.37*25; %or, perhaps better, 2.92 food per wood
wood_gather=.39*25;
wood_gather_tc=wood_gather*.7;
gold_gather=.38*25;
gold_gather_tc=gold_gather*.7;
stone_gather=.36*25;
stone_gather_tc=stone_gather*.7;

%Tc values are prorated by the walking cost of going back to the TC. The
%applicable value is selected based on if the relevant building has been
%created yet.

mill=0;
mining=0;
lumber=0;
num_farms=0;
archery=0;
barracks=0;
stable=0;
blacksmith=0;
num_houses=0;

feudal=0;
wheelbarrow=0;

military_spend=0;
num_spearmen=0;
num_MaA=0;
num_sc=0;
num_archer=0;
num_skirms=0;


%Costs; found at http://www.salamyhkaiset.org/aoe2/step_2_-_data_tables_and_times
%and http://ageofempires.wikia.com/wiki/Age_of_Empires_Series_Wiki
house_wood_cost=25;
house_build_time=25;

mining_wood_cost=100;
mining_build_time=35;

lumber_wood_cost=100;
lumber_build_time=35;

mill_wood_cost=100;
mill_build_time=35;

farm_wood_cost=60;
farm_build_time=15;

military_wood_cost=175;
military_build_time=50;

blacksmith_wood_cost=150;
blacksmith_build_time=40;

feudal_food_cost=500;

wheelbarrow_food_cost=175;
wheelbarrow_wood_cost=50;

MaA_food_cost=60;
MaA_gold_cost=20;
MaA_build_time=25; %Actually 21; Close enough to 25 to make no difference
MaA_turn=[];

spearman_food_cost=35;
spearman_wood_cost=25;
spearman_build_time=25; %Actually 22; Close enough to 25 to make no difference

archer_wood_cost=25;
archer_gold_cost=45;
archer_build_time=25; %actually 35, which is worryingly high.
%If we have time, we should deal with this somehow

skirm_food_cost=25;
skirm_wood_cost=35;
skirm_build_time=25; %Actually 22; Close enough to 25 to make no difference

sc_food_cost=80;
sc_build_time=25; %actually 30, which is also worryingly high


for step=1:36
    
    %% Villager creation step
    %We attempt to build a villager first thing every step.
    if (tc_occupied==0)&&(food_stockpile>=50)
        if (pop_cap~=1)
            vils=vils+1;
            food_stockpile=food_stockpile-50; %villager cost
        end
    elseif tc_occupied>0
        tc_occupied=tc_occupied-1;
    end
    
    %% Start chromosome-based build timing   
    %We examine when it is appropriate to build a farm. After we have built
    %the first farm, we will try to build another every time all farms are
    %occupied
    if(num_farms==0)&&(step>=build_times(4))
        if (wood_stockpile>=farm_wood_cost)&&(build_stockpile>=farm_build_time)
            num_farms=1;
            wood_stockpile=wood_stockpile-farm_wood_cost;
            build_stockpile=build_stockpile-farm_build_time;
        end
    %After the first house is built, we examine whether we should build another
    %house at every step
    elseif(num_farms>0)&&(1>=num_farms-a_num_vil_farm)
        %If there is less than one spare farm, build another one
        if (wood_stockpile>=farm_wood_cost)&&(build_stockpile>=farm_build_time)
            num_farms=num_farms+1;
            wood_stockpile=wood_stockpile-farm_wood_cost;
            build_stockpile=build_stockpile-farm_build_time;
        end
    end
    
    %a mill, next to the berries
    if(mill==0)&&(step>=build_times(1))
        if (wood_stockpile>=mill_wood_cost)&&(build_stockpile>=mill_build_time)
            mill=1;
            wood_stockpile=wood_stockpile-mill_wood_cost;
            build_stockpile=build_stockpile-mill_build_time;
        end
    end
    
    if(lumber==0)&&(step>=build_times(2))
        if (wood_stockpile>=lumber_wood_cost)&&(build_stockpile>=lumber_build_time)
            lumber=1;
            wood_stockpile=wood_stockpile-lumber_wood_cost;
            build_stockpile=build_stockpile-lumber_build_time;
        end
    end

    if(mining==0)&&(step>=build_times(3))
        if (wood_stockpile>=mining_wood_cost)&&(build_stockpile>=mining_build_time)
            mining=1;
            wood_stockpile=wood_stockpile-mining_wood_cost;
            build_stockpile=build_stockpile-mining_build_time;
        end
    end
    
    if(barracks==0)&&(step>=build_times(6))
        if (wood_stockpile>=military_wood_cost)&&(build_stockpile>military_build_time)
            barracks=1;
            barracks_turn=step;
            wood_stockpile=wood_stockpile-military_wood_cost;
            build_stockpile=build_stockpile-military_build_time;
            military_spend=military_spend+military_wood_cost;
        end
    end
        
    if(archery==0)&&(barracks==1)&&(feudal==1)&&(step>=build_times(7))
        if (wood_stockpile>=military_wood_cost)&&(build_stockpile>military_build_time)
            archery=1;
            wood_stockpile=wood_stockpile-military_wood_cost;
            build_stockpile=build_stockpile-military_build_time;
            military_spend=military_spend+military_wood_cost;
        end
    end
    
    if(stable==0)&&(barracks==1)&&(feudal==1)&&(step>=build_times(8))
        if (wood_stockpile>=military_wood_cost)&&(build_stockpile>military_build_time)
            stable=1;
            wood_stockpile=wood_stockpile-military_wood_cost;
            build_stockpile=build_stockpile-military_build_time;
            military_spend=military_spend+military_wood_cost;
        end
    end
    
    if(blacksmith==0)&&(feudal==1)&&(step>=build_times(5))
        if (wood_stockpile>=blacksmith_wood_cost)&&(build_stockpile>blacksmith_build_time)
            blacksmith=1;
            wood_stockpile=wood_stockpile-blacksmith_wood_cost;
            build_stockpile=build_stockpile-military_build_time;
            military_spend=military_spend+blacksmith_wood_cost;
        end
    end
    
    if(feudal==0)&&(step>=tech_times(1))
        %advance to feudal age
        if (food_stockpile>=feudal_food_cost)
            feudal=1;
            food_stockpile=food_stockpile-feudal_food_cost;
            feudal_time=step;
            
            %Since the TC isn't producing villagers during this time, we
            %don't step. Our already-created villagers, though, still
            %produce resources. The research takes 5 rounds, we've already
            %considered one; we'll now consider 4 more
            tc_occupied=5;
            
        end
    end
    
    if(wheelbarrow==0)&&(feudal==1)&&(step>=tech_times(2))
        
        if (food_stockpile>=wheelbarrow_food_cost)&&...
                (wood_stockpile>=wheelbarrow_wood_cost)&&...
                (feudal==1)
            wheelbarrow=1;
            food_stockpile=food_stockpile-wheelbarrow_food_cost;
            wood_stockpile=wood_stockpile-wheelbarrow_wood_cost;
            free_food_gather=free_food_gather*1.3;
            farm_gather=farm_gather*1.3;
            wood_gather=wood_gather*1.3;
            gold_gather=gold_gather*1.3;
            stone_gather=stone_gather*1.3;
            wheelbarrow_time=step;
            tc_occupied=3;
        end
    end
    
    
    
    %% Start military spend script
    if (barracks==1)
        if (pop_cap~=1)
            if (gold_stockpile>=MaA_gold_cost)&&(food_stockpile>=MaA_food_cost)
                num_MaA=num_MaA+1;
                gold_stockpile==gold_stockpile-MaA_gold_cost;
                food_stockpile==food_stockpile-MaA_food_cost;
                MaA_turn=[MaA_turn,step];
                military_spend=military_spend+MaA_food_cost+MaA_gold_cost;
            elseif (wood_stockpile>=spearman_wood_cost)&&(food_stockpile>=spearman_food_cost)
                num_spearmen=num_spearmen+1;
                wood_stockpile==wood_stockpile-spearman_wood_cost;
                food_stockpile==food_stockpile-spearman_food_cost;
                military_spend=military_spend+spearman_wood_cost+spearman_food_cost;
            end
        end
    end
    
    if (stable==1)
        if (pop_cap~=1)
            if (food_stockpile>=sc_food_cost)
                num_sc=num_sc+1;
                food_stockpile==food_stockpile-sc_food_cost;
                military_spend=military_spend+sc_food_cost;
            end
        end
    end
    
    if (archery==1)
        if (pop_cap~=1)
            if (gold_stockpile>=archer_gold_cost)&&(wood_stockpile>=archer_wood_cost)
                num_archer=num_archer+1;
                gold_stockpile==gold_stockpile-archer_gold_cost;
                wood_stockpile==wood_stockpile-archer_wood_cost;
                military_spend=military_spend+archer_wood_cost+archer_gold_cost;
            elseif (wood_stockpile>=skirm_wood_cost)&&(food_stockpile>=skirm_food_cost)
                num_skirms=num_skirms+1;
                wood_stockpile==wood_stockpile-skirm_wood_cost;
                food_stockpile==food_stockpile-skirm_food_cost;
                military_spend=military_spend+skirm_wood_cost+skirm_food_cost;
            end
        end
    end
    
    num_mil=num_skirms+num_archer+num_sc+num_MaA+num_spearmen;

    
    %% calculates the resources generated in a time period 
    a_num_vil_wood=numel(find(vil_assignments(1:vils)==3));
    a_num_vil_gold=numel(find(vil_assignments(1:vils)==4));
    a_num_vil_stone=numel(find(vil_assignments(1:vils)==5));
    a_num_vil_build=numel(find(vil_assignments(1:vils)==6));
    
    %food gatherers are more complicated; they may require farms. 
    %If we do not have enough, we re-route vils to free food, if 
    %possible. If we do not have free food left, then we try to put people
    %on farms. Any who don't have farms will sit idle until they get some.
    
    a_num_vil_free_food=0;
    a_num_vil_farm=0;
    
    num_proposed_vil_farm=numel(find(vil_assignments(1:vils)==2));
    num_proposed_vil_free_food=numel(find(vil_assignments(1:vils)==1));    
    
    if (free_food_gen_total<1500)
        if (num_proposed_vil_farm<=num_farms)
            a_num_vil_farm=num_proposed_vil_farm;
            a_num_vil_free_food=num_proposed_vil_free_food;
        else
            a_num_vil_farm=num_farms;
            a_num_vil_free_food=num_proposed_vil_free_food+num_proposed_vil_farm-num_farms;
        end
    elseif (free_food_gen_total>=1500)
        if (num_proposed_vil_farm+num_proposed_vil_free_food<=num_farms)
            a_num_vil_farm=num_proposed_vil_farm+num_proposed_vil_free_food;
            a_num_vil_free_food=0;
            a_num_vil_idle=0;
        else
            a_num_vil_farm=num_farms;
            a_num_vil_idle=num_proposed_vil_farm+num_proposed_vil_free_food-num_farms;
            a_num_vil_free_food=0;
        end       
    else
        disp 'broken'
    end
    
    %Determine how much food will be generated this round
    free_food_gen=free_food_gather*a_num_vil_free_food;
    free_food_gen_total=free_food_gen_total+free_food_gen;
    farm_food_gen=farm_gather*a_num_vil_farm;
    farm_food_gen_total=farm_food_gen_total+farm_food_gen;
%     farm_food_available=num_farms*175
    food_stockpile=farm_food_gen+free_food_gen+food_stockpile;
    
    %Determine how much wood has been generated this round
    if(lumber==1)
        wood_gen=wood_gather*a_num_vil_wood;
    else
        wood_gen=wood_gather_tc*a_num_vil_wood;
    end
    wood_stockpile=wood_gen+wood_stockpile;
    
    %determine gold generation
    if(mining==1)
        gold_gen=gold_gather*a_num_vil_gold;
    else
        gold_gen=gold_gather_tc*a_num_vil_gold;
    end
    gold_stockpile=gold_gen+gold_stockpile;
    
    %determine stone generation
    if(mining==1)
        stone_gen=stone_gather*a_num_vil_stone;
    else
        stone_gen=stone_gather_tc*a_num_vil_stone;
    end
    stone_stockpile=stone_gen+stone_stockpile;
    
    %determine build time generation
    build_time_gen=a_num_vil_build*25;
    build_stockpile=build_time_gen+build_stockpile;
    
    
        
    %% Start build script
    
    %We allow the computer to build a house immediately. No time
    %requirement; this is not a variable (would create too many infeasible
    %designs)
    if(num_houses==0)
        if (wood_stockpile>=house_wood_cost)&&(build_stockpile>=house_build_time)
            num_houses=1;
            house_turns=[house_turns,step];
            wood_stockpile=wood_stockpile-house_wood_cost;
            build_stockpile=build_stockpile-house_build_time;
        else
            %nothing; no house is built
        end
    %After the first house is built, we examine whether we should build another
    %house at every step
    elseif(num_houses*5-vils<=3)
        %there are less than three empty population slots; try to build a
        %house
        if (wood_stockpile>=house_wood_cost)&&(build_stockpile>=house_build_time)
            num_houses=num_houses+1;
            house_turns=[house_turns,step];
            wood_stockpile=wood_stockpile-house_wood_cost;
            build_stockpile=build_stockpile-house_build_time;
        end
    end
    
    if (num_houses>1)&&(num_houses*5<=(vils+num_mil))
        pop_cap=1;
    else
        pop_cap=0;
    end
    
    
    
    
end


    %% Constraints
    %currently these are all done implicitly inside the model

    %free_food_generated<1500;
    %population<house*5
    %food_stockpile>0;
    %wood_stockpile>0;
    %stone_stockpile>0;
    %gold_stockpile>0;
    

end




