defmodule Ciudad do
  defstruct [:id, :nombre, :poblacion]
end

defmodule Movimiento do
  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_fin, :magnitud, :profundidad]
end

defmodule LectorArchivos do
  def leer_ciudades(ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.reduce({[], 0}, fn linea, {lista, descartados} ->
          case String.split(linea, "@") do
            [id, nombre, poblacion] ->
              case Integer.parse(String.trim(poblacion)) do
                {pob, ""} ->
                  ciudad = %Ciudad{
                    id: String.trim(id),
                    nombre: String.trim(nombre),
                    poblacion: pob
                  }
                  {[ciudad | lista], descartados}
                _ ->
                  {lista, descartados + 1}
              end
            _ ->
              {lista, descartados + 1}
          end
        end)
      {:error, razon} ->
        {:error, razon}
    end
  end

  def leer_movimientos(ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.reduce({[], 0}, fn linea, {lista, descartados} ->
          case String.split(linea, "@") do
            [codigo, id_ciudad, h_inicio, h_fin, magnitud, profundidad] ->
              with {mag, ""} <- Float.parse(String.trim(magnitud)),
                   {prof, ""} <- Float.parse(String.trim(profundidad)),
                   true <- prof >= 0 do
                mov = %Movimiento{
                  codigo: String.trim(codigo),
                  id_ciudad: String.trim(id_ciudad),
                  hora_inicio: String.trim(h_inicio),
                  hora_fin: String.trim(h_fin),
                  magnitud: mag,
                  profundidad: prof
                }
                {[mov | lista], descartados}
              else
                _ -> {lista, descartados + 1}
              end
            _ ->
              {lista, descartados + 1}
          end
        end)
      {:error, razon} ->
        {:error, razon}
    end
  end
end
