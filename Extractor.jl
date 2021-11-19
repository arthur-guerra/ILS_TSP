module Extractor

export InstanceInfo, extractFile

mutable struct InstanceInfo
	fileName::String
	name::String
	realName::String
	type::String
	comment::String
	edgeWeightType::String
	dimension::String
	
	InstanceInfo() = new("", "", "", "", "", "", "")				# Para instanciar um objeto do tipo InstanceInfo
end

function Base.println(instance::InstanceInfo)
	println("Name: ", instance.name)
	println("Type: ", instance.type)
	println("Comment: ", instance.comment)
	println("Edge Weight Type: ", instance.edgeWeightType)
	println("Dimension: ", instance.dimension)
end

function extractFile(filePath)

	instanceInfo = InstanceInfo()
	instanceInfo.fileName = filePath
	instanceInfo.realName = filePath[findlast(isequal('/'), filePath) + 1:end]	
	#println(filePath)
	open(filePath) do file    
		     
		while !eof(file)
			line = readline(file) 	

	
			#até o fim do arquivoj
			if (occursin("NAME", line))
	
				instanceInfo.name = line[findlast(isequal(' '), line) + 1 : end]
				#println("NAME")
				
			elseif (occursin("TYPE", line) && !occursin("_", line))

				instanceInfo.type = line[findlast(isequal(' '), line) + 1:end]
				#println("TYPE")

			elseif (occursin("COMMENT", line)) 
				
				instanceInfo.comment = line[findlast(isequal(' '), line) + 1:end]
				#println("COMMENT")

			elseif (occursin("EDGE_WEIGHT_TYPE", line)) 
				
				instanceInfo.edgeWeightType = line[findlast(isequal(' '), line) + 1:end]
				#println("EDGE_WEIGHT_TYPE")

			elseif (occursin("DIMENSION", line)) 
				instanceInfo.dimension = line[findlast(isequal(' '), line) + 1:end]
				#println("DIMENSION")

			else
				break
			end

			#instanceInfo.name = line
		end
	end


	return instanceInfo
	
end


end