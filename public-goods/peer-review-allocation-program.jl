using CSV

# ===================================== #
# =============== SETUP =============== #
# ===================================== #

objects = ["a","b","c"];
individuals = ["p1", "p2", "p3", "p4"];

# Define the preferences of each individual over the goods
preferences = Dict(
    "p1" => ["a", "b", "c"],
    "p2" => ["c", "a", "b"],
    "p3" => ["c", "a", "b"],
    "p4" => ["b", "a", "c"]
)

function calculate_payoff(allocation, preferences, max_payoff)
    return max_payoff - findfirst(x -> x .== allocation, preferences)
end

# =================================================== #
# =============== SERIAL DICTATORSHIP =============== #
# =================================================== #

function serial_dictator(preferences, objects, order, surplus_people)
    allocation = Dict()
    available_goods = Set(objects)
    unused_goods = Set(objects)
    used_goods = Set()
    multi_count = 0

    for i in 1:length(order)
        ind = individuals[order[i]]
        for preferred_good in preferences[ind]
            if preferred_good in available_goods
                allocation[ind] = preferred_good
                println("Individual $ind gets good $preferred_good")
                delete!(unused_goods, preferred_good)
                
                if preferred_good in used_goods
                    multi_count += 1
                end
                
                push!(used_goods, preferred_good)
                
                # once we have allocated to all surplus people, we can allocate the rest of the goods
                if multi_count >= surplus_people
                    available_goods = unused_goods
                end
                
                break
            end
        end
    end

    return allocation
end

surplus_people = length(individuals) - length(objects);

order = [1,2,3,4];

serial_dictator_allocation = serial_dictator(preferences, objects, order, surplus_people);

serial_dictator_payoff = Dict();

for ind in individuals
    serial_dictator_payoff[ind] = calculate_payoff(serial_dictator_allocation[ind], preferences[ind], length(objects))
    println("Individual $ind has payoff $(serial_dictator_payoff[ind])")
end
