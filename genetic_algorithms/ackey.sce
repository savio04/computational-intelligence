/*
    Foi obtido ótimos resultados com 50 gerações e uma população de 250 individiduos.
    Os melhores resultados observados foram: x=-0.0109768 e y=0.0471402
*/

clear;
clc;

/* Função ackley */
function result = ackley(x, y)
    term1 = -20 * exp(-0.2 * sqrt(0.5 * (x^2 + y^2)));
    term2 = -exp(0.5 * (cos(2 * %pi * x) + cos(2 * %pi * y)));
    result = term1 + term2 + 20 + exp(1);
endfunction

/* Inicializa a população com valores aleatórios */
function population = initialize_population(population_size, genome_length)
    population = round(rand(population_size, genome_length));
endfunction

/* Função de crossover */
function child = crossover(parent1, parent2)
    crossover_point = ceil(rand() * (size(parent1, 2) - 1));
    child = [parent1(1:crossover_point), parent2(crossover_point+1:$)];
endfunction

/* Função de mutação */
function mutated_child = mutate(child, mutation_rate)
    mutation_mask = rand(size(child)) < mutation_rate;
    mutated_child = child;

    /* Inverte os bits onde a máscara de mutação é verdadeira */
    mutated_child(mutation_mask) = ~mutated_child(mutation_mask);
endfunction

/* Função randsample */
function indices = randsample(population_size, sample_size, probabilities)
    /* Cria uma amostra aleatória com reposição */
    indices = ceil(rand(1, sample_size) * population_size);
    
    /*Se as probabilidades foram fornecidas, ajusta a amostra de acordo*/
    if nargin == 3
        indices = randsample_adjust(indices, probabilities);
    end
endfunction

/* Função auxiliar para ajustar amostra de acordo com as probabilidades*/
function indices = randsample_adjust(indices, probabilities)
    sorted_probs = gsort(probabilities, "g", "i");
    sorted_indices = gsort(indices, "g", "i");
    
    [_, sorted_order] = gsort(sorted_indices, "g", "i");
    
    [_, inverse_order] = gsort(sorted_order, "g", "i");
    
    indices = inverse_order;
endfunction

/* Função para ajustar um valor para um intervalo específico */
function adjusted_value = adjustToInterval(original_value)
    /* Função para ajustar um valor original para o intervalo [-10, 10] */
    
    /* Fator de normalização para garantir que original_value esteja no intervalo [0, 1] */
    normalization_factor = 2^20 - 1;
    
    /* Normaliza original_value para o intervalo [0, 1] */
    normalized_value = original_value / normalization_factor;

    /* Ajusta para o intervalo desejado [-10, 10] */
    adjusted_value = 20 * normalized_value - 10;
endfunction

/* Função para converter binário para decimal */
function decimal_value = binaryToDecimal(binary_vector)
    decimal_value = 0;
    for i = 1:length(binary_vector)
        decimal_value = decimal_value * 2 + binary_vector(i);
    end
endfunction

/* Função para converter decimal para binário */
function binary_vector = decimalToBinary(decimal_value, num_bits)
    binary_vector = zeros(1, num_bits);

    for i = 1:num_bits
        binary_vector(num_bits - i + 1) = mod(decimal_value, 2);
        decimal_value = floor(decimal_value / 2);
    end
endfunction


/* Função principal do algoritmo genético */
function [best_solution, best_fitness] = genetic_algorithm(population_size, generations, mutation_rate)
    genome_length = 40; // 20 bits para x, 20 bits para y
    
    /* Inicializa a população */
    population = initialize_population(population_size, genome_length);
    
    
   /* Avalia o fitness da população inicial */
    fitness_values = zeros(population_size, 1);
    for i = 1:population_size
        x_binary = population(i, 1:20);
        x_decimal = adjustToInterval(binaryToDecimal(x_binary));
        
        /* Converte a parte 'y' de binário para decimal */
        y_binary = population(i, 21:40);
        y_decimal = adjustToInterval(binaryToDecimal(y_binary));
        fitness_values(i) = ackley(x_decimal, y_decimal);
    end
    
    /* Encontra o melhor indivíduo na população inicial */
    [best_fitness, best_index] = min(fitness_values);
    best_solution = population(best_index, :);
    
    /* Itera sobre as gerações */
    for generation = 1:generations
        /* Calcula as probabilidades de seleção para a roleta */
        selection_probabilities = fitness_values / sum(fitness_values);
        
        /* Seleciona pais para reprodução usando o metod da roleta */
        parent_indices = randsample(population_size, population_size, selection_probabilities);
       
        /* Loop para realizar crossover e mutação para gerar descendentes */
        for i = 1:2:population_size
            /* Seleciona os pais */
            parent1 = population(parent_indices(i), :);
            parent2 = population(parent_indices(i+1), :);
    
            /* Realiza crossover e mutação para gerar um descendente */
            child = crossover(parent1, parent2);
            child = mutate(child, mutation_rate);
    
            /* Atribui o descendente aos índices apropriados na matriz offspring */
            offspring(i, :) = child;
            offspring(i+1, :) = child;
        end

        /* Avalia o fitness dos descendentes */
        offspring_fitness = zeros(population_size, 1);
        for i = 1:population_size
            x_binary = offspring(i, 1:20);
            x_decimal = adjustToInterval(binaryToDecimal(x_binary));
            
            /* Converte a parte 'y' de binário para decimal */
            y_binary = offspring(i, 21:40);
            y_decimal =  adjustToInterval(binaryToDecimal(y_binary))
            
            offspring_fitness(i) = ackley(x_decimal, y_decimal);
        end
        
        /* Substitui a população pela união de pais e descendentes */
        combined_population = [population; offspring];
        combined_fitness = [fitness_values; offspring_fitness];
        
        /* Seleciona os melhores indivíduos para a próxima geração */
        [values, indices] = gsort(combined_fitness, "g", "i");
        population = combined_population(indices(1:population_size), :);
        fitness_values = combined_fitness(indices(1:population_size));
        
        /* Atualiza a melhor solução encontrada */
        [best_fitness, best_index] = min(fitness_values);
        best_solution = population(best_index, :);
        
        /* Exibe informações sobre a geração */
        disp(['Geração ', string(generation), ':']);
        disp(['  Nota média: ', string(mean(fitness_values))]);
        disp(['  Nota do pior indivíduo: ', string(max(fitness_values)), ' (', string(max(fitness_values) / sum(fitness_values) * 100), '%)']);
        disp(['  Nota do melhor indivíduo: ', string(best_fitness), ' (', string(best_fitness / sum(fitness_values) * 100), '%)']);
    end
endfunction

/* Teste da função principal */
[best_solution, best_fitness] = genetic_algorithm(250, 50, 0.05);

/* Exibe a melhor solução encontrada */
disp('Melhor solução encontrada:');
disp(['  x: ', string(adjustToInterval(binaryToDecimal(best_solution(1:20))))]);
disp(['  y: ', string(adjustToInterval(binaryToDecimal(best_solution(21:40))))]);
disp(['  f (x, y): ', string(best_fitness)]);
