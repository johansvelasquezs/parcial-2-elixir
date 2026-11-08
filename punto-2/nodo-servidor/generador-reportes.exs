defmodule GeneradorReportes do
  def calcular_metricas([], _id_ciudad) do
    {0, 0.0, 0.0, 0}
  end

  def calcular_metricas(movimientos, id_ciudad) do
    filtrar_y_acumular(movimientos, id_ciudad, 0, 0.0, 0.0, 0)
  end

  defp filtrar_y_acumular([], _id_ciudad, count, max_mag, _suma_prof, 0) do
    {count, max_mag, 0.0, 0}
  end
  defp filtrar_y_acumular([], _id_ciudad, count, max_mag, suma_prof, total_prof) do
    {count, max_mag, suma_prof / total_prof, total_prof}
  end

  defp filtrar_y_acumular([mov | resto], id_ciudad, count, max_mag, suma_prof, total_prof) do
    if mov.id_ciudad == id_ciudad do
      nuevo_count = count + 1
      nueva_max_mag = if mov.magnitud > max_mag, do: mov.magnitud, else: max_mag
      nueva_suma_prof = suma_prof + mov.profundidad
      filtrar_y_acumular(resto, id_ciudad, nuevo_count, nueva_max_mag, nueva_suma_prof, total_prof + 1)
    else
      filtrar_y_acumular(resto, id_ciudad, count, max_mag, suma_prof, total_prof)
    end
  end

  # Generar reporte para una ciudad en específico
  def generar_reporte_ciudad(ciudades, movimientos, id_buscado) do
    case Enum.find(ciudades, fn c -> c.id == id_buscado end) do
      nil ->
        "Error: La ciudad con ID '#{id_buscado}' no existe en el sistema."
      ciudad ->
        {count, max_mag, avg_prof, _} = calcular_metricas(movimientos, ciudad.id)

        bloque =
          if count == 0 do
            [
              "Ciudad: #{ciudad.nombre} (ID: #{ciudad.id})",
              "  Población: #{ciudad.poblacion}",
              "  Sin movimientos registrados",
              "  Total Sismos: 0",
              "  Magnitud Máxima: No aplica",
              "  Profundidad Promedio: No aplica"
            ]
          else
            [
              "Ciudad: #{ciudad.nombre} (ID: #{ciudad.id})",
              "  Población: #{ciudad.poblacion}",
              "  Total Sismos: #{count}",
              "  Magnitud Máxima: #{max_mag}",
              "  Profundidad Promedio: #{:erlang.float_to_binary(avg_prof, decimals: 2)} km"
            ]
          end

        Enum.join(bloque, "\n")
    end
  end

  # Generar reporte general completo
  def generar_reporte_general(ciudades, movimientos, descartados_ciudades, descartados_movimientos) do
    lineas_reporte = [
      "========================================",
      "      REPORTE DEL OBSERVATORIO SÍSMICO  ",
      "========================================",
      ""
    ]

    lineas_reporte = lineas_reporte ++ procesar_ciudades(ciudades, movimientos)

    lineas_reporte = lineas_reporte ++ [
      "",
      "----------------------------------------",
      "REGISTROS DESCARTADOS:",
      "  - Ciudades mal formadas: #{descartados_ciudades}",
      "  - Movimientos mal formados: #{descartados_movimientos}",
      "========================================"
    ]

    Enum.join(lineas_reporte, "\n")
  end

  defp procesar_ciudades([], _movimientos), do: []
  defp procesar_ciudades([ciudad | resto], movimientos) do
    {count, max_mag, avg_prof, _} = calcular_metricas(movimientos, ciudad.id)

    bloque =
      if count == 0 do
        [
          "Ciudad: #{ciudad.nombre} (ID: #{ciudad.id})",
          "  Población: #{ciudad.poblacion}",
          "  Sin movimientos registrados",
          "  Total Sismos: 0",
          "  Magnitud Máxima: No aplica",
          "  Profundidad Promedio: No aplica",
          "----------------------------------------"
        ]
      else
        [
          "Ciudad: #{ciudad.nombre} (ID: #{ciudad.id})",
          "  Población: #{ciudad.poblacion}",
          "  Total Sismos: #{count}",
          "  Magnitud Máxima: #{max_mag}",
          "  Profundidad Promedio: #{:erlang.float_to_binary(avg_prof, decimals: 2)} km",
          "----------------------------------------"
        ]
      end

    bloque ++ procesar_ciudades(resto, movimientos)
  end
end
