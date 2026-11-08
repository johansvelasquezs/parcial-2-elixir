Code.require_file("lector-archivos.exs", __DIR__)
Code.require_file("generador-reportes.exs", __DIR__)

defmodule Observatorio do
  def main do
    ruta_ciudades = "punto-1/resources/ciudades.txt"
    ruta_movimientos = "punto-1/resources/movimientos.txt"

    {ciudades, desc_ciudades} = LectorArchivos.leer_ciudades(ruta_ciudades)
    {movimientos, desc_movimientos} = LectorArchivos.leer_movimientos(ruta_movimientos)

    GeneradorReportes.generar_reporte(ciudades, movimientos, desc_ciudades, desc_movimientos)
  end
end

Observatorio.main()
