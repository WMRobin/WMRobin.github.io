using CSV

objects = ["a","b","c"];

p1 = ["b" "c" "a"];
p2 = ["a" "b" "c"];
p3 = ["a" "c" "b"];
p4 = ["b" "c" "a"]
preferences = [p1; p2; p3];

order = [3 2 1];

function serial_dictator(preferences, objects, order)
    # initialize outcome vector -- will be vector of triples
    outcome = [];

    # all objects are available before first move
    available = objects;

    # allocate best available to each person
    for i in 1:length(order)
        # individual's preferences
        preferences_i = preferences[i,:]
        
        for j in 1:length(preferences_i)
            # if the jth object is available, assign it, calculate payoff, and move to next person
            if preferences_i[j] in available
                push!(outcome, (order[i], preferences_i[j], j)) # (individual, allocation, payoff)
                available = setdiff(available, [preferences_i[j]])
                break
            end
        end
    end
    return outcome
end

serial_dictator(preferences, objects, [2 1 3])



preferences = [p1; p2; p3; p4]
# initialize outcome vector -- will be vector of triples
outcome = [];

# all objects are available before first move
available = objects;

order = [1 2 3 4]
# how many more people than objects do we have?
surplus = 1;
objects_surplus = repeat(objects, surplus+1)

outcome = []
available = objects_surplus
allocations = []
payoffs = []
# allocate best available to each person
for i in 1:length(order)
# for i in 1:3
    # individual's preferences
    preferences_i = preferences[i,:]
    
    for j in 1:length(preferences_i)
        # if the jth object is available, assign it, calculate payoff, and move to next person
        if preferences_i[j] in available
        # if occursin(preferences_i[j], available)
            push!(outcome, (order[i], preferences_i[j], j)) # (individual, allocation, payoff)
            push!(allocations, preferences_i[j])
            push!(payoffs, j)
            if length(findall(x -> x == preferences_i[j], allocations)) > surplus
                available = setdiff(available, allocations)
            else
                popat!(available, findall(x -> x == preferences_i[j], available)[1])
            end
            # available = setdiff(available, [preferences_i[j]])
            break
        end
    end
end
outcome
allocations
payoffs