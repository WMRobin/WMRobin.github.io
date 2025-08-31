# ============================================================================ #
# SET PARAMETERS ============================================================= #
# ============================================================================ #

# set your directories
indir = "./";  # this director holds the input CSV file
outdir = "./"; # this is where the allocation file will be saved

# name of csv file
# filename = "example-preferences.csv";
filename = "example-preferences2.csv";

# ============================================================================ #
# YOU ARE NOT REQUIRED TO EDIT ANYTHING BELOW THIS LINE ====================== #
# ============================================================================ #

using CSV
using DataFrames
import Combinatorics
import Random

# Set the seed for reproducibility
Random.seed!(42);

# read data
prefs = CSV.read(indir * filename, DataFrame);

# identify individuals
individuals = collect(names(prefs));

# convert data to dictionary
preferences = Dict{String,Vector{String}}();
objects = Set();
for i in 1:size(prefs, 2)
    preferences[names(prefs)[i]] = collect(prefs[!, i])
    objects = union(objects, Set(preferences[names(prefs)[i]]))
end
objects = sort(collect(objects));

# ============================================================================ #
# DESCRIPTIVES =============================================================== #
# ============================================================================ #

i = 1
preferences[individuals[i]]
objects

current_prefs = preferences[individuals[i]]
argmin(current_prefs == "a")
argmin(current_prefs == "b")
argmin(current_prefs == "c")

# initialize ranking matrix
ranks = zeros(Int, length(objects), length(objects))

# loop through data, counting each time object j is given rank k
for i in 1:length(individuals)
    current_prefs = preferences[individuals[i]]
    for j in 1:length(objects)
        rank_j = findfirst(x -> x .== objects[j], current_prefs)
        ranks[rank_j, j] += 1
    end
end

# format for saving as CSV
ranks_df = DataFrame(ranks, objects)
ranks_df[!, :rank] = 1:length(objects)
select!(ranks_df, :rank, :)

# save this as CSV
CSV.write(outdir * "rank-counts.csv", ranks_df);

# ============================================================================ #
# FUNCTIONS ================================================================== #
# ============================================================================ #

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

function calculate_payoffs(allocation, preferences, max_payoff)
    individuals = collect(keys(preferences))
    v = 0
    for ind in individuals
        v += max_payoff - findfirst(x -> x .== allocation[ind], preferences[ind])
    end
    return v
end

# ============================================================================ #
# SERIAL DICTATOR ALGORITHM ================================================== #
# ============================================================================ #

# how many more people are there than objects?
surplus_people = length(individuals) - length(objects);

# the maximum payoff is the number of objects plus one
max_payoff = length(objects) + 1;

# allocate the goods to the individuals in all possible orders
allocations = Dict();
for order in collect(Combinatorics.permutations(1:length(individuals)))
    println("order: $order")
    allocations[order] = serial_dictator(preferences, objects, order, surplus_people)
    println("")
end

# collect the orders that identify allocations
orders = collect(keys(allocations));

# calculate the payoff for each order
payoffs = Dict();
for order in collect(keys(allocations))
    println("Order: $order")
    payoffs[order] = calculate_payoffs(allocations[order], preferences, max_payoff)
    println("payoff: $(payoffs[order])\n")
end

# identify the orders that give maximum payoff
max_orders = orders[findall(x -> payoffs[x] .== maximum(values(payoffs)), orders)];
# if more than one, return all? default is to use lottery to choose one
return_all = false;
if length(max_orders) == 1
    # if there is a unique optimal order, choose it
    optimal_order = max_orders[1]
    optimal_allocation = allocations[optimal_order]
elseif length(max_orders) > 1 && return_all
    # if there are multiple optimal orders, return all
    optimal_allocation = Dict()
    for order in max_orders
        optimal_allocation[order] = allocations[order]
    end
elseif length(max_orders) > 1 && !return_all
    # if there are multiple optimal orders, choose one at random
    optimal_order = max_orders[rand(1:length(max_orders))]
    optimal_allocation = allocations[optimal_order]
end

# save the optimal allocation to a CSV file
CSV.write(outdir * "serial-dictator-allocation.csv", DataFrame(optimal_allocation));
