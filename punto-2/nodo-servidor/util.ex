defmodule Util do


  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
  end

  def mostrar_error(mensaje) do
    IO.puts(:stderr, mensaje)
  end

  def mostrar_mensaje_java(mensaje) do
    IO.puts(mensaje)
    System.cmd("java", ["-cp", ".", "Mensaje", mensaje])
  end

  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :entero) do
    ingresar(mensaje, &String.to_integer/1, :entero)
  end

  def ingresar(mensaje, :real) do
    ingresar(mensaje, &String.to_float/1, :real)
  end

  def ingresar(mensaje, :booleano)do
    valor = mensaje
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> String.to_atom()

    if valor == "si" do
      true
    else
      false
    end

  end

  def ingresar(mensaje, parser, tipo_dato) do
    try do
      mensaje
      |> ingresar(:texto)
      |> parser.()
    rescue
      ArgumentError ->
        "Error, se espera que ingrese un numero #{tipo_dato}\n"
        |> mostrar_error()

        mensaje
        |> ingresar(parser, tipo_dato)
    end
  end

  def formater(valor) do
    :erlang.float_to_binary(valor,decimals: 2)
  end


end
