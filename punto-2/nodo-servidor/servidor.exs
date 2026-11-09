Code.require_file("lector-archivos.exs", __DIR__)
Code.require_file("generador-reportes.exs", __DIR__)

defmodule Servidor do
  def iniciar do
    Process.register(self(), :servicio_sismos)
    IO.puts("Servidor iniciado en nodo #{node()} con nombre :servicio_sismos")
    bucle_servidor()
  end

  defp bucle_servidor do
    receive do
      {destino_respuesta, solicitud} ->
        resultado = procesar_solicitud(solicitud)
        send(destino_respuesta, {:respuesta_sismos, resultado})

        if solicitud == :fin do
          IO.puts("Sesión finalizada para el cliente. Esperando nuevas conexiones...")
        end

        bucle_servidor()
    end
  end

  defp procesar_solicitud(:fin), do: :fin

  defp procesar_solicitud({:ciudad, id_ciudad}) do
    ruta_ciudades = "resources/ciudades.txt"
    ruta_movimientos = "resources/movimientos.txt"

    task_ciudades = Task.async(fn -> LectorArchivos.leer_ciudades(ruta_ciudades) end)
    task_movimientos = Task.async(fn -> LectorArchivos.leer_movimientos(ruta_movimientos) end)

    resultado_ciudades = Task.await(task_ciudades)
    resultado_movimientos = Task.await(task_movimientos)

    case {resultado_ciudades, resultado_movimientos} do
      {{:error, razon}, _} ->
        "Error leyendo archivo ciudades.txt: #{razon}"
      {_, {:error, razon}} ->
        "Error leyendo archivo movimientos.txt: #{razon}"
      {{ciudades, _desc_c}, {movimientos, _desc_m}} ->
        texto_reporte = GeneradorReportes.generar_reporte_ciudad(ciudades, movimientos, id_ciudad)
        File.write("resources/reporte_ciudad_#{id_ciudad}.txt", texto_reporte)
        texto_reporte
    end
  end

  defp procesar_solicitud(:reporte_general) do
    ruta_ciudades = "resources/ciudades.txt"
    ruta_movimientos = "resources/movimientos.txt"

    task_ciudades = Task.async(fn -> LectorArchivos.leer_ciudades(ruta_ciudades) end)
    task_movimientos = Task.async(fn -> LectorArchivos.leer_movimientos(ruta_movimientos) end)

    resultado_ciudades = Task.await(task_ciudades)
    resultado_movimientos = Task.await(task_movimientos)

    case {resultado_ciudades, resultado_movimientos} do
      {{:error, razon}, _} ->
        "Error leyendo archivo ciudades.txt: #{razon}"
      {_, {:error, razon}} ->
        "Error leyendo archivo movimientos.txt: #{razon}"
      {{ciudades, desc_ciudades}, {movimientos, desc_movimientos}} ->
        ids_ciudades = MapSet.new(ciudades, & &1.id)

        {movimientos_validos, desc_inexistentes} =
          Enum.reduce(movimientos, {[], 0}, fn mov, {validos, descartados} ->
            if MapSet.member?(ids_ciudades, mov.id_ciudad) do
              {[mov | validos], descartados}
            else
              {validos, descartados + 1}
            end
          end)

        total_desc_movimientos = desc_movimientos + desc_inexistentes

        texto_reporte = GeneradorReportes.generar_reporte_general(
          ciudades,
          movimientos_validos,
          desc_ciudades,
          total_desc_movimientos
        )

        File.write("resources/reporte_general.txt", texto_reporte)
        texto_reporte
    end
  end
end

Servidor.iniciar()
