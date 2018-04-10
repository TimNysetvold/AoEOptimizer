function [zz_military_spend,zz_vils] = AoEModel(chromosome)
%Rationale: In AoE, it is widely accepted that during the first 15 minutes
%of the game, a player should create villagers constantly. How these
%villagers are distributed determines the total amount of resources that
%can be spent on military units, which is how the game is won. In this
%optimization, we determine which villagers should be allocated to which
%activities to maximize military production.

num_steps = 20*60;
max_Vils=num_steps/25+3; %One vil is created every 25 seconds of game time.
%in 20 minutes, this works out to 48 vils, plus three starting vils.
%However, we will research wheelbarrow (75 sec; -3 vils) and Feudal age
%(130 sec, ~-5 vils), so we should probably actually have a total of 42 vils.
num_buildings=8; %Currently, 8 buildings are implemented
num_techs=8;    %Currently, 8 techs are implemented

%% We will divide the game into 8 equal sections.
% In each section, villagers will be randomly assigned to different
% resources.

num_vil_assignments=8;

for i=1:num_vil_assignments
    vil_assignments{i}=chromosome(max_Vils*(i-1)+1:max_Vils*i);
end
build_times=chromosome(max_Vils*num_vil_assignments+1:max_Vils*num_vil_assignments+num_buildings);
tech_times=chromosome(max_Vils*num_vil_assignments+num_buildings+1:max_Vils*num_vil_assignments+num_buildings+num_techs);


%% start static model


num_steps = 20*60;
tick_time = 1;
pop_cap=0;
zz_vils=3;

tc_occupied=0;
vil_flag=0;

%Resource stockpiles
aa_food_stockpile=300;
aa_wood_stockpile=200;
aa_gold_stockpile=200;
aa_stone_stockpile=200;
build_vils_occupied=0;
build_vils_available=0;

free_food_gen_total=0;
farm_food_gen_total=0;

%general interest:
house_turns=[];

%Villager gather rates per 25 seconds
free_food_gather=.32; %Food is treated differently than other resources; the .8 accounts for not having a mill at the start
farm_gather=.36*.9; %An assumed slight reduction is included for farm build time
wood_gather=.39;
wood_gather_tc=wood_gather*.7;
gold_gather=.38;
gold_gather_tc=gold_gather*.7;
stone_gather=.36;
stone_gather_tc=stone_gather*.7;

%Tc values are prorated by the walking cost of going back to the TC. The
%applicable value is selected based on if the relevant building has been
%created yet.


num_farms=0;
num_houses=0;
house_flag=0;


blacksmith_occupied=0;
barracks_occupied=0;

zz_military_spend=0;
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
mining=0;
mining_flag=0;

lumber_wood_cost=100;
lumber_build_time=35;
lumber_flag=0;
lumber=0;

mill_wood_cost=100;
mill_build_time=35;
mill=0;
mill_flag=0;

farm_wood_cost=60;
farm_build_time=15;


military_wood_cost=175;
military_build_time=50;
archery=0;
archery_flag=0;
archery_occupied=0;
barracks=0;
barracks_flag=0;
barracks_occupied=0;
stable=0;
stable_flag=0;
stable_occupied=0;

blacksmith_wood_cost=150;
blacksmith_build_time=40;
blacksmith=0;
blacksmith_occupied=0;
blacksmith_flag=0;

feudal_food_cost=500;
feudal=0;
feudal_time=0;
feudal_research_time=130;
feudal_flag=0;

wheelbarrow_food_cost=175;
wheelbarrow_wood_cost=50;
wheelbarrow=0;
wheelbarrow_time=0;
wheelbarrow_research_time=75; %75 seconds
wheelbarrow_flag=0;

scale_mail_tech=0;
scale_mail_flag=0;
scale_mail_food_cost=100;
scale_mail_time_cost=50; %actually 40; close enough

scale_barding_tech=0;
scale_barding_flag=0;
scale_barding_food_cost=150;
scale_barding_time_cost=50; %actually 45; close enough

fletching_tech=0;
fletching_food_cost=100;
fletching_gold_cost=50;
fletching_time_cost=25; %actually 30; close enough
fletching_flag=0;

pad_archer_tech=0;
pad_archer_food_cost=100;
pad_archer_time_cost=50; %actually 40; close enough
pad_archer_flag=0;

forging_tech=0;
forging_food_cost=150;
forging_time_cost=50; %actually 50
forging_flag=0;

MaA_tech_food_cost=200;
MaA_tech_gold_cost=65;
MaA_tech_time_cost=50; %Actually 45; Close enough to 50 to make no difference
MaA_tech_turn=[];
MaA_tech=0;

vil_food_cost=50;
vil_build_time=25;


MaA_food_cost=60;
MaA_gold_cost=20;
MaA_build_time=21; %Actually 21; Close enough to 25 to make no difference
MaA_turn=[];

spearman_food_cost=35;
spearman_wood_cost=25;
spearman_build_time=22; %Actually 22; Close enough to 25 to make no difference

archer_wood_cost=25;
archer_gold_cost=45;
archer_build_time=35; %actually 35

skirm_food_cost=25;
skirm_wood_cost=35;
skirm_build_time=22; %Actually 22

sc_food_cost=80;
sc_build_time=30; %actually 30,



%%Begin vil assignments
vil_assignment_counter=1;


for step=1:num_steps-1
    
    if mod(step,num_steps/num_vil_assignments)==0
        vil_assignment_counter=vil_assignment_counter+1;
        %%Reassign vil counts, maybe? I think that can be done other places
    end
    
    %% Instantiation step
    %In this step, all the units, buildings, and technologies
    %that have been queued and finished are instantated.
    if (tc_occupied==0)
        if (vil_flag==1)
            zz_vils=zz_vils+1;
            vil_flag=0;
        elseif (feudal_flag==1)
            feudal=1;
            feudal_time=step;
        elseif (wheelbarrow_flag==1)
            wheelbarrow=1;
            wheelbarrow_flag=0;
            wheelbarrow_time=step;
            free_food_gather=free_food_gather*1.2;
            farm_gather=farm_gather*1.2;
            wood_gather=wood_gather*1.2;
            gold_gather=gold_gather*1.2;
            stone_gather=stone_gather*1.2;
        end
    end
    
    if (house_flag==1)&&(house_time_left==0)
        num_houses=num_houses+1;
        house_flag=0;
        build_vils_occupied=build_vils_occupied-1;
    elseif (house_flag==1)&&(house_time_left>0)
        house_time_left=house_time_left-1;
    end
    
    if (mill_flag==1)&&(mill_time_left==0)
        mill_flag=0;
        mill=1;
        free_food_gather=free_food_gather*1.2;
        farm_gather=farm_gather*1.1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (mill_flag==1)&&(mill_time_left>0)
        mill_time_left=mill_time_left-1;
    end
    
    if (lumber_flag==1)&&(lumber_time_left==0)
        lumber_flag=0;
        lumber=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (lumber_flag==1)&&(lumber_time_left>0)
        lumber_time_left=lumber_time_left-1;
    end
        
    if (mining_flag==1)&&(mining_time_left==0)
        mining_flag=0;
        mining=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (mining_flag==1)&&(mining_time_left>0)
        mining_time_left=mining_time_left-1;
    end
    
    
    if (barracks_flag==1)&&(barracks_time_left==0)
        barracks_flag=0;
        barracks=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (barracks_flag==1)&&(barracks_time_left>0)
        barracks_time_left=barracks_time_left-1;
    end
    
    if (archery_flag==1)&&(archery_time_left==0)
        archery_flag=0;
        archery=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (archery_flag==1)&&(archery_time_left>0)
        archery_time_left=archery_time_left-1;
    end
    
    if (stable_flag==1)&&(stable_time_left==0)
        stable_flag=0;
        stable=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (stable_flag==1)&&(stable_time_left>0)
        stable_time_left=stable_time_left-1;
    end
    
    if (blacksmith_flag==1)&&(blacksmith_time_left==0)
        blacksmith_flag=0;
        blacksmith=1;
        build_vils_occupied=build_vils_occupied-1;
    elseif (blacksmith_flag==1)&&(blacksmith_time_left>0)
        blacksmith_time_left=blacksmith_time_left-1;
    end
    
    if (blacksmith==1)&&(blacksmith_occupied==0)
        if (pad_archer_flag==1)
            pad_archer_tech=1;
        end
        if (fletching_flag==1)
            fletching_tech=1;
        end
        if (forging_flag==1)
            forging_tech=1;
        end
        if (scale_barding_flag==1)
            scale_barding_tech=1;
        end
        if (scale_mail_flag==1)
            scale_mail_tech=1;
        end
    end
    
    
    
    %% Town Center step
    %First, we check if the TC is currently producing something.
    %Afterwards, we check if we can research the feudal age. Then, we check
    %wheelbarrow. Finally, we attempt to build a vil.
    
    if tc_occupied>0
        tc_occupied=tc_occupied-1;
    else
        if(feudal==0)&&(feudal_flag==0)&&(step>=tech_times(1))
        %try to advance to feudal age if the chromosome says to, and we
        %have not already done so and aren't trying
            if (aa_food_stockpile>=feudal_food_cost)
                aa_food_stockpile=aa_food_stockpile-feudal_food_cost;
                tc_occupied=feudal_research_time;
                feudal_flag=1;
            end
        end
        if(wheelbarrow==0)&&(wheelbarrow_flag==0)&&(feudal==1)&&(step>=tech_times(2))&&(tc_occupied==0)
            %try to research wheelbarrow, if appropriate
            if (aa_food_stockpile>=wheelbarrow_food_cost)&&...
                    (aa_wood_stockpile>=wheelbarrow_wood_cost)&&...
                    (feudal==1)
                wheelbarrow_flag=1;
                aa_food_stockpile=aa_food_stockpile-wheelbarrow_food_cost;
                aa_wood_stockpile=aa_wood_stockpile-wheelbarrow_wood_cost;
                tc_occupied=wheelbarrow_research_time;
            end
        end
        if (aa_food_stockpile>=50)&&(tc_occupied==0)
            if (pop_cap~=1)
                vil_flag=1;
                tc_occupied=vil_build_time;
                aa_food_stockpile=aa_food_stockpile-50; %villager cost
            end
        end
    end
    
    %% Start house script
    
    %We allow the computer to build a house immediately. No time
    %requirement; this is not a variable (would create too many infeasible
    %designs).
    if(num_houses==0)
        if (aa_wood_stockpile>=house_wood_cost)&&build_vils_available>0
            house_flag=1;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            house_turns=[house_turns,step];
            aa_wood_stockpile=aa_wood_stockpile-house_wood_cost;
            house_time_left=house_build_time;
        else
            %nothing; no house is built
        end
    %After the first house is built, we examine whether we should build another
    %house at every step
    elseif(num_houses*5-zz_vils<=3)&&house_flag==0
        %there are less than three empty population slots; try to build a
        %house
        if (aa_wood_stockpile>=house_wood_cost)&&(build_vils_available>0)
            house_flag=1;
            house_turns=[house_turns,step];
            aa_wood_stockpile=aa_wood_stockpile-house_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            house_time_left=house_build_time;
        end
    end
    
    if (num_houses>1)&&(num_houses*5<=(zz_vils+num_mil))
        pop_cap=1;
    else
        pop_cap=0;
    end 
    
    %% Start chromosome-based build timing   
    %We examine when it is appropriate to build a farm. After we have built
    %the first farm, we will try to build another every time all farms are
    %occupied. Farm build time is rolled into the farm production rate;
    %farms do not affect build vils.
    if(num_farms==0)&&(step>=build_times(4))
        if (aa_wood_stockpile>=farm_wood_cost)
            num_farms=1;
            aa_wood_stockpile=aa_wood_stockpile-farm_wood_cost;
        end
    elseif(num_farms>0)&&(1>=num_farms-a_num_vil_farm)
        %If there is less than one spare farm, build another one
        if (aa_wood_stockpile>=farm_wood_cost)
            num_farms=num_farms+1;
            aa_wood_stockpile=aa_wood_stockpile-farm_wood_cost;
        end
    end
    
    %a mill, next to the berries
    if(mill_flag==0)&&(step>=build_times(1))&&(mill==0)
        if (aa_wood_stockpile>=mill_wood_cost)&&(build_vils_available>0)
            mill_flag=1;    
            aa_wood_stockpile=aa_wood_stockpile-mill_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            mill_time_left=mill_build_time;
        end
    end
    
    if(lumber_flag==0)&&(step>=build_times(2))&&(lumber==0)
        if (aa_wood_stockpile>=lumber_wood_cost)&&(build_vils_available>0)
            lumber_flag=1;
            aa_wood_stockpile=aa_wood_stockpile-lumber_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            lumber_time_left=lumber_build_time;
        end
    end

    if(mining_flag==0)&&(mining==0)&&(step>=build_times(3))
        if (aa_wood_stockpile>=mining_wood_cost)&&(build_vils_available>0)
            mining_flag=1;
            aa_wood_stockpile=aa_wood_stockpile-mining_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            mining_time_left=mining_build_time;
        end
    end
    
    if(barracks_flag==0)&&(barracks==0)&&(step>=build_times(6))
        if (aa_wood_stockpile>=military_wood_cost)&&(build_vils_available>0)
            barracks_flag=1;
            barracks_turn=step;
            aa_wood_stockpile=aa_wood_stockpile-military_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            barracks_time_left=military_build_time;
            
            zz_military_spend=zz_military_spend+military_wood_cost;
        end
    end
        
    if(archery_flag==0)&&(archery==0)&&(barracks==1)&&(feudal==1)&&(step>=build_times(7))
        if (aa_wood_stockpile>=military_wood_cost)&&(build_vils_available>0)
            archery_flag=1;
            aa_wood_stockpile=aa_wood_stockpile-military_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            archery_time_left=military_build_time;
            
            zz_military_spend=zz_military_spend+military_wood_cost;
        end
    end
    
    if(stable_flag==0)&&(stable==0)&&(barracks==1)&&(feudal==1)&&(step>=build_times(8))
        if (aa_wood_stockpile>=military_wood_cost)&&(build_vils_available>0)
            stable_flag=1;
            aa_wood_stockpile=aa_wood_stockpile-military_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            stable_time_left=military_build_time;
            
            zz_military_spend=zz_military_spend+military_wood_cost;
        end
    end
    
    if(blacksmith_flag==0)&&(blacksmith==0)&&(feudal==1)&&(step>=build_times(5))
        if (aa_wood_stockpile>=blacksmith_wood_cost)&&(build_vils_available>0)
            blacksmith_flag=1;
            aa_wood_stockpile=aa_wood_stockpile-blacksmith_wood_cost;
            build_vils_occupied=build_vils_occupied+1;
            build_vils_available=build_vils_available-1;
            blacksmith_time_left=blacksmith_build_time;
            
            zz_military_spend=zz_military_spend+blacksmith_wood_cost;
        end
    end
    
    
    
    
    
    %% Start military spend script
   
    if (barracks==1)&&(barracks_occupied==0)
         if (aa_food_stockpile>=MaA_tech_food_cost)&&(MaA_tech==0)&&(step>=tech_times(8))
            MaA_tech=1;
            aa_food_stockpile=aa_food_stockpile-MaA_tech_food_cost;
            aa_gold_stockpile=aa_gold_stockpile-MaA_tech_gold_cost;
            zz_military_spend=zz_military_spend+MaA_tech_food_cost+MaA_tech_gold_cost;
            barracks_occupied=MaA_tech_time_cost/tick_time;
        end
        if (pop_cap~=1)
            if (aa_gold_stockpile>=MaA_gold_cost)&&(aa_food_stockpile>=MaA_food_cost)
                num_MaA=num_MaA+1;
                aa_gold_stockpile=aa_gold_stockpile-MaA_gold_cost;
                aa_food_stockpile=aa_food_stockpile-MaA_food_cost;
                MaA_turn=[MaA_turn,step];
                barracks_occupied=MaA_build_time/tick_time;
                zz_military_spend=zz_military_spend+MaA_food_cost+MaA_gold_cost;
            elseif (aa_wood_stockpile>=spearman_wood_cost)&&(aa_food_stockpile>=spearman_food_cost)
                num_spearmen=num_spearmen+1;
                aa_wood_stockpile=aa_wood_stockpile-spearman_wood_cost;
                aa_food_stockpile=aa_food_stockpile-spearman_food_cost;
                barracks_occupied=spearman_build_time/tick_time;
                zz_military_spend=zz_military_spend+spearman_wood_cost+spearman_food_cost;
            end
        end
    elseif (barracks==1)&&(barracks_occupied>0)
        barracks_occupied=barracks_occupied-1;
    end
    
    if (stable==1)&&(stable_occupied==0)
        if (pop_cap~=1)
            if (aa_food_stockpile>=sc_food_cost)
                num_sc=num_sc+1;
                aa_food_stockpile=aa_food_stockpile-sc_food_cost;
                stable_occupied=sc_build_time/tick_time;
                zz_military_spend=zz_military_spend+sc_food_cost;
            end
        end
    elseif (stable==1)&&(stable_occupied>0)
        stable_occupied=stable_occupied-1;
    end
    
    if (archery==1)&&(archery_occupied>0)
        if (pop_cap~=1)
            if (aa_gold_stockpile>=archer_gold_cost)&&(aa_wood_stockpile>=archer_wood_cost)
                num_archer=num_archer+1;
                aa_gold_stockpile=aa_gold_stockpile-archer_gold_cost;
                aa_wood_stockpile=aa_wood_stockpile-archer_wood_cost;
                archery_occupied=archer_build_time/tick_time;
                zz_military_spend=zz_military_spend+archer_wood_cost+archer_gold_cost;
            elseif (aa_wood_stockpile>=skirm_wood_cost)&&(aa_food_stockpile>=skirm_food_cost)
                num_skirms=num_skirms+1;
                aa_wood_stockpile=aa_wood_stockpile-skirm_wood_cost;
                aa_food_stockpile=aa_food_stockpile-skirm_food_cost;
                archery_occupied=skirm_build_time/tick_time;
                zz_military_spend=zz_military_spend+skirm_wood_cost+skirm_food_cost;
            end
        end
    elseif (archery==1)&&(archery_occupied>0)
        archery_occupied=archery_occupied-1;
    end
    
    
    if (blacksmith==1)&&(blacksmith_occupied==0)
        if (aa_food_stockpile>=pad_archer_food_cost)&&(pad_archer_tech)==0&&(step>=tech_times(3))&&(blacksmith_occupied==0)
            aa_food_stockpile=aa_food_stockpile-pad_archer_food_cost;
            zz_military_spend=zz_military_spend+pad_archer_food_cost;
            blacksmith_occupied=pad_archer_time_cost/tick_time;
            pad_archer_flag=1;
        end
        if (aa_food_stockpile>=fletching_food_cost)&&(aa_gold_stockpile>=fletching_gold_cost)&&(fletching_tech)==0&&(step>=tech_times(4))&&(blacksmith_occupied==0)
            fletching_flag=1;
            aa_food_stockpile=aa_food_stockpile-fletching_food_cost;
            aa_gold_stockpile=aa_gold_stockpile-fletching_gold_cost;
            zz_military_spend=zz_military_spend+fletching_food_cost+fletching_gold_cost;
            blacksmith_occupied=fletching_time_cost/tick_time;
        end
        if (aa_food_stockpile>=forging_food_cost)&&(forging_tech)==0&&(step>=tech_times(5))&&(blacksmith_occupied==0)
            forging_flag=1;
            aa_food_stockpile=aa_food_stockpile-forging_food_cost;
            zz_military_spend=zz_military_spend+forging_food_cost;
            blacksmith_occupied=forging_time_cost/tick_time;
        end
        if (aa_food_stockpile>=scale_barding_food_cost)&&(scale_barding_tech)==0&&(step>=tech_times(6))&&(blacksmith_occupied==0)
            scale_barding_flag=1;
            aa_food_stockpile=aa_food_stockpile-scale_barding_food_cost;
            zz_military_spend=zz_military_spend+scale_barding_food_cost;
            blacksmith_occupied=scale_barding_time_cost/tick_time;
        end
        if (aa_food_stockpile>=scale_mail_food_cost)&&(scale_mail_tech)==0&&(step>=tech_times(7))&&(blacksmith_occupied==0)
            scale_mail_flag=1;
            aa_food_stockpile=aa_food_stockpile-scale_mail_food_cost;
            zz_military_spend=zz_military_spend+scale_mail_food_cost;
            blacksmith_occupied=scale_mail_time_cost/tick_time;
        end
        
    elseif (blacksmith==1)&&(blacksmith_occupied==1)
        blacksmith_occupied=blacksmith_occupied-1;
    end
    
    num_mil=num_skirms+num_archer+num_sc+num_MaA+num_spearmen;

    
    %% calculates the resources generated in a time period 
    
%     try vil_assignments{vil_assignment_counter}(1:zz_vils);
%         
%     catch fail
%         fail=1;
%     end
    
    a_num_vil_wood=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==3));
    a_num_vil_gold=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==4));
    a_num_vil_stone=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==5));
    a_num_vil_build=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==6));
    build_vils_available=a_num_vil_build-build_vils_occupied;
    
    %food gatherers are more complicated; they may require farms. 
    %If we do not have enough, we re-route vils to free food, if 
    %possible. If we do not have free food left, then we try to put people
    %on farms. Any who don't have farms will sit idle until they get some.
    
    a_num_vil_free_food=0;
    a_num_vil_farm=0;
    
    num_proposed_vil_farm=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==2));
    num_proposed_vil_free_food=numel(find(vil_assignments{vil_assignment_counter}(1:zz_vils)==1));    
    
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
            %vils that can't get food go to wood
        else
            a_num_vil_farm=num_farms;
            a_num_vil_wood=a_num_vil_wood+num_proposed_vil_farm+num_proposed_vil_free_food-num_farms;
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
    aa_food_stockpile=farm_food_gen+free_food_gen+aa_food_stockpile;
    
    %Determine how much wood has been generated this round
    if(lumber==1)
        wood_gen=wood_gather*a_num_vil_wood;
    else
        wood_gen=wood_gather_tc*a_num_vil_wood;
    end
    aa_wood_stockpile=wood_gen+aa_wood_stockpile;
    
    %determine gold generation
    if(mining==1)
        gold_gen=gold_gather*a_num_vil_gold;
    else
        gold_gen=gold_gather_tc*a_num_vil_gold;
    end
    aa_gold_stockpile=gold_gen+aa_gold_stockpile;
    
    %determine stone generation
    if(mining==1)
        stone_gen=stone_gather*a_num_vil_stone;
    else
        stone_gen=stone_gather_tc*a_num_vil_stone;
    end
    aa_stone_stockpile=stone_gen+aa_stone_stockpile;
    
        
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




