module Solution

export Solucao, swapVertices, reverseSegment, moveSegment, swapSegments, copySolution

mutable struct Solucao              
	caminho::Vector{Int64} ## ajustar esse nome 
	custo::Float64			# Preciso alterar para float
	dist::Array{Float64,2}

	# Isso tá relacionado ao construtor
	# No caso, se eu adicionar um objeto e apenas apontar um argumento, isso significa que através desse argumento, será transformado nas três posições
	
	Solucao(dist::Array{Float64,2}) = new([], Inf, dist) # No caso, essas duas estruturas permitem que 
	Solucao(caminho::Vector{Int64}, dist::Array{Float64,2}) = new(caminho, custoCaminho(caminho, dist), dist)   # Foi utilizado na função Construcao  ## A tipagem é feita também nos parametros
end

# Público
# copy = cópia superficial, objetos compartilham referências
# deepcopy = cópia profunda, cópia todos os subobjetos, cria objetos 100% independentes

function copySolution(solucao::Solucao)::Solucao
	
	# s = Solucao()
	# s.custo = solucao.custo  # usar o copy aqui seria redundante, mas provavelmente funcionaria
	# s.dist = solucao.dist
	# s.caminho = copy(solucao.caminho)

	return Solucao(copy(solucao.caminho), solucao.dist)
end

# swap
function swapVertices(solucao::Solucao, inicio::Int64, destino::Int64)
	tmp::Int64 = solucao.caminho[inicio]
	solucao.caminho[inicio] = solucao.caminho[destino]
	solucao.caminho[destino] = tmp

	atualizaCusto(solucao)
end

# busca_2opt
function reverseSegment(solucao::Solucao, inicio::Int64, fim::Int64)
	reverse!(solucao.caminho, inicio, fim) 
	atualizaCusto(solucao)
end

# orOpt
function moveSegment(solucao::Solucao, inicio::Int64, destino::Int64, K::Int64)
	
	n::Int64 = 0
	
	tmp::Vector{Int64} = solucao.caminho[inicio:inicio+K-1]

	while(n < K)				# K é o tamanho da seção   
		splice!(solucao.caminho, inicio)
		n += 1
	end

	n = 0
	
	while(n < K)
		insert!(solucao.caminho, destino+n, tmp[n+1])
		n += 1
	end

	atualizaCusto(solucao)
end

# pertuba
function swapSegments(solucao::Solucao, p1::Int64, p2::Int64, p3::Int64, p4::Int64)

	seg_1::Vector{Int64} = solucao.caminho[p1:p2]
	seg_2::Vector{Int64} = solucao.caminho[p3:p4]

	for i = length(seg_1):-1:1  ## O loop invertido
		# insert!(collection, index, item)
		insert!(solucao.caminho, p3, seg_1[i])
	end
	
	deleteat!(solucao.caminho, p1:p2)
	deleteat!(solucao.caminho, p3:p4)

	#tamanho_seg_2 = length(seg_2)

	for i = length(seg_2):-1:1  ## O loop invertido
		insert!(solucao.caminho, p1, seg_2[i])
	end

	atualizaCusto(solucao)

end

# Privado

function atualizaCusto(solucao::Solucao)  	
	solucao.custo = custoCaminho(solucao.caminho, solucao.dist)
end

function custoCaminho(caminho::Vector{Int64}, distancia::Array{Float64,2})::Float64

	if length(caminho) == 0
		return typemax(Int64)
	end
	
	custo::Float64 = 0
	for i=1:length(caminho)-1
		custo += distancia[caminho[i], caminho[i+1]]
	end

	return custo
end

end