require "rubygems"
require "ai4r/genetic_algorithm/genetic_algorithm"
require "gnuplot"
benefits = [
  [0,0,0,0],
  [0.28,0.25,0.15,0.20],
  [0.45,0.41,0.25,0.33],
  [0.65,0.55,0.40,0.42],
  [0.78,0.65,0.50,0.48],
  [0.90,0.75,0.62,0.53],
  [1.02,0.80,0.73,0.56],
  [1.13,0.85,0.82,0.58],
  [1.23,0.88,0.90,0.60],
  [1.32,0.90,0.96,0.60],
  [1.38,0.90,1.00,0.60]
]

class Ai4r::GeneticAlgorithm::GeneticSearch

  def run
    x = []
    y = []
    generate_initial_population                    #Generate initial population 
    @max_generation.times do |i|
      selected_to_breed = selection                #Evaluates current population 
      offsprings = reproduction selected_to_breed  #Generate the population for this new generation
      replace_worst_ranked offsprings
      x << i+1
      y << best_chromosome.fitness
    end
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|

        plot.title  "TP2"
        plot.ylabel "Fitness"
        plot.xlabel "Generacion"

        plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
          ds.with = "linespoints"
          ds.notitle
        end
      end
    end
    best_chromosome
  end
  def selection
    @population.sort! { |a, b| b.fitness <=> a.fitness}
    best_fitness = @population[0].fitness
    worst_fitness = @population.last.fitness
    acum_fitness = 0
    if best_fitness-worst_fitness > 0
      @population.each do |chromosome| 
        chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/(best_fitness-worst_fitness)
        acum_fitness += chromosome.normalized_fitness
      end
    else
      @population.each { |chromosome| chromosome.normalized_fitness = 1}  
    end
    selected_to_breed = []
    ((2*@population_size)/3).times do |i|
      selected_to_breed << @population[i]
    end
    selected_to_breed
  end
end
class Ai4r::GeneticAlgorithm::Chromosome
  @@benefits = [
    [0,0,0,0],
    [0.28,0.25,0.15,0.20],
    [0.45,0.41,0.25,0.33],
    [0.65,0.55,0.40,0.42],
    [0.78,0.65,0.50,0.48],
    [0.90,0.75,0.62,0.53],
    [1.02,0.80,0.73,0.56],
    [1.13,0.85,0.82,0.58],
    [1.23,0.88,0.90,0.60],
    [1.32,0.90,0.96,0.60],
    [1.38,0.90,1.00,0.60]
  ]

  def fitness
    ganancias = 0
    suma = @data.inject(0,:+)
    @data.each_with_index do |el, i|
      ganancias += @@benefits[el][i]
    end
    ganancias = ganancias / ( 500 * (suma-10).abs + 1)
    @fitness = ganancias
  end

  def self.seed
    return self.new(Array.new(4).collect { |el| r = rand(11) })
  end

  def self.reproduce(a,b)
    rep = Array.new(a.data)
    rep[1] = b.data[1]
    rep[2] = b.data[2]
    return self.new(rep) 
  end
end

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(500, 50)
result = search.run
result.data.each_with_index {|r,i| puts "Region#{i+1}: #{r} #{r ==1 ? 'millon': 'millones'}"}
ganancias = 0
suma = result.data.inject(0,:+)
result.data.each_with_index do |el, i|
  ganancias += benefits[el][i]
end
ganancias = ganancias / ( 500 * (suma-10).abs + 1)
puts "Ganancia: #{ganancias}"
