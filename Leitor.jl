module Leitor

export readFile

mutable struct Point
	n::Int64
	c1::Float64
	c2::Float64
end

mutable struct InstanceData
	name::String
	type::String
	dimension::Int64
	edgeWeightType::String
	edgeWeightFormat::String
	
	InstanceData() = new("", "", 0, "", "")				# Para instanciar um objeto do tipo InstanceInfo
end

function readFile(filePath)
	
	instanceData = InstanceData()
	matrix = []

	#Abre o arquivo e começa a trabalhar com ele                
	open(filePath) do file         # att48 # burma14
		readHeader(file, instanceData)
		
		if instanceData.edgeWeightType == "EXPLICIT"

			matrix = readEdgeWeight(file, instanceData)
			
			#println("InstanceData: ", instanceData)

			#println(".")
		else
			matrix = readNodeCoord(file, instanceData)
			#println("p")
		end
	end

	return matrix

end


function readHeader(file, instanceData)

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		
		if (occursin("TYPE", line) && !occursin("_", line))
			instanceData.type = line[findlast(isequal(' '), line) + 1:end]
		elseif (occursin("DIMENSION", line)) #Se a linha conter "DIMENSION", pega a dimensão
			dim = line[findlast(isequal(' '), line) + 1:end]
			instanceData.dimension = parse(Int64, dim)
		elseif (occursin("EDGE_WEIGHT_TYPE", line)) #Se a linha conter "EDGE_WEIGHT_TYPE", pega a dimensão
			instanceData.edgeWeightType = line[findlast(isequal(' '), line) + 1:end]
			break
		end

	end

end


function readNodeCoord(file, instanceData)

	data = []

	while !eof(file)
		line = readline(file) #Lê a linha
		
		if (occursin("NODE_COORD_SECTION", line))
			break
		end
	end

	while !eof(file)

		line = readline(file) #Lê a linha
		
		#Quebra a linha onde tiver espaço
		numbers = split(line, " ")
		filter!(value -> value != "", numbers)

		point = Point(
			parse(Int64, numbers[1]),
			parse(Float64, numbers[2]),
			parse(Float64, numbers[3])
		)

		#println("Point: ", point)

		push!(data, point) #Joga os dados para um vetor

		if (point.n == instanceData.dimension) #Sai do loop quando tiver lido todos os pontos
			break
		end

	end

	return distancia(instanceData.dimension, data, instanceData.edgeWeightType)
end


function readEdgeWeight(file, instanceData)

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		#println(line)
		
		if (occursin("EDGE_WEIGHT_FORMAT", line))
			line = filter(!isspace, line)
			instanceData.edgeWeightFormat = line[findlast(isequal(':'), line) + 1:end]		
		elseif (occursin("DISPLAY_DATA_TYPE", line)) #Se a linha conter "DIMENSION", pega a dimensão
			instanceData = instanceData
		elseif (occursin("EDGE_WEIGHT_SECTION", line)) #Se a linha conter "EDGE_WEIGHT_TYPE", pega a dimensão
			break
		end

	end

	if instanceData.edgeWeightFormat == "UPPER_ROW"
		return distanceExplicitUpperRow(file, instanceData)
	elseif instanceData.edgeWeightFormat == "LOWER_DIAG_ROW"
		return distanceExplicitLowerDiagRow(file, instanceData)
	elseif instanceData.edgeWeightFormat == "UPPER_DIAG_ROW"
		return distanceExplicitUpperDiagRow(file, instanceData)
	elseif instanceData.edgeWeightFormat == "FULL_MATRIX"
		return distanceExplicitFullMatrix(file, instanceData)
	end

end

# function split(string)
# 	i = 1
# 	array = []

# 	while i <= lenght(string)

# 		elemento = ""

# 		# i = 9
# 		while i <= lenght(string) && string[i] != " "
# 			elemento = string(elemento, string[i])  # elemento = "FGH"
# 			i += i
# 		end

# 		push!(array, elemento) # array = ["ABC", "", "", "", "", "FGH"]
# 		i += i
# 	end

# 	return array
# end

function distanceExplicitFullMatrix(file, instanceData)

	matrix = zeros(Float64, instanceData.dimension, instanceData.dimension)
	lineCounter = 0

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		lineCounter += 1
		
		distArray = split(line, " ")
		filter!(value -> value != "", distArray)

		for i = 1 : instanceData.dimension
			value = parse(Float64, distArray[i])
			matrix[lineCounter, i] = value
		end

		if lineCounter == instanceData.dimension
			return matrix
		end
	end
end


# Caso de exemplo
# 213 145  36
#  94 217
# 162

# 0	213	145	36
# 213	0	94	217
# 145	94	0	162
# 36	217	162	0

# > 213 145  36
# matrix[1, 2] = distArray[1] = 213
# matrix[2, 1] = distArray[1] = 213
# matrix[1, 3] = distArray[2] = 145
# matrix[3, 1] = distArray[2] = 145
# matrix[1, 4] = distArray[3] = 36
# matrix[4, 1] = distArray[3] = 36

# > 94 217
# matrix[2, 3] = distArray[1] = 94
# matrix[3, 2] = distArray[1] = 94
# matrix[2, 4] = distArray[2] = 217
# matrix[4, 2] = distArray[2] = 217

# > 162
# matrix[3, 4] = distArray[1] = 162
# matrix[4, 3] = distArray[1] = 162


function distanceExplicitUpperRow(file, instanceData)

	matrix = zeros(Float64, instanceData.dimension, instanceData.dimension)
	lineCounter = 0

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		lineCounter += 1
		
		distArray = split(line, " ")
		filter!(value -> value != "", distArray)

		for i = lineCounter+1 : instanceData.dimension
			value = parse(Float64, distArray[i-lineCounter])
			matrix[lineCounter, i] = value
			matrix[i, lineCounter] = value
		end

		if lineCounter == instanceData.dimension
			return matrix
		end
	end
end


function distanceExplicitLowerDiagRow(file, instanceData)

	matrix = zeros(Float64, instanceData.dimension, instanceData.dimension)
	lineCounter = 0
	rowArray = [""]

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		
		line = string(rowArray[end], " ", line)
		rowArray = split(line, " 0") 
		
		#println("Row Array: ", rowArray)
		#readline()

		for j = 1:length(rowArray) - 1	
			
			distArray = split(rowArray[j], " ")
			filter!(value -> value != "", distArray)

			lineCounter += 1

			for i = 1 : length(distArray)
				value = parse(Float64, distArray[i])
				matrix[lineCounter, i] = value
				matrix[i, lineCounter] = value
			end

			if lineCounter == instanceData.dimension
				return matrix
			end

		end

	end
end

function distanceExplicitUpperDiagRow(file, instanceData)
	matrix = zeros(Float64, instanceData.dimension, instanceData.dimension)
	lineCounter = 0
	rowArray = [""]
	ignoreLast = 1

	while !eof(file) #Trabalha com o arquivo até chegar no fim
		
		line = readline(file) #Lê a linha
		
		line = string(rowArray[end], " ", line)
		rowArray = split(line, " 0") 
		
		if lineCounter + length(rowArray) == instanceData.dimension
			ignoreLast = 0
		end
		
		#println("Row Array: ", rowArray)
		#readline()

		for j = 1:length(rowArray) - ignoreLast

			distArray = split(rowArray[j], " ")
			filter!(value -> value != "", distArray)
			
			if isempty(distArray)
				continue
			end
			lineCounter += 1

			for i = lineCounter+1 : length(distArray)

				value = parse(Float64, distArray[i-lineCounter])
				matrix[lineCounter, i] = value
				matrix[i, lineCounter] = value
			end

			if lineCounter == instanceData.dimension-1
				return matrix
			end

		end

	end
end


#Calcula as distâncias conforme o tipo da instância
function distancia(dim, data, type)

		#println("Dim: ", dim)
		#println("Data: ", data)
		#println("Type: ", type)
	d = zeros(Float64, dim, dim)

	if (type == "EUC_2D")
		for i in 1:dim
			for j in 1:dim
				distx = data[i].c1 - data[j].c1
				disty = data[i].c2 - data[j].c2
				
				auxiliar = sqrt((distx*distx) + (disty*disty))
				
				d[i, j] = Int.(floor(auxiliar + 0.5))
			end
		end
	elseif (type == "MAN_2D")
		for i in 1:dim
			for j in 1:dim
				distx = abs(data[i].c1 - data[j].c1)
				disty = abs(data[i].c2 - data[j].c2)
				
				d[i, j] = Int.(distx + disty)
			end
		end
	elseif (type == "MAX_2D" || type == "MAX_3D")
		for i in 1:dim
			for j in 1:dim
				distx = abs(data[i].c1 - data[j].c1)
				disty = abs(data[i].c2 - data[j].c2)
				
				d[i, j] = max(Int.(distx), Int.(disty))
			end
		end   
	elseif (type == "ATT")
		t = zeros(Int64, dim, dim)
		r = zeros(Float64, dim, dim)
		
		for i in 1:dim
			for j in 1:dim
				distx = data[i].c1 - data[j].c1
				disty = data[i].c2 - data[j].c2
				
				r[i, j] = sqrt((distx*distx + disty*disty) / 10.0)
				t[i, j] = Int.(floor(r[i, j] + 0.5))
				
				if (t[i, j] < r[i, j]) 
					d[i, j] = t[i, j] + 1
				else 
					d[i, j] = t[i, j]
				end
			end
		end

		
	
	elseif (type == "GEO")

		

		latitude = zeros(Float64, dim)
		longitude = zeros(Float64, dim)
		RRR = 6378.388

		for i in 1:dim
			deg = trunc(data[i].c1)
			minimo = data[i].c1 - deg
			latitude[i] = π * (deg + 5.0 * minimo / 3.0 ) / 180.0
			
			deg = trunc(data[i].c2)
			minimo = data[i].c2 - deg;
			longitude[i] = π * (deg + 5.0 * minimo / 3.0 ) / 180.0;

			for j in 1:dim
				
				if (i == j)
					d[i, j] = 0
					continue
				end

				deg = trunc(data[j].c1)
				minimo = data[j].c1 - deg
				latitude[j] = π * (deg + 5.0 * minimo / 3.0 ) / 180.0
				deg = trunc(data[j].c2)
				minimo = data[j].c2 - deg
				longitude[j] = π * (deg + 5.0 * minimo / 3.0 ) / 180.0

				q1 = cos( longitude[i] - longitude[j] )
				q2 = cos( latitude[i] - latitude[j] )
				q3 = cos( latitude[i] + latitude[j] )
				d[i, j] = trunc(RRR * acos( 0.5*((1.0+q1)*q2 - (1.0-q1)*q3) ) + 1.0)

			end
		end
	end

	return d
end
end

