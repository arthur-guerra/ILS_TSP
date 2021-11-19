module Heuristica

using Solution, Profile
export ILS, iteracoes_ILS

struct InsertionInfo
	noInserido::Int64
	posicaoInsercao::Int64
	custo::Float64
end

function Construcao(distancia::Array{Float64,2})::Solucao      #o retorno é solução.  Qual tipo?

	caminho::Vector{Int64} = Vector{Int64}(undef, 0)
	linha_dist::Int64 = size(distancia, 1)

	nao_selecionado::Vector{Int64} = collect(1:linha_dist)		 ## ---dúvida

	for i=1:3
		a::Int64 = rand(1:length(nao_selecionado))
		caminho = push!(caminho, nao_selecionado[a])
		splice!(nao_selecionado, a)
	end

	while !isempty(nao_selecionado)  
		vetor_aleat::Vector{InsertionInfo} = Vector{InsertionInfo}(undef, 0)	# ---dúvida

		for node_k in nao_selecionado                   # Forma alternativa de estruturar o for, o conjunto k vai reduzindo
			for i=1:length(caminho)                     # O conjunto caminho vai aumentando
				
				node_i::Int64 = caminho[i]                 #node/valor_k => valor da posição
				j::Int64 = i % length(caminho) + 1         #_Guarda a posição. O % pega o resto do valor, e.g. 1/3 => resto = 1, o último vai ser 0+1
				node_j::Int64 = caminho[j]                 
				#node_k = nao_selecionado[k]        #_Não existe nessa estrutura

				dist_ik::Float64 = distancia[node_i, node_k]
				dist_kj::Float64 = distancia[node_k, node_j]
				dist_ij::Float64 = distancia[node_i, node_j]   

				somatorio_ijk::Float64 = dist_ik + dist_kj - dist_ij

				soma_Troca::InsertionInfo = InsertionInfo(node_k, j, somatorio_ijk)
				push!(vetor_aleat, soma_Troca)
			end
		end
	
		sort!(vetor_aleat, by = elem -> elem.custo)   # Ordena do menor para o maior, pela posição do variável custo
		
		length_metade_aleat::Int64= ceil(Int, (length(vetor_aleat))/2)   ## ---dúvida

		b::Int64= rand(1:length_metade_aleat)       # Metade do vetor ordenado, se for valor quebrado, arredonda pra cima

		escolha_aleatoria::InsertionInfo = vetor_aleat[b]            # Um dos valores dos 50% melhor
	
		insert!(caminho, escolha_aleatoria.posicaoInsercao, escolha_aleatoria.noInserido)
		setdiff!(nao_selecionado, caminho)		
	end

	push!(caminho, caminho[1])
	solucao::Solucao = Solucao(caminho, distancia)   # seria o caso com dois parametros que retornam 3 no caso, se eu printar "solucao" 
											# Nesse objeto, será chamado a função custocaminho
    #println("Solucao dentro da Construção: ", solucao)
	return solucao
end

function swap(solucao::Solucao)::Bool  # Função de troca de posição

	caminho::Vector{Int64} = solucao.caminho        
	distancia::Array{Float64, 2}= solucao.dist        		
	custo_Corrente::Float64 = solucao.custo   
	
	tamanho::Int64 = length(caminho)

	melhor_custo::Float64= custo_Corrente
	no_final_A::Int64= 0
	no_final_B::Int64 = 0
	
	for no_A = 2:tamanho-2             
		for no_B = no_A+1:tamanho-1

			no_A_anterior::Int64 = no_A - 1
			no_A_seguinte::Int64 = no_A + 1
			no_B_anterior::Int64 = no_B - 1
			no_B_seguinte::Int64 = no_B + 1

			custo_Removido_A::Float64 = 0
			custo_Removido_B::Float64 = 0
			custo_Adicionado_B::Float64 = 0
			custo_Adicionado_A::Float64 = 0

			if (no_B == no_A + 1)
				custo_Removido_A = distancia[caminho[no_A_anterior], caminho[no_A]]
				custo_Removido_B = distancia[caminho[no_B], caminho[no_B_seguinte]]
				custo_Adicionado_B = distancia[caminho[no_A_anterior], caminho[no_B]]
				custo_Adicionado_A = distancia[caminho[no_A], caminho[no_B_seguinte]]

			else
				custo_Removido_A = distancia[caminho[no_A_anterior], caminho[no_A]] + distancia[caminho[no_A], caminho[no_A_seguinte]]
				custo_Removido_B = distancia[caminho[no_B_anterior], caminho[no_B]] + distancia[caminho[no_B], caminho[no_B_seguinte]]
				custo_Adicionado_B = distancia[caminho[no_A_anterior], caminho[no_B]] + distancia[caminho[no_B], caminho[no_A_seguinte]]
				custo_Adicionado_A = distancia[caminho[no_B_anterior], caminho[no_A]] + distancia[caminho[no_A], caminho[no_B_seguinte]]
			
			end

			custo_Removido::Float64 = custo_Removido_A + custo_Removido_B  # Custo original sem a mudança
			custo_Adicionado::Float64 = custo_Adicionado_B + custo_Adicionado_A # Custo com a inversão de B para A e A para B!
			custo::Float64 = custo_Corrente + custo_Adicionado - custo_Removido

			if(custo < melhor_custo)
				melhor_custo = custo
				no_final_A = no_A
				no_final_B = no_B
			end
		end
	end
	
	if(melhor_custo < custo_Corrente)

		@time swapVertices(solucao, no_final_A, no_final_B)
		return true
	end

	return false    
end

function busca_2opt(solucao::Solucao)::Bool

	caminho::Vector{Int64} = solucao.caminho		
	distancia::Array{Float64, 2} = solucao.dist		
	custo_Corrente::Float64 = solucao.custo	
	melhor_custo::Float64 = custo_Corrente 	

	p1::Int64 = 0 
	p2::Int64 = 0 

	# 

	for node_inicial =2:length(caminho)-1 
		for node_final = node_inicial+1:length(caminho)-1 

			custo_Adicionado::Float64 = 0 
			custo_Removido::Float64 = 0 
		
			for n = node_inicial:node_final+1 
				custo_Removido += distancia[caminho[n-1],caminho[n]] 
			end 

			for n = node_inicial+1:node_final							   # Nesse caso tem a "inversão" 
				custo_Adicionado += distancia[caminho[n],caminho[n-1]] 

			end 

			custo_Adicionado += distancia[caminho[node_inicial],caminho[node_final+1]] # Calculo do extremo inicial 
			custo_Adicionado += distancia[caminho[node_inicial-1],caminho[node_final]] # Calculo do extremo final 

			custo::Float64 = custo_Corrente + custo_Adicionado - custo_Removido 

			if(custo < melhor_custo) 
				p1 = node_inicial 
				p2 = node_final 
				melhor_custo = custo 
			end 
		end 
	end 

	if (melhor_custo < custo_Corrente) 
		reverseSegment(solucao, p1, p2)
		return true
	end 

	return false 
end 

function orOpt(solucao::Solucao, K::Int64)::Bool    # K é o tamanho da seção (1, 2 ou 3) 

	caminho::Vector{Int64} = solucao.caminho			#---dúvida
	distancia::Array{Float64, 2} = solucao.dist			#---dúvida
	custo_Corrente::Float64 = solucao.custo		#---dúvida
	melhor_custo::Float64 = custo_Corrente		#---dúvida
	melhor_Inicio::Int64 = 0					#---dúvida	
	melhor_Destino::Int64 = 0 					#---dúvida

	for origem =2:length(caminho)-K
		for destino = 2:length(caminho)-K

			if (origem == destino)
				continue
			end

			custo_Adicionado::Float64 = 0
			custo_Removido::Float64 = 0
			# Declarar as variáveis fora do laço -1,2,3	
			custo_Adicionado_1::Float64
			custo_Adicionado_2::Float64
			custo_Adicionado_3::Float64


			if origem < destino
				custo_Removido =    distancia[caminho[origem-1], caminho[origem]] + 
				distancia[caminho[origem+K-1], caminho[origem+K]] +  distancia[caminho[destino+K-1], caminho[destino+K]]

				custo_Adicionado_1 =  distancia[caminho[origem-1], caminho[origem+K]]       # validado
				custo_Adicionado_2 =  distancia[caminho[destino+K-1], caminho[origem]]          # validado  
				custo_Adicionado_3 = distancia[caminho[origem+K-1], caminho[destino+K]]     # validado

				custo_Adicionado = custo_Adicionado_1 + custo_Adicionado_2 + custo_Adicionado_3

			else
				custo_Removido =   distancia[caminho[destino-1], caminho[destino]] + 
				distancia[caminho[origem-1], caminho[origem]] +  distancia[caminho[origem+K-1], caminho[origem+K]]
				
				custo_Adicionado_1 =  distancia[caminho[destino-1], caminho[origem]]        # validado
				custo_Adicionado_2 =  distancia[caminho[origem+K-1], caminho[destino]]      # validado
				custo_Adicionado_3 =  distancia[caminho[origem-1], caminho[origem+K]]       # validado. Estava errado anteriormente. O erro era no segundo indice e o correto é caminho[noInicio+k] e não +1

				custo_Adicionado = custo_Adicionado_1 + custo_Adicionado_2 + custo_Adicionado_3
			end

			custo::Float64 = custo_Corrente + custo_Adicionado - custo_Removido


			if(custo < melhor_custo)
				melhor_custo = custo
				melhor_Inicio = origem
				melhor_Destino = destino
			end
		end
	end
		

	if (melhor_custo < custo_Corrente)
		moveSegment(solucao, melhor_Inicio, melhor_Destino, K)
		return true
	end

	return false
	
end    

function perturbacao(solucao::Solucao)::Solucao                  # Perturbar levemente a solução da busca Local

	nova_solucao::Solucao = copySolution(solucao)
	caminho::Vector{Int64} = nova_solucao.caminho				# Nesse caso, aponta para o mesmo objeto
	tamanho_caminho::Int64 = length(caminho)

	if tamanho_caminho < 6              # Abaixo de 6, o código não é valido
		return nova_solucao
	end

	K1::Int64 = 0
	K2::Int64 = 0

	if tamanho_caminho < 20
		K1 = 2
		K2 = 2
	else
		K1 = rand(2:round(Int, tamanho_caminho/10))
		K2 = rand(2:round(Int, tamanho_caminho/10))
	end

	p1::Int64 = rand(2:tamanho_caminho-(K1+K2))
	p2::Int64 = p1 + K1 - 1
	p3::Int64 = rand(p2+1:tamanho_caminho-(K2))
	p4::Int64 = p3 + K2 - 1

	swapSegments(nova_solucao, p1, p2, p3, p4)

	return nova_solucao

end

function Buscalocal(solucao::Solucao)::Bool    #---dúvida (Verificar se o retorno de fato é assim)    # Consolidação dos movimentos e do algoritmo em si!

	vetor::Vector{Int64} = [1,2,3,4,5]

	improvement::Bool = false

	while !isempty(vetor)

		a::Int64 = rand(1:length(vetor))

		if vetor[a] == 1
			improvement = swap(solucao)

		elseif vetor[a] == 2
			improvement = busca_2opt(solucao)

		elseif vetor[a] == 3
			improvement = orOpt(solucao, 1)

		elseif vetor[a] == 4
			improvement = orOpt(solucao, 2)

		else
			improvement = orOpt(solucao, 3)
		end

		if improvement
			vetor = [1,2,3,4,5]
		else
			splice!(vetor, a)
		end

	end

	return improvement
end

function ILS(distancias::Array{Float64,2}, maxIter::Int64, maxIter_localsearch::Int64)::Solucao

	bestOfAll::Solucao = Solucao(distancias)		# Isso seria dispensável ? Se eu colocasse aqui diretamente o objeto com o valor Inf pela possibilidade de tratar como float
	
    #println("CUSTO inicial: ", bestOfAll.custo)

    #println("maxIter: ", maxIter)

	for i = 1:maxIter 
		
		solucao::Solucao = Construcao(distancias)	##---dúvida        # gera um caminho inicial que será utilizado na busca local
		best::Solucao = copySolution(solucao)			# copia o vetor da solução, e o "deepcopy" para mudar o objeto que tá sendo apontado
        
        #println("Solucao teste: ", solucao)
        #println("best: ", best)

		iterIls::Int64 = 1						# 1 : número máximo de interações
		
		while iterIls <= maxIter_localsearch
			
			Buscalocal(solucao)
			
			if solucao.custo < best.custo		# nesse passo, depois da busca local, ele vai pegar o melhor resultado e atribuir como best 
				best = solucao
				iterIls = 1						# se for encontrado uma melhor solução do que atual, reinicia o LOOP	
			end
			
            #println("CUSTO TESTE: ", best.custo)

			solucao = perturbacao(best)			# aplica a perturbacao no best e roda mais um laço do while
			#println("caminho: ", solucao.caminho)
            #println("custo: ", solucao.custo)

            iterIls += 1						# isso indica que no momento que iterIls = maxIterIls, o laço vai ser quebrado
		end
		
		if best.custo < bestOfAll.custo
			bestOfAll = best
            #println("CUSTO BESTOFFALL: ", bestOfAll.custo)

		end
        println("CUSTO BEST.CUSTO: ", best.custo)
	end
    #println("Caminho final é: ", bestOfAll)
	return bestOfAll
	
end


function iteracoes_ILS(distancias::Array{Float64,2})::Int64
    
    linhas::Int64 = size(distancias, 1)  ## ---dúvida

    if linhas >= 150
		return ceil(Int, linhas/2)									
    end
    
	return linhas
end

end

###############################################################################

# maxIterIls = iteracoes_ILS(distancias)

# println("MAX ITER ILS: ", maxIterIls)

# ILS(distancias, 50, maxIterIls)


