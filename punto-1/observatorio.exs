Code.require_file("lector-archivos.exs", __DIR__)
Code.require_file("generador-reportes.exs", __DIR__)

defmodule Observatorio do
  def main do
    ruta_ciudades = "resources/ciudades.txt"
    ruta_movimientos = "resources/movimientos.txt"

    task_ciudades = Task.async(fn -> LectorArchivos.leer_ciudades(ruta_ciudades) end)
    task_movimientos = Task.async(fn -> LectorArchivos.leer_movimientos(ruta_movimientos) end)

    case {Task.await(task_ciudades), Task.await(task_movimientos)} do
      {{:error, razon}, _} ->
        IO.puts("Error leyendo ciudades: #{razon}")
      {_, {:error, razon}} ->
        IO.puts("Error leyendo movimientos: #{razon}")
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

        texto_reporte = GeneradorReportes.generar_reporte(ciudades, movimientos_validos, desc_ciudades, total_desc_movimientos)

        case File.write("resources/reporte_general.txt", texto_reporte) do
          :ok ->
            IO.puts(texto_reporte)
            IO.puts("Reporte generado y guardado en punto-1/resources/reporte_general.txt")
          {:error, razon} ->
            IO.puts("Error al guardar el archivo: #{razon}")
        end
    end
  end
end

Observatorio.main()
