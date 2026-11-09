defmodule Cliente do
  def conectar(nodo_servidor) do
    case Process.whereis(:servicio_respuesta) do
      nil -> :ok
      pid -> Process.unregister(:servicio_respuesta)
    end

    Process.register(self(), :servicio_respuesta)

    IO.puts("Intentando conectar al nodo servidor: #{nodo_servidor}...")

    case Node.connect(nodo_servidor) do
      true ->
        IO.puts("¡Conexión exitosa con el servidor!")
        enviar_solicitudes(nodo_servidor)

      _ ->
        IO.puts(:stderr, "Error: No se pudo conectar al nodo servidor #{nodo_servidor}.")
        System.halt(1)
    end
  end

  defp enviar_solicitudes(nodo_servidor) do
    destino = {:servicio_sismos, nodo_servidor}
    solicitudes = [
      {:ciudad, "C01"},          # 1. Ciudad con movimientos 
      {:ciudad, "C05"},          # 2. Ciudad sin movimientos
      {:ciudad, "C99"},          # 3. Ciudad con identificador inexistente
      :reporte_general,          # 4. Reporte general
      :fin                       # 5. Mensaje fin
    ]

    cliente_tupla = {:servicio_respuesta, node()}

    Enum.each(solicitudes, fn solicitud ->
      send(destino, {cliente_tupla, solicitud})
    end)

    IO.puts("\n--- Solicitudes enviadas. Esperando respuestas del servidor ---\n")

    recibir_respuestas()
  end

  defp recibir_respuestas do
    receive do
      {:respuesta_sismos, :fin} ->
        IO.puts("--- Fin de la sesión recibido del servidor ---")
        :ok

      {:respuesta_sismos, reporte} ->
        IO.puts(reporte)
        IO.puts("----------------------------------------")
        recibir_respuestas()
    after 10000 ->
      IO.puts(:stderr, "Tiempo de espera agotado (timeout) esperando respuesta del servidor.")
    end
  end
end
Cliente.conectar(:servidor@Samuel)
