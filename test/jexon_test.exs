defmodule JexonTest do
  use ExUnit.Case
  doctest Jexon

  defmodule Demo do
    defstruct ~w(foo baz bar)a
  end

  defmodule Demo2 do
    defstruct ~w(foo baz bam)a
  end

  test "map to json" do
    data = %{foo: 1, baz: 2, bar: 3}
    assert Jexon.to_json(data) === Jason.encode(data)
  end

  test "map from json" do
    data = ~S({"foo": 1, "baz": 2, "bar": 3})
    assert Jexon.from_json(data) === {:ok, %{foo: 1, baz: 2, bar: 3}}
  end

  test "list to json" do
    data = [1,2,3]
    assert Jexon.to_json(data) === {:ok, ~S([1,2,3])}
  end

  test "list from json" do
    data = ~S([1,2,3])
    assert Jexon.from_json(data) === {:ok, [1,2,3]}
  end

  test "keyword to json" do
    data = [foo: 1, baz: 2, bar: 3]
    assert Jexon.to_json(data) === {:ok,"[[\"__tuple__\",[\"__atom__\",\"foo\"],1],[\"__tuple__\",[\"__atom__\",\"baz\"],2],[\"__tuple__\",[\"__atom__\",\"bar\"],3]]"}
  end

  test "keyword from json" do
    data = ~S([["__tuple__",["__atom__", "foo"],1], ["__tuple__",["__atom__", "baz"],2], ["__tuple__",["__atom__", "bar"],3]])
    assert Jexon.from_json(data) === {:ok, [foo: 1, baz: 2, bar: 3]}
  end

  test "boolean to json" do
    data = true
    assert Jexon.to_json(data) === Jason.encode(data)
  end

  test "boolean from json" do
    data = "false"
    assert Jexon.from_json(data) === {:ok, false}
  end

  test "number to json" do
    assert Jexon.to_json(42) === Jason.encode(42)
    assert Jexon.to_json(42.24) === Jason.encode(42.24)
  end

  test "number from json" do
    assert Jexon.from_json("42") === {:ok, 42}
    assert Jexon.from_json("42.24") === {:ok, 42.24}
  end

  test "atom to json" do
    assert Jexon.to_json(:foo) === {:ok, ~S(["__atom__","foo"])}
  end

  test "atom from json" do
    assert Jexon.from_json(~S(["__atom__","foo"])) === {:ok, :foo}
  end

  test "tuple to json" do
    assert Jexon.to_json({1,2,3}) === {:ok, ~S(["__tuple__",1,2,3])}
  end

  test "tuple from json" do
    assert Jexon.from_json(~S(["__tuple__",1,2,3])) === {:ok, {1,2,3}}
  end

  test "nested tuple to json" do
    assert Jexon.to_json({1,2,3, {4,5,6, {7,8,9}}}) === {:ok, "[\"__tuple__\",1,2,3,[\"__tuple__\",4,5,6,[\"__tuple__\",7,8,9]]]"}
  end

  test "nested tuple from json" do
    assert Jexon.from_json("[\"__tuple__\",1,2,3,[\"__tuple__\",4,5,6,[\"__tuple__\",7,8,9]]]") === {:ok, {1,2,3, {4,5,6, {7,8,9}}}}
  end

  test "struct to map" do
    data = %Demo{foo: "a", baz: "b", bar: "c"}

    assert Jexon.to_map(data) === %{"foo" => "a", "baz" => "b", "bar" => "c", "__struct__" => Demo}
    assert Jexon.to_map(data, with_struct_info: false) === %{"foo" => "a", "baz" => "b", "bar" => "c"}
  end

  test "struct to json" do
    data = %Demo{foo: "a", baz: "b", bar: "c"}

    assert Jexon.to_json(data) ===  {:ok, "{\"__struct__\":[\"__atom__\",\"Elixir.JexonTest.Demo\"],\"bar\":\"c\",\"baz\":\"b\",\"foo\":\"a\"}"}
  end

  test "nested struct to/from json" do
    data = %Demo{
      foo: 1,
      baz: 2,
      bar: %Demo{
        foo: 3,
        baz: 4,
        bar: %Demo{
          foo: 5,
          baz: 6,
          bar: %Demo{
            foo: 7,
            baz: 8,
            bar: 9
          }
        }
      }
    }

    expected_json = "{\"__struct__\":[\"__atom__\",\"Elixir.JexonTest.Demo\"],\"bar\":{\"__struct__\":[\"__atom__\",\"Elixir.JexonTest.Demo\"],\"bar\":{\"__struct__\":[\"__atom__\",\"Elixir.JexonTest.Demo\"],\"bar\":{\"__struct__\":[\"__atom__\",\"Elixir.JexonTest.Demo\"],\"bar\":9,\"baz\":8,\"foo\":7},\"baz\":6,\"foo\":5},\"baz\":4,\"foo\":3},\"baz\":2,\"foo\":1}"

    assert Jexon.to_json(data) === {:ok, expected_json}
    assert Jexon.from_json(expected_json) === {:ok, data}
  end


  test "changed struct keys (upgrade/update scenario)" do
    old_json =
      %Demo{foo: 1, baz: 2, bar: 3}
      |> Jexon.to_json()
      |> elem(1)
      |> String.replace("Demo", "Demo2")

    {:ok, data} = Jexon.from_json(old_json)

    assert data === %Demo2{foo: 1, baz: 2, bam: nil}
  end

  test "complex nested struct" do
    data = [%Demo{
      foo: 42,
      baz: 42.0,
      bar: %Demo{
        foo: %{foo: "foo", baz: "baz", bar: "bar"},
        baz: true,
        bar: %Demo{
          foo: {1,2,3},
          baz: {1, :foo, false, {1,2,3}},
          bar: %Demo{
            foo: [foo: 1, baz: 2, bar: 3],
            baz: [{:foo, :baz}, true, "foo"],
            bar: "end"
          }
        }
      }
    }, {1,2,3}]

    {:ok, json} = Jexon.to_json(data)

    assert Jexon.from_json(json) === {:ok, data}
  end

end
