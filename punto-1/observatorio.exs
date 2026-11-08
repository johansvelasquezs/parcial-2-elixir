Code.require_file("lector-archivos.exs", __DIR__)
Code.require_file("generador-reportes.exs", __DIR__)

defmodule Observatorio do
  def main do
    ruta_ciudades = "punto-1/resources/ciudades.txt"
    ruta_movimientos = "punto-1/resources/movimientos.txt"

    task_ciudades = Task.async(fn -> LectorArchivos.leer_ciudades(ruta_ciudades) end)
    task_movimientos = Task.async(fn -> LectorArchivos.leer_movimientos(ruta_movimientos) end)

    {ciudades, desc_ciudades} = Task.await(task_ciudades)
    {movimientos, desc_movimientos} = Task.await(task_movimientos)

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

    GeneradorReportes.generar_reporte(ciudades, movimientos_validos, desc_ciudades, total_desc_movimientos)
  end
end

Observatorio.main()
