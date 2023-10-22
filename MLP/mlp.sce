clear;
clc;

/*Carregando os dados do arquivo "column_3C.dat" no formato de string*/
dados_string = csvRead("column_3C.dat", [], [], "string");

/*
   Os dados extraídos da base consistem em 7 colunas e 310 linhas. 
   A última coluna contém rótulos que classificam as entradas em uma das três classes possíveis: DH, SL ou NO. 
   Realizaremos a seguinte transformação na última coluna da base: 
   DH será representado como 1, 
   SL como 2 e NO como 3. 
   Assim, teremos o seguinte mapeamento:

    Classe 1 corresponde a DH.
    Classe 2 corresponde a SL.
    Classe 3 corresponde a NO.
    Para ilustrar, aqui está um exemplo de uma linha de dados:

    Entrada original: "63.03" "22.55" "39.61" "40.48" "98.67" "-0.25" "DH".
    Após a aplicação do mapeamento: 63.03 22.55 39.61 40.48 98.67 -0.25 1.
    
    Dessa forma, os rótulos das classes foram convertidos em valores numéricos 
    para facilitar a análise e o processamento dos dados.
*/

dados_numericos = zeros(size(dados_string, 1), 7); /*Aqui, os dados são armazenados após a aplicação do mapeamento*/

/*Mapeamento das classes*/
for i = 1:size(dados_string, 1)
    words = strsplit(dados_string(i), ' ')';
    
    for j = 1:7
        if strcmp(words(j), "DH") == 0
            words(j) = '1';
        elseif strcmp(words(j), "SL") == 0
            words(j) = '2';
        elseif strcmp(words(j), "NO") == 0
            words(j) = '3';
        end
    end
    
    numbers = strtod(words);

    dados_numericos(i, :) = numbers;
end

atributos = dados_numericos(:, 1:6)'; /*Matriz com os atributos*/
rotulos = dados_numericos(:, 7)' /*Matriz com os rotulos*/

/*
    Codificação das classes:
    
    Classe 1 vai ser representada por [1 0 0]
    Classe 2 vai ser representada por [0 1 0]
    Classe 3 vai ser representada por [0 0 1]
*/
descritor = zeros(3, 310);

for i = 1:size(dados_numericos)(1)
    select rotulos(i)
    case 1
        descritor(:, i) = [1 0 0]';
    case 2
        descritor(:, i) = [0 1 0]';
    case 3
        descritor(:, i) = [0 0 1]';
    end
end

/*Normalizando atributos utilizando z-score*/
for i = 1:6
    atributos(i, :) = (atributos(i, :) - mean(atributos(i, :)))/stdev(atributos(i, :));
end

/*
    A camada de entrada tem 6 neurônios – um neurônio para cada atributo.
    A camada de saída possui 3 neurônios – um neurônio para cada classe.
    A camada oculta tem 10 neurônios.
*/
N = [6 10 3];

/*Os pesos das conexões entre os neurônios são inicializados*/
W = ann_FF_init(N);

/*Parâmetros de treinamento: taxa de aprendizado e o limiar de erro*/
lp = [0.01, 1e-4];

/*Quantidade de épocas*/
epochs = 200

/*Realizaremos a execução de treinamento e teste 10 vezes, variado as amostras de treino e teste.*/
num_execucoes = 10;
acuracias = zeros(1, num_execucoes);

for execucao = 1:num_execucoes
    printf("\n Executando a %d° interação...", execucao);
    
    /*Embaralhando os índices das colunas das amostras*/
    numero_colunas = size(atributos, 2)
    indices_embaralhados = grand(1, "prm", 1:numero_colunas);
    
    /*Calculando o tamanho do conjunto de treinamento (70%)*/
    tamanho_treinamento = round(0.7 * numero_colunas);
    
    /*Conjunto de treinamento*/
    indices_selecionados_treino = indices_embaralhados(1:tamanho_treinamento);
    
    conj_atr_treinamento = atributos(:, indices_selecionados_treino); /*Conjunto de atributos para treino*/
    conj_rot_treinamento = descritor(:, indices_selecionados_treino); /*Conjunto de rotulos para treino*/
    
    /*Conjunto de teste*/
    indices_selecionados_teste = indices_embaralhados(tamanho_treinamento+1:length(indices_embaralhados));
    
    conj_atr_teste = atributos(:, indices_selecionados_teste); /*Conjunto de atributos para teste*/
    conj_rot_teste = descritor(:, indices_selecionados_teste); /*Conjunto de rotulos para teste*/

    /* Treinando o modelo com conjunto de treinamento*/
    W = ann_FF_Std_batch(conj_atr_treinamento, conj_rot_treinamento,N, W, lp, epochs);

    /*Testando o modelo com conjunto de teste*/
    C = ann_FF_run(conj_atr_teste,N,W)
    
    /*Fazendo a validação do modelo com os dados de teste*/
    cont = 0;
    
    for i = 1:size(conj_rot_teste)(2)
        [a b] = max(conj_rot_teste(:, i)); /*a = maior valor, b = índice*/
        [c d] = max(C(:, i));
        if b == d
            cont = cont + 1;
        end
    end
    cont = 100 * (cont/size(conj_rot_teste)(2));
    
    printf("\n resultado obtido foi de %3.2f%%", cont);
    printf("\n");
    
    acuracias(execucao) = cont;
end

/*Calculando a acurácia média*/
acuracia_media = sum(acuracias)/length(acuracias)
printf('\n\n A acurácia média dessa rede MLP é %3.2f%%.', acuracia_media);
