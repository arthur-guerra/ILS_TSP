module Writer

export Result, writeFile

struct Result
  nome::String
  rodada::Int64
  custo::Float64
  tempo::Float64
end

function writeFile(filePath, results, delimiter)   ## ----------- VERIFICAR

  #Abre o arquivo e começa a trabalhar com ele                
  open(filePath, "w") do file         # att48 # burma14

    write(file, "Nome")
    write(file, delimiter)
    write(file, "Rodada")
    write(file, delimiter)
    write(file, "Custo")
    write(file, delimiter)
    write(file, "Tempo")
    write(file, "\n")

    for result in results
      write(file, result.nome)
      write(file, delimiter)
      write(file, string(result.rodada))
      write(file, delimiter)
      write(file, string(result.custo))
      write(file, delimiter)
      write(file, string(result.tempo))
      write(file, "\n")
    end
  end
end

end